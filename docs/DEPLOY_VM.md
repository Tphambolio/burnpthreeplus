# Deploy BurnP3+ to a Virtual Machine

**The simplest way to deploy the entire BurnP3+ application.**

---

## Why Deploy to a VM?

✅ **Single deployment** - Everything runs on one machine
✅ **One command** - `docker-compose up -d`
✅ **No platform juggling** - No Railway/Vercel complexity
✅ **Complete control** - Full root access
✅ **Easy debugging** - Just SSH in and check logs
✅ **Cost effective** - $6-12/month for everything

---

## Option 1: DigitalOcean (Recommended)

### Cost: $12/month (2GB RAM, 50GB disk)

### Step 1: Create Droplet

1. Go to https://www.digitalocean.com/
2. Click **"Create"** → **"Droplets"**
3. Choose:
   - **Image**: **"Marketplace"** → **"Docker on Ubuntu 22.04"**
   - **Plan**: Basic Shared CPU
   - **Size**: **$12/month** (2GB RAM / 2 CPUs / 50GB SSD)
   - **Region**: Choose closest to you
   - **Authentication**: SSH key (recommended) or password
4. Click **"Create Droplet"**
5. Wait ~60 seconds for creation
6. **Copy the IP address** (e.g., `164.90.123.45`)

### Step 2: Connect via SSH

```bash
ssh root@YOUR_VM_IP
```

### Step 3: Deploy Application

```bash
# Clone the repository
git clone https://github.com/Tphambolio/burnpthreeplus.git
cd burnpthreeplus

# Switch to the correct branch
git checkout claude/initialize-burnp3-project-011CUPExpoSehx8oTKgwTVd6

# Run deployment script
bash deploy-vm.sh
```

**That's it!** The script will:
- Install Docker/Docker Compose if needed
- Build all containers
- Start all services
- Show you the URLs to access

### Step 4: Access Your Application

Open in your browser:

- **Frontend**: `http://YOUR_VM_IP:3000`
- **Backend API Docs**: `http://YOUR_VM_IP:8000/docs`
- **Backend Health**: `http://YOUR_VM_IP:8000/api/v1/health`
- **Celery Flower (Job Monitor)**: `http://YOUR_VM_IP:5555`
- **MinIO Console (File Storage)**: `http://YOUR_VM_IP:9001`

---

## Option 2: AWS EC2

### Cost: ~$10-15/month (t3.small instance)

### Step 1: Launch EC2 Instance

1. Go to AWS Console → EC2 → **"Launch Instance"**
2. Choose:
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance Type**: t3.small (2 vCPU, 2GB RAM)
   - **Security Group**: Allow ports 22, 80, 3000, 8000, 5555
3. Launch and download the `.pem` key file

### Step 2: Connect

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

### Step 3: Install Docker

```bash
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```

Log out and back in, then:

```bash
git clone https://github.com/Tphambolio/burnpthreeplus.git
cd burnpthreeplus
git checkout claude/initialize-burnp3-project-011CUPExpoSehx8oTKgwTVd6
docker-compose up -d
```

---

## Option 3: Fly.io (Modern, Auto-SSL)

### Cost: ~$5-10/month

Fly.io automatically handles:
- SSL certificates (HTTPS)
- Custom domains
- Health checks
- Auto-restarts

### Step 1: Install Fly CLI

```bash
curl -L https://fly.io/install.sh | sh
```

### Step 2: Login and Deploy

```bash
flyctl auth login
flyctl launch
flyctl deploy
```

Fly.io will:
- Detect your `docker-compose.yml`
- Build and deploy everything
- Give you a URL like `https://burnp3-plus.fly.dev`

---

## What Gets Deployed?

When you run `docker-compose up`, you get:

| Service | Port | Description |
|---------|------|-------------|
| **Frontend** | 3000 | React app with Leaflet maps |
| **Backend** | 8000 | FastAPI REST API |
| **PostgreSQL** | 5432 | Database with PostGIS |
| **Redis** | 6379 | Cache and job queue |
| **MinIO** | 9000/9001 | S3-compatible file storage |
| **Celery Worker** | - | Background job processor |
| **Flower** | 5555 | Celery monitoring UI |

**All services are networked together automatically.**

---

## Useful Commands

### View logs
```bash
docker-compose logs -f
```

### View logs for specific service
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Restart all services
```bash
docker-compose restart
```

### Stop everything
```bash
docker-compose down
```

### Update code and restart
```bash
git pull origin claude/initialize-burnp3-project-011CUPExpoSehx8oTKgwTVd6
docker-compose up -d --build
```

### Check service status
```bash
docker-compose ps
```

### Access database directly
```bash
docker-compose exec db psql -U burnp3 -d burnp3
```

---

## Troubleshooting

### Services won't start
```bash
# Check logs
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose up -d --build
```

### Can't access from browser
```bash
# Check if ports are open
sudo ufw allow 3000
sudo ufw allow 8000
sudo ufw allow 5555

# Or disable firewall temporarily
sudo ufw disable
```

### Database connection errors
```bash
# Wait for database to be ready
docker-compose up -d db
sleep 10
docker-compose up -d
```

### Out of disk space
```bash
# Clean up old images and containers
docker system prune -a
```

---

## Production Hardening (Optional)

### 1. Use Nginx Reverse Proxy

Uncomment the nginx service in `docker-compose.yml`:

```bash
docker-compose --profile production up -d
```

Now access everything through port 80:
- Frontend: `http://YOUR_IP/`
- Backend: `http://YOUR_IP/api/`

### 2. Add SSL Certificate

Install Certbot:
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

### 3. Set Up Domain Name

1. Buy domain (Namecheap, Google Domains, etc.)
2. Point A record to your VM IP
3. Update environment variables:
   ```bash
   # In docker-compose.yml
   VITE_API_URL: https://api.yourdomain.com
   ```

### 4. Enable Automatic Backups

```bash
# Backup script
docker-compose exec db pg_dump -U burnp3 burnp3 > backup.sql

# Add to crontab (daily backup at 2am)
crontab -e
0 2 * * * cd /root/burnpthreeplus && docker-compose exec -T db pg_dump -U burnp3 burnp3 > backup-$(date +\%Y\%m\%d).sql
```

---

## Cost Comparison

| Platform | Monthly Cost | Complexity | Control |
|----------|-------------|------------|---------|
| **DigitalOcean Droplet** | $12 | Low | Full |
| **AWS EC2 (t3.small)** | $15 | Medium | Full |
| **Fly.io** | $5-10 | Very Low | Medium |
| **Railway + Vercel** | $10-20 | High | Limited |
| **Heroku** | $25+ | Low | Limited |

**Recommendation**: Start with DigitalOcean for best balance of simplicity and control.

---

## Next Steps After Deployment

1. **Test the application**
   - Register a user at `http://YOUR_IP:3000`
   - Create a scenario
   - Check API docs at `http://YOUR_IP:8000/docs`

2. **Monitor services**
   - Check Flower at `http://YOUR_IP:5555`
   - View logs: `docker-compose logs -f`

3. **Secure your VM**
   - Set up SSH key authentication only
   - Configure firewall (ufw)
   - Enable automatic security updates

4. **Set up domain and SSL** (optional)
   - Point domain to your IP
   - Use Certbot for free SSL

5. **Configure backups**
   - Set up automated database backups
   - Backup to S3 or similar

---

## Support

- **Repository**: https://github.com/Tphambolio/burnpthreeplus
- **Documentation**: `/docs` folder in repository
- **Issues**: Create GitHub issue for bugs

---

## Summary

**Deploying to a VM is the simplest approach** because:
- Everything runs together
- No platform-specific quirks
- Easy to debug and maintain
- Complete control over the environment
- Works exactly like running locally

**Total time from zero to live application: ~10 minutes**
