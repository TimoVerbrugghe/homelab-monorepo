import voluptuous as vol
from homeassistant import config_entries

class KubeAssistantConfigFlow(config_entries.ConfigFlow, domain="kubeassistant"):
    async def async_step_user(self, user_input=None):
        errors = {}
        if user_input is not None:
            return self.async_create_entry(title="KubeAssistant", data=user_input)
        return self.async_show_form(
            step_id="user",
            data_schema=vol.Schema({
                vol.Required("kubeconfig"): str,
            }),
            errors=errors,
        )