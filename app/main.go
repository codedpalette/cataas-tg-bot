package main

import (
	_ "github.com/joho/godotenv/autoload"
)

func main() {
	api := CreateAPI()
	service := CreateService(api)
	bot := CreateBot(service)
	bot.Start()
}
