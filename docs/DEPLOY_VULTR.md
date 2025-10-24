# Deploy BurnP3+ to Vultr (Automated)

**The fastest way to deploy BurnP3+ with automatic VM provisioning.**

---

## Why Vultr?

✅ **Automated provisioning** - Script creates and configures VM automatically
✅ **Fast deployment** - Global infrastructure with 25+ locations
✅ **Cost-effective** - Starting at $6/month for full stack
✅ **Simple API** - Easy automation with Vultr API
✅ **Reliable** - 100% SLA uptime guarantee
✅ **Scalable** - Easily upgrade instance size as needed

---

## Quick Start (Automated)

### Prerequisites

1. **Vultr Account**
   - Sign up at https://www.vultr.com/
   - Add payment method (no charge until you deploy)

2. **Vultr API Key**
   - Go to https://my.vultr.com/settings/#settingsapi
   - Click "Enable API" if not enabled
   - Copy your API key

### One-Command Deployment

```bash
# Clone repository
git clone https://github.com/Tphambolio/burnpthreeplus.git
cd burnpthreeplus

# Set your Vultr API key
export VULTR_API_KEY='your-api-key-here'

# Run automated deployment
bash deploy-vultr.sh
```

**That's it!** The script will:
1. Create a new Vultr instance
2. Install Docker and dependencies
3. Deploy the entire BurnP3+ application
4. Give you access URLs

**Total time: ~5 minutes**

---

## What the Script Does

### Step 1: Validates API Key
- Checks connection to Vultr API
- Verifies account access

### Step 2: Sets Up SSH Key
- Generates new SSH key pair
- Uploads public key to Vultr
- Enables secure access to VM

### Step 3: Creates Vultr Instance
- Provisions Ubuntu 22.04 VM
- Configures networking
- Assigns public IP

### Step 4: Installs Dependencies
- Updates system packages
- Installs Docker and Docker Compose
- Installs Git

### Step 5: Deploys Application
- Clones BurnP3+ repository
- Builds Docker images
- Starts all services

---

## Configuration Options

You can customize the deployment by editing these variables in `deploy-vultr.sh`:

### Instance Size

```bash
PLAN_ID="vc2-1c-1gb"  # Default: 1 CPU, 1GB RAM - $6/month
```

**Available Plans:**

| Plan ID | vCPU | RAM | Storage | Bandwidth | Monthly Cost |
|---------|------|-----|---------|-----------|--------------|
| `vc2-1c-1gb` | 1 | 1GB | 25GB SSD | 1TB | $6 |
| `vc2-1c-2gb` | 1 | 2GB | 55GB SSD | 2TB | $12 |
| `vc2-2c-4gb` | 2 | 4GB | 80GB SSD | 3TB | $24 |
| `vc2-4c-8gb` | 4 | 8GB | 160GB SSD | 4TB | $48 |
| `vc2-6c-16gb` | 6 | 16GB | 320GB SSD | 5TB | $96 |

**Recommendation:**
- **Development/Testing**: `vc2-1c-1gb` ($6/month)
- **Small Production**: `vc2-1c-2gb` ($12/month)
- **Production**: `vc2-2c-4gb` ($24/month)
- **Heavy Usage**: `vc2-4c-8gb` ($48/month)

### Region

```bash
REGION="ewr"  # Default: New York
```

**Available Regions:**

#### North America
- `ewr` - New York (NJ)
- `ord` - Chicago
- `dfw` - Dallas
- `sea` - Seattle
- `lax` - Los Angeles
- `sjc` - Silicon Valley
- `atl` - Atlanta
- `mia` - Miami
- `yto` - Toronto

#### Europe
- `lhr` - London
- `fra` - Frankfurt
- `ams` - Amsterdam
- `par` - Paris
- `mad` - Madrid
- `waw` - Warsaw

#### Asia-Pacific
- `sgp` - Singapore
- `syd` - Sydney
- `nrt` - Tokyo
- `sel` - Seoul
- `icn` - Seoul (Incheon)
- `bom` - Mumbai
- `del` - Delhi

#### Other
- `sao` - São Paulo
- `mex` - Mexico City
- `jnb` - Johannesburg

---

## Manual Deployment (Step by Step)

If you prefer manual control:

### Step 1: Create Vultr Instance Manually

1. Go to https://my.vultr.com/
2. Click **"Deploy New Server"**
3. Choose:
   - **Server Type**: Cloud Compute
   - **Location**: Choose closest to you
   - **Server Type**: Ubuntu 22.04 x64
   - **Server Size**:
     - Minimum: 1GB RAM ($6/month)
     - Recommended: 2GB RAM ($12/month)
   - **Additional Features**: Enable IPv6 (optional)
4. Click **"Deploy Now"**
5. Wait ~60 seconds for deployment
6. Copy the IP address and root password

### Step 2: Connect via SSH

```bash
ssh root@YOUR_VM_IP
# Enter password when prompted
```

### Step 3: Deploy Application

```bash
# Clone repository
git clone https://github.com/Tphambolio/burnpthreeplus.git
cd burnpthreeplus

# Checkout correct branch
git checkout claude/vultr-deployment-setup-011CURAy4ie4xo17LwA7xvhG

# Run deployment script
bash deploy-vm.sh
```

---

## After Deployment

### Access Your Application

The deployment script will show URLs like:

```
🌐 Access Your Application:
  Frontend:   http://YOUR_IP:3000
  Backend:    http://YOUR_IP:8000
  API Docs:   http://YOUR_IP:8000/docs
  Flower:     http://YOUR_IP:5555
  MinIO:      http://YOUR_IP:9001
```

### Test Your Deployment

1. **Frontend**: Open `http://YOUR_IP:3000` in your browser
2. **API Health**: Visit `http://YOUR_IP:8000/health`
3. **API Documentation**: Visit `http://YOUR_IP:8000/docs`

### SSH Access

```bash
# Using the SSH key created by the script
ssh -i ~/.ssh/burnp3_deploy root@YOUR_IP

# Or using password (if you deployed manually)
ssh root@YOUR_IP
```

---

## Managing Your Deployment

### View Logs

```bash
ssh -i ~/.ssh/burnp3_deploy root@YOUR_IP
cd burnpthreeplus
docker-compose logs -f
```

### Check Service Status

```bash
docker-compose ps
```

### Restart Services

```bash
docker-compose restart
```

### Update Application

```bash
git pull origin claude/vultr-deployment-setup-011CURAy4ie4xo17LwA7xvhG
docker-compose up -d --build
```

### Stop Services

```bash
docker-compose down
```

---

## Firewall Configuration (Optional)

Vultr instances are open by default. To secure your instance:

### Option 1: Vultr Firewall (Recommended)

1. Go to https://my.vultr.com/firewall/
2. Click **"Add Firewall Group"**
3. Add rules:
   - Port 22 (SSH) - Your IP only
   - Port 80 (HTTP) - 0.0.0.0/0
   - Port 443 (HTTPS) - 0.0.0.0/0
   - Port 3000 (Frontend) - 0.0.0.0/0
   - Port 8000 (Backend) - 0.0.0.0/0
4. Attach firewall to your instance

### Option 2: UFW (Ubuntu Firewall)

```bash
ssh -i ~/.ssh/burnp3_deploy root@YOUR_IP

# Enable firewall
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 3000/tcp  # Frontend
ufw allow 8000/tcp  # Backend
ufw allow 5555/tcp  # Flower (optional)
ufw enable
```

---

## Adding a Domain Name

### Step 1: Point Domain to Vultr IP

In your domain registrar's DNS settings:

```
Type: A
Name: @
Value: YOUR_VULTR_IP
TTL: 3600
```

For subdomain:
```
Type: A
Name: app
Value: YOUR_VULTR_IP
TTL: 3600
```

### Step 2: Install SSL Certificate (HTTPS)

```bash
ssh -i ~/.ssh/burnp3_deploy root@YOUR_IP

# Install Certbot
apt install -y certbot python3-certbot-nginx nginx

# Configure Nginx (uncomment nginx in docker-compose.yml first)
# Then get certificate
certbot --nginx -d yourdomain.com
```

---

## Scaling Your Instance

### Upgrade Instance Size

1. **Stop services**:
   ```bash
   cd burnpthreeplus
   docker-compose down
   ```

2. **Take snapshot** (optional but recommended):
   - Go to Vultr dashboard
   - Select your instance
   - Click "Snapshots" → "Take Snapshot"

3. **Resize instance**:
   - In Vultr dashboard
   - Click your instance
   - Click "Settings" → "Resize"
   - Choose new plan
   - Click "Resize Server"

4. **Restart services**:
   ```bash
   cd burnpthreeplus
   docker-compose up -d
   ```

---

## Backup and Disaster Recovery

### Automatic Backups (Vultr)

1. Go to your instance in Vultr dashboard
2. Click "Settings" → "Backups"
3. Enable automatic backups ($1/month)
4. Backups run daily

### Manual Database Backup

```bash
ssh -i ~/.ssh/burnp3_deploy root@YOUR_IP
cd burnpthreeplus

# Backup database
docker-compose exec -T db pg_dump -U burnp3 burnp3 > backup-$(date +%Y%m%d).sql

# Download backup to your local machine
scp -i ~/.ssh/burnp3_deploy root@YOUR_IP:/root/burnpthreeplus/backup-*.sql ./
```

### Restore from Backup

```bash
# Upload backup to server
scp -i ~/.ssh/burnp3_deploy backup-20250124.sql root@YOUR_IP:/root/burnpthreeplus/

# SSH into server
ssh -i ~/.ssh/burnp3_deploy root@YOUR_IP
cd burnpthreeplus

# Restore database
docker-compose exec -T db psql -U burnp3 burnp3 < backup-20250124.sql
```

---

## Monitoring

### Built-in Monitoring

- **Flower** (Celery tasks): `http://YOUR_IP:5555`
- **MinIO Console** (Storage): `http://YOUR_IP:9001`

### Vultr Monitoring

1. Go to Vultr dashboard
2. Select your instance
3. Click "Monitoring" tab
4. View CPU, RAM, bandwidth graphs

### Health Check Endpoint

```bash
# Check if backend is healthy
curl http://YOUR_IP:8000/health

# Should return:
# {"status":"healthy","version":"0.1.0"}
```

---

## Cost Breakdown

### Monthly Costs

| Component | Cost |
|-----------|------|
| VM (1GB RAM) | $6.00 |
| VM (2GB RAM) | $12.00 |
| Automatic Backups | $1.00 |
| IPv6 | Free |
| Bandwidth (1TB+) | Included |

**Total: $6-13/month** depending on configuration

### Cost Comparison

| Provider | Monthly Cost | Setup Complexity |
|----------|-------------|------------------|
| **Vultr (Automated)** | $6-12 | Very Low |
| DigitalOcean | $12-18 | Low |
| AWS EC2 | $15-30 | High |
| Railway + Vercel | $10-25 | Medium |

---

## Troubleshooting

### Script Fails to Create Instance

**Check API key**:
```bash
curl -H "Authorization: Bearer $VULTR_API_KEY" \
  https://api.vultr.com/v2/account
```

**Common issues**:
- API key not enabled in Vultr dashboard
- Insufficient account balance
- Invalid region or plan ID

### Cannot Connect via SSH

**Wait longer**: Instance may still be initializing (can take 3-5 minutes)

**Check SSH key**:
```bash
ssh -i ~/.ssh/burnp3_deploy -v root@YOUR_IP
```

**Use password instead** (check email or Vultr dashboard for password)

### Services Won't Start

**Check Docker status**:
```bash
systemctl status docker
```

**Check logs**:
```bash
cd burnpthreeplus
docker-compose logs
```

**Rebuild from scratch**:
```bash
docker-compose down -v
docker-compose up -d --build
```

### Out of Memory

**Upgrade instance**:
- 1GB RAM is minimum - may need 2GB+ for production
- See "Scaling Your Instance" section above

---

## Deleting Your Instance

### Via Vultr Dashboard

1. Go to https://my.vultr.com/
2. Select your instance
3. Click "Settings" → "Destroy Server"
4. Confirm deletion

### Via API (Automated)

```bash
INSTANCE_ID="your-instance-id"  # Shown in deployment output

curl -X DELETE \
  "https://api.vultr.com/v2/instances/${INSTANCE_ID}" \
  -H "Authorization: Bearer ${VULTR_API_KEY}"
```

---

## Advanced Configuration

### Custom Environment Variables

Edit `docker-compose.yml` before running `deploy-vm.sh`:

```yaml
backend:
  environment:
    - ENVIRONMENT=production
    - SECRET_KEY=your-custom-secret-key
    - CORS_ORIGINS=https://yourdomain.com
```

### Enable Nginx Reverse Proxy

Uncomment nginx service in `docker-compose.yml`:

```yaml
# Uncomment this section
nginx:
  image: nginx:alpine
  ports:
    - "80:80"
    - "443:443"
  # ...
```

Then deploy:
```bash
docker-compose up -d
```

---

## Security Best Practices

### 1. Change Default Passwords

```bash
# MinIO admin console
# Edit docker-compose.yml and change:
MINIO_ROOT_USER: your-custom-user
MINIO_ROOT_PASSWORD: your-secure-password
```

### 2. Use SSH Keys Only

```bash
# Disable password authentication
vim /etc/ssh/sshd_config

# Set:
PasswordAuthentication no

# Restart SSH
systemctl restart sshd
```

### 3. Enable Automatic Security Updates

```bash
apt install unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

### 4. Set Up Fail2Ban

```bash
apt install fail2ban
systemctl enable fail2ban
systemctl start fail2ban
```

---

## Support and Resources

### Vultr Resources
- **Documentation**: https://www.vultr.com/docs/
- **API Docs**: https://www.vultr.com/api/
- **Support**: https://my.vultr.com/support/

### BurnP3+ Resources
- **Repository**: https://github.com/Tphambolio/burnpthreeplus
- **Documentation**: `/docs` folder
- **Issues**: GitHub Issues

---

## Summary

**Deploying to Vultr with automation is the fastest way to get BurnP3+ online:**

✅ **One command** - Entire deployment automated
✅ **5 minutes** - From zero to live application
✅ **$6/month** - Most affordable full-stack deployment
✅ **Full control** - Root access, Docker, complete flexibility
✅ **Scalable** - Easy to upgrade as needed
✅ **Reliable** - Enterprise-grade infrastructure

**Get started now:**
```bash
export VULTR_API_KEY='your-api-key-here'
bash deploy-vultr.sh
```
