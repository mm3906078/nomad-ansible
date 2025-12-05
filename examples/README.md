# Nomad Job Examples with External Templates

This directory contains example Nomad job specifications using **external template files** for better organization and maintainability.

## Directory Structure

```
examples/
├── mongodb-systemd.nomad
├── clickhouse-external-templates.nomad
├── nginx-external-templates.nomad
├── README.md
├── EXTERNAL-TEMPLATES.md
└── templates/
    ├── mongodb-setup.sh.tpl
    ├── clickhouse-config.xml.tpl
    ├── nginx.conf.tpl
    ├── nginx-index.html.tpl
    └── setup-dirs.sh.tpl
```

## Why External Templates?

✅ **Better organization** - Separate configuration from job definitions
✅ **Reusability** - Share templates across multiple jobs
✅ **Syntax highlighting** - Proper editor support for config files
✅ **Maintainability** - Update configs without modifying job specs
✅ **Version control** - Track configuration changes independently

> 📘 See [EXTERNAL-TEMPLATES.md](EXTERNAL-TEMPLATES.md) for detailed documentation on using external templates.

---

## Jobs Overview

### 1. MongoDB with Raw Exec Driver (`mongodb-systemd.nomad`)

Runs MongoDB using the `raw_exec` driver with external template for setup script.

**Features:**
- Uses raw_exec driver for direct process execution
- External template for directory setup (`templates/mongodb-setup.sh.tpl`)
- Static port binding (27017)
- Consul service registration with TCP health checks
- Configurable resource limits

**Prerequisites:**
```bash
# MongoDB must be installed on the Nomad client node
sudo apt-get install -y mongodb-org  # Ubuntu/Debian
# or
sudo yum install -y mongodb-org      # CentOS/RHEL
```

**Deploy:**
```bash
cd examples
nomad job run mongodb-systemd.nomad
```

**Access:**
```bash
mongo --host <nomad-client-ip> --port 27017
```

---

### 2. ClickHouse with Raw Exec Driver (`clickhouse-external-templates.nomad`)

Runs ClickHouse database using the `raw_exec` driver with external templates.

**Features:**
- Uses raw_exec driver for native execution
- External templates for complex XML configuration
- Multiple ports: HTTP (8123), Native (9000), Interserver (9009)
- Automatic directory structure creation via template
- Multiple service registrations (HTTP and Native)
- HTTP and TCP health checks

**Templates Used:**
- `templates/clickhouse-config.xml.tpl` - Main configuration
- `templates/setup-dirs.sh.tpl` - Directory initialization

**Prerequisites:**
```bash
# ClickHouse must be installed on the Nomad client node
sudo apt-get install -y clickhouse-server clickhouse-client  # Ubuntu/Debian
# or
sudo yum install -y clickhouse-server clickhouse-client      # CentOS/RHEL
```

**Deploy:**
```bash
cd examples
nomad job run clickhouse-external-templates.nomad
```

**Access:**
```bash
# HTTP interface
curl http://<nomad-client-ip>:8123/

# CLI client
clickhouse-client --host <nomad-client-ip> --port 9000
```

---

### 3. Nginx with Docker Driver (`nginx-external-templates.nomad`)

Runs Nginx web server using the Docker container driver with external templates.

**Features:**
- Uses Docker driver for containerized execution
- External templates for nginx config and HTML
- Dynamic HTML content with Nomad metadata
- Health check endpoint
- Port mapping (8080 → 80)
- Fabio-compatible tags for load balancing
- Auto-restart policy

**Templates Used:**
- `templates/nginx.conf.tpl` - Nginx configuration
- `templates/nginx-index.html.tpl` - Custom index page with Nomad info

**Prerequisites:**
```bash
# Docker must be installed and running on the Nomad client
docker --version
```

**Deploy:**
```bash
cd examples
nomad job run nginx-external-templates.nomad
```

**Access:**
```bash
# Direct access
curl http://<nomad-client-ip>:8080/

# Health check
curl http://<nomad-client-ip>:8080/health

# Via Fabio (if configured)
curl http://<fabio-address>/
```

---

## Template Files

All configuration is managed through external template files in the `templates/` directory:

| Template File | Used By | Purpose |
|--------------|---------|---------|
| `mongodb-setup.sh.tpl` | MongoDB | Directory initialization |
| `clickhouse-config.xml.tpl` | ClickHouse | Main database configuration |
| `setup-dirs.sh.tpl` | ClickHouse | Directory structure setup |
| `nginx.conf.tpl` | Nginx | Web server configuration |
| `nginx-index.html.tpl` | Nginx | Custom index page |

### Modifying Templates

To customize configurations:

1. Edit the template file in `templates/`
2. Template changes take effect on next job deployment
3. For running jobs, redeploy: `nomad job run <job-file.nomad>`

**Example - Update Nginx port:**

Edit `templates/nginx.conf.tpl`:
```nginx
server {
    listen 8080;  # Change this
    ...
}
```

Then redeploy:
```bash
nomad job run nginx-external-templates.nomad
```

---

## Important Notes

### Raw Exec Driver Security

The `raw_exec` driver must be enabled in your Nomad client configuration. This driver provides no isolation and should only be used in trusted environments.

**Enable raw_exec in Nomad client configuration:**

Edit `/etc/nomad.d/nomad-client.hcl` or `/etc/nomad.d/client.hcl` and add:

```hcl
plugin "raw_exec" {
  config {
    enabled = true
  }
}
```

Then restart Nomad:
```bash
sudo systemctl restart nomad
```

### Docker Driver Requirements

Ensure Docker is installed and the Nomad client has permission to use it:

```bash
# Test Docker access
docker ps

# Add nomad user to docker group (if needed)
sudo usermod -aG docker nomad
sudo systemctl restart nomad
```

---

## Job Management Commands

### Validate before deploying
```bash
nomad job validate <job-file.nomad>
```

### View job status
```bash
nomad job status <job-name>
```

### View allocation logs
```bash
nomad alloc logs <alloc-id>
nomad alloc logs -f <alloc-id>  # Follow logs
```

### Stop a job
```bash
nomad job stop <job-name>
```

### Update a running job
```bash
nomad job run <job-file.nomad>
```

### Force purge a job
```bash
nomad job stop -purge <job-name>
```

---

## Service Discovery

All jobs register with Consul for service discovery. Query services:

```bash
# Via Consul API
curl http://localhost:8500/v1/catalog/service/mongodb
curl http://localhost:8500/v1/catalog/service/clickhouse
curl http://localhost:8500/v1/catalog/service/nginx

# Via Consul DNS
dig @localhost -p 8600 mongodb.service.consul
dig @localhost -p 8600 clickhouse.service.consul
dig @localhost -p 8600 nginx.service.consul
```

---

## Troubleshooting

### Connection refused error
```
Error submitting job: Put "http://127.0.0.1:4646/v1/jobs": dial tcp 127.0.0.1:4646: connection refused
```

**Solution:** Configure Nomad CLI to connect to your Nomad server. You have two options:

**Option 1: Environment variable (temporary)**
```bash
export NOMAD_ADDR=http://192.168.1.10:4646
nomad job run nginx-container.nomad
```

**Option 2: System-wide configuration (permanent)**

Create `/etc/nomad-cli.env`:
```bash
sudo tee /etc/nomad-cli.env > /dev/null <<EOF
NOMAD_ADDR=http://192.168.1.10:4646
NOMAD_NAMESPACE=default
EOF
```

Then add to your shell profile (`~/.zshrc` or `~/.bashrc`):
```bash
# Load Nomad CLI configuration
if [ -f /etc/nomad-cli.env ]; then
    export $(grep -v '^#' /etc/nomad-cli.env | xargs)
fi
```

Reload your shell:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

Verify connection:
```bash
nomad server members
nomad node status
```

### Template not found error
```
Error: failed to read template: open templates/config.tpl: no such file or directory
```

**Solution:** Ensure you run `nomad job run` from the `examples/` directory:
```bash
cd /home/mreza/Desktop/Work/nomad-ansible/examples
nomad job run nginx-external-templates.nomad
```

### Check Nomad client configuration
```bash
nomad node status
nomad node status -self
```

### View detailed allocation information
```bash
nomad alloc status <alloc-id>
```

### Check allocation events
```bash
nomad alloc status <alloc-id> | grep -A 20 "Recent Events"
```

### View full logs
```bash
nomad alloc logs -f <alloc-id>
nomad alloc logs -stderr <alloc-id>
```

### Validate job file
```bash
nomad job validate <job-file.nomad>
```

### Plan job changes (dry run)
```bash
nomad job plan <job-file.nomad>
```

### Check template rendering
If a template fails to render, check the allocation logs for details about missing variables or syntax errors.

---

## Additional Resources

- **[EXTERNAL-TEMPLATES.md](EXTERNAL-TEMPLATES.md)** - Comprehensive guide on using external templates
- **Nomad Documentation**: https://developer.hashicorp.com/nomad/docs
- **Template Syntax**: https://developer.hashicorp.com/nomad/docs/job-specification/template
