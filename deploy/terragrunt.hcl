remote_state {
  backend = "s3"
  config = {
    bucket  = "cataas-bot-terraform-state"
    profile = "cataas-bot"
    key     = "terraform.tfstate"
    encrypt = true
    region  = "us-east-1"
  }
}
