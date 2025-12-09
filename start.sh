#!/bin/bash

echo "[Validator] Starting the validator service..."

lock_file="/tmp/app.lock"

touch $lock_file

if [ -f $lock_file ]; then

    PID=$(cat /tmp/app.lock)
    if ps -p "$PID" > /dev/null ; then
        echo "[ERROR] app is running"

        pkill -9 $PID

    fi
fi


# Ensure .env exists
if [ ! -f .env ]; then
    echo "[ERROR] Missing .env file. Please run setup.sh first."
    exit 1
fi

# Run orchestrator logic
echo "[Validator] Starting Orchestrator..."
npm start &

echo $! > $lock_file

