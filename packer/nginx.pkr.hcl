packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = ">= 1.0.0"
    }
  }
}

variable "image_name" {
  type    = string
  default = "custom-nginx"
}

variable "image_tag" {
  type    = string
  default = "1.0"
}

source "docker" "nginx_custom" {
  image  = "nginx:alpine"
  commit = true

  changes = [
    "EXPOSE 80"
  ]
}

build {
  name    = "nginx_with_index"
  sources = ["source.docker.nginx_custom"]

  provisioner "file" {
    source      = "index.html"
    destination = "/usr/share/nginx/html/index.html"
  }

  provisioner "shell" {
    inline = [
      "chmod 644 /usr/share/nginx/html/index.html"
    ]
  }

  post-processor "docker-tag" {
    repository = var.image_name
    tags       = [var.image_tag]
  }
}
