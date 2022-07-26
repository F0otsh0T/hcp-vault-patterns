terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "mtlsserver" {
  name         = "mtlsserver:latest"
  keep_locally = false
}

resource "docker_container" "mtlsserver" {
  image = docker_image.mtlsserver.latest
  name  = "mtlsserver"
  ports {
    internal = 443
    external = 9002
  }
}

resource "docker_image" "mtlsclient" {
  name         = "mtlsclient:latest"
  keep_locally = false
}

resource "docker_container" "mtlsclient" {
  image = docker_image.mtlsclient.latest
  name  = "mtlsclient"
  ports {
    internal = 443
    external = 9004
  }
}