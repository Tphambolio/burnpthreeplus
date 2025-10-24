# 🚀 Deploy BurnP3+ to Fly.io in 15 Minutes

**The simplest deployment option - one command does everything!**

---

## Prerequisites (Do This First - 5 minutes)

### 1. Create Fly.io Account
1. Go to https://fly.io/app/sign-up
2. Click "Sign up with GitHub"
3. Verify your email
4. Add payment method (required for free tier, won't be charged)

✅ **Done!**

---

## Deployment (10 minutes)

### Step 1: Navigate to Project
```bash
cd /home/user/burnpthreeplus
```

### Step 2: Run Deployment Script
```bash
bash deploy-flyio.sh
```

### Step 3: Answer 3 Questions

**Question 1: Region?**
```
Enter your preferred region (default: sea - Seattle):
```
**Type**: `sea` (or your preferred region) and press Enter

**Question 2: Backend app name?**
```
Enter backend app name (default: burnp3-backend):
```
**Type**: Just press Enter (or enter unique name if default is taken)

**Question 3: Frontend app name?**
```
Enter frontend app name (default: burnp3-frontend):
```
**Type**: Just press Enter (or enter unique name if default is taken)

**Confirm deployment?**
```
Continue with deployment? (y/n):
```
**Type**: `y` and press Enter

### Step 4: Wait for Deployment

The script will now:
- ⏱️ Install Fly.io CLI (30 seconds)
- 🔐 Log you in (opens browser, click "Authorize")
- 🗄️ Create PostgreSQL database (2 minutes)
- 🔴 Create Redis (1 minute)
- 🚀 Deploy backend (5-8 minutes) ← **This takes longest**
- 🌐 Deploy frontend (3-5 minutes)
- 🔧 Configure CORS (10 seconds)

**Total time: ~12-15 minutes**

☕ **Grab a coffee while it builds!**

---

## You're Live! 🎉

When deployment completes, you'll see:

```
✅ Deployment Complete!

📍 Access URLs:
   Frontend:      https://burnp3-frontend.fly.dev
   Backend API:   https://burnp3-backend.fly.dev
   API Docs:      https://burnp3-backend.fly.dev/api/v1/docs
```

**Click the URLs to access your app!**

---

## Test Your Deployment

### 1. Check Backend Health
Visit: `https://burnp3-backend.fly.dev/health`

Should see:
```json
{"status": "healthy", "version": "0.1.0"}
```

### 2. Check API Docs
Visit: `https://burnp3-backend.fly.dev/api/v1/docs`

Should see: Interactive API documentation

### 3. Use Your App
Visit: `https://burnp3-frontend.fly.dev`

Should see: BurnP3+ application homepage

---

## What You Just Got

✅ Full-stack BurnP3+ application
✅ FastAPI backend with automatic SSL
✅ React frontend with global CDN
✅ PostgreSQL database with PostGIS
✅ Redis for caching
✅ Auto-scaling (stops when idle to save money)
✅ Health checks and monitoring
✅ Professional URLs with HTTPS

**All running in the cloud, accessible worldwide!**

---

## Common Issues

### "App name already taken"
**Solution**: When asked for app name, use a unique name:
```
burnp3-backend-yourname
burnp3-frontend-yourname
```

### "Payment method required"
**Solution**: Add credit card at https://fly.io/dashboard (won't be charged for free tier)

### "Not logged in"
**Solution**: Browser should open automatically. Click "Authorize" and return to terminal.

### "Build failed"
**Solution**:
```bash
# Make sure you're in the right directory
pwd  # Should show: /home/user/burnpthreeplus

# Run again
bash deploy-flyio.sh
```

---

## Useful Commands

```bash
# View logs (real-time)
flyctl logs --app burnp3-backend

# Check app status
flyctl status --app burnp3-backend

# SSH into backend
flyctl ssh console --app burnp3-backend

# Connect to database
flyctl postgres connect --app burnp3-backend-db

# Redeploy after code changes
cd backend && flyctl deploy --app burnp3-backend
cd frontend && flyctl deploy --app burnp3-frontend
```

---

## Cost

**Free Tier**: Covers small deployments
**Your Setup**: ~$0-5/month with auto-stop enabled
**Production**: ~$10-20/month for always-on service

**Auto-stop is enabled by default** - your app stops when idle and auto-starts when someone visits!

---

## Need More Details?

See the complete guide: `docs/DEPLOY_FLYIO_STEP_BY_STEP.md`

---

## Summary

**What you need to do**:
1. Create Fly.io account (5 min)
2. Run `bash deploy-flyio.sh` (1 command)
3. Answer 3 simple questions
4. Wait 15 minutes
5. Use your app!

**What the script does**:
- Everything else automatically!

---

## Regions Available

Common regions (choose one closest to you):
- `sea` - Seattle, USA (West Coast)
- `dfw` - Dallas, USA (Central)
- `iad` - Virginia, USA (East Coast)
- `lhr` - London, UK
- `fra` - Frankfurt, Germany
- `syd` - Sydney, Australia
- `nrt` - Tokyo, Japan
- `gru` - São Paulo, Brazil

Full list: https://fly.io/docs/reference/regions/

---

**Ready? Let's deploy!**

```bash
cd /home/user/burnpthreeplus
bash deploy-flyio.sh
```

**Good luck! 🔥**
