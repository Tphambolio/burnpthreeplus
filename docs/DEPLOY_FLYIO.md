# Deploy BurnP3+ to Fly.io

**The modern way to deploy BurnP3+ with automatic SSL, custom domains, and global edge deployment.**

---

## Why Fly.io?

✅ **Free tier available** - Great for getting started
✅ **Automatic SSL** - HTTPS out of the box
✅ **Global edge network** - Deploy close to your users
✅ **Managed databases** - PostgreSQL and Redis included
✅ **Auto-scaling** - Scale to zero when idle
✅ **Docker-native** - Use your existing Dockerfiles
✅ **Simple CLI** - Deploy with a single command

---

## Cost

### Free Tier Includes:
- Up to 3 shared-cpu-1x VMs (256MB RAM)
- 3GB persistent volume storage
- 160GB outbound data transfer

### Estimated Monthly Cost (Beyond Free Tier):
- **Development**: $0-5/month
- **Production**: $10-20/month
  - Backend VM: ~$5/month (shared-cpu-1x, 512MB)
  - Frontend VM: ~$3/month (shared-cpu-1x, 256MB)
  - PostgreSQL: ~$2/month (1GB storage)
  - Redis: ~$2/month
  - Data transfer: Usually within free tier

---

## Quick Deploy (Automated)

The fastest way to deploy - just run one script!

### Prerequisites

- Git installed
- A Fly.io account (free signup at https://fly.io)
- This repository cloned locally

### One-Command Deployment

```bash
cd burnpthreeplus
bash deploy-flyio.sh
```

**That's it!** The script will:
1. Install Fly.io CLI if needed
2. Log you in to Fly.io
3. Create PostgreSQL database
4. Create Redis instance
5. Deploy backend with all dependencies
6. Deploy frontend
7. Configure environment variables and CORS
8. Give you the URLs to access your app

**Deployment time: ~10-15 minutes**

---

## Manual Deployment (Step-by-Step)

If you prefer to understand each step or customize the deployment:

### Step 1: Install Fly.io CLI

**macOS/Linux:**
```bash
curl -L https://fly.io/install.sh | sh
```

**Windows (PowerShell):**
```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

**Add to PATH:**
```bash
export PATH="$HOME/.fly/bin:$PATH"
```

### Step 2: Login to Fly.io

```bash
flyctl auth login
```

This will open a browser window for authentication.

### Step 3: Create PostgreSQL Database

```bash
flyctl postgres create \
  --name burnp3-db \
  --region sea \
  --initial-cluster-size 1 \
  --vm-size shared-cpu-1x \
  --volume-size 1
```

**Options:**
- `--region`: Choose closest to you (`sea`, `dfw`, `lhr`, `syd`, etc.)
- `--vm-size`: Start small, scale later
- `--volume-size`: Database storage in GB

**Save the connection details** that are displayed!

### Step 4: Create Redis Instance

```bash
flyctl redis create \
  --name burnp3-redis \
  --region sea
```

Choose the same region as your database.

### Step 5: Deploy Backend

```bash
cd backend

# Create the app
flyctl apps create burnp3-backend

# Attach PostgreSQL
flyctl postgres attach burnp3-db --app burnp3-backend

# Set environment variables
flyctl secrets set \
  ENVIRONMENT=production \
  SECRET_KEY=$(openssl rand -hex 32) \
  CORS_ORIGINS='["*"]' \
  --app burnp3-backend

# Get Redis URL and set it
# First, get the Redis URL:
flyctl redis status burnp3-redis
# Then set it:
flyctl secrets set REDIS_URL="redis://your-redis-url" --app burnp3-backend

# Deploy!
flyctl deploy --app burnp3-backend
```

**Get your backend URL:**
```bash
flyctl info --app burnp3-backend
```

### Step 6: Deploy Frontend

```bash
cd ../frontend

# Create .env.production with your backend URL
cat > .env.production <<EOF
VITE_API_URL=https://burnp3-backend.fly.dev
VITE_WS_URL=wss://burnp3-backend.fly.dev
EOF

# Create the app
flyctl apps create burnp3-frontend

# Deploy!
flyctl deploy --app burnp3-frontend
```

### Step 7: Update CORS Settings

Now that you have your frontend URL, update the backend CORS:

```bash
flyctl secrets set \
  CORS_ORIGINS='["https://burnp3-frontend.fly.dev"]' \
  --app burnp3-backend
```

### Step 8: Enable PostGIS Extension

Connect to your database and enable PostGIS:

```bash
flyctl postgres connect --app burnp3-db

-- In the PostgreSQL console:
CREATE EXTENSION IF NOT EXISTS postgis;
\q
```

---

## Access Your Application

Once deployed, your app will be available at:

- **Frontend**: `https://burnp3-frontend.fly.dev`
- **Backend API**: `https://burnp3-backend.fly.dev`
- **API Docs**: `https://burnp3-backend.fly.dev/api/v1/docs`
- **Health Check**: `https://burnp3-backend.fly.dev/health`

---

## Custom Domain (Optional)

### Add Your Own Domain

```bash
# Add domain to frontend
flyctl certs add yourdomain.com --app burnp3-frontend

# Add domain to backend
flyctl certs add api.yourdomain.com --app burnp3-backend
```

### Update DNS

Add these DNS records at your domain registrar:

```
Type    Name    Value
CNAME   @       burnp3-frontend.fly.dev
CNAME   api     burnp3-backend.fly.dev
```

Fly.io automatically provisions SSL certificates!

### Update Environment Variables

```bash
# Update backend CORS
flyctl secrets set \
  CORS_ORIGINS='["https://yourdomain.com"]' \
  --app burnp3-backend

# Rebuild frontend with new API URL
cd frontend
cat > .env.production <<EOF
VITE_API_URL=https://api.yourdomain.com
VITE_WS_URL=wss://api.yourdomain.com
EOF
flyctl deploy --app burnp3-frontend
```

---

## Useful Commands

### View Logs

```bash
# Real-time backend logs
flyctl logs --app burnp3-backend

# Real-time frontend logs
flyctl logs --app burnp3-frontend

# Database logs
flyctl logs --app burnp3-db
```

### SSH into Containers

```bash
# SSH to backend
flyctl ssh console --app burnp3-backend

# SSH to database
flyctl postgres connect --app burnp3-db
```

### Scaling

```bash
# Scale backend to 2 instances
flyctl scale count 2 --app burnp3-backend

# Scale backend VM size
flyctl scale vm shared-cpu-2x --app burnp3-backend

# Scale database storage
flyctl volumes extend vol_xxx --size 10  # 10GB
```

### Monitor Resources

```bash
# Check app status
flyctl status --app burnp3-backend

# Check metrics
flyctl metrics --app burnp3-backend

# List all apps
flyctl apps list
```

### Database Management

```bash
# Connect to database
flyctl postgres connect --app burnp3-db

# Database credentials
flyctl postgres db show burnp3-db

# Create backup
flyctl postgres backup create --app burnp3-db

# List backups
flyctl postgres backup list --app burnp3-db
```

### Redis Management

```bash
# Connect to Redis
flyctl redis connect --app burnp3-redis

# Check Redis status
flyctl redis status burnp3-redis
```

---

## Continuous Deployment

### Deploy Updates

After making changes to your code:

```bash
# Deploy backend
cd backend
git pull
flyctl deploy --app burnp3-backend

# Deploy frontend
cd ../frontend
git pull
flyctl deploy --app burnp3-frontend
```

### Automated Deployments with GitHub Actions

Create `.github/workflows/deploy-flyio.yml`:

```yaml
name: Deploy to Fly.io

on:
  push:
    branches: [main]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only --app burnp3-backend
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
        working-directory: ./backend

  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only --app burnp3-frontend
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
        working-directory: ./frontend
```

Get your API token:
```bash
flyctl auth token
```

Add it to GitHub Secrets as `FLY_API_TOKEN`.

---

## Troubleshooting

### Deployment Fails

```bash
# Check deployment logs
flyctl logs --app burnp3-backend

# Check app status
flyctl status --app burnp3-backend

# Restart app
flyctl apps restart burnp3-backend
```

### Database Connection Issues

```bash
# Verify database is attached
flyctl postgres db list --app burnp3-db

# Check connection string
flyctl secrets list --app burnp3-backend

# Verify PostGIS extension
flyctl postgres connect --app burnp3-db
# Then: \dx
```

### CORS Errors

```bash
# Verify CORS settings
flyctl secrets list --app burnp3-backend

# Update CORS
flyctl secrets set CORS_ORIGINS='["https://your-frontend-url.fly.dev"]' --app burnp3-backend
```

### Out of Memory

```bash
# Scale to larger VM
flyctl scale vm shared-cpu-2x --app burnp3-backend

# Or add more memory
flyctl scale memory 1024 --app burnp3-backend
```

### Build Failures

```bash
# Clear build cache
flyctl deploy --app burnp3-backend --build-only --force-rebuild

# Check Dockerfile
flyctl deploy --app burnp3-backend --local-only
```

---

## Cost Optimization

### Auto-stop When Idle

Your `fly.toml` is already configured for this:

```toml
[http_service]
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0
```

This means:
- Apps automatically stop when inactive
- Auto-start on incoming requests
- **Save money during low-traffic periods**

### Monitor Costs

```bash
# View current usage
flyctl dashboard

# Check billing
flyctl billing show
```

### Free Tier Optimization

Stay within free tier:
- Use shared-cpu-1x VMs (smallest)
- Keep volumes under 3GB total
- Monitor data transfer
- Scale down development instances

---

## Production Hardening

### 1. Enable Health Checks

Already configured in `fly.toml`:

```toml
[[http_service.checks]]
  grace_period = "10s"
  interval = "30s"
  method = "GET"
  path = "/health"
```

### 2. Set Up Alerts

```bash
# Install Fly.io monitoring (coming soon)
# For now, use external monitoring like UptimeRobot
```

### 3. Enable Backups

```bash
# Automated daily backups
flyctl postgres backup create --app burnp3-db

# Restore from backup
flyctl postgres backup restore <backup-id> --app burnp3-db
```

### 4. Security Hardening

```bash
# Use secrets for all sensitive data
flyctl secrets set SECRET_KEY="$(openssl rand -hex 32)" --app burnp3-backend

# Never commit secrets to Git
# Use .env.production for build-time vars only

# Review security settings
flyctl secrets list --app burnp3-backend
```

### 5. Use Multiple Regions

```bash
# Add a region for better global coverage
flyctl regions add dfw --app burnp3-backend  # Dallas
flyctl regions add lhr --app burnp3-backend  # London

# Scale across regions
flyctl scale count 2 --app burnp3-backend
```

---

## Comparison with Other Platforms

| Feature | Fly.io | Railway | Render | Heroku |
|---------|--------|---------|--------|--------|
| **Free Tier** | ✅ Good | ✅ $5 credit | ✅ Limited | ❌ None |
| **Auto SSL** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Global Edge** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Scale to Zero** | ✅ Yes | ❌ No | ✅ Yes | ❌ No |
| **PostgreSQL** | ✅ Managed | ✅ Managed | ✅ Managed | 💰 Paid add-on |
| **Redis** | ✅ Managed | ✅ Managed | ✅ Managed | 💰 Paid add-on |
| **Docker Native** | ✅ Yes | ✅ Yes | ⚠️ Limited | ❌ Buildpacks |
| **CLI Quality** | ✅ Excellent | ✅ Good | ✅ Good | ⚠️ Outdated |
| **Pricing** | 💰 $5-20/mo | 💰 $10-20/mo | 💰 $7-20/mo | 💰 $25+/mo |

**Verdict**: Fly.io is best for Docker-native apps needing global edge deployment.

---

## Support & Resources

- **Fly.io Documentation**: https://fly.io/docs
- **Fly.io Community**: https://community.fly.io
- **Status Page**: https://status.flyio.net
- **Pricing Calculator**: https://fly.io/docs/about/pricing/

---

## Summary

**Deploying to Fly.io gives you:**

✅ Production-ready infrastructure
✅ Automatic SSL certificates
✅ Global edge deployment
✅ Managed databases (PostgreSQL + Redis)
✅ Auto-scaling and auto-stop
✅ Simple CLI workflow
✅ Affordable pricing

**Total time from zero to production: ~10 minutes**

---

## Next Steps After Deployment

1. **Test your application**
   - Visit your frontend URL
   - Check API docs at `/api/v1/docs`
   - Test the health endpoint

2. **Set up monitoring**
   - Configure UptimeRobot for uptime monitoring
   - Set up error tracking (Sentry)
   - Monitor logs with `flyctl logs`

3. **Enable backups**
   - Schedule regular database backups
   - Test restore procedures

4. **Add custom domain** (optional)
   - Configure DNS
   - Let Fly.io provision SSL

5. **Set up CI/CD**
   - Enable GitHub Actions
   - Automated deployments on push

---

**Ready to deploy?** Run `bash deploy-flyio.sh` to get started!
