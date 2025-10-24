# Deploy Official SyncroSim BurnP3+ on Windows Server VM

**Complete guide to deploying the official SyncroSim BurnP3+ desktop application on a cloud VM with GUI access.**

---

## 🎯 What You're Deploying

This guide shows you how to deploy the **OFFICIAL** SyncroSim BurnP3+ application:
- ✅ SyncroSim Studio (Windows GUI application)
- ✅ BurnP3+ package
- ✅ BurnP3+Cell2Fire package
- ✅ BurnP3+Prometheus package (optional)
- ✅ Full desktop environment with remote access

**This is NOT the web application** - this is the desktop software described in the official BurnP3+ documentation.

---

## 📋 Prerequisites

### What You Need:
1. **Cloud Platform Account** (choose one):
   - AWS account (free tier available)
   - DigitalOcean account (recommended - easiest)
   - Azure account
   - Google Cloud account

2. **Credit card** (for VM billing)

3. **Remote Desktop Client**:
   - Windows: Built-in (Remote Desktop Connection)
   - Mac: Download Microsoft Remote Desktop from App Store
   - Linux: Install Remmina (`sudo apt install remmina`)

---

## 🚀 Option 1: DigitalOcean Windows Droplet (Recommended - Easiest)

### Cost: ~$48/month (4GB RAM, 80GB SSD)
**Why DigitalOcean?** Simplest setup, built-in console access, easy to use.

### Step 1: Create Windows Droplet

1. **Sign up/Login** to DigitalOcean: https://www.digitalocean.com/

2. **Create a new Droplet**:
   - Click **"Create"** → **"Droplets"**

3. **Choose Configuration**:
   - **Image**:
     - Go to **"Marketplace"** tab
     - Search for **"Windows Server 2022"** or **"Windows Server 2019"**
     - Select it

   - **Plan**:
     - Regular (Basic)
     - **$48/month** - 4GB RAM / 2 CPUs / 80GB SSD
     - (SyncroSim needs at least 4GB RAM)

   - **Datacenter Region**:
     - Choose closest to you

   - **Authentication**:
     - Password (you'll set this)
     - Create a strong password (save it!)

4. **Create Droplet**
   - Wait ~3-5 minutes for creation

5. **Get Your IP Address**:
   - Copy the IP address shown (e.g., `157.230.123.45`)

### Step 2: Connect via Remote Desktop

**On Windows:**
```
1. Press Windows key + R
2. Type: mstsc
3. Enter IP address: 157.230.123.45
4. Username: Administrator
5. Password: [your password]
6. Click "Connect"
```

**On Mac:**
```
1. Open Microsoft Remote Desktop
2. Click "Add PC"
3. PC name: 157.230.123.45
4. User account: Administrator
5. Password: [your password]
6. Click "Connect"
```

**On Linux:**
```bash
remmina
# Add new connection
# Protocol: RDP
# Server: 157.230.123.45
# Username: Administrator
# Password: [your password]
# Connect
```

### Step 3: Install SyncroSim and BurnP3+ (Automated)

Once connected to your Windows Server desktop:

1. **Open PowerShell as Administrator**:
   - Right-click Start menu → "Windows PowerShell (Admin)"

2. **Download and run installation script**:

```powershell
# Download installation script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Tphambolio/burnpthreeplus/claude/build-github-repo-011CUR4jhPBfMF6cQSwa1X4K/scripts/install-syncrosim-burnp3.ps1" -OutFile "install-syncrosim.ps1"

# Run installation script
.\install-syncrosim.ps1
```

**The script will automatically:**
- ✅ Install SyncroSim 3.0.9+
- ✅ Install Miniconda
- ✅ Install BurnP3+ package
- ✅ Install BurnP3+Cell2Fire package
- ✅ Create conda environment
- ✅ Create desktop shortcuts

**Installation time: ~15-20 minutes**

### Step 4: Launch SyncroSim Studio

After installation completes:

1. **Double-click** "SyncroSim Studio" icon on desktop
2. **Verify installation**:
   - Go to **File** → **Local Packages**
   - You should see:
     - ✅ burnP3Plus (with checkmark)
     - ✅ burnP3PlusCell2Fire (with checkmark)

### Step 5: Follow Official Tutorial

Now follow the official BurnP3+ tutorial:
https://burnp3.github.io/BurnP3Plus/getting_started.html

Starting from **Step 2: Opening a BurnP3+ library**

All the GUI steps from the official documentation will work exactly as described!

---

## 🚀 Option 2: AWS EC2 Windows Server (More Control)

### Cost: ~$30-50/month (t3.medium instance)

### Step 1: Launch Windows EC2 Instance

1. **Login to AWS Console**: https://console.aws.amazon.com/

2. **Go to EC2**:
   - Services → EC2 → Launch Instance

3. **Configure Instance**:

   **Name**: `SyncroSim-BurnP3Plus`

   **AMI (Operating System)**:
   - Click "Browse more AMIs"
   - Search for: "Windows Server 2022 Base"
   - Select **Microsoft Windows Server 2022 Base**

   **Instance Type**:
   - Select **t3.medium** (2 vCPU, 4GB RAM)
   - Minimum for SyncroSim

   **Key Pair**:
   - Create new key pair
   - Name: `syncrosim-key`
   - Type: RSA
   - Format: .pem (for Windows/Mac/Linux)
   - **Download and save the .pem file**

   **Network Settings**:
   - Allow RDP traffic from "My IP" (for security)
   - Or "Anywhere" (0.0.0.0/0) if you'll access from different locations

   **Storage**:
   - 50 GB GP3 SSD (minimum)

4. **Launch Instance**
   - Wait ~5 minutes for instance to start

5. **Get Windows Password**:
   - Select your instance
   - Click **"Connect"** → **"RDP client"** tab
   - Click **"Get password"**
   - Upload your .pem key file
   - Click **"Decrypt password"**
   - **Save the password!**

6. **Download RDP File**:
   - Click **"Download remote desktop file"**

### Step 2: Connect via RDP

**Double-click the downloaded .rdp file**
- Username: Administrator
- Password: [decrypted password]
- Click "Connect"

### Step 3: Install SyncroSim and BurnP3+

Follow the same PowerShell script instructions from Option 1, Step 3.

---

## 🚀 Option 3: Azure Windows VM

### Step 1: Create Windows VM

1. **Login to Azure Portal**: https://portal.azure.com/

2. **Create Virtual Machine**:
   - Click **"Create a resource"** → **"Virtual Machine"**

3. **Configure**:
   - **Image**: Windows Server 2022 Datacenter
   - **Size**: Standard_B2s (2 vCPUs, 4GB RAM)
   - **Username**: azureuser (or your choice)
   - **Password**: [create strong password]
   - **Public inbound ports**: Allow RDP (3389)

4. **Create** and wait for deployment

5. **Connect**:
   - Click **"Connect"** → **"RDP"**
   - Download RDP file
   - Connect with your credentials

### Step 2: Install SyncroSim

Follow PowerShell script from Option 1, Step 3.

---

## 📦 Manual Installation (If Script Fails)

If the automated script doesn't work, here's the manual process:

### 1. Download SyncroSim

In your Windows Server, open browser and go to:
https://syncrosim.com/download/

Click **"Download SyncroSim for Windows"**

### 2. Install SyncroSim

1. Run the downloaded installer
2. Accept defaults
3. Click through installation wizard
4. Launch SyncroSim Studio when done

### 3. Install BurnP3+ Package

1. Open **SyncroSim Studio**
2. Go to **File** → **Local Packages...**
3. Click **"Install from Server..."**
4. Select **"burnP3Plus"** checkbox
5. Click **OK**
6. **If prompted to install Miniconda**: Click **Yes**
7. **If prompted to create conda environment**: Click **Yes**
8. Wait for installation (~10-15 minutes)

### 4. Install BurnP3+Cell2Fire

1. Click **"Install from Server..."** again
2. Select **"burnP3PlusCell2Fire"** checkbox
3. Click **OK**
4. Wait for installation

### 5. Verify Installation

Check that both packages have checkmarks in the Conda column.

---

## 📥 Download Example Library

### Option A: In Windows Server Browser

1. Open browser in your Windows Server VM
2. Go to: https://syncrosim.com/cloud/
3. Search for: "Cell2Fire Example"
4. Download the `.ssimbak` file
5. Save to Desktop

### Option B: Transfer from Your Computer

1. **Windows/Mac**:
   - While in RDP session, copy file on your computer
   - Paste in RDP window (should transfer)

2. **Using DigitalOcean Console**:
   - Upload file to a cloud storage (Google Drive, Dropbox)
   - Download from within Windows Server

---

## 🔧 Post-Installation Setup

### Enable Copy/Paste Between Local and Remote

**On Windows:**
1. In Remote Desktop Connection, before connecting
2. Click "Show Options"
3. Go to "Local Resources" tab
4. Under "Clipboard", check "Clipboard"
5. Connect

**On Mac (Microsoft Remote Desktop):**
1. Edit connection
2. Under "Devices & Audio", enable "Clipboard"

### Increase Performance

1. **Disable visual effects**:
   - Right-click "This PC" → Properties
   - Advanced system settings
   - Performance → Settings
   - Select "Adjust for best performance"

2. **Disable Windows Defender** (optional, for speed):
   - Windows Security → Virus & threat protection
   - Manage settings → Turn off real-time protection

---

## 💰 Cost Comparison

| Platform | Instance Type | Monthly Cost | Best For |
|----------|--------------|--------------|----------|
| **DigitalOcean** | 4GB RAM, 2 CPU | **$48** | Easiest setup |
| **AWS EC2** | t3.medium | **$30-35** | Pay-as-you-go |
| **Azure** | Standard_B2s | **$40-50** | Enterprise users |
| **Google Cloud** | n1-standard-1 | **$35-40** | Google ecosystem |

**Money-Saving Tips:**
- Stop VM when not in use (AWS/Azure charge by hour)
- Use reserved instances for long-term (30-50% discount)
- Set up billing alerts

---

## 🔒 Security Best Practices

### 1. Use Strong Password
- Minimum 16 characters
- Mix of uppercase, lowercase, numbers, symbols

### 2. Restrict RDP Access
- Only allow your IP address
- Change RDP port from 3389 to custom port

### 3. Enable Windows Firewall
```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

### 4. Regular Updates
```powershell
# Check for Windows updates
Start-Process ms-settings:windowsupdate
```

### 5. Backup Your Work
- Regularly download your `.ssim` library files to your local computer
- Use VM snapshots (available in all platforms)

---

## 🐛 Troubleshooting

### Can't Connect via RDP

**Check:**
- Firewall allows RDP (port 3389)
- Security group allows your IP
- VM is running (not stopped)
- Using correct IP address

**Solution:**
```
# In cloud console, check:
1. Instance is "Running"
2. Security rules allow RDP from your IP
3. Public IP is correct
```

### SyncroSim Won't Install

**Error: "Installation failed"**

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Miniconda Installation Hangs

**Solution:**
1. Close SyncroSim
2. Manually download Miniconda: https://docs.conda.io/en/latest/miniconda.html
3. Install Miniconda
4. Restart SyncroSim
5. Try installing packages again

### BurnP3+ Package Not Found

**Solution:**
1. Check internet connection in VM
2. Try: File → Update Package Inventory
3. Then try installing again

### Out of Disk Space

**Solution:**
```powershell
# Clean temporary files
cleanmgr

# Or resize disk in cloud console
```

### Slow Performance

**Upgrade VM size:**
- DigitalOcean: Resize droplet to 8GB RAM
- AWS: Change to t3.large (2 vCPU, 8GB RAM)
- Azure: Change to Standard_B2ms

---

## 📚 Using SyncroSim BurnP3+

Once installed, follow the **official tutorial**:
https://burnp3.github.io/BurnP3Plus/getting_started.html

### Quick Start:

1. **Open SyncroSim Studio** (desktop icon)

2. **Download Example Library**:
   - Explore → Search "Cell2Fire Example"
   - Download `.ssimbak` file

3. **Open Library**:
   - File → Open
   - Select downloaded `.ssimbak` file

4. **Run Scenario**:
   - Right-click "Baseline Burning Hours"
   - Select "Run"
   - Wait for completion

5. **View Results**:
   - Navigate to Results panel
   - View charts and maps

All steps from the official documentation will work exactly as shown!

---

## 🔄 Workflow Tips

### Transferring Data TO VM

**Method 1: Copy/Paste (Small Files)**
- Enable clipboard sharing
- Copy on local computer
- Paste in RDP session

**Method 2: Cloud Storage (Large Files)**
- Upload to Google Drive/Dropbox on local computer
- Download from within VM

**Method 3: Direct Transfer (Advanced)**
- Use Windows file sharing
- Or set up FTP server

### Transferring Results FROM VM

**Method 1: Export Results**
- In SyncroSim: right-click results → Export
- Save to location
- Copy to local computer

**Method 2: Email**
- Attach small result files
- Email to yourself

**Method 3: Cloud Upload**
- Upload results to Google Drive from VM
- Download on local computer

---

## 📊 Performance Tuning

### For Large Simulations

1. **Increase VM Size**:
   - 8GB RAM minimum for large landscapes
   - 16GB RAM for very large simulations

2. **Enable Multiprocessing** (in SyncroSim):
   - File → Options → Multiprocessing
   - Set to: (number of CPUs - 1)

3. **Use SSD Storage**:
   - All platforms offer SSD by default
   - Ensure you selected SSD when creating VM

4. **Optimize Iterations**:
   - Start with fewer iterations for testing
   - Scale up for production runs

---

## 🎓 Learning Resources

### Official Documentation
- BurnP3+ Docs: https://burnp3.github.io/BurnP3Plus/
- SyncroSim Docs: https://docs.syncrosim.com/
- BurnP3+ GitHub: https://github.com/BurnP3/BurnP3Plus

### Tutorials
- Getting Started: https://burnp3.github.io/BurnP3Plus/getting_started.html
- Video Tutorials: Check SyncroSim YouTube channel

### Support
- SyncroSim Forums: https://syncrosim.com/forums/
- BurnP3+ GitHub Issues: https://github.com/BurnP3/BurnP3Plus/issues

---

## 📝 Summary

**What You Did:**
1. ✅ Created Windows Server VM in the cloud
2. ✅ Connected via Remote Desktop
3. ✅ Installed SyncroSim Studio (GUI)
4. ✅ Installed BurnP3+ packages
5. ✅ Ready to use official BurnP3+ exactly as documented!

**What You Can Do:**
- Run the official BurnP3+ tutorials
- Create fire risk models
- Run simulations with Cell2Fire or Prometheus
- View results in GUI
- Export data for analysis

**Cost:**
- ~$30-50/month while VM is running
- Stop VM when not in use to save money

**Access:**
- From anywhere with internet
- Any device with RDP client
- Full Windows desktop experience

---

## ✅ Next Steps

1. **Launch SyncroSim Studio** on your VM

2. **Follow Official Tutorial**:
   https://burnp3.github.io/BurnP3Plus/getting_started.html

3. **Start from Step 2** (we already did Step 1: Installation)

4. **Download Cell2Fire Example** library

5. **Run your first simulation!**

---

**Ready to get started?**

Choose your platform (DigitalOcean recommended for beginners) and follow the steps above!

**Questions?** Check the troubleshooting section or refer to official SyncroSim documentation.

**Good luck with your wildfire modeling! 🔥**
