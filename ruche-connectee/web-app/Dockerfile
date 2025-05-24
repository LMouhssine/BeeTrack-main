# Dockerfile pour l'API BeeTrack Spring Boot

# Étape 1: Construction de l'application
FROM maven:3.9.4-openjdk-17-slim AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de configuration Maven
COPY pom.xml .
COPY src ./src

# Construire l'application
RUN mvn clean package -DskipTests

# Étape 2: Image de production
FROM openjdk:17-jre-slim

# Métadonnées
LABEL maintainer="BeeTrack Team"
LABEL description="API REST Spring Boot pour le système de ruches connectées BeeTrack"
LABEL version="1.0.0"

# Créer un utilisateur non-root pour la sécurité
RUN groupadd -r beetrack && useradd -r -g beetrack beetrack

# Définir le répertoire de travail
WORKDIR /app

# Copier le JAR depuis l'étape de build
COPY --from=build /app/target/*.jar app.jar

# Créer le répertoire pour les logs
RUN mkdir -p /app/logs && chown -R beetrack:beetrack /app

# Changer vers l'utilisateur non-root
USER beetrack

# Exposer le port de l'application
EXPOSE 8080

# Variables d'environnement par défaut
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Point de santé pour Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Commande de démarrage
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 