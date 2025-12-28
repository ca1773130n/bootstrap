# PostgreSQL on VPS (Vultr/Hetzner)

## 1. Provision VPS

**Vultr**: $6/mo (1 vCPU, 1GB RAM, 25GB SSD)
**Hetzner**: €4.51/mo (CX11, 1 vCPU, 2GB RAM, 20GB SSD)

Choose Ubuntu 22.04 LTS.

## 2. Initial Setup

```bash
ssh root@YOUR_VPS_IP

apt update && apt upgrade -y
apt install -y postgresql postgresql-contrib ufw fail2ban

ufw allow OpenSSH
ufw allow 5432/tcp
ufw enable
```

## 3. Configure PostgreSQL

```bash
sudo -u postgres psql

CREATE USER appuser WITH PASSWORD 'your-secure-password';
CREATE DATABASE appdb OWNER appuser;
GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;
\q
```

Edit `/etc/postgresql/14/main/postgresql.conf`:
```
listen_addresses = '*'
```

Edit `/etc/postgresql/14/main/pg_hba.conf`:
```
host    appdb    appuser    0.0.0.0/0    scram-sha-256
```

Restart:
```bash
systemctl restart postgresql
```

## 4. SSL (Recommended)

```bash
apt install -y certbot
certbot certonly --standalone -d db.yourdomain.com

cp /etc/letsencrypt/live/db.yourdomain.com/fullchain.pem /var/lib/postgresql/14/main/server.crt
cp /etc/letsencrypt/live/db.yourdomain.com/privkey.pem /var/lib/postgresql/14/main/server.key
chown postgres:postgres /var/lib/postgresql/14/main/server.*
chmod 600 /var/lib/postgresql/14/main/server.key
```

Edit `postgresql.conf`:
```
ssl = on
ssl_cert_file = '/var/lib/postgresql/14/main/server.crt'
ssl_key_file = '/var/lib/postgresql/14/main/server.key'
```

## 5. Connection String

```
postgresql://appuser:your-secure-password@YOUR_VPS_IP:5432/appdb?sslmode=require
```

Set as `DATABASE_URL` in Fly.io secrets:
```bash
fly secrets set DATABASE_URL="postgresql://..."
```

## 6. Backups

```bash
crontab -e

0 3 * * * pg_dump -U appuser appdb | gzip > /backups/appdb_$(date +\%Y\%m\%d).sql.gz
```

## 7. Init Schema

```bash
psql $DATABASE_URL < infra/supabase.sql
```
