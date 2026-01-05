# PostgreSQL on VPS

## 1. Provision VPS

| Provider | Price | Notes |
|----------|-------|-------|
| **Oracle Cloud** | Free | ARM A1 (up to 4 OCPU, 24GB RAM) — recommended |
| **Hetzner** | €4/mo | Best value paid option |
| **Vultr** | $6/mo | Global regions |
| **DigitalOcean** | $6/mo | Good docs |

## 2. Oracle Cloud Setup

### 2.1 Create Instance

1. Go to [Oracle Cloud Console](https://cloud.oracle.com/)
2. **Compute** → **Instances** → **Create Instance**
3. Configure:
   - **Image**: Oracle Linux 9 (default)
   - **Shape**: VM.Standard.A1.Flex (ARM) — up to 4 OCPU, 24GB RAM free
   - **SSH Key**: Add your public key (`~/.ssh/id_rsa.pub`)
4. Click **Create**
5. Wait for instance to be **Running**, note the **Public IP**

### 2.2 Open Port 5432 in Security List

1. Go to instance details → **Attached VNICs** → click your VNIC
2. Click the **Subnet** link (e.g., `subnet-XXXXXXXX-XXXX`)
3. Click **Security Lists** → click the default security list
4. Click **Add Ingress Rules**:
   - **Source Type**: CIDR
   - **Source CIDR**: `0.0.0.0/0`
   - **IP Protocol**: TCP
   - **Destination Port Range**: `5432`
   - **Description**: PostgreSQL
5. Click **Add Ingress Rules**

### 2.3 SSH into Instance

```bash
# Oracle Cloud uses 'opc' user (not root)
ssh opc@YOUR_PUBLIC_IP

# If permission denied, ensure your SSH key is correct:
ssh -i ~/.ssh/id_rsa opc@YOUR_PUBLIC_IP
```

### 2.4 Install PostgreSQL

```bash
sudo dnf update -y
sudo dnf install -y postgresql-server postgresql-contrib

# Initialize and start PostgreSQL
sudo postgresql-setup --initdb
sudo systemctl enable --now postgresql

# Open firewall on the instance
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
```

---

## Alternative: Ubuntu / Debian VPS

```bash
ssh root@YOUR_VPS_IP

sudo apt update && sudo apt upgrade -y
sudo apt install -y postgresql postgresql-contrib ufw fail2ban

sudo ufw allow OpenSSH
sudo ufw allow 5432/tcp
sudo ufw enable
```

## 3. Configure PostgreSQL

### 3.1 Create Database and User

```bash
sudo -u postgres psql
```

```sql
CREATE USER appuser WITH PASSWORD 'your-secure-password';
CREATE DATABASE appdb OWNER appuser;
GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;
\q
```

### 3.2 Allow Remote Connections

**Oracle Linux / RHEL:**

```bash
# Edit postgresql.conf - find listen_addresses line and change to:
sudo nano /var/lib/pgsql/data/postgresql.conf
```
```
listen_addresses = '*'
```

```bash
# Edit pg_hba.conf - add this line at the end:
sudo nano /var/lib/pgsql/data/pg_hba.conf
```
```
host    appdb    appuser    0.0.0.0/0    scram-sha-256
```

```bash
# Restart PostgreSQL
sudo systemctl restart postgresql
```

**Ubuntu / Debian:**

```bash
sudo nano /etc/postgresql/*/main/postgresql.conf
# Set: listen_addresses = '*'

sudo nano /etc/postgresql/*/main/pg_hba.conf
# Add: host appdb appuser 0.0.0.0/0 scram-sha-256

sudo systemctl restart postgresql
```

## 4. Test Connection

From your local machine:

```bash
# Test connection (replace with your values)
psql "postgresql://appuser:PASSWORD@YOUR_PUBLIC_IP:5432/appdb"

# If successful, you'll see:
# appdb=>
```

If connection fails:
- Check Security List has port 5432 open (Oracle Cloud Console)
- Check firewall: `sudo firewall-cmd --list-ports`
- Check PostgreSQL is listening: `sudo ss -tlnp | grep 5432`
- Check pg_hba.conf has the correct entry

## 5. Update Fly.io Secrets

```bash
# Update .env.fly with your connection string
DATABASE_URL=postgresql://appuser:PASSWORD@YOUR_PUBLIC_IP:5432/appdb

# Set in Fly.io
fly secrets set DATABASE_URL="postgresql://appuser:PASSWORD@YOUR_PUBLIC_IP:5432/appdb" --app myapp-api
```

## 6. Init Schema

```bash
psql "postgresql://appuser:PASSWORD@YOUR_PUBLIC_IP:5432/appdb" < infra/init.sql
```

## 7. SSL (Optional)

Skip for most cases. Add SSL only if connecting over public internet without VPN.

```bash
# Oracle Linux
sudo dnf install -y certbot
sudo certbot certonly --standalone -d db.yourdomain.com

# Copy certs
sudo cp /etc/letsencrypt/live/db.yourdomain.com/fullchain.pem /var/lib/pgsql/data/server.crt
sudo cp /etc/letsencrypt/live/db.yourdomain.com/privkey.pem /var/lib/pgsql/data/server.key
sudo chown postgres:postgres /var/lib/pgsql/data/server.*
sudo chmod 600 /var/lib/pgsql/data/server.key

# Add to postgresql.conf
sudo nano /var/lib/pgsql/data/postgresql.conf
```
```
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file = 'server.key'
```

## 8. Backups (Optional)

```bash
# Create backup directory
sudo mkdir -p /backups
sudo chown postgres:postgres /backups

# Add daily backup cron job
sudo crontab -u postgres -e
```
```
0 3 * * * pg_dump appdb | gzip > /backups/appdb_$(date +\%Y\%m\%d).sql.gz
```
