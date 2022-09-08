# cataas-tg-bot

Inline Telegram bot for [CATaaS](https://cataas.com/) REST API

## Local dev

1. Copy `.env.template` to `.env` file
2. Fill out the variables
3. Run `go run .`

## Deploy to cloud

### Prerequisites

1. Install [Terraform](https://www.terraform.io/)

    ```bash
    brew install terraform
    ```

2. Create an AWS account
3. Create an IAM user to be used by Terraform
4. Store user's credentials in `~/.aws` directory

    ```bash
    # ~/.aws/config
    [profile cataas-bot]
    region=us-east-1
    output=json

    # ~/.aws/credentials
    [cataas-bot]
    aws_access_key_id=<ACCESS_KEY>
    aws_secret_access_key=<SECRET_KEY>
    ```
