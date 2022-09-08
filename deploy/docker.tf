resource "docker_registry_image" "cataas-bot-image" {
  name = "${local.ecr_url}:v1"

  build {
    context = "context"
    #dockerfile = "../Dockerfile"
    no_cache = true
  }

  depends_on = [aws_ecr_repository.go_server]
}
