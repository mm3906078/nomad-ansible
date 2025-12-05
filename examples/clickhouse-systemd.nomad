job "clickhouse" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${meta.node_type}"
    value     = "systemd"
  }

  group "clickhouse" {
    count = 1

    network {
      port "http" {
        static = 8123
        to     = 8123
      }
      port "native" {
        static = 9000
        to     = 9000
      }
      port "interserver" {
        static = 9009
        to     = 9009
      }
    }

    task "clickhouse-server" {
      driver = "exec"

      # Download ClickHouse binary
      artifact {
        source      = "https://builds.clickhouse.com/master/amd64/clickhouse"
        destination = "local/bin/clickhouse"
        mode        = "file"
      }

      # Download template files from GitHub
      artifact {
        source      = "https://raw.githubusercontent.com/mm3906078/nomad-ansible/main/examples/templates/clickhouse-config.xml.tpl"
        destination = "local/templates/clickhouse-config.xml.tpl"
        mode        = "file"
      }

      artifact {
        source      = "https://raw.githubusercontent.com/mm3906078/nomad-ansible/main/examples/templates/setup-dirs.sh.tpl"
        destination = "local/templates/setup-dirs.sh.tpl"
        mode        = "file"
      }

      config {
        command = "local/bin/clickhouse"
        args = [
          "server",
          "--config-file=${NOMAD_TASK_DIR}/config.xml"
        ]
      }

      resources {
        cpu    = 1000
        memory = 1024
      }

      # ClickHouse configuration from downloaded file
      template {
        source      = "local/templates/clickhouse-config.xml.tpl"
        destination = "local/config.xml"
      }

      # Setup script from downloaded file
      template {
        source      = "local/templates/setup-dirs.sh.tpl"
        destination = "local/setup.sh"
        perms       = "755"
      }

      service {
        name = "clickhouse"
        port = "http"

        tags = [
          "database",
          "clickhouse",
          "analytics",
          "urlprefix-/clickhouse strip=/clickhouse"
        ]

        check {
          name     = "ClickHouse HTTP Health"
          type     = "http"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        name = "clickhouse-native"
        port = "native"

        tags = [
          "database",
          "clickhouse",
          "native"
        ]

        check {
          name     = "ClickHouse Native Port"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
