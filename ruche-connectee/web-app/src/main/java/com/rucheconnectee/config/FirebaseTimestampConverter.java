package com.rucheconnectee.config;

import com.google.cloud.Timestamp;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;

/**
 * Convertisseur pour gérer la conversion entre Firebase Timestamp et LocalDateTime
 */
@Component
public class FirebaseTimestampConverter {

    /**
     * Convertit un Timestamp Firebase en LocalDateTime
     */
    public static LocalDateTime timestampToLocalDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toDate().toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDateTime();
    }

    /**
     * Convertit un LocalDateTime en Timestamp Firebase
     */
    public static Timestamp localDateTimeToTimestamp(LocalDateTime localDateTime) {
        if (localDateTime == null) {
            return null;
        }
        // Convertir LocalDateTime vers java.util.Date puis vers Timestamp
        return Timestamp.of(java.util.Date.from(localDateTime.toInstant(ZoneOffset.UTC)));
    }

    /**
     * Désérialiseur JSON personnalisé pour les Timestamp Firebase
     */
    public static class TimestampDeserializer extends JsonDeserializer<LocalDateTime> {
        @Override
        public LocalDateTime deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
            String timestampStr = p.getText();
            try {
                // Essayer de parser comme timestamp
                Timestamp timestamp = Timestamp.parseTimestamp(timestampStr);
                return timestampToLocalDateTime(timestamp);
            } catch (Exception e) {
                // Si ça échoue, retourner null ou la valeur par défaut
                return null;
            }
        }
    }

    /**
     * Sérialiseur JSON personnalisé pour les Timestamp Firebase
     */
    public static class TimestampSerializer extends JsonSerializer<LocalDateTime> {
        @Override
        public void serialize(LocalDateTime value, JsonGenerator gen, SerializerProvider serializers) throws IOException {
            if (value != null) {
                Timestamp timestamp = localDateTimeToTimestamp(value);
                gen.writeString(timestamp.toString());
            } else {
                gen.writeNull();
            }
        }
    }
} 