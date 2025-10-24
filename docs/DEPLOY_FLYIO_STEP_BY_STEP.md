# BurnP3+ Fly.io Deployment - Complete Step-by-Step Guide

**For absolute beginners - every single step explained!**

---

## What is Fly.io?

Fly.io is a platform that runs your application on virtual machines (VMs) around the world. Think of it like renting a computer in the cloud that runs your code 24/7.

**Key Concept**: You don't create the app in Fly.io's website. You deploy FROM YOUR COMPUTER using a command-line tool (CLI).

---

## How Deployment Works

Here's the simple flow:

```
Your Computer → Fly.io CLI → Fly.io Servers → Your App Running!
     ↓              ↓              ↓
  Code here    Sends code    Creates VMs
  (GitHub)     to Fly.io     and runs it
```

**You do NOT need to:**
- Copy/paste code into Fly.io's website
- Create apps manually in a web interface
- Upload files through a browser

**You DO need to:**
- Have the code on your computer (already done ✅)
- Install Fly.io CLI tool (script does this for you ✅)
- Run ONE command that does everything

---

## Prerequisites (What You Need First)

### 1. A Fly.io Account (Free)

**Create account FIRST:**

1. Go to https://fly.io/app/sign-up
2. Click "Sign up with GitHub" (easiest)
3. Authorize Fly.io to access your GitHub
4. Verify your email
5. **Add payment method** (required even for free tier - they won't charge you unless you exceed free limits)

✅ **You now have a Fly.io account!**

### 2. The Code on Your Computer

You already have this:
```bash
/home/user/burnpthreeplus
```

✅ **Code is ready!**

---

## The Complete Deployment Process

### Step 1: Open Your Terminal

```bash
# Navigate to your project
cd /home/user/burnpthreeplus

# Verify you're in the right place
pwd
# Should show: /home/user/burnpthreeplus

# Check the deployment script exists
ls -la deploy-flyio.sh
# Should show: -rwxr-xr-x ... deploy-flyio.sh
```

---

### Step 2: Run the Deployment Script

**Just run this ONE command:**

```bash
bash deploy-flyio.sh
```

---

### Step 3: What the Script Does (Automated)

Here's what happens when you run the script. **You just watch and answer a few questions!**

#### 3a. Install Fly.io CLI (Automatic)

```
🔥 BurnP3+ Fly.io Deployment Script
====================================

❌ Fly.io CLI not found. Installing...
✅ Fly.io CLI installed
```

**What happened**: The script downloaded and installed the `flyctl` tool (Fly.io's command-line interface).

---

#### 3b. Login to Fly.io (You Do This)

```
📝 Checking Fly.io authentication...
❌ Not logged in to Fly.io. Please log in...
```

**A browser window will open automatically.**

In the browser:
1. You'll see "Authorize Fly.io CLI?"
2. Click "**Authorize**"
3. See "Successfully logged in!"
4. **Close the browser tab**
5. Go back to your terminal

Terminal shows:
```
✅ Logged in to Fly.io
```

---

#### 3c. Choose Configuration (You Answer Questions)

```
🎯 Deployment Configuration
============================

Enter your preferred region (default: sea - Seattle):
```

**Type one of these regions** (or press Enter for Seattle):
- `sea` - Seattle, USA (West Coast)
- `dfw` - Dallas, USA (Central)
- `iad` - Virginia, USA (East Coast)
- `lhr` - London, UK
- `fra` - Frankfurt, Germany
- `syd` - Sydney, Australia
- `nrt` - Tokyo, Japan
- `gru` - São Paulo, Brazil

**Just type 3 letters and press Enter**. Example:
```
sea
```

---

Next question:
```
Enter backend app name (default: burnp3-backend):
```

**Press Enter** to use default name `burnp3-backend`, or type your own unique name.

**Note**: App names must be unique across ALL of Fly.io. If `burnp3-backend` is taken, try:
- `burnp3-backend-yourname`
- `burnp3-backend-2024`
- `your-burnp3-backend`

---

Next question:
```
Enter frontend app name (default: burnp3-frontend):
```

**Press Enter** or type a unique name like `burnp3-frontend-yourname`.

---

Configuration summary appears:
```
Configuration:
  Region: sea
  Backend: burnp3-backend
  Frontend: burnp3-frontend

Continue with deployment? (y/n):
```

**Type `y` and press Enter** to continue.

---

#### 3d. Create PostgreSQL Database (Automatic)

```
🗄️  Step 1: Setting up PostgreSQL Database
===========================================

Creating PostgreSQL database cluster...
```

**What's happening**:
- Fly.io creates a PostgreSQL database server for you
- Adds PostGIS extension for geospatial data
- Takes about 1-2 minutes

**You see**:
```
Postgres cluster burnp3-backend-db created
  Username:    postgres
  Password:    [some random password]
  Hostname:    burnp3-backend-db.internal
  Proxy port:  5432
  Postgres port: 5433
  Connection string: postgres://postgres:[password]@burnp3-backend-db.internal:5432

✅ Database created!
```

**Don't worry about copying this** - it's automatically connected to your app.

---

#### 3e. Create Redis (Automatic)

```
🔴 Step 2: Setting up Redis
============================

Creating Redis instance...
```

**What's happening**:
- Fly.io creates a Redis server for caching and background jobs
- Takes about 30 seconds

**You see**:
```
Redis instance burnp3-backend-redis created
  Connection string: redis://default:[password]@burnp3-backend-redis.internal:6379

✅ Redis created!
```

---

#### 3f. Deploy Backend (Automatic - Takes Longest)

```
🚀 Step 3: Deploying Backend
=============================

Creating backend app...
Attaching PostgreSQL database...
Setting environment variables...
Deploying backend...
```

**What's happening**:
1. Creates an app named `burnp3-backend` in Fly.io
2. Connects the PostgreSQL database to it
3. Connects the Redis to it
4. Sets environment variables (SECRET_KEY, CORS settings, etc.)
5. **Builds your Docker image** (this takes 5-10 minutes)
6. Uploads the image to Fly.io
7. Starts the backend server

**You'll see lots of output like**:
```
Building image...
[+] Building 234.5s (20/20) FINISHED
 => [builder 1/8] FROM python:3.11-slim
 => [builder 2/8] RUN apt-get update && apt-get install...
 => [builder 3/8] WORKDIR /app
 => [builder 4/8] RUN pip install poetry
 => [builder 5/8] COPY pyproject.toml ./
 => [builder 6/8] RUN poetry install...
 => [production 1/5] FROM python:3.11-slim
 => [production 2/5] COPY --from=builder...
 => exporting to image

Image published to registry
Deploying burnp3-backend
Waiting for deployment to complete...

✅ Backend deployed!
```

**This is the longest step - be patient!**

---

#### 3g. Deploy Frontend (Automatic)

```
🌐 Step 4: Deploying Frontend
==============================

Creating frontend app...
Deploying frontend...
```

**What's happening**:
1. Creates an app named `burnp3-frontend` in Fly.io
2. Builds your React app with Vite (5-7 minutes)
3. Uploads and starts the frontend server

**You see**:
```
Building image...
[+] Building 187.3s (15/15) FINISHED
 => [builder 1/7] FROM node:20-alpine
 => [builder 2/7] WORKDIR /app
 => [builder 3/7] RUN npm install -g pnpm
 => [builder 4/7] COPY package*.json ./
 => [builder 5/7] RUN pnpm install
 => [builder 6/7] COPY . .
 => [builder 7/7] RUN pnpm build
 => [production 1/3] FROM node:20-alpine
 => [production 2/3] RUN npm install -g serve
 => [production 3/3] COPY --from=builder /app/dist ./dist

Deploying burnp3-frontend
Waiting for deployment to complete...

✅ Frontend deployed!
```

---

#### 3h. Configure CORS (Automatic)

```
🔧 Step 5: Updating CORS Settings
==================================
```

**What's happening**:
- Updates backend to allow requests from your frontend URL
- Necessary for security

**You see**:
```
✅ CORS configured!
```

---

### Step 4: Deployment Complete! 🎉

```
✅ Deployment Complete!
=======================

🌐 Your BurnP3+ application is now live!

📍 Access URLs:
   Frontend:      https://burnp3-frontend.fly.dev
   Backend API:   https://burnp3-backend.fly.dev
   API Docs:      https://burnp3-backend.fly.dev/api/v1/docs
   Health Check:  https://burnp3-backend.fly.dev/health

🗄️  Database & Services:
   PostgreSQL:    burnp3-backend-db
   Redis:         burnp3-backend-redis

📝 Useful Commands:
   View backend logs:     flyctl logs --app burnp3-backend
   View frontend logs:    flyctl logs --app burnp3-frontend
   SSH to backend:        flyctl ssh console --app burnp3-backend
   Scale backend:         flyctl scale count 2 --app burnp3-backend
   Database console:      flyctl postgres connect --app burnp3-backend-db
   Redis console:         flyctl redis connect --app burnp3-backend-redis

🔄 To redeploy after changes:
   Backend:  cd backend && flyctl deploy --app burnp3-backend
   Frontend: cd frontend && flyctl deploy --app burnp3-frontend

🎉 Happy wildfire modeling!
```

**Copy your URLs** - you'll need them!

---

## Step 5: Test Your Deployment

### 5a. Test Backend Health

Open in your browser:
```
https://burnp3-backend.fly.dev/health
```

**You should see**:
```json
{
  "status": "healthy",
  "version": "0.1.0",
  "environment": "production"
}
```

✅ **Backend is working!**

---

### 5b. Test API Documentation

Open in your browser:
```
https://burnp3-backend.fly.dev/api/v1/docs
```

**You should see**:
- Swagger UI interface
- List of all API endpoints
- Interactive API testing

✅ **API docs are working!**

---

### 5c. Test Frontend

Open in your browser:
```
https://burnp3-frontend.fly.dev
```

**You should see**:
- BurnP3+ application homepage
- Map interface
- Navigation menu

✅ **Frontend is working!**

---

## What Just Happened? (Under the Hood)

Let me explain what the script did:

### 1. Code Stays on GitHub
- Your code is still in your GitHub repository
- Fly.io doesn't host your code - it hosts the RUNNING application

### 2. Docker Images Built
- The script took your code
- Built Docker images (like packages of your app + dependencies)
- Sent those images to Fly.io

### 3. Virtual Machines Created
- Fly.io created VMs (virtual computers) in their data centers
- Installed your Docker images on those VMs
- Started running your application

### 4. Databases Provisioned
- Created a PostgreSQL server with your data
- Created a Redis server for caching
- Connected them to your app

### 5. URLs Assigned
- Fly.io gave you public URLs (like burnp3-backend.fly.dev)
- Set up SSL certificates (HTTPS)
- Made your app accessible worldwide

---

## How to Update Your App

When you make code changes:

### Option 1: Redeploy Backend

```bash
cd /home/user/burnpthreeplus/backend
flyctl deploy --app burnp3-backend
```

### Option 2: Redeploy Frontend

```bash
cd /home/user/burnpthreeplus/frontend
flyctl deploy --app burnp3-frontend
```

### Option 3: Redeploy Everything

```bash
cd /home/user/burnpthreeplus
bash deploy-flyio.sh
# Answer questions the same way as before
```

---

## How to Check Logs

### Backend Logs (Real-time)

```bash
flyctl logs --app burnp3-backend
```

**You see**:
```
2024-01-20T10:30:45Z app[...] INFO:     Started server process
2024-01-20T10:30:45Z app[...] INFO:     Waiting for application startup.
2024-01-20T10:30:45Z app[...] INFO:     Application startup complete.
2024-01-20T10:30:50Z app[...] INFO:     GET /health - 200 OK
```

Press `Ctrl+C` to stop watching logs.

### Frontend Logs

```bash
flyctl logs --app burnp3-frontend
```

---

## How to SSH Into Your App

Want to look around inside the running container?

```bash
# SSH into backend
flyctl ssh console --app burnp3-backend

# You're now inside the container!
# Try these commands:
ls -la               # List files
pwd                  # Show current directory
python --version     # Check Python version
exit                 # Leave SSH session
```

---

## How to Check Database

```bash
# Connect to PostgreSQL
flyctl postgres connect --app burnp3-backend-db

# You're now in the PostgreSQL console
# Try these commands:
\dt                  # List tables
\dx                  # List extensions (should see PostGIS)
\q                   # Quit
```

---

## How to Scale Your App

### Add More Instances (More Power)

```bash
# Run 2 backend instances instead of 1
flyctl scale count 2 --app burnp3-backend
```

### Upgrade VM Size (More Memory)

```bash
# Upgrade to 1GB RAM (from 512MB)
flyctl scale vm shared-cpu-2x --app burnp3-backend
```

### Scale Down (Save Money)

```bash
# Back to 1 instance
flyctl scale count 1 --app burnp3-backend
```

---

## Common Issues & Solutions

### Issue 1: "App name already taken"

**Error**:
```
Error: app name 'burnp3-backend' is already taken
```

**Solution**: Choose a unique name when the script asks:
```
Enter backend app name: burnp3-backend-yourname
Enter frontend app name: burnp3-frontend-yourname
```

---

### Issue 2: "Payment method required"

**Error**:
```
Error: Payment method required
```

**Solution**:
1. Go to https://fly.io/dashboard
2. Click your profile → "Billing"
3. Add a credit card (they won't charge for free tier usage)
4. Run the script again

---

### Issue 3: "Build failed"

**Error**:
```
Error: failed to build image
```

**Solution**:
```bash
# Check if you're in the right directory
pwd
# Should be: /home/user/burnpthreeplus

# Check if Dockerfiles exist
ls -la backend/Dockerfile
ls -la frontend/Dockerfile

# Try deploying again
bash deploy-flyio.sh
```

---

### Issue 4: "Not enough resources"

**Error**:
```
Error: not enough resources on free tier
```

**Solution**: You might have other apps on Fly.io. Delete unused ones:
```bash
# List all your apps
flyctl apps list

# Delete an app you don't need
flyctl apps destroy old-app-name
```

---

### Issue 5: Frontend can't connect to backend

**Symptom**: Frontend loads but API calls fail

**Solution**:
```bash
# Check CORS settings
flyctl secrets list --app burnp3-backend

# Update CORS with your frontend URL
flyctl secrets set CORS_ORIGINS='["https://burnp3-frontend.fly.dev"]' --app burnp3-backend
```

---

## Cost Breakdown

### Free Tier Includes:
- 3 shared-cpu-1x VMs (256MB RAM each)
- 3GB total persistent volumes
- 160GB outbound data transfer

### What You're Using:
- Backend: 1 VM (512MB) - **~$5/month** (or free if you scale to 256MB)
- Frontend: 1 VM (256MB) - **Free**
- PostgreSQL: 1GB storage - **~$2/month** (or free if under limit)
- Redis: Small instance - **~$2/month** (or free if under limit)

### How to Stay Free:
```bash
# Scale backend to 256MB
flyctl scale memory 256 --app burnp3-backend

# Enable auto-stop (already configured in fly.toml)
# Your app stops when idle and starts when someone visits
```

**Estimated cost with auto-stop**: **$0-5/month**

---

## Quick Reference Commands

```bash
# View all your apps
flyctl apps list

# Check app status
flyctl status --app burnp3-backend

# View real-time logs
flyctl logs --app burnp3-backend

# SSH into app
flyctl ssh console --app burnp3-backend

# Connect to database
flyctl postgres connect --app burnp3-backend-db

# Connect to Redis
flyctl redis connect --app burnp3-backend-redis

# Scale app
flyctl scale count 2 --app burnp3-backend

# Check billing
flyctl billing show

# Deploy updates
cd backend && flyctl deploy --app burnp3-backend
cd frontend && flyctl deploy --app burnp3-frontend

# Destroy app (careful!)
flyctl apps destroy burnp3-backend
```

---

## Summary

**The entire process is**:

1. ✅ Create Fly.io account (one-time, 5 minutes)
2. ✅ Run `bash deploy-flyio.sh` (automated, 15 minutes)
3. ✅ Answer 3 simple questions (region, app names)
4. ✅ Wait for deployment to complete
5. ✅ Visit your URLs and use your app!

**You do NOT**:
- Manually create apps in Fly.io dashboard
- Copy/paste code anywhere
- Configure servers manually
- Set up databases manually

**The script does EVERYTHING for you!**

---

## Next Steps

1. **Bookmark your URLs**
   - Frontend: `https://burnp3-frontend.fly.dev`
   - API Docs: `https://burnp3-backend.fly.dev/api/v1/docs`

2. **Test the application**
   - Create a user account
   - Upload some data
   - Run a simulation

3. **Monitor your app**
   - Check logs regularly: `flyctl logs --app burnp3-backend`
   - Watch for errors
   - Monitor costs in Fly.io dashboard

4. **Make it your own** (optional)
   - Add custom domain
   - Set up monitoring alerts
   - Enable CI/CD for auto-deployment

---

**Ready to deploy?**

```bash
cd /home/user/burnpthreeplus
bash deploy-flyio.sh
```

**Questions during deployment?**
- Check this guide
- Read the on-screen instructions
- The script tells you what it's doing at each step

**Good luck! 🚀**
