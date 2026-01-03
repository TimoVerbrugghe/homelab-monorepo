# Tesla Fleet Public Key Host

This folder contains a Home Assistant addon to expose a public key at the following path:

```text
https://<yourdomain>/.well-known/appspecific/com.tesla.3p.public-key.pem
```

## Purpose

The purpose of this addon is to host a public key that can be accessed by Tesla services. Usually combined with the Home Assistant Tesla Fleet
Integration at <https://www.home-assistant.io/integrations/tesla_fleet/> (see first step "Hosting Public & Private Key").

## Installation

1. Add this repository to Home Assistant by clicking the button on the home page of this repo.
2. Navigate to Settings -> Add-Ons -> Add-On Store. Click on Check For Updates.
3. Find the "Tesla Fleet Public Key Host" addon under local add-ons and click "Install".
4. Generate a public/private key pair using instructions at <https://www.home-assistant.io/integrations/tesla_fleet/> and put the public key
   (named `com.tesla.3p.public-key.pem`) in the `/config` folder.

## Usage

Once set up as described above, start the addon. The public key will be available at:

```text
http://<your-home-assistant-url>:<the-port-you-configured>/.well-known/appspecific/com.tesla.3p.public-key.pem
```

## HTTPS setup

You will still need a reverse proxy with SSL enabled that points to `http://<your-home-assistant-ip>:<the-port-you-configured>/`.
I personally use cloudflare tunnels or you could use traefik/nginx proxy manager.
