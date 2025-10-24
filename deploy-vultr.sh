#!/bin/bash

# BurnP3+ Vultr Automated Deployment Script
# This script automatically provisions a Vultr VM and deploys BurnP3+

set -e  # Exit on any error

echo "🔥 BurnP3+ Vultr Automated Deployment"
echo "====================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
VULTR_API_KEY="${VULTR_API_KEY}"
PLAN_ID="vc2-1c-1gb"  # 1 CPU, 1GB RAM - $6/month (you can change this)
REGION="ewr"           # New York - change to your preferred region
OS_ID="1743"           # Ubuntu 22.04 x64
LABEL="burnp3-production"
HOSTNAME="burnp3.local"
SSH_KEY_NAME="burnp3-deploy-key"

# Check if API key is set
if [ -z "$VULTR_API_KEY" ]; then
    echo -e "${RED}❌ Error: VULTR_API_KEY environment variable not set${NC}"
    echo ""
    echo "Please set your Vultr API key:"
    echo "  export VULTR_API_KEY='your-api-key-here'"
    echo ""
    echo "Or create a .env file with:"
    echo "  VULTR_API_KEY=your-api-key-here"
    echo ""
    exit 1
fi

# Function to make Vultr API calls
vultr_api() {
    local endpoint=$1
    local method=${2:-GET}
    local data=${3:-}

    if [ -n "$data" ]; then
        curl -s -X "$method" \
            "https://api.vultr.com/v2/${endpoint}" \
            -H "Authorization: Bearer ${VULTR_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "$data"
    else
        curl -s -X "$method" \
            "https://api.vultr.com/v2/${endpoint}" \
            -H "Authorization: Bearer ${VULTR_API_KEY}"
    fi
}

echo "📋 Step 1: Checking Vultr API connection..."
account_info=$(vultr_api "account")
if echo "$account_info" | grep -q "account"; then
    echo -e "${GREEN}✅ Connected to Vultr API${NC}"
else
    echo -e "${RED}❌ Failed to connect to Vultr API${NC}"
    echo "Response: $account_info"
    exit 1
fi

echo ""
echo "🔑 Step 2: Setting up SSH key..."

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/burnp3_deploy ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/burnp3_deploy -N "" -C "burnp3-deploy"
    echo -e "${GREEN}✅ Generated new SSH key${NC}"
else
    echo -e "${YELLOW}⚠️  SSH key already exists, using existing key${NC}"
fi

# Get public key content
SSH_KEY_CONTENT=$(cat ~/.ssh/burnp3_deploy.pub)

# Upload SSH key to Vultr
echo "Uploading SSH key to Vultr..."
ssh_key_response=$(vultr_api "ssh-keys" "POST" "{\"name\":\"${SSH_KEY_NAME}\",\"ssh_key\":\"${SSH_KEY_CONTENT}\"}")
SSH_KEY_ID=$(echo "$ssh_key_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$SSH_KEY_ID" ]; then
    # Key might already exist, try to get it
    existing_keys=$(vultr_api "ssh-keys")
    SSH_KEY_ID=$(echo "$existing_keys" | grep -B2 "$SSH_KEY_NAME" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
fi

if [ -n "$SSH_KEY_ID" ]; then
    echo -e "${GREEN}✅ SSH key uploaded (ID: ${SSH_KEY_ID})${NC}"
else
    echo -e "${YELLOW}⚠️  Could not upload SSH key, continuing without it${NC}"
fi

echo ""
echo "🌍 Step 3: Available Vultr regions:"
echo ""
echo "Common regions:"
echo "  ewr  - New York (NJ)"
echo "  ord  - Chicago"
echo "  dfw  - Dallas"
echo "  sea  - Seattle"
echo "  lax  - Los Angeles"
echo "  atl  - Atlanta"
echo "  lhr  - London"
echo "  fra  - Frankfurt"
echo "  ams  - Amsterdam"
echo "  sgp  - Singapore"
echo "  syd  - Sydney"
echo ""
echo "Using region: ${REGION}"
echo ""

echo "💻 Step 4: Available Vultr plans:"
echo ""
echo "  vc2-1c-1gb    - 1 CPU,  1GB RAM,  25GB SSD - \$6/month   (minimum)"
echo "  vc2-1c-2gb    - 1 CPU,  2GB RAM,  55GB SSD - \$12/month  (recommended)"
echo "  vc2-2c-4gb    - 2 CPU,  4GB RAM,  80GB SSD - \$24/month  (optimal)"
echo "  vc2-4c-8gb    - 4 CPU,  8GB RAM, 160GB SSD - \$48/month  (heavy load)"
echo ""
echo "Using plan: ${PLAN_ID}"
echo ""

read -p "Continue with this configuration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

echo ""
echo "🚀 Step 5: Creating Vultr instance..."

# Prepare instance creation data
instance_data="{
    \"region\":\"${REGION}\",
    \"plan\":\"${PLAN_ID}\",
    \"os_id\":${OS_ID},
    \"label\":\"${LABEL}\",
    \"hostname\":\"${HOSTNAME}\",
    \"enable_ipv6\":true,
    \"backups\":\"disabled\",
    \"ddos_protection\":false,
    \"activation_email\":false"

if [ -n "$SSH_KEY_ID" ]; then
    instance_data="${instance_data},\"sshkey_id\":[\"${SSH_KEY_ID}\"]"
fi

instance_data="${instance_data}}"

# Create the instance
create_response=$(vultr_api "instances" "POST" "$instance_data")
INSTANCE_ID=$(echo "$create_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$INSTANCE_ID" ]; then
    echo -e "${RED}❌ Failed to create instance${NC}"
    echo "Response: $create_response"
    exit 1
fi

echo -e "${GREEN}✅ Instance created (ID: ${INSTANCE_ID})${NC}"

echo ""
echo "⏳ Step 6: Waiting for instance to be ready..."
echo "This may take 2-3 minutes..."

# Wait for instance to be active
max_attempts=60
attempt=0
while [ $attempt -lt $max_attempts ]; do
    instance_info=$(vultr_api "instances/${INSTANCE_ID}")
    status=$(echo "$instance_info" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ "$status" = "active" ]; then
        echo -e "${GREEN}✅ Instance is active!${NC}"
        break
    fi

    echo -n "."
    sleep 5
    ((attempt++))
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "${RED}❌ Timeout waiting for instance to become active${NC}"
    exit 1
fi

# Get instance IP address
INSTANCE_IP=$(echo "$instance_info" | grep -o '"main_ip":"[^"]*"' | head -1 | cut -d'"' -f4)
echo ""
echo -e "${GREEN}Instance IP: ${INSTANCE_IP}${NC}"

echo ""
echo "⏳ Step 7: Waiting for SSH to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if ssh -i ~/.ssh/burnp3_deploy -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@${INSTANCE_IP} "echo 'SSH ready'" 2>/dev/null; then
        echo -e "${GREEN}✅ SSH is ready!${NC}"
        break
    fi
    echo -n "."
    sleep 10
    ((attempt++))
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "${RED}❌ Timeout waiting for SSH${NC}"
    echo "You may need to wait a bit longer and connect manually:"
    echo "  ssh -i ~/.ssh/burnp3_deploy root@${INSTANCE_IP}"
    exit 1
fi

echo ""
echo "📦 Step 8: Installing Docker and dependencies..."

ssh -i ~/.ssh/burnp3_deploy -o StrictHostKeyChecking=no root@${INSTANCE_IP} << 'ENDSSH'
    # Update system
    apt-get update
    apt-get upgrade -y

    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh

    # Install Docker Compose
    apt-get install -y docker-compose-plugin

    # Install git
    apt-get install -y git

    echo "✅ Docker and dependencies installed"
ENDSSH

echo -e "${GREEN}✅ Docker installed${NC}"

echo ""
echo "🔥 Step 9: Deploying BurnP3+ application..."

ssh -i ~/.ssh/burnp3_deploy -o StrictHostKeyChecking=no root@${INSTANCE_IP} << 'ENDSSH'
    # Clone repository
    git clone https://github.com/Tphambolio/burnpthreeplus.git
    cd burnpthreeplus

    # Checkout the correct branch
    git checkout claude/vultr-deployment-setup-011CURAy4ie4xo17LwA7xvhG

    # Make deploy script executable
    chmod +x deploy-vm.sh

    # Run deployment
    ./deploy-vm.sh
ENDSSH

echo -e "${GREEN}✅ Application deployed!${NC}"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🎉 Deployment Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Instance Details:"
echo "  Instance ID: ${INSTANCE_ID}"
echo "  IP Address:  ${INSTANCE_IP}"
echo "  SSH Key:     ~/.ssh/burnp3_deploy"
echo ""
echo "🌐 Access Your Application:"
echo "  Frontend:   http://${INSTANCE_IP}:3000"
echo "  Backend:    http://${INSTANCE_IP}:8000"
echo "  API Docs:   http://${INSTANCE_IP}:8000/docs"
echo "  Flower:     http://${INSTANCE_IP}:5555"
echo "  MinIO:      http://${INSTANCE_IP}:9001"
echo ""
echo "🔑 SSH Access:"
echo "  ssh -i ~/.ssh/burnp3_deploy root@${INSTANCE_IP}"
echo ""
echo "📝 Useful Commands (run on VM):"
echo "  cd burnpthreeplus"
echo "  docker-compose logs -f              # View logs"
echo "  docker-compose ps                   # Check status"
echo "  docker-compose restart              # Restart services"
echo "  docker-compose down                 # Stop services"
echo "  git pull && docker-compose up -d --build  # Update app"
echo ""
echo "💰 Monthly Cost: ~\$6-12 (depending on plan selected)"
echo ""
echo "🗑️  To delete this instance:"
echo "  curl -X DELETE \\"
echo "    'https://api.vultr.com/v2/instances/${INSTANCE_ID}' \\"
echo "    -H 'Authorization: Bearer \$VULTR_API_KEY'"
echo ""
echo "═══════════════════════════════════════════════════════════"
