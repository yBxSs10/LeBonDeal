# 🛍️ LeBonDeal — Application mobile de bons plans

> Application mobile communautaire de partage de bons plans, développée avec Flutter et Firebase

## 📋 Table des matières
- [🚀 Installation et lancement](#-installation-et-lancement)
- [📱 Lancement sur émulateur](#-lancement-sur-émulateur)
- [🧪 Tests unitaires](#-tests-unitaires)
- [⚙️ CI/CD](#️-cicd)
- [📦 Fichiers de configuration](#-fichiers-de-configuration)
- [📚 Fonctionnalités](#-fonctionnalités)

---

## 🚀 Installation et lancement

### Prérequis
- **Flutter SDK** (stable) : [Installation Flutter](https://flutter.dev/docs/get-started/install)
- **Android Studio** ou **Xcode** (pour les émulateurs)
- **VS Code** avec extensions Flutter et Dart

### Installation des dépendances

```bash
flutter pub get
```

### Vérifier l'installation

```bash
flutter doctor
```

---

## 📱 Lancement sur émulateur

### Android

#### Via VS Code :
1. Ouvrez VS Code à la racine du projet
2. Démarrez un émulateur Android :
   - `Ctrl+Shift+P` → "Flutter: Launch Emulator"
   - Ou Android Studio → AVD Manager → Start
3. Lancez l'application :
   - `F5` ou `Ctrl+F5`

#### Via terminal :
```bash
# Vérifiez les appareils disponibles
flutter devices

# Lancez l'application
flutter run

# Build APK de production
flutter build apk
```

### iOS (macOS uniquement)

```bash
# Ouvrez le simulateur iOS
open -a Simulator

# Lancez l'application
flutter run

# Build iOS
flutter build ios
```

### Web

```bash
flutter run -d chrome
```

---

## 🧪 Tests unitaires

Le projet contient **20 tests unitaires** couvrant l'authentification, les deals et la sécurité.

```bash
# Lancer tous les tests
flutter test

# Lancer avec détails
flutter test --reporter=expanded

# Lancer avec couverture de code
flutter test --coverage
```

### Résultats attendus

```
✅ DEAL-001 à DEAL-009   — Entité Deal + persistance Firestore
✅ AUTH-001 à AUTH-005   — Repository d'authentification Firebase
✅ SEC-001  à SEC-005    — Validation et règles de sécurité

+20: All tests passed!
```

### Fichiers de tests

```
test/
├── features/auth/
│   └── auth_repository_test.dart      # AUTH-001 à AUTH-005
├── features/deals/
│   ├── deal_entity_test.dart          # DEAL-001 à DEAL-005
│   └── create_deal_usecase_test.dart  # DEAL-006 à DEAL-009
└── features/security/
    └── deal_validation_test.dart      # SEC-001 à SEC-005
```

---

## ⚙️ CI/CD

Un pipeline GitHub Actions se déclenche automatiquement à chaque `push` sur `main` :

```
✅ Checkout code
✅ Setup Flutter (stable)
✅ Install dependencies
✅ Check formatting (dart format)
✅ Analyze code (flutter analyze)
✅ Run unit tests (20/20)
✅ Run tests with coverage
✅ Upload coverage artifact
```

Consultez l'onglet **Actions** du dépôt pour l'historique des exécutions.

---

## 📦 Fichiers de configuration

### Fichiers sensibles (non versionnés)

```
# Firebase — à obtenir depuis la Firebase Console
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
```

> Ces fichiers contiennent les clés API Firebase et ne sont pas inclus dans le dépôt.

### Firestore Security Rules

Les règles de sécurité sont définies dans `firestore.rules` :

- Lecture publique des deals
- Écriture authentifiée avec vérification `authorId == uid`
- Modèle de rôles : `user` / `moderator` / `admin`
- Limite anti-spam : commentaires ≤ 500 caractères

```bash
# Déployer les règles (Firebase CLI requis)
firebase deploy --only firestore:rules
```

---

## 📚 Fonctionnalités

### ✅ Implémentées

- **Authentification** — email/mot de passe, inscription, connexion anonyme (invité)
- **Liste des deals** — affichage, recherche temps réel, filtre par catégorie
- **Détail d'un deal** — description, prix barré, remise, commentaires
- **Publication** — formulaire de création de deal (utilisateurs authentifiés uniquement)
- **Favoris** — sauvegarde et retrait des deals
- **Profil** — page utilisateur avec informations du compte
- **Commentaires** — section de commentaires par deal
- **Navigation** — barre de navigation : Accueil, Tendances, Sauvegardés, Profil

### 🛡️ Sécurité

- Firestore Security Rules (principe du moindre privilège)
- Vérification `authorId == request.auth.uid` à chaque écriture
- Blocage de la publication pour les utilisateurs anonymes
- Validation des données côté règles Firestore

### ♿ Accessibilité

- Conformité **WCAG 2.1 niveau AA**
- Labels `Semantics` sur les éléments interactifs clés
- Compatible TalkBack (Android) et VoiceOver (iOS)

---

## 🗂️ Architecture

```
lib/
├── core/                    # DI (GetIt), thème Material 3, navigation
└── features/
    ├── auth/                # Clean Architecture : domain / data / presentation
    ├── deals/               # Entité Deal, DataService, pages, widgets
    ├── categories/          # Filtrage par catégorie
    ├── comments/            # Modèle commentaire
    └── profile/             # Page profil
```

Architecture **Clean Architecture** : séparation stricte domain / data / presentation.

---

## 🔧 Outils recommandés

- **VS Code** avec extensions Flutter et Dart
- **Android Studio** pour l'émulation Android
- **Firebase Console** pour la gestion des données et des règles
- **GitHub Actions** pour la CI/CD (déjà configuré)
