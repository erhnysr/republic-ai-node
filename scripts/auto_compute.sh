#!/bin/bash

# Republic AI Auto Compute Script
# Automatically checks for jobs and executes them

echo "🚀 Republic AI Auto Compute Script"
echo "=================================="

VALIDATOR="raivaloper1xnjkyyggaz54288vtrsle9wjwqz5tz4lttk8ka"
NODE="tcp://localhost:43657"

while true; do
    echo "⏰ $(date): Checking for new jobs..."
    
    # Check for assigned jobs
    JOBS=$(republicd query computevalidation list-job --node $NODE --output json 2>/dev/null | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    my_val='$VALIDATOR'
    pending = [j for j in d.get('jobs', []) if j.get('target_validator') == my_val and j.get('status') == 'PendingExecution']
    for job in pending:
        print(job['id'])
except:
    pass
")
    
    if [ -n "$JOBS" ]; then
        for JOB_ID in $JOBS; do
            echo "✅ Found job: $JOB_ID - Executing..."
            # Job sidecar will handle execution
        done
    else
        echo "⏳ No pending jobs"
    fi
    
    # Check every 30 seconds
    sleep 30
done
