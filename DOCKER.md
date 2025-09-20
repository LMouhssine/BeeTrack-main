# 🐳 Guide Docker pour BeeTrack

## 🚀 Démarrage rapide

### Prérequis
- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum
- 10GB d'espace disque libre

### Lancement de l'application

```bash
# Cloner le repository
git clone <repository-url>
cd BeeTrack-main

# Copier la configuration d'environnement
cp .env.example .env

# Démarrer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

L'application sera accessible sur :
- **Application principale** : http://localhost:80
- **API Spring Boot** : http://localhost:8080
- **Monitoring Grafana** : http://localhost:3000 (admin/admin123)
- **Metrics Prometheus** : http://localhost:9090

## 📦 Services disponibles

### Service principal
- **beetrack-api** : Application Spring Boot sur le port 8080
- **nginx** : Reverse proxy et serveur statique sur le port 80
- **redis** : Cache et session store sur le port 6379

### Services optionnels (profil monitoring)
```bash
# Démarrer avec monitoring
docker-compose --profile monitoring up -d

# Services supplémentaires
- **prometheus** : Collecte de métriques sur le port 9090
- **grafana** : Visualisation sur le port 3000
```

## ⚙️ Configuration

### Variables d'environnement

Éditez le fichier `.env` :

```env
# Base de données Redis
REDIS_PASSWORD=your-secure-password

# Monitoring
GRAFANA_PASSWORD=your-grafana-password

# Application
SPRING_PROFILES_ACTIVE=docker
JAVA_OPTS=-Xmx1024m -Xms512m

# Firebase (optionnel)
FIREBASE_PROJECT_ID=your-firebase-project
FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com/
```

### Configuration Firebase

1. Placez votre fichier `firebase-service-account.json` dans `ruche-connectee/web-app/src/main/resources/`
2. Configurez les variables Firebase dans `.env`

## 🔧 Commandes utiles

### Gestion des conteneurs

```bash
# Démarrer les services
docker-compose up -d

# Arrêter les services
docker-compose down

# Voir les logs
docker-compose logs -f beetrack-api

# Redémarrer un service
docker-compose restart beetrack-api

# Reconstruire une image
docker-compose build beetrack-api
```

### Développement

```bash
# Mode développement avec rechargement automatique
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Exécuter des commandes dans le conteneur
docker-compose exec beetrack-api bash

# Accéder aux logs
docker-compose logs -f --tail=100 beetrack-api
```

### Debugging

```bash
# Vérifier la santé des services
docker-compose ps

# Inspecter un conteneur
docker inspect beetrack-api

# Voir l'utilisation des ressources
docker stats

# Nettoyer les volumes inutilisés
docker system prune -a --volumes
```

## 📊 Monitoring et métriques

### Health Checks

L'application expose plusieurs endpoints de santé :

- `http://localhost:8080/actuator/health` - Santé de l'application
- `http://localhost:80/health` - Santé du proxy Nginx
- `http://localhost:6379` - Redis (utilisez redis-cli PING)

### Métriques Prometheus

Les métriques sont collectées automatiquement :

- **Application** : http://localhost:8080/actuator/prometheus
- **Prometheus UI** : http://localhost:9090
- **Grafana** : http://localhost:3000

### Tableaux de bord Grafana

Dashboards préconfigurés :
- **Spring Boot Metrics** : Métriques JVM, HTTP, base de données
- **System Metrics** : CPU, mémoire, disque, réseau
- **Business Metrics** : Métriques métier BeeTrack

## 🛡️ Sécurité

### Bonnes pratiques appliquées

- ✅ Utilisateurs non-root dans les conteneurs
- ✅ Variables d'environnement pour les secrets
- ✅ Isolation réseau avec des sous-réseaux dédiés
- ✅ Health checks intégrés
- ✅ Limitations de ressources
- ✅ Logs centralisés

### Configuration SSL/TLS (Production)

```bash
# Générer des certificats auto-signés pour les tests
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem -out ssl/cert.pem

# Activer HTTPS dans nginx/conf.d/beetrack.conf
# Décommenter la section HTTPS
```

## 🚀 Déploiement en production

### Prérequis production

1. **Serveur** : Ubuntu 20.04+ ou CentOS 8+
2. **Docker** : Version stable la plus récente
3. **Ressources** : 4GB RAM, 2 CPU cores, 20GB disque
4. **Domaine** : Configuration DNS vers votre serveur

### Étapes de déploiement

```bash
# 1. Préparer l'environnement
cp .env.example .env
# Éditer .env avec vos valeurs de production

# 2. Configurer les secrets
# Ajouter firebase-service-account.json
# Configurer les mots de passe sécurisés

# 3. Démarrer en production
docker-compose -f docker-compose.yml up -d

# 4. Configurer le reverse proxy
# Configurer nginx avec votre domaine
# Activer SSL/TLS

# 5. Configurer la sauvegarde
# Scripts de sauvegarde pour Redis et volumes
```

## 🔍 Dépannage

### Problèmes courants

**Service ne démarre pas**
```bash
# Vérifier les logs
docker-compose logs service-name

# Vérifier la configuration
docker-compose config
```

**Problème de mémoire**
```bash
# Augmenter les limites Java
JAVA_OPTS="-Xmx2048m -Xms1024m"

# Vérifier l'utilisation
docker stats
```

**Problème de réseau**
```bash
# Recréer le réseau
docker-compose down
docker network prune
docker-compose up -d
```

**Base de données Redis**
```bash
# Se connecter à Redis
docker-compose exec redis redis-cli

# Vérifier les données
redis-cli -a $REDIS_PASSWORD info
```

### Logs importants

```bash
# Application Spring Boot
docker-compose logs beetrack-api

# Proxy Nginx
docker-compose logs nginx

# Base Redis
docker-compose logs redis
```

## 📚 Documentation supplémentaire

- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [Redis Configuration](https://redis.io/documentation)
- [Docker Compose](https://docs.docker.com/compose/)
- [Prometheus Monitoring](https://prometheus.io/docs/)

## 🆘 Support

En cas de problème :

1. Vérifiez les logs : `docker-compose logs -f`
2. Consultez la documentation technique
3. Ouvrez une issue sur le repository GitHub