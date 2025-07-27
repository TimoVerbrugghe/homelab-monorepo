from kubernetes import config, client
from homeassistant.core import HomeAssistant

DOMAIN = "kubeassistant"

async def async_setup_entry(hass: HomeAssistant, entry):
    kubeconfig = entry.data["kubeconfig"]
    config.load_kube_config(config_file=kubeconfig)
    v1 = client.CoreV1Api()
    apps_v1 = client.AppsV1Api()
    batch_v1 = client.BatchV1Api()
    networking_v1 = client.NetworkingV1Api()

    # Store API clients for use in sensors
    hass.data[DOMAIN] = {
        "v1": v1,
        "apps_v1": apps_v1,
        "batch_v1": batch_v1,
        "networking_v1": networking_v1,
    }

    hass.async_create_task(
        hass.config_entries.async_forward_entry_setup(entry, "sensor")
    )
    return True