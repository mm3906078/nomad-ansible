job "mongodb" {
  datacenters = ["dc1"]
  type = "service"

  group "mongodb" {
    count = 1

    network {
      port "mongodb" {
        static = 27017
        to     = 27017
      }
    }

    task "mongodb-server" {
      driver = "exec"

      # Download MongoDB binary
      artifact {
        source      = "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2204-7.0.15.tgz"
        destination = "local/"
      }

      # Download template file from GitHub
      artifact {
        source      = "https://raw.githubusercontent.com/mm3906078/nomad-ansible/main/examples/templates/mongodb-setup.sh.tpl"
        destination = "local/templates/mongodb-setup.sh.tpl"
        mode        = "file"
      }

      config {
        command = "local/mongodb-linux-x86_64-ubuntu2204-7.0.15/bin/mongod"
        args = [
          "--dbpath", "${NOMAD_ALLOC_DIR}/data",
          "--port", "${NOMAD_PORT_mongodb}",
          "--bind_ip", "0.0.0.0",
          "--logpath", "${NOMAD_ALLOC_DIR}/logs/mongod.log",
          "--logappend"
        ]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "mongodb"
        port = "mongodb"

        tags = [
          "database",
          "mongodb",
          "urlprefix-/mongodb strip=/mongodb"
        ]

        check {
          name     = "MongoDB Health Check"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # Setup script from downloaded file
      template {
        source      = "local/templates/mongodb-setup.sh.tpl"
        destination = "local/setup.sh"
        perms       = "755"
      }
    }
  }
}
