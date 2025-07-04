# Logo BeeTrack - Design Unifié

## Vue d'ensemble

Le nouveau logo BeeTrack utilise un design moderne et professionnel avec une **abeille stylisée dans un hexagone**. Ce logo est utilisé de manière cohérente dans toutes les applications de l'écosystème BeeTrack.

## Design du Logo

### Éléments visuels
- **Hexagone** : Forme géométrique rappelant les alvéoles de ruche
- **Abeille stylisée** : Représentation moderne et épurée d'une abeille
- **Palette de couleurs** : Amber (#F59E0B) et gris foncé (#1F2937)
- **Style** : Minimaliste, vectoriel, scalable

### Symbolisme
- **Hexagone** : Structure, organisation, efficacité (comme dans une ruche)
- **Abeille** : Productivité, surveillance, connectivité
- **Amber** : Couleur naturelle du miel, chaleur, énergie
- **Professionnel** : Design épuré sans emojis "familiaux"

## Implémentation par Application

### 1. Application Web (React + TypeScript)

**Fichier** : `src/components/Logo.tsx`

```tsx
import { BeeLogo } from './components/Logo';

// Usage
<Logo variant="full" size="large" />     // Logo + texte BEETRCK
<Logo variant="icon" size="medium" />    // Icône uniquement
<Logo variant="text" size="small" />     // Texte uniquement
```

**Tailles disponibles** :
- `small` : 40px (header compact)
- `medium` : 60px (navigation standard)  
- `large` : 100px (splash screen, hero)

**Fichiers générés** :
- `public/logo.svg` : Fichier SVG pour usage général
- Intégré dans `App.tsx` pour l'écran de chargement

### 2. Application Mobile (Flutter)

**Fichier** : `lib/widgets/bee_logo.dart`

```dart
import 'package:ruche_connectee/widgets/bee_logo.dart';

// Usage
BeeLogo(
  size: 120.0,
  color: Colors.amber.shade600,    // Couleur hexagone
  beeColor: Colors.amber.shade300, // Couleur abeille
)
```

**Implémentation** :
- `CustomPainter` pour un rendu vectoriel natif
- Animation compatible avec les transitions Flutter
- Utilisé dans `splash_screen.dart`

**Icônes d'application** :
- Android : `android/app/src/main/res/drawable/app_icon.xml`
- iOS : Assets générés automatiquement

### 3. Backend Spring Boot

**Documentation** : Logo utilisé dans :
- Documentation Swagger/OpenAPI
- Pages d'erreur personnalisées
- Emails de notification (si implémentés)

## Utilisation du Logo

### ✅ Usage approprié
- Applications officielles BeeTrack
- Documentation technique
- Présentations professionnelles
- Interfaces utilisateur

### ❌ Usage inapproprié
- Modification des couleurs ou proportions
- Ajout d'éléments visuels non autorisés
- Usage commercial non autorisé
- Déformation ou rotation

## Migration depuis l'ancien logo

### Changements effectués
1. **Icons.hive** → **BeeLogo personnalisé**
2. **Emojis 🐝** → **Design vectoriel professionnel**
3. **"Ruche Connectée"** → **"BEETRCK"** (branding simplifié)

### Fichiers modifiés
- ✅ `src/components/Logo.tsx`
- ✅ `src/App.tsx` (splash screen)
- ✅ `lib/widgets/bee_logo.dart`
- ✅ `lib/screens/splash_screen.dart`
- ✅ `android/app/src/main/res/drawable/app_icon.xml`

## Assets générés

```
public/
├── logo.svg                    # Logo web principal
└── favicon.ico                 # (à générer depuis logo.svg)

ruche-connectee/mobile-app/
├── lib/widgets/bee_logo.dart   # Widget Flutter
└── android/app/src/main/res/
    └── drawable/app_icon.xml   # Icône Android vectorielle
```

## Cohérence visuelle

Le nouveau logo assure une **identité visuelle unifiée** sur :
- 📱 **App mobile** (Android/iOS)
- 💻 **App web** (React)
- 🔗 **API/Backend** (Spring Boot)
- 📖 **Documentation** (Markdown)

## Prochaines étapes

1. **Favicon web** : Générer favicon.ico depuis logo.svg
2. **iOS App Icons** : Créer Assets.xcassets complets
3. **Marketing** : Adapter pour site web, réseaux sociaux
4. **Print** : Versions haute résolution pour impression

---

*Logo créé pour maintenir une image de marque professionnelle et moderne pour l'écosystème BeeTrack.* 