<div align="center">

<img src="public/logo.svg" alt="BeeTrack Logo" width="120" height="120">

# BEETRCK

**Plateforme de Surveillance Intelligente pour Ruches Connectées**

[![React](https://img.shields.io/badge/React-18.3.1-blue.svg)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.5.3-blue.svg)](https://www.typescriptlang.org/)
[![Firebase](https://img.shields.io/badge/Firebase-11.7.3-orange.svg)](https://firebase.google.com/)
[![Vite](https://img.shields.io/badge/Vite-5.4.2-purple.svg)](https://vitejs.dev/)

*Application web moderne pour la surveillance et la gestion de ruches connectées*

</div>

## 📋 Vue d'ensemble

BeeTrack est une plateforme complète permettant aux apiculteurs de surveiller leurs ruches connectées en temps réel. L'application offre une interface intuitive pour suivre les paramètres vitaux des ruches, gérer les alertes et analyser les données historiques.

### ✨ Fonctionnalités principales

- 🔐 **Authentification sécurisée** avec Firebase Auth
- 📦 **Gestion des ruchers et ruches** avec organisation hiérarchique
- 📊 **Surveillance en temps réel** des données de capteurs
- 🚨 **Système d'alertes intelligent** (couvercle ouvert, anomalies)
- 📈 **Tableaux de bord et statistiques** avec graphiques interactifs
- 📱 **Interface responsive** adaptée à tous les appareils
- 🔄 **Synchronisation temps réel** avec Firebase Firestore

## 🚀 Démarrage rapide

### Prérequis

- Node.js 18+ 
- npm ou yarn
- Compte Firebase configuré

### Installation

```bash
# Cloner le projet
git clone https://github.com/votre-username/BeeTrack-main.git
cd BeeTrack-main

# Installer les dépendances
npm install

# Configurer Firebase (voir section Configuration)
# Copier et modifier firebase-config.ts avec vos clés

# Lancer en développement
npm run dev
```

L'application sera accessible sur `http://localhost:5173`

### Build de production

```bash
npm run build
npm run preview
```

## 🏗️ Architecture

### Stack technique

- **Frontend** : React 18 + TypeScript + Vite
- **Styling** : Tailwind CSS + Lucide Icons
- **Backend** : Firebase (Auth + Firestore)
- **Charts** : Recharts
- **Bundler** : Vite

### Structure du projet

```
src/
├── components/          # Composants React réutilisables
│   ├── Navigation.tsx
│   ├── RuchesList.tsx
│   ├── MesuresRuche.tsx
│   └── ...
├── services/           # Services Firebase et logique métier
│   ├── rucheService.ts
│   ├── rucherService.ts
│   ├── donneesCapteursService.ts
│   └── alerteCouvercleService.ts
├── hooks/              # Hooks React personnalisés
│   ├── useRuchers.ts
│   ├── useAlertesCouvercle.ts
│   └── useNotifications.ts
├── config/             # Configuration
│   └── firebase-config.ts
└── ...
```

## 🔧 Configuration

### Firebase

1. Créer un projet Firebase
2. Activer Authentication (Email/Password)
3. Configurer Firestore Database
4. Copier la configuration dans `src/firebase-config.ts`

```typescript
// firebase-config.ts
const firebaseConfig = {
  apiKey: "votre-api-key",
  authDomain: "votre-projet.firebaseapp.com",
  projectId: "votre-projet-id",
  // ...
};
```

### Structure Firestore

```
apiculteurs/           # Collection des utilisateurs
  {userId}/
    - email: string
    - nom: string
    - prenom: string

ruchers/              # Collection des ruchers
  {rucherId}/
    - nom: string
    - adresse: string
    - idApiculteur: string
    - nombreRuches: number

ruches/               # Collection des ruches
  {rucheId}/
    - nom: string
    - position: string
    - idRucher: string
    - idApiculteur: string

donneesCapteurs/      # Collection des mesures
  {mesureId}/
    - rucheId: string
    - timestamp: Timestamp
    - temperature: number
    - humidity: number
    - couvercleOuvert: boolean
    - batterie: number
```

## 🎯 Fonctionnalités détaillées

### Gestion des ruchers
- Création, modification et suppression de ruchers
- Organisation géographique des installations
- Statistiques par rucher

### Surveillance des ruches
- Visualisation temps réel des données de capteurs
- Graphiques d'évolution sur 7 jours
- Détection automatique d'anomalies

### Système d'alertes
- Alerte couvercle ouvert avec options d'ignore
- Notifications visuelles en temps réel
- Historique des alertes

### Interface utilisateur
- Design moderne et responsive
- Navigation intuitive
- Tableaux de bord personnalisables

## 🧪 Tests et développement

### Outils de diagnostic

L'application inclut des outils de diagnostic intégrés :
- Test de connectivité Firebase
- Génération de données de test
- Diagnostic des composants

### Commandes disponibles

```bash
npm run dev         # Serveur de développement
npm run build       # Build de production
npm run preview     # Aperçu du build
npm run lint        # Linter ESLint
```

## 📚 Documentation

La documentation détaillée est disponible dans le dossier `/docs` :

- **Configuration** : Guides d'installation et configuration
- **Développement** : Architecture et guides de développement  
- **Utilisateur** : Guides d'utilisation des fonctionnalités

## 🤝 Contribution

Les contributions sont bienvenues ! Voici comment contribuer :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Standards de code

- TypeScript strict
- ESLint configuré
- Composants fonctionnels avec hooks
- Documentation des fonctions complexes

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

- **Issues** : [GitHub Issues](https://github.com/votre-username/BeeTrack-main/issues)
- **Discussions** : [GitHub Discussions](https://github.com/votre-username/BeeTrack-main/discussions)

## 🏆 Équipe

Développé avec ❤️ par l'équipe BeeTrack

---

<div align="center">
  <strong>Fait pour les apiculteurs, par des passionnés de technologie</strong>
</div> 