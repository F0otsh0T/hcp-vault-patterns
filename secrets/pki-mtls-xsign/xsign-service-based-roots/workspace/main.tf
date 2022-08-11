terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

## AMF

resource "docker_image" "mtlsxamf" {
  name         = "mtlsxamf:latest"
  keep_locally = false
}

resource "docker_container" "mtlsxamf" {
  image = docker_image.mtlsxamf.latest
  name  = "mtlsxamf"
  ports {
    internal = 20080
    external = 20080
  }
  ports {
    internal = 20443
    external = 20443
  }
}

## NEF

resource "docker_image" "mtlsxnef" {
  name         = "mtlsxnef:latest"
  keep_locally = false
}

resource "docker_container" "mtlsxnef" {
  image = docker_image.mtlsxnef.latest
  name  = "mtlsxnef"
  ports {
    internal = 21080
    external = 21080
  }
  ports {
    internal = 21443
    external = 21443
  }
}

## PCF

resource "docker_image" "mtlsxpcf" {
  name         = "mtlsxpcf:latest"
  keep_locally = false
}

resource "docker_container" "mtlsxpcf" {
  image = docker_image.mtlsxpcf.latest
  name  = "mtlsxpcf"
  ports {
    internal = 22080
    external = 22080
  }
  ports {
    internal = 22443
    external = 22443
  }
  ports {
    internal = 22081
    external = 22081
  }
  ports {
    internal = 22444
    external = 22444
  }
  ports {
    internal = 22082
    external = 22082
  }
  ports {
    internal = 22445
    external = 22445
  }
}

## SMF

resource "docker_image" "mtlsxsmf" {
  name         = "mtlsxsmf:latest"
  keep_locally = false
}

resource "docker_container" "mtlsxsmf" {
  image = docker_image.mtlsxsmf.latest
  name  = "mtlsxsmf"
  ports {
    internal = 23080
    external = 23080
  }
  ports {
    internal = 23443
    external = 23443
  }
  ports {
    internal = 23081
    external = 23081
  }
  ports {
    internal = 23444
    external = 23444
  }
  ports {
    internal = 23082
    external = 23082
  }
  ports {
    internal = 23445
    external = 23445
  }
}


