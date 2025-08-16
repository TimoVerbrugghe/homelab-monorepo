import os
import voluptuous as vol
from homeassistant import config_entries
from homeassistant.helpers.selector import FileSelector, FileSelectorConfig
from homeassistant.util import slugify
import logging

_LOGGER = logging.getLogger(__name__)

DOMAIN = "kubeassistant"

class KubeAssistantConfigFlow(config_entries.ConfigFlow, domain=DOMAIN):
    VERSION = 1
    
    async def async_step_user(self, user_input=None):
        errors = {}
        
        if user_input is not None:
            file_id = user_input.get("kubeconfig_file")
            
            if file_id:
                # Store the file in Home Assistant's share directory
                stored_path = await self._store_kubeconfig_file(file_id)
                
                if stored_path:
                    # Save the stored path in the config entry
                    return self.async_create_entry(
                        title="KubeAssistant",
                        data={
                            "kubeconfig_stored_path": stored_path
                        }
                    )
                else:
                    errors["base"] = "file_storage_failed"

        return self.async_show_form(
            step_id="user",
            data_schema=vol.Schema({
                vol.Required("kubeconfig_file"): FileSelector(
                    FileSelectorConfig(accept=".yaml,.yml,.conf")
                ),
            }),
            errors=errors
        )
    
    async def _store_kubeconfig_file(self, file_id):
        """Store the uploaded kubeconfig file in the share directory."""
        try:
            # Process the uploaded file
            file_content = await self._read_uploaded_file(file_id)
            
            if not file_content:
                return None
            # Use the config directory for persistent storage
            storage_dir = self.hass.config.path(DOMAIN)
            
            # Create directory if it doesn't exist
            await self.hass.async_add_executor_job(os.makedirs, storage_dir, True)
            
            # Generate a unique filename
            entry_id = slugify(f"kubeconfig_{self.flow_id}")
            stored_filename = f"{entry_id}.yaml"
            stored_path = os.path.join(storage_dir, stored_filename)
            
            # Write the file content
            await self.hass.async_add_executor_job(
                self._write_file, stored_path, file_content
            )
            
            _LOGGER.info(f"Stored kubeconfig at: {stored_path}")
            return stored_path
            
        except Exception as e:
            _LOGGER.error(f"Failed to store kubeconfig file: {e}")
            return None
        
    async def _read_uploaded_file(self, file_id):
        """Read the uploaded file content."""
        try:
            # Access Home Assistant's file upload storage
            from homeassistant.helpers.storage import Store
            
            # Try to read from the uploads storage
            uploads_store = Store(self.hass, 1, f"uploads/{file_id}")
            data = await uploads_store.async_load()
            
            if data and "content" in data:
                # Decode base64 content if necessary
                import base64
                if isinstance(data["content"], str):
                    return base64.b64decode(data["content"])
                return data["content"]
            
            # Alternative: try direct file access
            upload_paths = [
                os.path.join(self.hass.config.config_dir, ".storage", "uploads", file_id),
                os.path.join(self.hass.config.config_dir, "uploads", file_id),
                file_id  # Sometimes it's already a full path
            ]
            
            for path in upload_paths:
                if os.path.exists(path):
                    with open(path, 'rb') as f:
                        return f.read()
            
            _LOGGER.error(f"Could not find uploaded file with ID: {file_id}")
            return None
            
        except Exception as e:
            _LOGGER.error(f"Failed to read uploaded file: {e}")
            return None
        
    def _write_file(self, path, content):
        """Write file content and set permissions."""
        with open(path, 'wb') as f:
            f.write(content)
        # Set appropriate permissions
        os.chmod(path, 0o600)  # Read/write for owner only