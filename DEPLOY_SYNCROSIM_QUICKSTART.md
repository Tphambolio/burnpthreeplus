# 🔥 Deploy Official SyncroSim BurnP3+ to Cloud VM - Quick Start

**Get the official BurnP3+ desktop application running on a cloud VM with GUI access in ~30 minutes.**

---

## What You're Getting

✅ **Official SyncroSim Studio** (Windows GUI application)
✅ **BurnP3+ package** installed
✅ **BurnP3+Cell2Fire package** installed
✅ **Remote desktop access** from anywhere
✅ **Cloud-based** - no local installation needed

**This is the OFFICIAL BurnP3+ from the tutorial**, not a web app!

---

## Prerequisites (5 minutes)

Choose ONE cloud platform and create an account:

| Platform | Cost/Month | Easiest For | Link |
|----------|------------|-------------|------|
| **DigitalOcean** | $48 | Beginners | https://www.digitalocean.com/ |
| **AWS** | $30-50 | Flexible pricing | https://aws.amazon.com/ |
| **Azure** | $40-50 | Microsoft users | https://portal.azure.com/ |

**Recommended: DigitalOcean** (simplest setup)

---

## Step-by-Step Deployment

### Part 1: Create Windows Server VM (10 minutes)

#### DigitalOcean (Recommended):

1. **Login** to DigitalOcean
2. **Create** → **Droplets**
3. **Select**:
   - Image: **Marketplace** → **Windows Server 2022**
   - Plan: **$48/month** (4GB RAM, 2 CPUs)
   - Datacenter: Closest to you
   - Authentication: Set a **strong password** (save it!)
4. **Create Droplet**
5. **Wait 3-5 minutes** for creation
6. **Copy IP address** (e.g., `157.230.123.45`)

#### AWS EC2:

1. **Login** to AWS Console
2. **EC2** → **Launch Instance**
3. **Configure**:
   - Name: `SyncroSim-BurnP3`
   - AMI: **Windows Server 2022 Base**
   - Instance type: **t3.medium**
   - Key pair: Create new (download .pem file)
   - Security: Allow **RDP** from your IP
   - Storage: **50 GB**
4. **Launch Instance**
5. **Get Password**:
   - Connect → RDP → Get password
   - Upload .pem file → Decrypt
   - **Save password!**

---

### Part 2: Connect via Remote Desktop (2 minutes)

**On Windows:**
```
1. Press Windows + R
2. Type: mstsc
3. Enter your VM IP: 157.230.123.45
4. Username: Administrator
5. Password: [your VM password]
6. Click "Connect"
```

**On Mac:**
```
1. Download "Microsoft Remote Desktop" from App Store
2. Add PC → Enter IP address
3. Username: Administrator
4. Password: [your VM password]
5. Connect
```

**On Linux:**
```bash
# Install Remmina if needed
sudo apt install remmina

# Open Remmina → RDP → Enter details
```

---

### Part 3: Install SyncroSim & BurnP3+ (15 minutes)

#### Option A: Automated (Recommended)

Once connected to Windows Server desktop:

1. **Open PowerShell as Admin**:
   - Right-click **Start** → **Windows PowerShell (Admin)**

2. **Download installation script**:
```powershell
# Allow script execution
Set-ExecutionPolicy Bypass -Scope Process -Force

# Download script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Tphambolio/burnpthreeplus/claude/build-github-repo-011CUR4jhPBfMF6cQSwa1X4K/scripts/install-syncrosim-burnp3.ps1" -OutFile "install.ps1"

# Run script
.\install.ps1
```

3. **Wait for installation** (~10 minutes):
   - Installs SyncroSim Studio
   - Installs Miniconda
   - Creates desktop shortcuts

4. **Launch SyncroSim Studio** (double-click desktop icon)

5. **Install BurnP3+ packages** (in SyncroSim):
   - File → Local Packages
   - Install from Server → Select **burnP3Plus** → OK
   - If prompted for Miniconda: Click **Yes**
   - If prompted for conda environment: Click **Yes**
   - Wait ~5-10 minutes
   - Repeat for **burnP3PlusCell2Fire**

#### Option B: Manual Installation

1. **Download SyncroSim**:
   - Open browser in VM
   - Go to: https://syncrosim.com/download/
   - Download "SyncroSim for Windows"
   - Run installer (accept defaults)

2. **Launch SyncroSim Studio**

3. **Install Packages**:
   - File → Local Packages
   - Install from Server → burnP3Plus → OK
   - Install from Server → burnP3PlusCell2Fire → OK

---

### Part 4: Download Example Library (3 minutes)

1. **In VM browser**, go to: https://syncrosim.com/cloud/
2. **Search**: "Cell2Fire Example"
3. **Download** the `.ssimbak` file
4. **Save** to Desktop

---

### Part 5: Run Your First Simulation! (5 minutes)

1. **Open** the downloaded file in SyncroSim Studio:
   - File → Open → Select `.ssimbak` file

2. **View** the pre-configured scenario:
   - Expand **Definitions** → **Baseline Burning Hours**

3. **Run** the simulation:
   - Right-click **Baseline Burning Hours**
   - Select **Run**
   - Wait ~2-5 minutes

4. **View Results**:
   - Double-click result scenario
   - Navigate to **Output Fire Statistics**
   - Check **Maps** tab for burn probability maps

---

## ✅ You're Done!

**What you now have:**
- ✅ Official SyncroSim BurnP3+ running in the cloud
- ✅ Access from anywhere via Remote Desktop
- ✅ Can follow official BurnP3+ tutorial exactly
- ✅ Full Windows desktop environment

---

## 🎓 Next Steps

### Follow Official Tutorial

**Full tutorial**: https://burnp3.github.io/BurnP3Plus/getting_started.html

**Start from Step 3** (we already did Steps 1-2):
- Configuring the BurnP3+ library
- Running different scenarios
- Analyzing results

### Create Your Own Models

1. **Create new library**:
   - File → New Library
   - Select burnP3PlusCell2Fire template

2. **Add your data**:
   - Fuel maps
   - Elevation data
   - Weather data
   - Fire zones

3. **Configure scenarios**

4. **Run simulations**

---

## 💰 Cost Management

**Monthly costs:**
- DigitalOcean: $48/month (4GB RAM)
- AWS: $30-50/month (t3.medium)
- Azure: $40-50/month (Standard_B2s)

**Save money:**
```
# Stop VM when not in use
# (In cloud console, stop/deallocate instance)

# AWS charges by hour when stopped: ~$0
# Azure charges by hour when deallocated: ~$0
# DigitalOcean charges full price even when stopped
```

**Billing alerts:**
- Set up in your cloud platform dashboard
- Get notified if costs exceed limit

---

## 🔒 Important: Data Backup

**Your VM can be deleted!** Always backup:

1. **Download `.ssim` library files** to your computer regularly
2. **Export results** before shutting down
3. **Take VM snapshots** (in cloud console) before major changes

---

## 🐛 Quick Troubleshooting

### Can't connect via RDP?
- Check VM is **running** (not stopped)
- Check **firewall allows RDP** from your IP
- Verify you're using correct **IP address** and **password**

### SyncroSim won't install?
- Run PowerShell **as Administrator**
- Manually download from: https://syncrosim.com/download/

### Package installation fails?
- Check **internet connection** in VM
- File → **Update Package Inventory**
- Try again

### Out of disk space?
- Run **Disk Cleanup** (cleanmgr)
- Or **resize disk** in cloud console

### Too slow?
- **Upgrade VM size** to 8GB RAM
- DigitalOcean: Resize droplet
- AWS: Change to t3.large
- Azure: Change to Standard_B2ms

---

## 📚 Resources

**Official Documentation:**
- BurnP3+ Tutorial: https://burnp3.github.io/BurnP3Plus/getting_started.html
- SyncroSim Docs: https://docs.syncrosim.com/
- BurnP3+ GitHub: https://github.com/BurnP3/BurnP3Plus

**Support:**
- SyncroSim Forums: https://syncrosim.com/forums/
- BurnP3+ Issues: https://github.com/BurnP3/BurnP3Plus/issues

**Detailed Guide:**
- See `docs/DEPLOY_SYNCROSIM_VM.md` for advanced options

---

## 📋 Summary

**What you did:**
1. ✅ Created Windows Server VM
2. ✅ Connected via Remote Desktop
3. ✅ Installed SyncroSim + BurnP3+
4. ✅ Downloaded example library
5. ✅ Ran first simulation

**Time:** ~30 minutes
**Cost:** ~$30-50/month
**Result:** Official BurnP3+ accessible from anywhere!

---

## ❓ FAQs

**Q: Can I access this from my phone/tablet?**
A: Yes! Download Microsoft Remote Desktop app for iOS/Android.

**Q: Can multiple people use the same VM?**
A: Yes, but only one at a time via RDP. Consider multiple VMs for team use.

**Q: How do I transfer large datasets?**
A: Upload to cloud storage (Google Drive, Dropbox), then download in VM.

**Q: Can I use Linux instead?**
A: Linux only has SyncroSim **Console** (no GUI). Windows Server required for GUI.

**Q: What if I want to automate simulations?**
A: Use SyncroSim Console commands or rsyncrosim (R package).

**Q: How do I shut down the VM?**
A: In cloud console, **Stop** or **Deallocate** the instance.

---

**Ready to start?** Pick your cloud platform and begin! 🚀

**Platform Signup Links:**
- DigitalOcean: https://www.digitalocean.com/
- AWS: https://aws.amazon.com/
- Azure: https://portal.azure.com/
