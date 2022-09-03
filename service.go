package main

import (
	"log"
	"net/url"
	"time"
)

type CataasRequest struct {
	resultsSize int
	says        *string
	textSize    int
	thumbWidth  int
	thumbHeight int
}

type CataasResponse struct {
	id       string
	photoUrl *url.URL
	thumbUrl *url.URL
}

type serviceConfig struct {
	api CataasAPI
}

type Service interface {
	GetCats(request *CataasRequest) (response []*CataasResponse)
}

func (service *serviceConfig) GetCats(request *CataasRequest) (responses []*CataasResponse) {
	responses = make([]*CataasResponse, 0, request.resultsSize)
	catUrls := service.getUniqueCats(request.resultsSize)
	for id, url := range catUrls {
		photoUrl := service.api.BuildUrl(url, request.says, &request.textSize, nil, nil)
		thumbUrl := service.api.BuildUrl(url, request.says, nil, &request.thumbWidth, &request.thumbHeight)
		response := &CataasResponse{id, photoUrl, thumbUrl}
		responses = append(responses, response)
	}
	return
}

func (service *serviceConfig) getUniqueCats(resultsSize int) (catUrls map[string]string) {
	start := time.Now()
	for catUrls = make(map[string]string); len(catUrls) < resultsSize; {
		cat, err := service.api.GetRandomCat()
		if err != nil {
			log.Println("Error when retrieving cat JSON from API", err)
			continue
		}
		id, url := cat.Id, cat.Url
		_, exists := catUrls[id]
		if exists {
			continue
		}
		catUrls[id] = url
	}
	elapsed := time.Since(start)
	log.Printf("getUniqueCats took %s", elapsed)
	return
}

func CreateService(api CataasAPI) Service {
	return &serviceConfig{api}
}
