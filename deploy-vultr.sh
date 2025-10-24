#!/bin/bash

# BurnP3+ Vultr Deployment Script
# Deploys BurnP3+ application to a Vultr VM instance

set -e  # Exit on any error

echo "🔥 BurnP3+ Vultr Deployment Script"
echo "===================================="
echo ""

# Check if API key is provided
if [ -z "$VULTR_API_KEY" ]; then
    echo "❌ Error: VULTR_API_KEY environment variable is not set"
    echo "Usage: VULTR_API_KEY=your_api_key ./deploy-vultr.sh"
    exit 1
fi

# Vultr API endpoint
API_URL="https://api.vultr.com/v2"

echo "📡 Testing Vultr API connection..."
ACCOUNT_INFO=$(curl -s -H "Authorization: Bearer $VULTR_API_KEY" "$API_URL/account")
if echo "$ACCOUNT_INFO" | grep -q "invalid"; then
    echo "❌ Invalid API key"
    exit 1
fi
echo "✅ API connection successful"
echo ""

# Get available regions
echo "📍 Fetching available regions..."
REGIONS=$(curl -s -H "Authorization: Bearer $VULTR_API_KEY" "$API_URL/regions")
echo "Available regions fetched"
echo ""

# Use a default region (you can change this)
REGION="ewr"  # New Jersey
echo "🌎 Selected region: $REGION (New Jersey)"
echo ""

# Get available plans
echo "💰 Fetching available plans..."
PLANS=$(curl -s -H "Authorization: Bearer $VULTR_API_KEY" "$API_URL/plans")

# Find a suitable plan (2GB RAM, ~$12/month - plan ID: vc2-2c-4gb)
PLAN="vc2-2c-4gb"
echo "📦 Selected plan: $PLAN (2 vCPU, 4GB RAM, 80GB SSD)"
echo ""

# Get OS image for Ubuntu 22.04
echo "🐧 Fetching OS images..."
OS_ID=1743  # Ubuntu 22.04 LTS

# Create startup script
STARTUP_SCRIPT=$(cat << 'EOF'
#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose plugin
apt-get install -y docker-compose-plugin

# Clone repository
cd /root
git clone https://github.com/Tphambolio/burnpthreeplus.git
cd burnpthreeplus

# Checkout the correct branch
git checkout claude/review-burnp3-deployment-011CURBzS2gzJ65GThTRVova || git checkout main

# Start the application
docker compose up -d --build

# Wait for services to start
sleep 15

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me)

# Create a status file
cat > /root/deployment-status.txt << STATUS
🔥 BurnP3+ Deployment Complete!

🌐 Access URLs:
   Frontend:  http://${PUBLIC_IP}:3000
   Backend:   http://${PUBLIC_IP}:8000
   API Docs:  http://${PUBLIC_IP}:8000/docs
   Flower:    http://${PUBLIC_IP}:5555
   MinIO:     http://${PUBLIC_IP}:9001

📝 Useful commands:
   View logs:        cd /root/burnpthreeplus && docker compose logs -f
   Stop services:    cd /root/burnpthreeplus && docker compose down
   Restart:          cd /root/burnpthreeplus && docker compose restart
   Update & restart: cd /root/burnpthreeplus && git pull && docker compose up -d --build

STATUS

echo "Deployment complete! Check /root/deployment-status.txt for details."
EOF
)

# Base64 encode the startup script
STARTUP_SCRIPT_B64=$(echo "$STARTUP_SCRIPT" | base64 -w 0)

echo "🚀 Creating Vultr instance..."
INSTANCE_RESPONSE=$(curl -s -X POST "$API_URL/instances" \
  -H "Authorization: Bearer $VULTR_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"region\": \"$REGION\",
    \"plan\": \"$PLAN\",
    \"os_id\": $OS_ID,
    \"label\": \"burnp3-plus\",
    \"hostname\": \"burnp3-plus\",
    \"enable_ipv6\": false,
    \"backups\": \"disabled\",
    \"user_data\": \"$STARTUP_SCRIPT_B64\",
    \"tags\": [\"burnp3\", \"production\"]
  }")

# Extract instance ID and IP
INSTANCE_ID=$(echo "$INSTANCE_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$INSTANCE_ID" ]; then
    echo "❌ Failed to create instance"
    echo "Response: $INSTANCE_RESPONSE"
    exit 1
fi

echo "✅ Instance created successfully!"
echo "Instance ID: $INSTANCE_ID"
echo ""

echo "⏳ Waiting for instance to be active and get IP address..."
for i in {1..60}; do
    sleep 5
    INSTANCE_INFO=$(curl -s -H "Authorization: Bearer $VULTR_API_KEY" "$API_URL/instances/$INSTANCE_ID")
    STATUS=$(echo "$INSTANCE_INFO" | grep -o '"status":"[^"]*' | head -1 | cut -d'"' -f4)
    MAIN_IP=$(echo "$INSTANCE_INFO" | grep -o '"main_ip":"[^"]*' | head -1 | cut -d'"' -f4)

    if [ "$STATUS" = "active" ] && [ ! -z "$MAIN_IP" ] && [ "$MAIN_IP" != "0.0.0.0" ]; then
        echo "✅ Instance is active!"
        echo "IP Address: $MAIN_IP"
        break
    fi

    echo "Status: $STATUS, IP: $MAIN_IP (attempt $i/60)"
done

if [ -z "$MAIN_IP" ] || [ "$MAIN_IP" = "0.0.0.0" ]; then
    echo "❌ Failed to get instance IP address"
    exit 1
fi

echo ""
echo "⏳ Waiting for instance to finish initialization (this may take 5-10 minutes)..."
echo "The instance is installing Docker and deploying the application..."
echo ""

# Wait for SSH to be available
echo "Waiting for SSH to be ready..."
for i in {1..30}; do
    if nc -z -w 5 "$MAIN_IP" 22 2>/dev/null; then
        echo "✅ SSH is ready"
        break
    fi
    sleep 10
    echo "Waiting for SSH... (attempt $i/30)"
done

echo ""
echo "✅ Deployment initiated successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 BurnP3+ Instance Created on Vultr!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Instance Details:"
echo "   Instance ID: $INSTANCE_ID"
echo "   IP Address:  $MAIN_IP"
echo "   Region:      $REGION"
echo "   Plan:        $PLAN"
echo ""
echo "⏳ Application deployment in progress..."
echo "   The startup script is installing Docker and deploying BurnP3+."
echo "   This process takes approximately 5-10 minutes."
echo ""
echo "🌐 Your application will be available at:"
echo "   Frontend:  http://$MAIN_IP:3000"
echo "   Backend:   http://$MAIN_IP:8000"
echo "   API Docs:  http://$MAIN_IP:8000/docs"
echo "   Flower:    http://$MAIN_IP:5555"
echo "   MinIO:     http://$MAIN_IP:9001"
echo ""
echo "🔐 SSH Access:"
echo "   ssh root@$MAIN_IP"
echo "   (Use the password from Vultr dashboard)"
echo ""
echo "📝 Check deployment status:"
echo "   ssh root@$MAIN_IP 'tail -f /var/log/cloud-init-output.log'"
echo ""
echo "📊 View application logs:"
echo "   ssh root@$MAIN_IP 'cd /root/burnpthreeplus && docker compose logs -f'"
echo ""
echo "💡 Tip: Check Vultr dashboard for the root password"
echo "   https://my.vultr.com/subs/?SUBID=$INSTANCE_ID"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Save instance info to file
cat > vultr-instance-info.txt << INFO
BurnP3+ Vultr Instance Information
===================================

Instance ID: $INSTANCE_ID
IP Address:  $MAIN_IP
Region:      $REGION
Plan:        $PLAN
Created:     $(date)

Access URLs:
  Frontend:  http://$MAIN_IP:3000
  Backend:   http://$MAIN_IP:8000
  API Docs:  http://$MAIN_IP:8000/docs
  Flower:    http://$MAIN_IP:5555
  MinIO:     http://$MAIN_IP:9001

SSH Access:
  ssh root@$MAIN_IP

Management:
  Vultr Dashboard: https://my.vultr.com/subs/?SUBID=$INSTANCE_ID

Useful Commands:
  # Delete instance
  curl -X DELETE "https://api.vultr.com/v2/instances/$INSTANCE_ID" \\
    -H "Authorization: Bearer \$VULTR_API_KEY"

  # Get instance info
  curl -H "Authorization: Bearer \$VULTR_API_KEY" \\
    "https://api.vultr.com/v2/instances/$INSTANCE_ID"
INFO

echo "💾 Instance information saved to: vultr-instance-info.txt"
echo ""
