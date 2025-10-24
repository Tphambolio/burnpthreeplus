#!/bin/bash

# BurnP3+ VM Deployment Script
# This script deploys the entire BurnP3+ application to a VM with Docker

set -e  # Exit on any error

echo "🔥 BurnP3+ VM Deployment Script"
echo "================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo "✅ Docker installed"
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found. Installing..."
    apt-get update
    apt-get install -y docker-compose-plugin
    echo "✅ Docker Compose installed"
fi

echo ""
echo "📦 Pulling latest code from GitHub..."
git pull origin claude/initialize-burnp3-project-011CUPExpoSehx8oTKgwTVd6

echo ""
echo "🔨 Building Docker images..."
docker-compose build

echo ""
echo "🚀 Starting all services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "🌐 Access your application:"
echo "   Frontend:  http://$(curl -s ifconfig.me):3000"
echo "   Backend:   http://$(curl -s ifconfig.me):8000"
echo "   API Docs:  http://$(curl -s ifconfig.me):8000/docs"
echo "   Flower:    http://$(curl -s ifconfig.me):5555"
echo ""
echo "📝 Useful commands:"
echo "   View logs:        docker-compose logs -f"
echo "   Stop services:    docker-compose down"
echo "   Restart:          docker-compose restart"
echo "   Update & restart: git pull && docker-compose up -d --build"
echo ""
