#!/bin/bash

# BurnP3+ Fly.io Deployment Script
# This script deploys the entire BurnP3+ application to Fly.io

set -e  # Exit on any error

echo "🔥 BurnP3+ Fly.io Deployment Script"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo -e "${YELLOW}❌ Fly.io CLI not found. Installing...${NC}"
    curl -L https://fly.io/install.sh | sh

    # Add to PATH for current session
    export FLYCTL_INSTALL="$HOME/.fly"
    export PATH="$FLYCTL_INSTALL/bin:$PATH"

    echo -e "${GREEN}✅ Fly.io CLI installed${NC}"
    echo -e "${YELLOW}⚠️  You may need to restart your terminal or run: export PATH=\"\$HOME/.fly/bin:\$PATH\"${NC}"
fi

echo ""
echo "📝 Checking Fly.io authentication..."

# Check if user is logged in
if ! flyctl auth whoami &> /dev/null; then
    echo -e "${YELLOW}❌ Not logged in to Fly.io. Please log in...${NC}"
    flyctl auth login
    echo -e "${GREEN}✅ Logged in to Fly.io${NC}"
else
    echo -e "${GREEN}✅ Already logged in to Fly.io${NC}"
fi

echo ""
echo "🎯 Deployment Configuration"
echo "============================"
echo ""
read -p "Enter your preferred region (default: sea - Seattle): " REGION
REGION=${REGION:-sea}

read -p "Enter backend app name (default: burnp3-backend): " BACKEND_APP
BACKEND_APP=${BACKEND_APP:-burnp3-backend}

read -p "Enter frontend app name (default: burnp3-frontend): " FRONTEND_APP
FRONTEND_APP=${FRONTEND_APP:-burnp3-frontend}

echo ""
echo -e "${GREEN}Configuration:${NC}"
echo "  Region: $REGION"
echo "  Backend: $BACKEND_APP"
echo "  Frontend: $FRONTEND_APP"
echo ""

read -p "Continue with deployment? (y/n): " CONTINUE
if [ "$CONTINUE" != "y" ]; then
    echo "Deployment cancelled."
    exit 0
fi

# Generate a random secret key
SECRET_KEY=$(openssl rand -hex 32)

echo ""
echo "🗄️  Step 1: Setting up PostgreSQL Database"
echo "==========================================="
echo ""

# Create PostgreSQL database
echo "Creating PostgreSQL database cluster..."
if ! flyctl postgres create --name ${BACKEND_APP}-db --region ${REGION} --initial-cluster-size 1 --vm-size shared-cpu-1x --volume-size 1; then
    echo -e "${YELLOW}⚠️  Database may already exist. Continuing...${NC}"
fi

# Attach database to backend app (this will be created later)
echo ""
echo "Database created! We'll attach it to the backend after creating the app."

echo ""
echo "🔴 Step 2: Setting up Redis"
echo "============================"
echo ""

# Create Redis instance
echo "Creating Redis instance..."
if ! flyctl redis create --name ${BACKEND_APP}-redis --region ${REGION}; then
    echo -e "${YELLOW}⚠️  Redis may already exist. Continuing...${NC}"
fi

echo ""
echo "🚀 Step 3: Deploying Backend"
echo "============================="
echo ""

cd backend

# Update fly.toml with app name and region
sed -i.bak "s/app = .*/app = \"${BACKEND_APP}\"/" fly.toml
sed -i.bak "s/primary_region = .*/primary_region = \"${REGION}\"/" fly.toml
rm -f fly.toml.bak

# Create the app if it doesn't exist
if ! flyctl apps list | grep -q ${BACKEND_APP}; then
    echo "Creating backend app..."
    flyctl apps create ${BACKEND_APP}
fi

# Attach PostgreSQL database
echo "Attaching PostgreSQL database..."
flyctl postgres attach ${BACKEND_APP}-db --app ${BACKEND_APP} || echo -e "${YELLOW}⚠️  Database may already be attached${NC}"

# Get Redis connection string
REDIS_URL=$(flyctl redis status ${BACKEND_APP}-redis --json | grep -o 'redis://[^"]*' | head -1)

# Set environment variables
echo "Setting environment variables..."
flyctl secrets set \
    ENVIRONMENT=production \
    SECRET_KEY=${SECRET_KEY} \
    REDIS_URL=${REDIS_URL} \
    CORS_ORIGINS='["*"]' \
    --app ${BACKEND_APP}

echo "Deploying backend..."
flyctl deploy --app ${BACKEND_APP}

# Get backend URL
BACKEND_URL=$(flyctl info --app ${BACKEND_APP} --json | grep -o 'https://[^"]*\.fly\.dev' | head -1)

cd ..

echo ""
echo "🌐 Step 4: Deploying Frontend"
echo "=============================="
echo ""

cd frontend

# Update fly.toml with app name and region
sed -i.bak "s/app = .*/app = \"${FRONTEND_APP}\"/" fly.toml
sed -i.bak "s/primary_region = .*/primary_region = \"${REGION}\"/" fly.toml
rm -f fly.toml.bak

# Create the app if it doesn't exist
if ! flyctl apps list | grep -q ${FRONTEND_APP}; then
    echo "Creating frontend app..."
    flyctl apps create ${FRONTEND_APP}
fi

# Create .env.production file for build
cat > .env.production <<EOF
VITE_API_URL=${BACKEND_URL}
VITE_WS_URL=${BACKEND_URL/https/wss}
EOF

echo "Deploying frontend..."
flyctl deploy --app ${FRONTEND_APP}

# Get frontend URL
FRONTEND_URL=$(flyctl info --app ${FRONTEND_APP} --json | grep -o 'https://[^"]*\.fly\.dev' | head -1)

cd ..

echo ""
echo "🔧 Step 5: Updating CORS Settings"
echo "=================================="
echo ""

# Update CORS to allow frontend URL
flyctl secrets set \
    CORS_ORIGINS="[\"${FRONTEND_URL}\"]" \
    --app ${BACKEND_APP}

echo ""
echo "✅ Deployment Complete!"
echo "======================="
echo ""
echo -e "${GREEN}🌐 Your BurnP3+ application is now live!${NC}"
echo ""
echo "📍 Access URLs:"
echo "   Frontend:      ${FRONTEND_URL}"
echo "   Backend API:   ${BACKEND_URL}"
echo "   API Docs:      ${BACKEND_URL}/api/v1/docs"
echo "   Health Check:  ${BACKEND_URL}/health"
echo ""
echo "🗄️  Database & Services:"
echo "   PostgreSQL:    ${BACKEND_APP}-db"
echo "   Redis:         ${BACKEND_APP}-redis"
echo ""
echo "📝 Useful Commands:"
echo "   View backend logs:     flyctl logs --app ${BACKEND_APP}"
echo "   View frontend logs:    flyctl logs --app ${FRONTEND_APP}"
echo "   SSH to backend:        flyctl ssh console --app ${BACKEND_APP}"
echo "   Scale backend:         flyctl scale count 2 --app ${BACKEND_APP}"
echo "   Database console:      flyctl postgres connect --app ${BACKEND_APP}-db"
echo "   Redis console:         flyctl redis connect --app ${BACKEND_APP}-redis"
echo ""
echo "🔄 To redeploy after changes:"
echo "   Backend:  cd backend && flyctl deploy --app ${BACKEND_APP}"
echo "   Frontend: cd frontend && flyctl deploy --app ${FRONTEND_APP}"
echo ""
echo -e "${GREEN}🎉 Happy wildfire modeling!${NC}"
echo ""
