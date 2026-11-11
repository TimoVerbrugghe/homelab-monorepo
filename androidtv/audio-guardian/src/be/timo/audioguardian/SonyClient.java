package be.timo.audioguardian;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Base64;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

final class SonyClient {
    private final SharedPreferences preferences;

    SonyClient(Context context) {
        preferences = context.getSharedPreferences("guardian", Context.MODE_PRIVATE);
    }

    boolean isPaired() {
        return !preferences.getString("cookie", "").isEmpty();
    }

    String output() throws IOException {
        try {
            JSONArray settings = request("audio", "getSoundSettings",
                    new JSONArray().put(new JSONObject().put("target", "outputTerminal")),
                    "1.1", null).getJSONArray("result").getJSONArray(0);
            for (int i = 0; i < settings.length(); i++) {
                JSONObject setting = settings.getJSONObject(i);
                if ("outputTerminal".equals(setting.getString("target"))) {
                    return setting.getString("currentValue");
                }
            }
            throw new IOException("Sony returned no outputTerminal");
        } catch (JSONException error) {
            throw new IOException("Invalid Sony output response", error);
        }
    }

    void selectAudioSystem() throws IOException {
        try {
            request("audio", "setSoundSettings", new JSONArray().put(new JSONObject()
                    .put("settings", new JSONArray().put(new JSONObject()
                            .put("target", "outputTerminal").put("value", "audioSystem")))),
                    "1.1", null);
        } catch (JSONException error) {
            throw new IOException("Unable to encode audio selection", error);
        }
    }

    void pair(String pin) throws IOException {
        String clientId = preferences.getString("client_id", "");
        if (clientId.isEmpty()) {
            clientId = "AudioGuardian:" + UUID.randomUUID();
            if (!preferences.edit().putString("client_id", clientId).commit()) {
                throw new IOException("Unable to save pairing identity");
            }
        }
        try {
            request("accessControl", "actRegister", new JSONArray()
                    .put(new JSONObject().put("clientid", clientId)
                            .put("nickname", "Audio Guardian").put("level", "private"))
                    .put(new JSONArray().put(new JSONObject()
                            .put("function", "WOL").put("value", "yes"))),
                    "1.0", "Basic " + Base64.encodeToString(
                            (":" + pin).getBytes(StandardCharsets.UTF_8), Base64.NO_WRAP));
        } catch (JSONException error) {
            throw new IOException("Unable to encode pairing request", error);
        }
    }

    private JSONObject request(String service, String method, JSONArray parameters,
            String version, String authorization) throws IOException {
        HttpURLConnection connection = (HttpURLConnection)
                new URL("http://127.0.0.1/sony/" + service).openConnection();
        try {
            connection.setInstanceFollowRedirects(false);
            connection.setConnectTimeout(3000);
            connection.setReadTimeout(3000);
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/json");
            if (authorization != null) {
                connection.setRequestProperty("Authorization", authorization);
            } else {
                connection.setRequestProperty("Cookie", preferences.getString("cookie", ""));
            }
            byte[] body = new JSONObject().put("method", method).put("params", parameters)
                    .put("id", 1).put("version", version)
                    .toString().getBytes(StandardCharsets.UTF_8);
            connection.setFixedLengthStreamingMode(body.length);
            try (OutputStream output = connection.getOutputStream()) {
                output.write(body);
            }
            int status = connection.getResponseCode();
            if (status == 401 || status == 403) {
                throw new AuthorizationException(status);
            }
            if (status != 200) {
                throw new IOException("Sony HTTP error " + status);
            }
            String response;
            try (InputStream input = connection.getInputStream();
                    ByteArrayOutputStream output = new ByteArrayOutputStream()) {
                byte[] buffer = new byte[2048];
                int count;
                while ((count = input.read(buffer)) != -1) {
                    if (output.size() + count > 32768) {
                        throw new IOException("Sony response exceeds size limit");
                    }
                    output.write(buffer, 0, count);
                }
                response = output.toString(StandardCharsets.UTF_8.name());
            }
            JSONObject parsed = new JSONObject(response);
            if (parsed.has("error")) {
                int code = parsed.getJSONArray("error").getInt(0);
                if (code == 401 || code == 403) {
                    throw new AuthorizationException(code);
                }
                throw new IOException("Sony API error " + code);
            }
            if (!parsed.has("result")) {
                throw new IOException("Sony response missing result");
            }
            if ("actRegister".equals(method)) {
                StringBuilder cookie = new StringBuilder();
                for (Map.Entry<String, List<String>> header
                        : connection.getHeaderFields().entrySet()) {
                    if ("Set-Cookie".equalsIgnoreCase(header.getKey())) {
                        for (String value : header.getValue()) {
                            if (cookie.length() > 0) {
                                cookie.append("; ");
                            }
                            cookie.append(value.split(";", 2)[0]);
                        }
                    }
                }
                if (cookie.length() == 0 || !preferences.edit()
                        .putString("cookie", cookie.toString()).commit()) {
                    throw new IOException("Unable to save Sony pairing cookie");
                }
            }
            return parsed;
        } catch (JSONException error) {
            throw new IOException("Invalid Sony JSON response", error);
        } finally {
            connection.disconnect();
        }
    }

    static final class AuthorizationException extends IOException {
        private static final long serialVersionUID = 1L;

        AuthorizationException(int status) {
            super("Sony authorization required (" + status + ")");
        }
    }
}
