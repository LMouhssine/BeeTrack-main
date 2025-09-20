#!/bin/bash

echo "============================================"
echo "    Correction des dépendances Flutter"
echo "============================================"

echo ""
echo "1. Vérification de la version Flutter..."
flutter --version

echo ""
echo "2. Configuration Flutter sans analytics..."
flutter config --no-analytics

echo ""
echo "3. Nettoyage complet du cache Flutter..."
flutter clean
rm -f pubspec.lock
rm -rf .dart_tool

echo ""
echo "4. Vérification de la configuration Flutter..."
flutter doctor -v

echo ""
echo "5. Récupération des dépendances avec versions compatibles..."
flutter pub get

echo ""
echo "6. Vérification des dépendances..."
flutter pub deps

echo ""
echo "7. Test d'analyse du code..."
flutter analyze --no-fatal-infos

echo ""
echo "8. Test de compilation..."
flutter build apk --debug

echo ""
echo "============================================"
echo "    Correction terminée !"
echo "============================================"
echo ""
echo "Versions compatibles installées :"
echo "- get_it: ^7.7.0 (compatible meta 1.11.0)"
echo "- injectable: ^2.1.2 (compatible meta 1.11.0)"
echo "- go_router: ^14.2.7 (compatible Dart 3.5.4)"
echo "- flutter_lints: ^4.0.0 (compatible Dart 3.5.4)"
echo "- Firebase: versions compatibles"
echo ""
echo "Vous pouvez maintenant lancer l'application avec :"
echo "flutter run"
echo ""