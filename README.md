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
| Firestore + Cloud Functions | Serveur d'application (backend serverless) | Google Cloud, région `europe-west1` |
| VS Code | Éditeur de code | Extensions : Flutter, Dart |
| Android Studio | Émulateur Android (AVD) | Hedgehog+ |

> Architecture serverless : il n'y a pas de serveur d'application à administrer au sens traditionnel — Firebase (Firestore, Auth, Cloud Functions) joue ce rôle de manière managée par Google Cloud.

### Séquences de déploiement

Le périmètre actuel couvre l'**intégration continue** (build + test automatisés à chaque push) et le **déploiement de l'artefact applicatif** (APK distribué comme prototype testable). Il n'y a pas encore de déploiement continu vers un environnement géré (Firebase App Distribution, Play Store internal track) — c'est une évolution identifiée pour la phase 2.

```
Développement local
  └── git push → GitHub Actions déclenché automatiquement
        ├── Job "test"  : format → lint → tests unitaires → couverture → monitoring check
        └── Job "build" : build APK debug → upload artefact (30 jours)
                                    ↓
                        APK téléchargeable sur GitHub Actions
                        (prototype fonctionnel, testable sans store)

En parallèle : déploiement du backend
  └── firebase deploy → règles Firestore + Cloud Functions publiées sur l'environnement Firebase (serveur d'application)
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

Le projet contient **50 tests unitaires** couvrant l'authentification, les deals, la sécurité et la couche présentation.

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
✅ USER-001 à USER-007   — Entité UserEntity (sérialisation, égalité)
✅ AUTH-001 à AUTH-005   — Repository d'authentification Firebase
✅ AUTH-006             — Création du profil Firestore (email, displayName, role) à l'inscription
✅ AUTH-P01 à AUTH-P06   — Mapping des codes d'erreur Firebase
✅ DEAL-001 à DEAL-005   — Entité Deal (copyWith, formatage)
✅ DEAL-006 à DEAL-009   — Persistance Firestore + garde utilisateur anonyme
✅ DEAL-010 à DEAL-018   — FirestoreService (vote, favoris, commentaires, streams)
✅ DEAL-019 à DEAL-020   — Ancienneté formatée (timeAgoLabel) et expiration du badge NEW
✅ BLOC-001 à BLOC-005   — AddDealBloc (état, catégories, notifications)
✅ SEC-001  à SEC-005    — Validation et règles de sécurité

+50: All tests passed!
```

### Fichiers de tests

```
test/
├── features/auth/
│   ├── user_entity_test.dart          # USER-001 à USER-007
│   ├── auth_repository_test.dart      # AUTH-001 à AUTH-006
│   └── auth_provider_test.dart        # AUTH-P01 à AUTH-P06
├── features/deals/
│   ├── deal_entity_test.dart          # DEAL-001 à DEAL-005, DEAL-019 à DEAL-020
│   ├── create_deal_usecase_test.dart  # DEAL-006 à DEAL-009
│   ├── firestore_service_test.dart    # DEAL-010 à DEAL-018
│   └── add_deal_bloc_test.dart        # BLOC-001 à BLOC-005
└── features/security/
    └── deal_validation_test.dart      # SEC-001 à SEC-005
```

---

## ⚙️ CI/CD et Intégration Continue

### Protocole de branches

Le projet est développé en solo : le workflow réel est un **push direct sur `main`** à chaque incrément, sans branches intermédiaires. C'est le pipeline CI (formatage, lint, 50 tests, build) qui joue le rôle de garde-fou avant chaque évolution, à défaut d'une revue de Pull Request par un pair.

```
Développement local
  └── git commit → git push origin main → GitHub Actions déclenché automatiquement
```

**Évolution prévue (phase 2, en cas de montée en équipe) :**
```
main        ← branche de production, protégée
  └── develop     ← branche d'intégration
        └── feature/*   ← développement de fonctionnalités
            hotfix/*    ← correctifs urgents → merge direct sur main
```
Le pipeline CI (`.github/workflows/ci.yml`) est déjà configuré pour se déclencher aussi sur `develop` et sur les Pull Requests vers `main`, en anticipation de ce modèle à plusieurs contributeurs.

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

- Lecture publique des deals ; profils utilisateurs lisibles par leur propriétaire ou un modérateur uniquement
- Écriture authentifiée avec vérification `authorId == uid`
- Vote, commentaire et publication réservés aux comptes réels — rejetés pour les sessions invité (anonymes) via `isNotAnonymous()`, y compris en appel direct à l'API (pas seulement côté client)
- Modèle de rôles : `user` / `moderator` / `admin`, rôle immuable côté client (attribution `moderator`/`admin` uniquement via Firebase Console/Admin SDK)
- Prix revalidé (`> 0`) à la création **et** à la mise à jour d'un deal
- Anti-spam : commentaires ≤ 500 caractères, et 30s minimum entre deux publications de deal par le même auteur (`users/{uid}.lastDealPublishedAt`)
- 4 correctifs vérifiés par script `@firebase/rules-unit-testing` contre l'émulateur Firestore (7/7 assertions) et **déployés en production**

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
- **Signalement** — bouton "Signaler" sur la fiche deal (4 motifs), masqué sur son propre deal
- **Modération** — écran dédié (signalements en attente/traités, suppression du deal signalé) pour les rôles `moderator`/`admin`
- **Navigation** — barre de navigation : Accueil, Tendances, Sauvegardés, Profil

### 🛡️ Sécurité

- Firestore Security Rules (principe du moindre privilège)
- Vérification `authorId == request.auth.uid` à chaque écriture
- Blocage serveur (pas seulement client) du vote, des commentaires et de la publication pour les comptes invités (anonymes)
- Profils utilisateurs non exposés publiquement (lecture restreinte au propriétaire/modérateur)
- Anti-spam à la publication : 30s minimum entre deux deals du même auteur
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

## ✅ Traçabilité fonctionnalités ↔ user stories (MoSCoW C1.4.1)

État réel du prototype face aux 15 fonctionnalités priorisées en Bloc 1 (C2.2.1).

| Fonctionnalité | Priorité | User story | Statut | Preuve |
|---|---|---|---|---|
| Authentification | MUST | Je veux m'inscrire via email ou Google | ⚠️ Partiel | `features/auth/` : email/mot de passe opérationnel ; connexion Google non implémentée |
| Création et publication d'un deal | MUST | Je veux poster un deal avec titre, prix, lien et image | ✅ | `add_deal_page.dart`, `add_deal_bloc.dart`, tests BLOC-001 à 005 |
| Consultation des deals (feed) | MUST | Je veux voir les meilleurs deals triés par popularité | ✅ | `home_page.dart`, `trending_page.dart`, tests DEAL-012 |
| Upvote / Downvote | MUST | Je veux voter pour évaluer la qualité d'un deal | ✅ | Sous-collection `votes` (`firestore.rules`), tests DEAL-014/015 |
| Commentaires | MUST | Je veux commenter un deal pour partager mon avis | ✅ | `comments/`, tests DEAL-010 |
| Recherche + filtres | MUST | Je veux filtrer les deals par catégorie, prix et marchand | ⚠️ Partiel | Recherche texte (titre/marchand) + filtre catégorie dans `home_page.dart` ; filtre par tranche de prix non implémenté |
| Profils utilisateurs | MUST | Je veux consulter mon profil et mes deals postés | ✅ | `profile/presentation/pages/profile_page.dart` |
| Notifications push (FCM) | MUST | Je veux être alerté des deals dans mes catégories | ⚠️ Code complet, déploiement en attente | Transport FCM validé en conditions réelles (permission + token + réception, testé sur émulateur Android). Ciblage par catégorie implémenté : écran "Notifications par catégorie" (`profile_page.dart`) → `FirestoreService.toggleFollowedCategory` (persistance `users/{uid}.followedCategoryIds`) → `NotificationService.subscribeToCategory` (topic `category_<id>`), testé de bout en bout sur émulateur (toggle → écriture Firestore → abonnement FCM confirmés en log). Cloud Function `notifyNewDealInCategory` (`functions/index.js`) publie sur le topic à la création d'un deal — validée via l'émulateur Firebase (Firestore + Functions), **reste à déployer en production** (`firebase deploy --only functions`) |
| Système de signalement | SHOULD | Je veux signaler un deal frauduleux ou expiré | ✅ | Bouton "Signaler" sur la fiche deal (masqué sur son propre deal), 4 motifs, testé de bout en bout sur émulateur — `report_dialog.dart`, `FirestoreService.createReport` |
| Interface modération | SHOULD | Je veux valider, supprimer ou bannir depuis l'app | ✅ | Écran `ModerationPage` (liste des signalements, "Ignorer"/"Supprimer"), accessible depuis Profil pour les rôles `moderator`/`admin` uniquement (`getUserRoleStream`) — attribution du rôle toujours manuelle (Firebase Console), par choix de sécurité |
| Détection automatique spam | SHOULD | Je veux que les faux deals soient filtrés automatiquement | ⚠️ Partiel | Limite de 500 caractères sur les commentaires (`firestore.rules`) ; pas de détection algorithmique |
| Maquettes UI/UX | COULD | Je veux une interface intuitive et agréable | ✅ | Thème Material 3 (`app_theme.dart`), sémantique WCAG 2.1 AA |
| Tests unitaires + recette | COULD | Je veux un harnais de tests pour prévenir les régressions | ✅ Dépassé | 50 tests unitaires (recette initiale visait un socle plus restreint) |
| Recommandation personnalisée | COULD | Je veux des suggestions basées sur mes catégories favorites | ❌ Non implémenté | — |
| Alertes prix | COULD | Je veux être notifié quand un produit suivi baisse de prix | ❌ Non implémenté | — |

**Bilan** : 5/8 MUST pleinement couverts, 2/8 partiels (Google Sign-In, filtre prix), 1/8 avec code complet mais non déployé (ciblage des notifications par catégorie) ; 2/3 SHOULD pleinement couverts (signalement, modération) et testés de bout en bout, 1/3 partiel (détection de spam limitée à une contrainte de longueur) ; les COULD sont couverts pour l'UX et les tests, non couverts pour la recommandation et les alertes prix — cohérent avec leur priorité la plus basse.

Le ciblage des notifications par catégorie est entièrement codé et testé (client + Cloud Function via émulateurs) mais nécessite un `firebase deploy --only functions` pour être actif en production — cette étape n'a pas été effectuée pour ne pas modifier le projet Firebase partagé sans validation explicite.

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
