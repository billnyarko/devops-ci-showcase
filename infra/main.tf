terraform {
  required_version = ">= 1.6"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "image" {
  default = "devops-ci-showcase:local"
}

provider "docker" {}

resource "docker_image" "app" {
  name = var.image
  keep_locally = true
}

resource "docker_container" "app" {
  name  = "devops-ci-showcase"
  image = docker_image.app.image_id
  ports {
    internal = 8000
    external = 8000
  }
}
