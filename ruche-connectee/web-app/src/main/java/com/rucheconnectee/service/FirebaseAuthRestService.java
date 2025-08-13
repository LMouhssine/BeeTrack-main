package com.rucheconnectee.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URI;
import java.nio.charset.StandardCharsets;
// import java.util.Map; // removed: unused
import jakarta.annotation.PostConstruct;

/**
 * Service léger pour authentifier un utilisateur Firebase via l'API REST (email + mot de passe).
 * Nécessite la clé API Web Firebase (firebase.api-key).
 */
@Service
@ConditionalOnProperty(name = "firebase.api-key")
public class FirebaseAuthRestService {

    @Value("${firebase.api-key}")
    private String apiKey;

    @PostConstruct
    public void logConfig() {
        String masked = (apiKey == null || apiKey.length() < 6) ? "MISSING" : ("***" + apiKey.substring(apiKey.length()-6));
        System.out.println("[LOGIN] FirebaseAuthRestService initialisé | apiKey=" + masked);
    }

    public AuthResult signInWithEmailAndPassword(String email, String password) throws IOException {
        String endpoint = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + apiKey;
        URI uri = URI.create(endpoint);
        URL url = uri.toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE);
        conn.setDoOutput(true);

        String body = String.format("{\"email\":\"%s\",\"password\":\"%s\",\"returnSecureToken\":true}",
                jsonEscape(email), jsonEscape(password));
        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int code = conn.getResponseCode();
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(
                code >= 200 && code < 300 ? conn.getInputStream() : conn.getErrorStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
        }

        String json = sb.toString();
        if (code >= 200 && code < 300) {
            // Parse minimal fields without a JSON lib
            String idToken = extractJsonString(json, "idToken");
            String localId = extractJsonString(json, "localId");
            String emailOut = extractJsonString(json, "email");
            return new AuthResult(true, emailOut, localId, idToken, null);
        } else {
            String message = extractJsonString(json, "message");
            return new AuthResult(false, null, null, null, message != null ? message : json);
        }
    }

    private static String jsonEscape(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static String extractJsonString(String json, String key) {
        // Simple extraction without regex to avoid deprecated/complex usage
        int idx = json.indexOf(key);
        if (idx == -1) return null;
        int start = json.indexOf('"', json.indexOf(':', idx) + 1) + 1;
        if (start <= 0 || start >= json.length()) return null;
        int end = json.indexOf('"', start);
        if (end <= start) return null;
        return json.substring(start, end);
    }

    public static class AuthResult {
        public final boolean success;
        public final String email;
        public final String uid;
        public final String idToken;
        public final String error;

        public AuthResult(boolean success, String email, String uid, String idToken, String error) {
            this.success = success;
            this.email = email;
            this.uid = uid;
            this.idToken = idToken;
            this.error = error;
        }
    }
}


