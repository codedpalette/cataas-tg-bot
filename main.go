package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
	_ "github.com/joho/godotenv/autoload"
)

const resultSize = 20
const pathCat = "cat"

var baseUri = &url.URL{
	Host:   "cataas.com",
	Scheme: "https",
}

type CatJson struct {
	Id        string   `json:"id"`
	CreatedAt string   `json:"created_at"`
	Tags      []string `json:"tags"`
	Url       string   `json:"url"`
}

func getCatJson() (cat *CatJson, err error) {
	uri := *baseUri
	uri.Path = pathCat
	q := uri.Query()
	q.Set("json", "true")
	uri.RawQuery = q.Encode()
	var resp *http.Response
	var data []byte
	resp, err = http.Get(uri.String())
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	data, err = io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	err = json.Unmarshal(data, &cat)
	if err != nil {
		return nil, err
	}
	return cat, nil
}

func handleInlineQuery(query *tgbotapi.InlineQuery, bot *tgbotapi.BotAPI) {
	catUrls := make(map[string]string)
	var results []interface{}

	for i := 0; i < resultSize; i++ {
		cat, err := getCatJson()
		if err != nil {
			i--
			continue
		}
		id, url := cat.Id, cat.Url
		_, exists := catUrls[id]
		if exists {
			i--
			continue
		}
		catUrls[id] = url
	}

	says := strings.TrimSpace(query.Query)
	for id, url := range catUrls {
		photoUri := *baseUri
		photoUri.Path = url
		q := photoUri.Query()
		if says != "" {
			photoUri.Path = path.Join(photoUri.Path, "says/"+says)
			q.Set("size", "50")
		}
		photoUri.RawQuery = q.Encode()
		photoUriPoint := &photoUri
		thumbUri := *photoUriPoint
		q = thumbUri.Query()
		q.Set("width", "100")
		q.Set("height", "100")
		q.Del("size")
		thumbUri.RawQuery = q.Encode()
		pic := tgbotapi.NewInlineQueryResultPhotoWithThumb(id, photoUri.String(), thumbUri.String())
		pic.Width = 100
		pic.Height = 100
		results = append(results, pic)
	}

	inlineConf := tgbotapi.InlineConfig{
		InlineQueryID: query.ID,
		IsPersonal:    true,
		CacheTime:     0,
		Results:       results,
	}

	if _, err := bot.Request(inlineConf); err != nil {
		log.Println(err)
	}
}

func main() {
	bot, err := tgbotapi.NewBotAPI(os.Getenv("BOT_TOKEN"))
	if err != nil {
		log.Panic(err)
	}
	bot.Debug = os.Getenv("ENV") == "dev"
	log.Printf("Authorized on account %s", bot.Self.UserName)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60
	updates := bot.GetUpdatesChan(u)
	for update := range updates {
		if update.InlineQuery != nil {
			handleInlineQuery(update.InlineQuery, bot)
		}

	}
}
