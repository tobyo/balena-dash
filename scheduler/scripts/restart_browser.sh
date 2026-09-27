#!/bin/bash
# Restart the browser service through the balena Supervisor API. cron runs
# jobs with an almost empty environment, so the Supervisor details come from
# the file start.sh writes at boot rather than from the container env.
. /usr/src/app/supervisor.env

echo "scheduler: restarting browser service"
curl -fsS -X POST -H "Content-Type: application/json" \
  -d '{"serviceName":"browser"}' \
  "$BALENA_SUPERVISOR_ADDRESS/v2/applications/$BALENA_APP_ID/restart-service?apikey=$BALENA_SUPERVISOR_API_KEY"
