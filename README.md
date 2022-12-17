# cataas-tg-bot

Inline Telegram bot for [CATaaS](https://cataas.com/) REST API

## Local dev

> **Note:** In order for VSCode to work you need to setup [Go workspace](https://go.dev/blog/get-familiar-with-workspaces).
> Run the following commands in the root directory
>
> ```bash
> go work init
> go work use app
> ```

1. `cd app`
2. Create `.env` file with the following content

   ```bash
   BOT_TOKEN=<TELEGRAM_BOT_TOKEN>
   ```

3. Run `go run .`

## Deploy to AWS

### Prerequisites

> See [here](https://dev.to/boodyvo/deploying-go-application-on-aws-with-terraform-849) for more details

1. Install [Terraform](https://www.terraform.io/), [awscli](https://aws.amazon.com/cli/) and [terragrunt](https://terragrunt.gruntwork.io/)

    ```bash
    brew install terraform awscli terragrunt
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

### Deployment

Run the following commands

```bash
cd deploy
echo 'telegram_bot_token = "<BOT_TOKEN>"' > secret.tfvars
terragrunt init
terragrunt apply -var-file="secret.tfvars"
```
