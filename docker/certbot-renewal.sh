# This script is an edge job from portainer running on the router VM added as a portainer edge agent
docker run --rm \
    --name certbot \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    --dns 8.8.8.8 \
    certbot/dns-cloudflare \
    certonly --non-interactive --keep-until-expiring -m timo@hotmail.be --agree-tos --no-eff-email \
    --dns-cloudflare --dns-cloudflare-propagation-seconds 20 --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
    --cert-name dns.timo.be -d dns.timo.be