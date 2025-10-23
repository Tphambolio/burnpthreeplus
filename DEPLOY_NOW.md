# 🚀 Deploy BurnP3+ Right Now (1 Click)

## Option 1: Railway One-Click Deploy

**This will deploy everything automatically - backend, database, and Redis!**

### Click this button:

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/burnp3)

**OR manually**:

1. Go to: https://railway.app/new/template/burnp3
2. Click "Deploy Now"
3. Login with GitHub
4. Click "Deploy"
5. ✅ Done! Railway deploys everything automatically

**What happens automatically:**
- ✅ Creates PostgreSQL database
- ✅ Creates Redis instance
- ✅ Deploys backend API
- ✅ Runs database migrations
- ✅ Links everything together
- ✅ Gives you a live URL

**Time: 2 minutes**

---

## Option 2: Manual Railway Deploy (Still Easy)

If the button doesn't work, here's the manual process:

### Step 1: Deploy to Railway
1. Go to: https://railway.app
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose `burnpthreeplus`
5. Railway auto-detects and deploys!

### Step 2: Add Services
In your Railway project:
1. Click "New" → "Database" → "PostgreSQL"
2. Click "New" → "Database" → "Redis"

### Step 3: Configure Backend
1. Click on your backend service
2. Settings → Variables → Add:
   ```
   ENVIRONMENT=production
   SECRET_KEY=your-random-32-character-string-here
   CORS_ORIGINS=["*"]
   ```
3. Settings → Root Directory: `backend`
4. Settings → Start Command:
   ```
   alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT
   ```

**Time: 5 minutes**

---

## Frontend Deploy (Vercel)

### Option 1: One-Click Vercel Deploy

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/Tphambolio/burnpthreeplus&project-name=burnp3-frontend&root-directory=frontend)

### Option 2: Manual Vercel Deploy

1. Go to: https://vercel.com
2. Click "Add New" → "Project"
3. Import `burnpthreeplus`
4. Configure:
   - Root Directory: `frontend`
   - Framework: Vite
   - Build Command: `pnpm install && pnpm build`
5. Add Environment Variable:
   - Name: `VITE_API_URL`
   - Value: `https://your-backend.up.railway.app` (get from Railway)
6. Click "Deploy"

**Time: 3 minutes**

---

## After Deployment

### 1. Get Your URLs

**Railway Backend URL**:
- Go to your Railway backend service
- Click "Settings" → "Domains"
- Copy the Railway-provided URL (e.g., `https://burnp3-production.up.railway.app`)

**Vercel Frontend URL**:
- Vercel shows it after deployment (e.g., `https://burnp3.vercel.app`)

### 2. Update CORS

1. Go to Railway backend
2. Variables → Update `CORS_ORIGINS`:
   ```
   ["https://burnp3.vercel.app", "https://burnp3-production.vercel.app"]
   ```
3. Save (auto-redeploys)

### 3. Enable PostGIS (One Time)

Railway PostgreSQL needs PostGIS extension:

**Option A: Railway Dashboard**
1. Click on PostgreSQL service
2. Click "Connect"
3. Use "psql" connection string
4. Run: `CREATE EXTENSION IF NOT EXISTS postgis;`

**Option B: CLI** (if you have psql installed)
```bash
# Get connection string from Railway
psql [your-railway-db-url]
CREATE EXTENSION IF NOT EXISTS postgis;
\q
```

### 4. Test Your Deployment

Open in browser:
- **Frontend**: Your Vercel URL
- **API Docs**: `https://your-railway-url.up.railway.app/api/v1/docs`
- **Health Check**: `https://your-railway-url.up.railway.app/health`

---

## 🎉 You're Live!

Your BurnP3+ application is now running online and accessible worldwide!

**Frontend**: https://burnp3.vercel.app
**Backend**: https://burnp3-backend.railway.app
**API Docs**: https://burnp3-backend.railway.app/api/v1/docs

---

## Next Steps

1. **Test the API** - Use the Swagger docs to create users and scenarios
2. **Share the URL** - Anyone can access your wildfire modeling platform
3. **Monitor** - Check Railway/Vercel dashboards for logs and metrics
4. **Develop More** - Push to GitHub and it auto-deploys!

---

## Troubleshooting

**Backend won't start?**
- Check Railway logs
- Verify environment variables are set
- Check PostgreSQL is connected

**CORS errors?**
- Update CORS_ORIGINS to include your Vercel URL
- Redeploy backend

**Database connection failed?**
- Enable PostGIS extension (see above)
- Check DATABASE_URL is set (Railway does this automatically)

---

## Cost: $0/month

Everything runs on free tiers:
- Railway: $5 credit/month (enough for this app)
- Vercel: Free tier (100GB bandwidth)
- No credit card required initially

---

**Need help?** Check the logs in Railway/Vercel dashboards or see DEPLOYMENT.md for detailed troubleshooting.
