# Nomad Ansible

Ansible playbooks for deploying a secure HashiCorp Nomad cluster with Consul service discovery and Fabio load balancing. Supports both container (Docker) and systemd worker nodes with single or multi-master configurations.

## Features

- **Nomad Cluster**: Deploy Nomad servers with single or multi-master (3+ servers recommended for HA)
- **Consul Integration**: Full Consul cluster for service discovery and health checking
- **Fabio Load Balancer**: HTTP/TCP load balancing with Consul integration
- **Container Workers**: Docker-enabled worker nodes for container workloads
- **Systemd Workers**: Worker nodes with exec and raw_exec drivers for systemd-based workloads
- **Secure Communication**: TLS/mTLS encryption for all inter-service communication
- **Gossip Encryption**: Encrypted gossip protocol for both Consul and Nomad
- **ACL Support**: Access Control Lists enabled by default

## Architecture

```
                    ┌─────────────────┐
                    │   Fabio LB      │
                    │  (Load Balancer)│
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
│  Consul Server  │ │  Consul Server  │ │  Consul Server  │
│  Nomad Server   │ │  Nomad Server   │ │  Nomad Server   │
│  (Master 1)     │ │  (Master 2)     │ │  (Master 3)     │
└─────────────────┘ └─────────────────┘ └─────────────────┘
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
│ Container Worker│ │ Container Worker│ │ Systemd Worker  │
│ (Docker)        │ │ (Docker)        │ │ (exec/raw_exec) │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

## Requirements

- Ansible 2.12+
- Python 3.8+
- Target nodes running Ubuntu 20.04+ or Debian 11+
- SSH access with sudo privileges

## Quick Start

### 1. Install Dependencies

```bash
# Install Ansible Galaxy collections
ansible-galaxy collection install -r requirements.yml
```

### 2. Configure Inventory

Edit `inventories/hosts.yml` to match your infrastructure:

```yaml
all:
  children:
    # Single master setup
    consul_servers:
      hosts:
        consul-server-1:
          ansible_host: 192.168.1.10

    # For multi-master (recommended for production)
    # consul_servers:
    #   hosts:
    #     consul-server-1:
    #       ansible_host: 192.168.1.10
    #     consul-server-2:
    #       ansible_host: 192.168.1.11
    #     consul-server-3:
    #       ansible_host: 192.168.1.12

    nomad_servers:
      hosts:
        nomad-server-1:
          ansible_host: 192.168.1.10

    container_workers:
      hosts:
        container-worker-1:
          ansible_host: 192.168.1.20

    systemd_workers:
      hosts:
        systemd-worker-1:
          ansible_host: 192.168.1.30

    fabio_nodes:
      hosts:
        fabio-1:
          ansible_host: 192.168.1.40
```

### 3. Configure Variables

Edit `group_vars/all.yml` to customize your deployment:

```yaml
# Datacenter name
datacenter: "dc1"
region: "global"

# Software versions
consul_version: "1.17.1"
nomad_version: "1.7.2"
fabio_version: "1.6.3"

# Security settings
enable_tls: true
enable_acl: true

# Pre-generated encryption keys (optional - will be auto-generated if empty)
consul_encrypt_key: ""
nomad_encrypt_key: ""
```

### 4. Run the Playbook

```bash
# Deploy the entire stack
ansible-playbook site.yml

# Deploy with verbose output
ansible-playbook site.yml -v

# Deploy to specific host group
ansible-playbook site.yml --limit consul_servers
```

## Directory Structure

```
.
├── ansible.cfg              # Ansible configuration
├── site.yml                 # Main playbook
├── requirements.yml         # Ansible Galaxy requirements
├── group_vars/
│   └── all.yml             # Global variables
├── inventories/
│   └── hosts.yml           # Inventory file
└── roles/
    ├── common/             # Common setup for all nodes
    ├── certificates/       # TLS certificate generation
    ├── consul/            # Consul installation
    ├── nomad/             # Nomad installation
    └── fabio/             # Fabio installation
```

## Configuration Details

### TLS/mTLS Configuration

TLS is enabled by default (`enable_tls: true`). The `certificates` role generates:

- **CA Certificate**: Self-signed CA for all services
- **Server Certificates**: For Consul and Nomad servers
- **Client Certificates**: For Consul and Nomad clients

Certificates are generated locally and distributed to nodes via Ansible.

### Multi-Master Setup

For high availability, deploy 3 or 5 servers:

1. Uncomment additional servers in `inventories/hosts.yml`
2. The `bootstrap_expect` is automatically calculated based on the number of servers

### Worker Node Types

#### Container Workers
- Docker driver enabled
- Suitable for containerized workloads
- Docker installed and configured automatically

#### Systemd Workers
- exec and raw_exec drivers enabled
- Suitable for traditional application deployment
- No container runtime required

### Fabio Load Balancer

Fabio provides:
- **Port 9999**: HTTP/TCP load balancer
- **Port 9998**: Web UI for route management
- Automatic service discovery via Consul

## Security Considerations

1. **TLS Encryption**: All communication is encrypted by default
2. **Gossip Encryption**: Cluster gossip is encrypted
3. **ACLs**: Access Control Lists are enabled by default
4. **Certificate Rotation**: Certificates are valid for 1 year (configurable)

## Post-Installation

### Bootstrap ACLs

After deployment, bootstrap ACLs:

```bash
# Consul ACL Bootstrap
consul acl bootstrap

# Nomad ACL Bootstrap
nomad acl bootstrap
```

### Verify Cluster Status

```bash
# Check Consul cluster
consul members

# Check Nomad cluster
nomad server members
nomad node status

# Check Fabio
curl http://fabio-host:9998/routes
```

## Troubleshooting

### View Service Logs

```bash
# Consul logs
journalctl -u consul -f

# Nomad logs
journalctl -u nomad -f

# Fabio logs
journalctl -u fabio -f
```

### Common Issues

1. **Cluster not forming**: Check network connectivity and firewall rules
2. **TLS errors**: Verify certificates are properly distributed
3. **ACL issues**: Ensure tokens are properly configured

## License

MIT

## Contributing

Contributions are welcome! Please submit a pull request or open an issue.
