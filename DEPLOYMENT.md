# Online Deployment Guide

This guide will help you deploy BurnP3+ fully online using cloud services - **no local installation required**.

## 🌐 Architecture Overview

**Frontend** → Vercel (free)
**Backend API** → Railway or Render (free tier)
**Database** → Managed PostgreSQL (included with Railway/Render)
**Redis** → Managed Redis (included with Railway/Render)
**Storage** → Cloudflare R2 or AWS S3 (free tier)

---

## 🚀 Option 1: Railway + Vercel (Recommended - Easiest)

### Step 1: Deploy Backend to Railway

1. **Create Railway Account**
   - Go to https://railway.app
   - Sign up with GitHub (free)

2. **Create New Project**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your `burnpthreeplus` repository
   - Select branch: `claude/vultr-deployment-setup-011CURAy4ie4xo17LwA7xvhG`

3. **Add PostgreSQL Database**
   - In your Railway project, click "New"
   - Select "Database" → "PostgreSQL"
   - Railway will automatically set `DATABASE_URL` environment variable

4. **Add Redis**
   - Click "New" → "Database" → "Redis"
   - Railway will automatically set `REDIS_URL` environment variable

5. **Configure Backend Service**
   - Click on your backend service
   - Go to "Settings"
   - Set **Root Directory**: `backend`
   - Set **Start Command**:
     ```bash
     alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT
     ```

6. **Add Environment Variables**
   - Go to "Variables" tab
   - Add these variables:

   ```
   ENVIRONMENT=production
   SECRET_KEY=[generate a random 32-char string]
   CORS_ORIGINS=["https://your-frontend.vercel.app"]

   # Storage (use Cloudflare R2 or AWS S3)
   S3_ENDPOINT=https://your-account.r2.cloudflarestorage.com
   S3_ACCESS_KEY=[your-r2-access-key]
   S3_SECRET_KEY=[your-r2-secret-key]
   S3_BUCKET_DATA=burnp3-data
   S3_BUCKET_RESULTS=burnp3-results
   S3_REGION=auto
   ```

7. **Enable PostGIS Extension**
   - Connect to your Railway database
   - Run: `CREATE EXTENSION IF NOT EXISTS postgis;`
   - Railway provides a connection string in the database settings

8. **Deploy**
   - Railway automatically deploys on push
   - Get your backend URL: `https://your-app.up.railway.app`

### Step 2: Deploy Frontend to Vercel

1. **Create Vercel Account**
   - Go to https://vercel.com
   - Sign up with GitHub (free)

2. **Import Project**
   - Click "Add New..." → "Project"
   - Import your `burnpthreeplus` repository
   - Select branch: `claude/vultr-deployment-setup-011CURAy4ie4xo17LwA7xvhG`

3. **Configure Build Settings**
   - Framework Preset: `Vite`
   - Root Directory: `frontend`
   - Build Command: `pnpm install && pnpm build`
   - Output Directory: `dist`
   - Install Command: `pnpm install`

4. **Add Environment Variables**
   ```
   VITE_API_URL=https://your-backend.up.railway.app
   VITE_WS_URL=wss://your-backend.up.railway.app
   ```

5. **Deploy**
   - Click "Deploy"
   - Vercel will build and deploy
   - Get your URL: `https://burnp3-app.vercel.app`

### Step 3: Update CORS Settings

1. Go back to Railway backend variables
2. Update `CORS_ORIGINS` to include your Vercel URL:
   ```
   CORS_ORIGINS=["https://burnp3-app.vercel.app"]
   ```

### Step 4: Set Up Storage (Cloudflare R2 - Free)

1. **Create Cloudflare Account**
   - Go to https://cloudflare.com
   - Sign up (free)

2. **Create R2 Bucket**
   - Go to R2 Object Storage
   - Create bucket: `burnp3-data`
   - Create bucket: `burnp3-results`

3. **Generate API Token**
   - Go to "Manage R2 API Tokens"
   - Create API token with read/write permissions
   - Copy Access Key ID and Secret Access Key

4. **Update Railway Environment Variables**
   - Add the S3 credentials (shown in Step 1.6 above)

---

## 🚀 Option 2: Render + Vercel

### Step 1: Deploy Backend to Render

1. **Create Render Account**
   - Go to https://render.com
   - Sign up with GitHub (free)

2. **Create PostgreSQL Database**
   - New → PostgreSQL
   - Name: `burnp3-db`
   - Plan: Free
   - Copy the Internal Database URL

3. **Create Redis Instance**
   - New → Redis
   - Name: `burnp3-redis`
   - Plan: Free
   - Copy the Internal Redis URL

4. **Create Web Service**
   - New → Web Service
   - Connect your repository
   - Select branch: `claude/vultr-deployment-setup-011CURAy4ie4xo17LwA7xvhG`
   - Settings:
     - Name: `burnp3-backend`
     - Runtime: Python 3
     - Build Command: `cd backend && pip install poetry && poetry install --no-dev`
     - Start Command: `cd backend && alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT`
     - Plan: Free

5. **Add Environment Variables** (in Render dashboard):
   ```
   DATABASE_URL=[your-postgres-internal-url]
   REDIS_URL=[your-redis-internal-url]
   ENVIRONMENT=production
   SECRET_KEY=[random-string]
   CORS_ORIGINS=["https://your-frontend.vercel.app"]
   S3_ENDPOINT=[cloudflare-r2-endpoint]
   S3_ACCESS_KEY=[r2-access-key]
   S3_SECRET_KEY=[r2-secret-key]
   S3_BUCKET_DATA=burnp3-data
   S3_BUCKET_RESULTS=burnp3-results
   ```

6. **Deploy**
   - Click "Create Web Service"
   - Render will deploy automatically
   - Get your URL: `https://burnp3-backend.onrender.com`

7. **Enable PostGIS**
   - Connect to database and run: `CREATE EXTENSION IF NOT EXISTS postgis;`

### Step 2: Deploy Frontend to Vercel

Same as Option 1, Step 2 above.

---

## 🚀 Option 3: All on Fly.io

1. **Install Fly CLI** (or use online dashboard)
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login to Fly**
   ```bash
   fly auth login
   ```

3. **Deploy Backend**
   ```bash
   cd backend
   fly launch
   # Follow prompts, select region
   ```

4. **Add PostgreSQL**
   ```bash
   fly postgres create
   fly postgres attach [postgres-app-name]
   ```

5. **Add Redis**
   ```bash
   fly redis create
   ```

6. **Deploy Frontend**
   ```bash
   cd ../frontend
   fly launch
   ```

---

## 🔧 Post-Deployment Setup

### 1. Initialize Database

After deployment, you need to create tables:

**Option A: Using Railway/Render Dashboard**
```bash
# Connect to your database via the web terminal
CREATE EXTENSION IF NOT EXISTS postgis;
```

**Option B: Via Backend Service**
The migrations run automatically on startup (in the start command)

### 2. Test Your Deployment

```bash
# Test health endpoint
curl https://your-backend-url.com/health

# Should return:
# {"status":"healthy","version":"0.1.0","environment":"production"}
```

### 3. Create First User

```bash
# Register a user
curl -X POST https://your-backend-url.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "securepassword123",
    "full_name": "Admin User"
  }'
```

### 4. Access Your App

- **Frontend**: https://your-app.vercel.app
- **API Docs**: https://your-backend-url.com/api/v1/docs

---

## 💰 Cost Breakdown (Free Tier)

### Railway (Free Tier)
- $5 credit per month
- PostgreSQL included
- Redis included
- ~500 hours execution time

### Render (Free Tier)
- PostgreSQL: 1GB storage
- Redis: 25MB
- 750 hours/month
- Auto-sleep after 15min inactivity

### Vercel (Free Tier)
- 100GB bandwidth
- Unlimited deployments
- Automatic HTTPS
- Global CDN

### Cloudflare R2 (Free Tier)
- 10GB storage
- 1M read requests/month
- No egress fees

**Total Monthly Cost: $0** (within free tier limits)

---

## 🔐 Security Checklist

Before going live:

- [ ] Change `SECRET_KEY` to a strong random string
- [ ] Set proper `CORS_ORIGINS` (your frontend domain only)
- [ ] Enable HTTPS (automatic on Vercel/Railway/Render)
- [ ] Set up database backups
- [ ] Configure rate limiting
- [ ] Review environment variables (no secrets in code)
- [ ] Set up monitoring/alerts

---

## 📊 Monitoring Your Deployment

### Railway
- Dashboard shows logs, metrics, deployments
- Set up webhooks for alerts

### Render
- Logs available in dashboard
- Set up health check notifications

### Vercel
- Analytics dashboard
- Function logs
- Performance insights

---

## 🔄 Continuous Deployment

Both Railway and Vercel auto-deploy when you push to GitHub:

```bash
# Make changes
git add .
git commit -m "feat: add new feature"
git push

# Railway and Vercel automatically deploy!
```

---

## 🐛 Troubleshooting

### Backend won't start
- Check environment variables are set
- View logs in Railway/Render dashboard
- Verify DATABASE_URL is correct

### Database connection failed
- Ensure PostGIS extension is enabled
- Check DATABASE_URL format
- Verify database is running

### CORS errors on frontend
- Update CORS_ORIGINS in backend env vars
- Include your Vercel URL
- Redeploy backend after changing

### Storage upload fails
- Verify S3 credentials
- Check bucket names are correct
- Ensure R2 API token has write permissions

---

## 📞 Support

- **Railway**: https://railway.app/help
- **Render**: https://render.com/docs
- **Vercel**: https://vercel.com/docs
- **Cloudflare R2**: https://developers.cloudflare.com/r2/

---

## 🎉 You're Live!

Once deployed, your BurnP3+ app will be accessible worldwide at:
- Frontend: `https://your-app.vercel.app`
- API: `https://your-backend.up.railway.app`
- API Docs: `https://your-backend.up.railway.app/api/v1/docs`

**No local setup required - everything runs in the cloud!**

---

## 🚀 Quick Deploy Links

**One-Click Deploy Options:**

### Railway
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/burnp3)

### Render
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

### Vercel (Frontend)
[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/yourusername/burnpthreeplus)

---

**Next Steps**: See TESTING.md for API testing workflows with your deployed URLs!
