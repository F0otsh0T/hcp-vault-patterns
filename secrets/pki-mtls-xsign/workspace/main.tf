terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "mtlsxserver" {
  name         = "mtlsxserver:latest"
  keep_locally = false
}

resource "docker_container" "mtlsxserver" {
  image = docker_image.mtlsxserver.latest
  name  = "mtlsxserver"
  ports {
    internal = 443
    external = 9006
  }
}

resource "docker_image" "mtlsxclient" {
  name         = "mtlsxclient:latest"
  keep_locally = false
}

resource "docker_container" "mtlsxclient" {
  image = docker_image.mtlsxclient.latest
  name  = "mtlsxclient"
  ports {
    internal = 443
    external = 9008
  }
}