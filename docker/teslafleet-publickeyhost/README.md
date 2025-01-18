# Tesla Fleet Public Key Host

This folder contains a Home Assistant addon to expose a public key at the following path:

```
/.well-known/com.tesla.3p.public-key.pem
```

## Purpose

The purpose of this addon is to provide a public key that can be accessed by Tesla services or other third-party applications. Usually combined with the home assistant tesla fleet integration (<https://www.home-assistant.io/integrations/tesla_fleet/>)

## Installation

1. Clone this repository to your Home Assistant addons folder.
2. Navigate to Settings -> Add-Ons -> Add-On Store. Click on Check For Updates.
3. Find the "Tesla Fleet Public Key Host" addon under local add-ons and click "Install".

## Usage

Once installed, fill out public key under options & start the addon. The public key will be available at:

```
http://<your-home-assistant-url>:<the-port-you-configured>/.well-known/com.tesla.3p.public-key.pem
```

## HTTPS setup
You will still need a reverse proxy with SSL enabled that points to http://<your-home-assistant-ip>:<the-port-you-configured>/. I personally use cloudflare tunnels or you could use traefik/nginx proxy manager.

## License

This project is licensed under the MIT License.