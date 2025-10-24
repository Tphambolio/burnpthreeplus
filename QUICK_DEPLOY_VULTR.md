# Quick Deploy BurnP3+ to Vultr (Manual - 10 Minutes)

## Step 1: Create Vultr VM (3 minutes)

1. **Go to**: https://my.vultr.com/
2. **Click**: "Deploy +" button (top right)
3. **Select**: "Deploy New Server"
4. **Configure**:
   - **Server Type**: Cloud Compute - Shared CPU
   - **Server Location**: Choose closest to you
   - **Server Image**: Ubuntu 22.04 x64
   - **Server Size**:
     ```
     ✅ Recommended: $12/month (2 vCPU, 4GB RAM, 80GB SSD)
     ⚠️ Minimum: $6/month (1 vCPU, 2GB RAM, 55GB SSD)
     ```
   - **Auto Backups**: Optional (+20% cost)
   - **SSH Keys**: Add your SSH key (recommended) or use password
   - **Server Hostname**: burnp3-plus
   - **Server Label**: BurnP3+ Production

5. **Click**: "Deploy Now"
6. **Wait**: ~60 seconds for VM to be created
7. **Copy**: Your server's IP address from the dashboard

## Step 2: Connect to Your Server (1 minute)

```bash
# SSH into your server (use password from Vultr dashboard)
ssh root@YOUR_SERVER_IP

# If using SSH key
ssh -i /path/to/your/key root@YOUR_SERVER_IP
```

## Step 3: Deploy BurnP3+ (6 minutes)

Run these commands on your Vultr server:

```bash
# Update system
apt-get update && apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
apt-get install -y docker-compose-plugin

# Clone BurnP3+ repository
cd /root
git clone https://github.com/Tphambolio/burnpthreeplus.git
cd burnpthreeplus

# Checkout correct branch
git checkout claude/review-burnp3-deployment-011CURBzS2gzJ65GThTRVova

# Deploy application
docker compose up -d --build

# Wait for services to start (2-3 minutes)
sleep 180

# Check status
docker compose ps
```

## Step 4: Access Your Application

Get your server's public IP:
```bash
curl ifconfig.me
```

Then open in your browser:

- **Frontend**: `http://YOUR_IP:3000`
- **Backend API**: `http://YOUR_IP:8000`
- **API Documentation**: `http://YOUR_IP:8000/docs`
- **Job Monitor (Flower)**: `http://YOUR_IP:5555`
- **MinIO Console**: `http://YOUR_IP:9001`

## Step 5: Configure Firewall (Optional but Recommended)

```bash
# Allow necessary ports
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 3000/tcp  # Frontend
ufw allow 8000/tcp  # Backend
ufw allow 5555/tcp  # Flower

# Enable firewall
ufw --force enable

# Check status
ufw status
```

## Verify Deployment

```bash
# Check all services are running
docker compose ps

# View logs
docker compose logs -f

# Test backend API
curl http://localhost:8000/api/v1/health
```

You should see all services in "Up" status.

---

## Common Commands

```bash
# View logs
docker compose logs -f [service_name]

# Restart services
docker compose restart

# Stop all services
docker compose down

# Update and restart
cd /root/burnpthreeplus
git pull
docker compose up -d --build

# Check disk space
df -h

# Clean up Docker resources
docker system prune -a
```

---

## Costs

| Plan | vCPU | RAM | Storage | Bandwidth | Monthly Cost |
|------|------|-----|---------|-----------|--------------|
| Starter | 1 | 2GB | 55GB SSD | 2TB | **$6** |
| Recommended | 2 | 4GB | 80GB SSD | 3TB | **$12** |
| Performance | 2 | 8GB | 160GB SSD | 4TB | **$24** |

**Note**: Vultr uses hourly billing, so you only pay for what you use!

---

## What's Running?

After deployment, you'll have:

| Service | Description | Port |
|---------|-------------|------|
| **Frontend** | React web application | 3000 |
| **Backend** | FastAPI REST API | 8000 |
| **PostgreSQL** | Database with PostGIS | 5432 |
| **Redis** | Cache and task queue | 6379 |
| **Celery Worker** | Background job processor | - |
| **Flower** | Job monitoring dashboard | 5555 |
| **MinIO** | S3-compatible object storage | 9000/9001 |

---

## Next Steps

### 1. Test the Application
- Visit the frontend at `http://YOUR_IP:3000`
- Try the API docs at `http://YOUR_IP:8000/docs`
- Check job monitor at `http://YOUR_IP:5555`

### 2. Set Up Domain (Optional)
- Point your domain's A record to your server IP
- Configure Nginx as reverse proxy
- Enable SSL with Let's Encrypt

### 3. Monitor Your Application
```bash
# View resource usage
docker stats

# Check disk space
df -h

# Monitor logs
docker compose logs -f
```

### 4. Set Up Backups (Recommended)
```bash
# Create backup directory
mkdir -p /root/backups

# Backup database
docker compose exec -T db pg_dump -U burnp3 burnp3 > /root/backups/backup-$(date +%Y%m%d).sql

# Create backup script (runs daily at 2 AM)
cat > /root/backup.sh << 'EOF'
#!/bin/bash
cd /root/burnpthreeplus
docker compose exec -T db pg_dump -U burnp3 burnp3 > /root/backups/backup-$(date +%Y%m%d).sql
find /root/backups -name "backup-*.sql" -mtime +7 -delete
EOF

chmod +x /root/backup.sh

# Add to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /root/backup.sh") | crontab -
```

---

## Troubleshooting

### Services won't start
```bash
# Check logs
docker compose logs

# Rebuild
docker compose down -v
docker compose up -d --build
```

### Can't access from browser
1. Check firewall: `ufw status`
2. Check services: `docker compose ps`
3. Check ports: `netstat -tlnp | grep -E '3000|8000'`

### Out of memory
```bash
# Check memory usage
free -h

# Upgrade to larger plan in Vultr dashboard
```

---

## Support

- **Vultr Dashboard**: https://my.vultr.com/
- **Vultr Docs**: https://www.vultr.com/docs/
- **BurnP3+ Issues**: https://github.com/Tphambolio/burnpthreeplus/issues

---

**Total Deployment Time**: ~10 minutes
**Monthly Cost**: $12 (recommended plan)
**Complexity**: ⭐⭐ (Easy)

🔥 **You're now running BurnP3+ on Vultr!**
