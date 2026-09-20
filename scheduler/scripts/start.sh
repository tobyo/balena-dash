#!/bin/bash

if [ ! -z ${ENABLE_BACKLIGHT_TIMER+x} ] && [ "$ENABLE_BACKLIGHT_TIMER" -eq "1" ]
then
  (crontab -l; echo "${BACKLIGHT_ON:-0 8 * * *} /usr/src/backlight_on.sh") | crontab -
  (crontab -l; echo "${BACKLIGHT_OFF:-0 23 * * *} /usr/src/backlight_off.sh") | crontab -
fi
(crontab -l; echo '3,12,21,30,39,48,57 * * * * curl --data "url=yearly-calendar:3000" http://browser:5011/url') | crontab -
(crontab -l; echo '6,15,24,33,42,51 * * * * curl --data "url=yearly-calendar:3000?view=month" http://browser:5011/url') | crontab -
(crontab -l; echo '9,18,27,36,45,54 * * * * curl --data "url=yearly-calendar:3000?view=week" http://browser:5011/url') | crontab -
(crontab -l; echo '0 6 * * * echo "on 0" | cec-client -s -d 1') | crontab -
(crontab -l; echo '1 6 * * * echo "as" | cec-client -s -d 1') | crontab -
(crontab -l; echo '0 10 * * * echo "standby 0" | cec-client -s -d 1') | crontab -
crond -f
