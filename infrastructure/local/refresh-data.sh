#!/bin/bash
set -e

echo "🔄 Refreshing Data (API Rebuild + Seeding)..."

# 1. Rebuild API (to include updated JSON)
echo "🔨 Rebuilding API container..."
docker-compose build api

# 2. Restart API
echo "🚀 Restarting API..."
docker-compose up -d api

# 3. Wait for API to be ready
echo "⏳ Waiting for API to start..."
sleep 5

# 4. Run Seeding
echo "🌱 Seeding Database..."
docker exec but_tc_api python -m app.seed_db

echo "✅ Data Refresh Complete!"
