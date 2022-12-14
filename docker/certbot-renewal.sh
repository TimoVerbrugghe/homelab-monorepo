docker run --rm \
    --name certbot \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    certbot/dns-cloudflare \
    certonly --non-interactive --keep-until-expiring -m timo@hotmail.be --agree-tos --no-eff-email \
    --dns-cloudflare --dns-cloudflare-propagation-seconds 20 --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
    --cert-name dns.timo.be -d dns.timo.be