# Epic Games Free Games Auto-Claimer

Kubernetes deployment for [epicgames-freegames-node](https://github.com/claabs/epicgames-freegames-node) - automatically claims weekly free games from the Epic Games Store.

## Features

- Automatically claims free games on a schedule (every 6 hours by default)
- Notifications via Pushover when action is needed (e.g., captcha solving)
- Web portal for captcha solving at port 3000
- Persistent storage for cookies and configuration

## Setup

### 1. Configure Secrets

Copy the template file and fill in your values:

```bash
cp epicgames-freegames-secrets.env.template epicgames-freegames-secrets.env
```

Edit `epicgames-freegames-secrets.env` with:
- `base_url`: The public URL for the captcha solving web portal
- `epic_email`: Your Epic Games account email
- `pushover_token`: Your Pushover application token (get from https://pushover.net/apps/build)
- `pushover_user_id`: Your Pushover user key (get from https://pushover.net/)

### 2. Adjust Configuration (Optional)

The `config.json.template` file contains the JSON configuration that will be injected into the container. You can modify:
- `cronSchedule`: When to check for free games (default: 0, 6, 12, 18 hours)
- `logLevel`: Logging verbosity (info, debug, trace)
- `searchStrategy`: How to find games (weekly, promotion, all)

### 3. Deploy

```bash
kubectl apply -k .
```

### 4. Access the Web Portal

You'll need to expose the service (port 3000) via an Ingress or port-forward to access the captcha solving interface when needed.

Example port-forward:
```bash
kubectl port-forward -n utilities svc/epicgames-freegames 3000:3000
```

## How It Works

1. The application runs on a cron schedule (default: every 6 hours)
2. It checks for new free games on the Epic Games Store
3. If a game is found, it attempts to claim it automatically
4. If a captcha or manual action is needed, you'll receive a Pushover notification
5. Click the notification link to access the web portal and complete the action
6. The application stores cookies in persistent storage to maintain your session

## Notifications

This deployment is configured to use **Pushover only** for notifications. When the application needs your attention (e.g., to solve a captcha), you'll receive a push notification with a link to the web portal.

## Troubleshooting

Check the logs:
```bash
kubectl logs -n utilities -l app.kubernetes.io/name=epicgames-freegames -f
```

Check the config:
```bash
kubectl get configmap -n utilities epicgames-freegames-config -o yaml
```

## Resources

- [GitHub Repository](https://github.com/claabs/epicgames-freegames-node)
- [Configuration Documentation](https://claabs.github.io/epicgames-freegames-node/classes/AppConfig.html)
