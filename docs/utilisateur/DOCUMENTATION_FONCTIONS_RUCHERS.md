# Documentation - Fonctions de Récupération des Ruchers

## 📋 Vue d'ensemble

Ce document décrit les nouvelles fonctions créées pour récupérer les ruchers de l'utilisateur connecté dans l'application web BeeTrack.

## 📋 Fonctions Principales

### 1. `RucherService.obtenirRuchersUtilisateurConnecte()`

**Description :** Récupère tous les ruchers de l'utilisateur actuellement connecté.

**Signature :**
```typescript
static async obtenirRuchersUtilisateurConnecte(): Promise<Rucher[]>
```

**Fonctionnalités :**
- ✅ Utilise automatiquement `FirebaseAuth.currentUser.uid`
- ✅ Filtre par `idApiculteur == currentUser.uid`
- ✅ Filtre par `actif == true` (suppression logique)
- ✅ Tri par `dateCreation` (plus récent en premier)
- ✅ Gestion d'erreurs spécifiques (permissions, index, réseau)
- ✅ Vérification de l'utilisateur connecté

**Exemple d'utilisation :**
```typescript
try {
  const ruchers = await RucherService.obtenirRuchersUtilisateurConnecte();
  console.log(`${ruchers.length} rucher(s) récupéré(s)`);
} catch (error) {
  console.error('Erreur:', error.message);
}
```

### 2. `RucherService.ecouterRuchersUtilisateurConnecte()`

**Description :** Écoute en temps réel les changements des ruchers de l'utilisateur connecté.

**Signature :**
```typescript
static ecouterRuchersUtilisateurConnecte(
  callback: (ruchers: Rucher[]) => void
): () => void
```

**Fonctionnalités :**
- ✅ Écoute temps réel avec `onSnapshot`
- ✅ Même filtrage que la fonction de récupération
- ✅ Callback appelé à chaque changement
- ✅ Retourne une fonction pour arrêter l'écoute
- ✅ Gestion d'erreurs automatique

**Exemple d'utilisation :**
```typescript
const unsubscribe = RucherService.ecouterRuchersUtilisateurConnecte((ruchers) => {
  setRuchers(ruchers);
  console.log(`Mise à jour: ${ruchers.length} rucher(s)`);
});

// Arrêter l'écoute
unsubscribe();
```

### 3. `RucherService.ajouterRucherUtilisateurConnecte()`

**Description :** Ajoute un nouveau rucher pour l'utilisateur connecté.

**Signature :**
```typescript
static async ajouterRucherUtilisateurConnecte(
  rucher: Omit<Rucher, 'id' | 'dateCreation' | 'nombreRuches' | 'actif' | 'idApiculteur'>
): Promise<string>
```

**Fonctionnalités :**
- ✅ Ajoute automatiquement `idApiculteur = currentUser.uid`
- ✅ Ajoute automatiquement `dateCreation = Timestamp.now()`
- ✅ Initialise `nombreRuches = 0` et `actif = true`
- ✅ Retourne l'ID du document créé

**Exemple d'utilisation :**
```typescript
const id = await RucherService.ajouterRucherUtilisateurConnecte({
  nom: "Rucher des Tilleuls",
  adresse: "123 Rue des Abeilles, Paris",
  description: "Rucher situé dans un environnement calme"
});
```

## 🎣 Hook Personnalisé : `useRuchers`

**Description :** Hook React qui encapsule toute la logique de gestion des ruchers.

**Fonctionnalités :**
- ✅ Écoute temps réel automatique
- ✅ Gestion des états (loading, error, ruchers)
- ✅ Fonctions CRUD intégrées
- ✅ Nettoyage automatique des listeners

**Valeurs retournées :**
```typescript
{
  ruchers: Rucher[],           // Liste des ruchers
  loading: boolean,            // État de chargement
  error: string,               // Message d'erreur
  rechargerRuchers: () => Promise<void>,
  ajouterRucher: (rucher) => Promise<string>,
  supprimerRucher: (id) => Promise<void>,
  mettreAJourRucher: (id, rucher) => Promise<void>,
  clearError: () => void
}
```

**Exemple d'utilisation :**
```typescript
const { ruchers, loading, error, ajouterRucher } = useRuchers();

if (loading) return <div>Chargement...</div>;
if (error) return <div>Erreur: {error}</div>;

return (
  <div>
    {ruchers.map(rucher => (
      <div key={rucher.id}>{rucher.nom}</div>
    ))}
  </div>
);
```

## 🔧 Composant Amélioré : `RuchersListV2`

**Description :** Version améliorée du composant de liste des ruchers utilisant le hook `useRuchers`.

**Nouvelles fonctionnalités :**
- ✅ Écoute temps réel (badge "Temps réel")
- ✅ Bouton d'actualisation manuelle
- ✅ Gestion d'erreurs avec bouton de fermeture
- ✅ Pas de prop `user` nécessaire
- ✅ Mise à jour automatique après actions

## 📊 Requête Firestore

**Collection :** `ruchers`

**Filtres appliqués :**
```javascript
where('idApiculteur', '==', currentUser.uid)
where('actif', '==', true)
orderBy('dateCreation', 'desc')
```

**Index Firestore requis :**
```
Collection: ruchers
Fields: idApiculteur (Ascending), actif (Ascending), dateCreation (Descending)
```

## 🛡️ Gestion d'Erreurs

**Types d'erreurs gérées :**

1. **Utilisateur non connecté**
   - Message : "Aucun utilisateur connecté. Veuillez vous connecter..."

2. **Permissions insuffisantes**
   - Code : `permission-denied`
   - Message : "Permissions insuffisantes pour accéder aux ruchers."

3. **Index manquant**
   - Code : `failed-precondition`
   - Message : "Index Firestore manquant. Veuillez créer un index composite..."

4. **Service indisponible**
   - Code : `unavailable`
   - Message : "Service Firestore temporairement indisponible. Veuillez réessayer."

5. **Erreur réseau**
   - Message générique : "Impossible de récupérer les ruchers. Vérifiez votre connexion internet."

## 🚀 Avantages

### Performance
- ✅ Écoute temps réel évite les rechargements manuels
- ✅ Filtrage côté serveur (Firestore)
- ✅ Tri optimisé avec index

### Expérience Utilisateur
- ✅ Mise à jour instantanée des changements
- ✅ Messages d'erreur explicites
- ✅ États de chargement visuels
- ✅ Interface responsive

### Développement
- ✅ Code réutilisable avec le hook
- ✅ Séparation des responsabilités
- ✅ TypeScript pour la sécurité des types
- ✅ Logs détaillés pour le débogage

## 📝 Migration

**Pour migrer de l'ancienne version :**

1. **Remplacer** `RucherService.obtenirRuchersUtilisateur(user.uid)`
   **Par** `RucherService.obtenirRuchersUtilisateurConnecte()`

2. **Utiliser** le hook `useRuchers` au lieu de la gestion manuelle d'état

3. **Remplacer** `RuchersList` par `RuchersListV2` pour l'écoute temps réel

## 🔍 Exemple Complet

```typescript
import React from 'react';
import { useRuchers } from '../hooks/useRuchers';

const MonComposant: React.FC = () => {
  const { 
    ruchers, 
    loading, 
    error, 
    ajouterRucher,
    supprimerRucher 
  } = useRuchers();

  const handleAjout = async () => {
    try {
      await ajouterRucher({
        nom: "Nouveau Rucher",
        adresse: "Adresse du rucher",
        description: "Description du rucher"
      });
      console.log('Rucher ajouté avec succès');
    } catch (error) {
      console.error('Erreur:', error);
    }
  };

  if (loading) return <div>Chargement...</div>;
  if (error) return <div>Erreur: {error}</div>;

  return (
    <div>
      <h2>Mes Ruchers ({ruchers.length})</h2>
      <button onClick={handleAjout}>Ajouter un rucher</button>
      
      {ruchers.map(rucher => (
        <div key={rucher.id}>
          <h3>{rucher.nom}</h3>
          <p>{rucher.adresse}</p>
          <p>{rucher.description}</p>
          <button onClick={() => supprimerRucher(rucher.id!)}>
            Supprimer
          </button>
        </div>
      ))}
    </div>
  );
};
```

---

**Date de création :** $(date)
**Version :** 1.0
**Auteur :** Assistant IA - BeeTrack Project 