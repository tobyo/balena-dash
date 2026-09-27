#!/bin/bash

# cron reads local time, so the zone has to be applied before any schedule
# is installed. TZ is a balena env var; without it everything fires on UTC.
if [ -n "${TZ:-}" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
  cp "/usr/share/zoneinfo/$TZ" /etc/localtime
  echo "$TZ" > /etc/timezone
  echo "scheduler: timezone $TZ, local time now $(date)"
else
  echo "scheduler: TZ unset or unknown ('${TZ:-}'), schedules will run on UTC"
fi

if [ ! -z ${ENABLE_BACKLIGHT_TIMER+x} ] && [ "$ENABLE_BACKLIGHT_TIMER" -eq "1" ]
then
  (crontab -l 2>/dev/null; echo "${BACKLIGHT_ON:-0 8 * * *} /usr/src/app/backlight_on.sh") | crontab -
  (crontab -l 2>/dev/null; echo "${BACKLIGHT_OFF:-0 23 * * *} /usr/src/app/backlight_off.sh") | crontab -
fi

# Nightly browser restart, to clear whatever Chromium accumulates over a day.
# Needs the io.balena.features.supervisor-api label on this service.
if [ -n "${BALENA_SUPERVISOR_ADDRESS:-}" ] && [ -n "${BALENA_SUPERVISOR_API_KEY:-}" ]; then
  (umask 077; cat > /usr/src/app/supervisor.env <<ENV
BALENA_SUPERVISOR_ADDRESS='$BALENA_SUPERVISOR_ADDRESS'
BALENA_SUPERVISOR_API_KEY='$BALENA_SUPERVISOR_API_KEY'
BALENA_APP_ID='$BALENA_APP_ID'
ENV
  )
  (crontab -l 2>/dev/null; echo "${BROWSER_RESTART:-0 3 * * *} /usr/src/app/restart_browser.sh") | crontab -
else
  echo "scheduler: Supervisor API not available, skipping nightly browser restart"
fi

(crontab -l 2>/dev/null; echo '0 6 * * * echo "on 0" | cec-client -s -d 1') | crontab -
(crontab -l 2>/dev/null; echo '1 6 * * * echo "as" | cec-client -s -d 1') | crontab -
(crontab -l 2>/dev/null; echo '0 10 * * * echo "standby 0" | cec-client -s -d 1') | crontab -

echo "scheduler: installed crontab"
crontab -l
crond -f
