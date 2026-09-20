if [ ! -f /etc/letsencrypt/cloudflare.cfg ]; then
  mv /tmp/cloudflare.cfg /etc/letsencrypt/cloudflare.cfg
  echo "Moved cloudflare config to /etc/letsencrypt/"
fi
if [[ ! -d "/etc/letsencrypt/live/$CERTBOT_CERT_NAME" || "$CERTBOT_FORCED" = "1" ]]; then
    echo "Generating TLS certificate.."
    #nginx -c /tmp/nginx-certbot.conf
    #certbot certonly --non-interactive --agree-tos --cert-name $CERTBOT_CERT_NAME -m $CERTBOT_MAIL -d $CERTBOT_DOMAIN_1 --webroot -w /var/www/certbot
    certbot certonly --non-interactive --agree-tos --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.cfg \
                     --cert-name $CERTBOT_CERT_NAME -m $CERTBOT_MAIL -d $CERTBOT_DOMAIN_1 
    #nginx -s stop
    sleep 5s
else 
  echo "TLS certificates were found"
fi
if [ ! -f /etc/letsencrypt/dhparam.pem ]; then
  mv /tmp/dhparam.pem /etc/letsencrypt/dhparam.pem
  echo "Moved DH private key to /etc/letsencrypt/dhparam.pem"
fi
if [[ ! -f /etc/nginx/conf.d/default.conf ]]; then
  :
else
  rm /etc/nginx/conf.d/default.conf
  echo "removed default.conf"
fi
echo "Webserver has been setup successfully, starting server..."
nginx -g 'daemon off;'
#crond -f
