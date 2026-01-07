#!/bin/bash

echo "🚀 Starting BUT TC Skills Hub..."

# Start Backend with RELOAD
echo "📡 Starting Backend (FastAPI) on http://localhost:8000..."
cd apps/api
if [ ! -d "venv" ]; then
    python3 -m venv venv
    ./venv/bin/pip install -r requirements.txt
fi
./venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!

# Start Frontend
echo "💻 Starting Frontend (React) on http://localhost:5173..."
cd ../web
npm run dev &
FRONTEND_PID=$!

echo "✅ Both services are starting."
echo "Login: admin / Rangetachambre76*"
echo "Press Ctrl+C to stop both."

trap "kill $BACKEND_PID $FRONTEND_PID" EXIT
wait