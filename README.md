# 🛍️ LeBonDeal — Application mobile de bons plans

> Application mobile communautaire de partage de bons plans, développée avec Flutter et Firebase

## 📋 Table des matières
- [🖥️ Environnement de développement](#-environnement-de-développement)
- [🚀 Installation et lancement](#-installation-et-lancement)
- [📱 Lancement sur émulateur](#-lancement-sur-émulateur)
- [🧪 Tests unitaires](#-tests-unitaires)
- [⚙️ CI/CD](#️-cicd)
- [📦 Fichiers de configuration](#-fichiers-de-configuration)
- [📚 Fonctionnalités](#-fonctionnalités)
- [🧭 Choix technologiques](#-choix-technologiques)
- [📝 Rapport de bogue](#-rapport-de-bogue)
- [📋 Changelog](CHANGELOG.md)

---

## 🖥️ Environnement de développement

### Outils et versions de référence

| Outil | Rôle | Version |
|---|---|---|
| Flutter SDK | Compilateur + framework UI | 3.x stable (CI : 3.44.2) |
| Dart SDK | Langage / compilateur | 3.x (inclus avec Flutter) |
| Android SDK | Compilateur cible Android | API 34 |
| Git | Gestion de sources | 2.x |
| GitHub | Hébergement dépôt + CI/CD | — |
| GitHub Actions | Serveur d'intégration continue | ubuntu-latest |
| Firebase CLI | Déploiement des règles Firestore | 13.x |
| VS Code | Éditeur de code | Extensions : Flutter, Dart |
| Android Studio | Émulateur Android (AVD) | Hedgehog+ |

### Séquences de déploiement

```
Développement local
  └── git push → GitHub Actions déclenché automatiquement
        ├── Job "test"  : format → lint → tests unitaires → couverture → monitoring check
        └── Job "build" : build APK debug → upload artefact (30 jours)
                                    ↓
                        APK téléchargeable sur GitHub Actions
                        (prototype fonctionnel, testable sans store)
```

### Critères de qualité et performance

| Critère | Outil | Seuil |
|---|---|---|
| Formatage | `dart format` | Bloquant si écart |
| Analyse statique | `flutter analyze` | Bloquant si warning fatal |
| Tests unitaires | `flutter test` | 20/20 obligatoires |
| Couverture de code | lcov | Rapport généré à chaque CI |
| Crashs production | Firebase Crashlytics | Alerte automatique |
| Performance réseau | Firebase Performance | Suivi des temps de réponse |

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

## ⚙️ CI/CD et Intégration Continue

### Protocole de branches

Le projet suit un modèle de branches à 3 niveaux :

```
main        ← branche de production, protégée
  └── develop     ← branche d'intégration
        └── feature/*   ← développement de fonctionnalités
            hotfix/*    ← correctifs urgents → merge direct sur main
```

**Règles de fusion :**
- `feature/*` → `develop` : merge via Pull Request, CI doit être verte
- `develop` → `main` : merge via Pull Request après validation complète
- `hotfix/*` → `main` : merge direct autorisé uniquement pour les correctifs critiques
- Les push directs sur `main` sont interdits

### Pipeline CI/CD

Le pipeline GitHub Actions se déclenche automatiquement :
- à chaque `push` sur `main` ou `develop`
- à chaque `pull_request` vers `main`

**Séquence d'intégration (9 étapes) :**

```
1. Checkout code          — récupération du code source
2. Setup Flutter          — installation Flutter stable + cache
3. Install dependencies   — flutter pub get
4. Check formatting       — dart format (bloquant si écart)
5. Analyze code           — flutter analyze (lint statique)
6. Run unit tests         — 20 tests unitaires (bloquant si échec)
7. Run tests with coverage— génération rapport lcov
8. Upload coverage        — artifact 30 jours
9. Verify monitoring deps — vérification Crashlytics + Performance
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

---

## 🧭 Choix technologiques

### Flutter / Dart

Flutter a été retenu face à React Native et au développement natif (Kotlin + Swift) pour trois raisons principales :

- **Un seul code source** pour Android et iOS, ce qui réduit de moitié le coût de maintenance sur une équipe réduite
- **Performances proches du natif** grâce au moteur de rendu Skia/Impeller — adapté à un feed de deals avec lazy loading
- **Écosystème mature** : pub.dev, Flutter Semantics (accessibilité WCAG 2.1), support Firebase officiel

### Firebase (Firestore, Auth, FCM, Crashlytics, Performance)

Firebase a été préféré à un backend custom (Node.js + PostgreSQL) ou à Supabase :

- **Serverless** : pas de serveur à provisionner, scalabilité automatique — pertinent pour un MVP avec pic de charge imprévisible
- **Firestore temps réel** : les streams de deals et commentaires ne nécessitent pas de polling
- **Firebase Auth** : gestion des sessions et des rôles sans écrire de couche d'authentification
- **Crashlytics + Performance** : supervision intégrée sans infrastructure de monitoring séparée
- **Coût** : tier gratuit suffisant pour la phase MVP (50 000 lectures/jour)

Limite identifiée : cold start des Cloud Functions (~1-2s) acceptable en phase MVP, à surveiller en phase 2.

### Clean Architecture (domain / data / presentation)

Séparation stricte en trois couches pour garantir la testabilité et la maintenabilité :

- **Domain** : entités et use cases purs Dart, sans dépendance Firebase — testables unitairement avec mockito
- **Data** : implémentations Firebase (repositories, Firestore service) isolées derrière des interfaces
- **Presentation** : widgets et BLoC, sans logique métier

### GetIt / Injectable

Injection de dépendances par service locator plutôt que par Provider seul :

- Les repositories sont enregistrés comme singletons — une seule instance Firestore par session
- L'injection facilite le remplacement des dépendances réelles par des mocks dans les tests

---

## 📝 Rapport de bogue

Les anomalies détectées en recette sont tracées via le template GitHub Issue intégré au dépôt.

Chaque rapport couvre : référence recette (AUTH-XXX, DEAL-XXX, SEC-XXX), sévérité, priorité, étapes de reproduction, cause identifiée, plan de correction et critère de validation.

→ [Créer un rapport de bogue](.github/ISSUE_TEMPLATE/bug_report.md)
