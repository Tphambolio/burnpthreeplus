# Deploy BurnP3+ to Vultr

This guide will help you deploy BurnP3+ to a Vultr VM instance.

## Prerequisites

1. **Vultr Account**: Sign up at https://www.vultr.com/
2. **Vultr API Key** with the following permissions:
   - Compute: Create/Read
   - Account: Read

## Option 1: Automated Deployment (Using API)

### Step 1: Create API Key

1. Go to https://my.vultr.com/settings/#settingsapi
2. Click "Enable API"
3. Copy your API key
4. **Important**: Ensure the API key has these permissions:
   - "Instance" permissions enabled
   - No IP restrictions (or add your deployment IP)

### Step 2: Run Deployment Script

```bash
# Set your API key
export VULTR_API_KEY="your_vultr_api_key_here"

# Run the deployment script
./deploy-vultr.sh
```

The script will:
- ✅ Create a Vultr instance (2 vCPU, 4GB RAM, Ubuntu 22.04)
- ✅ Install Docker and Docker Compose
- ✅ Clone the BurnP3+ repository
- ✅ Deploy all services
- ✅ Provide you with access URLs

**Deployment time**: ~10 minutes

### Step 3: Access Your Application

After deployment completes, you'll receive URLs like:
- Frontend: `http://YOUR_IP:3000`
- Backend: `http://YOUR_IP:8000`
- API Docs: `http://YOUR_IP:8000/docs`

---

## Option 2: Manual Deployment

### Step 1: Create Vultr Instance

1. Go to https://my.vultr.com/
2. Click "Deploy New Server"
3. Choose:
   - **Server Type**: Cloud Compute
   - **Server Location**: Choose closest to you
   - **Server Image**: Ubuntu 22.04 LTS x64
   - **Server Size**:
     - **$12/month**: 2 vCPU, 4GB RAM, 80GB SSD (Recommended)
     - **$6/month**: 1 vCPU, 2GB RAM, 55GB SSD (Minimum)
   - **Additional Features**:
     - ☑ Enable IPv6
     - ☑ Auto Backups (optional, +$1.20/month)
4. **Server Hostname**: `burnp3-plus`
5. **Server Label**: `BurnP3+ Production`
6. Click "Deploy Now"
7. Wait ~60 seconds for creation
8. **Copy the IP address and root password**

### Step 2: Connect to Your Instance

```bash
# SSH into your server (use password from Vultr dashboard)
ssh root@YOUR_SERVER_IP
```

### Step 3: Install Docker

```bash
# Update system
apt-get update && apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose plugin
apt-get install -y docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### Step 4: Deploy BurnP3+

```bash
# Clone repository
cd /root
git clone https://github.com/Tphambolio/burnpthreeplus.git
cd burnpthreeplus

# Checkout the correct branch
git checkout claude/review-burnp3-deployment-011CURBzS2gzJ65GThTRVova

# Start the application
docker compose up -d --build

# View logs
docker compose logs -f
```

### Step 5: Configure Firewall

```bash
# Allow required ports
ufw allow 22/tcp     # SSH
ufw allow 80/tcp     # HTTP
ufw allow 443/tcp    # HTTPS
ufw allow 3000/tcp   # Frontend
ufw allow 8000/tcp   # Backend API
ufw allow 5555/tcp   # Flower (job monitor)

# Enable firewall
ufw --force enable

# Check status
ufw status
```

### Step 6: Access Your Application

Open in your browser:
- **Frontend**: `http://YOUR_IP:3000`
- **Backend API**: `http://YOUR_IP:8000`
- **API Docs**: `http://YOUR_IP:8000/docs`
- **Flower**: `http://YOUR_IP:5555`
- **MinIO Console**: `http://YOUR_IP:9001`

---

## Verify Deployment

### Check Service Status

```bash
cd /root/burnpthreeplus
docker compose ps
```

All services should show "Up" status.

### Check Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
```

### Test Backend API

```bash
# Health check
curl http://localhost:8000/api/v1/health

# API documentation
curl http://localhost:8000/docs
```

---

## Cost Estimate

| Plan | vCPU | RAM | Storage | Bandwidth | Price |
|------|------|-----|---------|-----------|-------|
| Starter | 1 | 2GB | 55GB SSD | 2TB | $6/month |
| **Recommended** | 2 | 4GB | 80GB SSD | 3TB | **$12/month** |
| Performance | 2 | 8GB | 160GB SSD | 4TB | $24/month |

**Total estimated cost**: $12-24/month (depending on plan)

---

## Production Setup (Optional)

### 1. Set Up Domain Name

```bash
# Install Nginx
apt-get install -y nginx

# Configure Nginx as reverse proxy
# (See DEPLOYMENT.md for detailed Nginx configuration)
```

### 2. Enable SSL/HTTPS

```bash
# Install Certbot
apt-get install -y certbot python3-certbot-nginx

# Get SSL certificate
certbot --nginx -d yourdomain.com
```

### 3. Set Up Automated Backups

```bash
# Create backup script
cat > /root/backup.sh << 'EOF'
#!/bin/bash
cd /root/burnpthreeplus
docker compose exec -T db pg_dump -U burnp3 burnp3 > /root/backups/backup-$(date +%Y%m%d).sql
# Keep only last 7 days
find /root/backups -name "backup-*.sql" -mtime +7 -delete
EOF

chmod +x /root/backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /root/backup.sh
```

### 4. Set Up Monitoring

```bash
# Install monitoring tools
apt-get install -y htop nethogs iotop

# Monitor Docker stats
docker stats

# Monitor logs
docker compose logs -f
```

---

## Useful Commands

### Service Management

```bash
# View all services
docker compose ps

# Stop all services
docker compose down

# Restart all services
docker compose restart

# Restart specific service
docker compose restart backend

# View logs
docker compose logs -f [service_name]

# Rebuild and restart
docker compose up -d --build
```

### Update Application

```bash
cd /root/burnpthreeplus
git pull origin claude/review-burnp3-deployment-011CURBzS2gzJ65GThTRVova
docker compose up -d --build
```

### Database Management

```bash
# Access PostgreSQL
docker compose exec db psql -U burnp3 -d burnp3

# Backup database
docker compose exec db pg_dump -U burnp3 burnp3 > backup.sql

# Restore database
cat backup.sql | docker compose exec -T db psql -U burnp3 -d burnp3
```

### System Maintenance

```bash
# Check disk space
df -h

# Clean up Docker resources
docker system prune -a

# Update system packages
apt-get update && apt-get upgrade -y

# Restart server
reboot
```

---

## Troubleshooting

### Services Won't Start

```bash
# Check logs
docker compose logs

# Rebuild from scratch
docker compose down -v
docker compose up -d --build
```

### Can't Access from Browser

1. Check firewall rules:
   ```bash
   ufw status
   ```

2. Check if services are running:
   ```bash
   docker compose ps
   ```

3. Check if ports are listening:
   ```bash
   netstat -tlnp | grep -E '3000|8000|5555'
   ```

### Database Connection Errors

```bash
# Ensure database is running
docker compose up -d db
sleep 10

# Check database logs
docker compose logs db

# Restart backend
docker compose restart backend
```

### Out of Disk Space

```bash
# Check disk usage
df -h
docker system df

# Clean up
docker system prune -a -f

# Remove old images
docker image prune -a
```

---

## Security Best Practices

### 1. Change Default Passwords

```bash
# Change root password
passwd

# Update database passwords in docker-compose.yml
```

### 2. Set Up SSH Key Authentication

```bash
# On your local machine, copy your SSH key
ssh-copy-id root@YOUR_IP

# Disable password authentication
nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
systemctl restart sshd
```

### 3. Configure Firewall

```bash
# Only allow necessary ports
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3000/tcp
ufw allow 8000/tcp
ufw --force enable
```

### 4. Keep System Updated

```bash
# Enable automatic security updates
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

---

## Support

- **Vultr Support**: https://my.vultr.com/support/
- **Documentation**: https://www.vultr.com/docs/
- **BurnP3+ Issues**: https://github.com/Tphambolio/burnpthreeplus/issues

---

## Summary

Vultr provides a simple and cost-effective way to deploy BurnP3+:

✅ Easy setup with Docker
✅ Full control over the server
✅ Affordable pricing ($12/month)
✅ High performance SSD storage
✅ Global data center locations
✅ Hourly billing (pay only for what you use)

**Total deployment time**: 10-15 minutes
