job "nginx" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${meta.node_type}"
    value     = "container"
  }

  group "nginx" {
    count = 1

    network {
      port "http" {
        static = 8080
        to     = 80
      }
    }

    task "nginx-server" {
      driver = "docker"

      config {
        image = "nginx:latest"
        ports = ["http"]

        volumes = [
          "local/nginx.conf:/etc/nginx/nginx.conf",
          "local/html:/usr/share/nginx/html"
        ]
      }

      # Download template files from GitHub
      artifact {
        source      = "https://raw.githubusercontent.com/mm3906078/nomad-ansible/main/examples/templates/nginx.conf.tpl"
        destination = "local/templates/nginx.conf.tpl"
        mode        = "file"
      }

      artifact {
        source      = "https://raw.githubusercontent.com/mm3906078/nomad-ansible/main/examples/templates/nginx-index.html.tpl"
        destination = "local/templates/nginx-index.html.tpl"
        mode        = "file"
      }

      # Custom nginx configuration from downloaded file
      template {
        source      = "local/templates/nginx.conf.tpl"
        destination = "local/nginx.conf"
      }

      # Custom index.html from downloaded file
      template {
        source      = "local/templates/nginx-index.html.tpl"
        destination = "local/html/index.html"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "nginx"
        port = "http"

        tags = [
          "web",
          "nginx",
          "http",
          "urlprefix-/"
        ]

        check {
          name     = "Nginx Health Check"
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }

      restart {
        attempts = 3
        interval = "5m"
        delay    = "15s"
        mode     = "fail"
      }
    }
  }
}
