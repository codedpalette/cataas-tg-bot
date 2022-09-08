# cataas-tg-bot

Inline Telegram bot for [CATaaS](https://cataas.com/) REST API

## Local dev

1. Copy `app/.env.template` file to `app/.env`
2. Fill out the variables
3. `cd app`
4. Run `go run .`

## Deploy to cloud

### Prerequisites

> See [here](https://dev.to/boodyvo/deploying-go-application-on-aws-with-terraform-849) for more details

1. Install [Terraform](https://www.terraform.io/) and [awscli](https://aws.amazon.com/cli/)

    ```bash
    brew install terraform awscli
    ```

2. Create an AWS account
3. Create an IAM user to be used by Terraform
4. Store this user's credentials in `~/.aws` directory

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

> **Note:** If you change profile name here you need to update it in the `deploy/main.tf` and in subsequent commands as well
