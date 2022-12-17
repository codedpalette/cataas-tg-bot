package main

import (
	"context"
	"log"
	"net/url"
	"strings"
	"sync/atomic"
	"time"

	"golang.org/x/sync/errgroup"
)

const maxErrorCount = 3

type CataasRequest struct {
	resultsSize int
	says        *string
	textSize    int
	thumbWidth  int
	thumbHeight int
}

type PhotoType int32

const (
	Image PhotoType = iota
	Gif
)

type CataasResponse struct {
	id        string
	photoUrl  *url.URL
	thumbUrl  *url.URL
	photoType PhotoType
}

type serviceConfig struct {
	api CataasAPI
}

type Service interface {
	GetCats(request *CataasRequest) ([]*CataasResponse, error)
}

func (service *serviceConfig) GetCats(request *CataasRequest) ([]*CataasResponse, error) {
	responses := make([]*CataasResponse, 0, request.resultsSize)
	catJsons, err := service.getUniqueCats(request.resultsSize)
	if err != nil {
		return nil, err
	}
	for id, cat := range catJsons {
		url := cat.Url
		photoUrl := service.api.BuildUrl(url, request.says, &request.textSize, nil, nil)
		thumbUrl := service.api.BuildUrl(url, request.says, nil, &request.thumbWidth, &request.thumbHeight)
		var photoType PhotoType
		if strings.Contains(cat.MimeType, "gif") {
			photoType = Gif
		} else {
			photoType = Image
		}
		response := &CataasResponse{id, photoUrl, thumbUrl, photoType}
		responses = append(responses, response)
	}
	return responses, nil
}

func apiWorker(ctx context.Context, api CataasAPI, responses *chan *CatJson, done *chan struct{}, errorCount *int32) func() error {
	return func() error {
		for {
			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-*done:
				return nil
			default:
				cat, err := api.GetRandomCat()
				if err != nil {
					if count := atomic.AddInt32(errorCount, 1); count > maxErrorCount {
						return err
					}
					log.Println("Error when retrieving cat JSON from API: ", err)
					continue
				}
				*responses <- cat
				atomic.StoreInt32(errorCount, 0)
			}
		}
	}
}

func (service *serviceConfig) getUniqueCats(resultsSize int) (map[string]*CatJson, error) {
	start := time.Now()

	var errorCount int32 = 0
	catUrls := make(map[string]*CatJson)
	responses := make(chan *CatJson, resultsSize)
	done := make(chan struct{})
	g, ctx := errgroup.WithContext(context.Background())

	for i := 0; i < resultsSize; i++ {
		g.Go(apiWorker(ctx, service.api, &responses, &done, &errorCount))
	}

	go func() {
		for cat := range responses {
			_, exists := catUrls[cat.Id]
			if exists {
				continue
			}
			catUrls[cat.Id] = cat
			if len(catUrls) == resultsSize {
				close(done)
				return
			}
		}
	}()

	defer func() {
		elapsed := time.Since(start)
		log.Printf("getUniqueCats took %s", elapsed)
	}()

	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	case <-done:
		return catUrls, nil
	}
}

func CreateService(api CataasAPI) Service {
	return &serviceConfig{api}
}
