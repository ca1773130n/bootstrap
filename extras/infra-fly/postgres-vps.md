# PostgreSQL on VPS

## 1. Provision VPS

| Provider | Price | Notes |
|----------|-------|-------|
| **Oracle Cloud** | Free | ARM A1 (up to 4 OCPU, 24GB RAM) |
| **Hetzner** | €4/mo | Best value paid option |
| **Vultr** | $6/mo | Global regions |
| **DigitalOcean** | $6/mo | Good docs |

## 2. Initial Setup

### Oracle Linux / RHEL / CentOS

```bash
ssh opc@YOUR_VPS_IP  # Oracle Cloud uses 'opc' user

sudo dnf update -y
sudo dnf install -y postgresql-server postgresql-contrib firewalld fail2ban

# Initialize PostgreSQL
sudo postgresql-setup --initdb
sudo systemctl enable --now postgresql

# Firewall
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
```

**Oracle Cloud**: Also open port 5432 in Cloud Console:
- Networking → Virtual Cloud Networks → Your VCN → Security Lists → Add Ingress Rule (TCP 5432)

### Ubuntu / Debian

```bash
ssh root@YOUR_VPS_IP

sudo apt update && sudo apt upgrade -y
sudo apt install -y postgresql postgresql-contrib ufw fail2ban

sudo ufw allow OpenSSH
sudo ufw allow 5432/tcp
sudo ufw enable
```

## 3. Configure PostgreSQL

```bash
sudo -u postgres psql

CREATE USER appuser WITH PASSWORD 'your-secure-password';
CREATE DATABASE appdb OWNER appuser;
GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;
\q
```

### Oracle Linux / RHEL

```bash
sudo nano /var/lib/pgsql/data/postgresql.conf
# Set: listen_addresses = '*'

sudo nano /var/lib/pgsql/data/pg_hba.conf
# Add at end: host appdb appuser 0.0.0.0/0 scram-sha-256

sudo systemctl restart postgresql
```

### Ubuntu / Debian

```bash
sudo nano /etc/postgresql/*/main/postgresql.conf
# Set: listen_addresses = '*'

sudo nano /etc/postgresql/*/main/pg_hba.conf
# Add at end: host appdb appuser 0.0.0.0/0 scram-sha-256

sudo systemctl restart postgresql
```

## 4. SSL (Optional)

Skip if connecting only from Fly.io (traffic goes over private network).

```bash
# Oracle Linux
sudo dnf install -y certbot

# Ubuntu
sudo apt install -y certbot

# Get cert
sudo certbot certonly --standalone -d db.yourdomain.com

# Copy certs to PostgreSQL data dir
# Oracle Linux: /var/lib/pgsql/data/
# Ubuntu: /var/lib/postgresql/*/main/
PG_DATA="/var/lib/pgsql/data"  # adjust for your distro

sudo cp /etc/letsencrypt/live/db.yourdomain.com/fullchain.pem $PG_DATA/server.crt
sudo cp /etc/letsencrypt/live/db.yourdomain.com/privkey.pem $PG_DATA/server.key
sudo chown postgres:postgres $PG_DATA/server.*
sudo chmod 600 $PG_DATA/server.key
```

Add to `postgresql.conf`:
```
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
```

## 5. Connection String

```
# Without SSL
postgresql://appuser:your-secure-password@YOUR_VPS_IP:5432/appdb

# With SSL
postgresql://appuser:your-secure-password@YOUR_VPS_IP:5432/appdb?sslmode=require
```

Update `.env.fly` and set in Fly.io:
```bash
fly secrets set DATABASE_URL="postgresql://appuser:PASSWORD@YOUR_VPS_IP:5432/appdb" --app myapp-api
```

## 6. Init Schema

```bash
psql "postgresql://appuser:PASSWORD@YOUR_VPS_IP:5432/appdb" < infra/init.sql
```

## 7. Backups (Optional)

```bash
# Create backup directory
sudo mkdir -p /backups
sudo chown postgres:postgres /backups

# Add cron job
sudo crontab -u postgres -e
# Add: 0 3 * * * pg_dump appdb | gzip > /backups/appdb_$(date +\%Y\%m\%d).sql.gz
```
