# 🚀 Quick Start - Deploy BurnP3+ Online in 10 Minutes

**No local installation needed - everything runs in the cloud!**

---

## Step 1: Deploy Backend (5 minutes)

### Option A: Railway (Easiest)

1. Go to https://railway.app and sign up with GitHub
2. Click "New Project" → "Deploy from GitHub repo"
3. Select `burnpthreeplus` repository
4. Railway will detect and deploy automatically
5. Add PostgreSQL: Click "New" → "PostgreSQL"
6. Add Redis: Click "New" → "Redis"
7. Set environment variables in Railway dashboard:
   ```
   ENVIRONMENT=production
   SECRET_KEY=your-random-32-char-string
   CORS_ORIGINS=["*"]
   ```
8. Your backend is live! Copy the URL (e.g., `https://burnp3-production.up.railway.app`)

### Option B: Render

1. Go to https://render.com and sign up with GitHub
2. New → Web Service
3. Connect your `burnpthreeplus` repository
4. Settings:
   - Root Directory: `backend`
   - Build: `pip install poetry && poetry install --no-dev`
   - Start: `alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Add PostgreSQL: New → PostgreSQL
6. Add Redis: New → Redis
7. Copy your backend URL

---

## Step 2: Deploy Frontend (3 minutes)

1. Go to https://vercel.com and sign up with GitHub
2. Click "Add New..." → "Project"
3. Import your `burnpthreeplus` repository
4. Configure:
   - Framework: Vite
   - Root Directory: `frontend`
   - Build Command: `pnpm install && pnpm build`
5. Add environment variable:
   ```
   VITE_API_URL=https://your-backend-url.com
   ```
6. Click "Deploy"
7. Your frontend is live! (e.g., `https://burnp3.vercel.app`)

---

## Step 3: Update CORS (1 minute)

1. Go back to your backend (Railway or Render)
2. Update environment variable:
   ```
   CORS_ORIGINS=["https://your-frontend.vercel.app"]
   ```
3. Redeploy backend

---

## Step 4: Test Your App (1 minute)

1. Open your frontend URL: `https://your-app.vercel.app`
2. Open API docs: `https://your-backend-url.com/api/v1/docs`
3. Register a user and start creating scenarios!

---

## 🎉 Done!

Your BurnP3+ app is now live and accessible from anywhere!

**Frontend**: https://your-app.vercel.app
**Backend API**: https://your-backend.up.railway.app
**API Docs**: https://your-backend.up.railway.app/api/v1/docs

---

## 💡 What's Next?

- Add your first wildfire scenario
- Upload spatial data (coming soon)
- Run fire simulations (coming soon)
- View burn probability maps (coming soon)

See **DEPLOYMENT.md** for detailed deployment options and configuration.

---

## ❓ Need Help?

- Can't access backend? Check Railway/Render logs
- CORS errors? Update CORS_ORIGINS with your Vercel URL
- Database issues? Verify PostgreSQL is running and PostGIS extension is enabled

See **DEPLOYMENT.md** for troubleshooting guide.
