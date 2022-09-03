package main

import (
	"log"
	"os"
	"strings"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
)

const maxResultsSize = 50
const thumbWidth = 100
const thumbHeight = 100
const textSize = 50

type botConfig struct {
	token   string
	env     string
	service Service
}

type Bot interface {
	Start()
}

func (config *botConfig) Start() {
	bot, err := tgbotapi.NewBotAPI(config.token)
	if err != nil {
		log.Panic(err)
	}
	bot.Debug = strings.ToLower(config.env) != "prod"
	log.Printf("Authorized on account %s", bot.Self.UserName)

	updateConfig := tgbotapi.NewUpdate(0)
	updateConfig.Timeout = 60
	updates := bot.GetUpdatesChan(updateConfig)
	for update := range updates {
		if update.InlineQuery != nil {
			config.handleInlineQuery(update.InlineQuery, bot)
		}
	}
}

func (config *botConfig) handleInlineQuery(query *tgbotapi.InlineQuery, bot *tgbotapi.BotAPI) {
	resultsSize := maxResultsSize
	results := make([]interface{}, 0, resultsSize)
	var says *string
	if trim := strings.TrimSpace(query.Query); trim != "" {
		says = &trim
	}
	cataasRequest := CataasRequest{resultsSize, says, textSize, thumbWidth, thumbHeight}
	cataasResponse := config.service.GetCats(&cataasRequest)
	for _, response := range cataasResponse {
		pic := tgbotapi.NewInlineQueryResultPhotoWithThumb(response.id, response.photoUrl.String(), response.thumbUrl.String())
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

func CreateBot(service Service) Bot {
	return &botConfig{os.Getenv("BOT_TOKEN"), os.Getenv("ENV"), service}
}
