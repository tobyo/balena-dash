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

CALENDAR_URL="${CALENDAR_URL:-http://yearly-calendar:3000}"
BROWSER_API="${BROWSER_API:-http://browser:5011/url}"

if [ ! -z ${ENABLE_BACKLIGHT_TIMER+x} ] && [ "$ENABLE_BACKLIGHT_TIMER" -eq "1" ]
then
  (crontab -l 2>/dev/null; echo "${BACKLIGHT_ON:-0 8 * * *} /usr/src/app/backlight_on.sh") | crontab -
  (crontab -l 2>/dev/null; echo "${BACKLIGHT_OFF:-0 23 * * *} /usr/src/app/backlight_off.sh") | crontab -
fi

# Rotate the browser through the three views, one every three minutes.
(crontab -l 2>/dev/null; echo "3,12,21,30,39,48,57 * * * * curl -fsS --data \"url=$CALENDAR_URL\" $BROWSER_API") | crontab -
(crontab -l 2>/dev/null; echo "6,15,24,33,42,51 * * * * curl -fsS --data \"url=$CALENDAR_URL?view=month\" $BROWSER_API") | crontab -
(crontab -l 2>/dev/null; echo "9,18,27,36,45,54 * * * * curl -fsS --data \"url=$CALENDAR_URL?view=week\" $BROWSER_API") | crontab -

(crontab -l 2>/dev/null; echo '0 6 * * * echo "on 0" | cec-client -s -d 1') | crontab -
(crontab -l 2>/dev/null; echo '1 6 * * * echo "as" | cec-client -s -d 1') | crontab -
(crontab -l 2>/dev/null; echo '0 10 * * * echo "standby 0" | cec-client -s -d 1') | crontab -

echo "scheduler: installed crontab"
crontab -l
crond -f
