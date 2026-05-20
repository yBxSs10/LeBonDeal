# CONCEVOIR ET DÉVELOPPER DES APPLICATIONS LOGICIELLES

## LeBonDeal
### Application mobile communautaire de partage de bons plans

**Lien du dépôt Git :** https://github.com/yBxSs10/LeBonDeal

**Année :** 2024/2025  
**Projet :** RNCP39583 — Expert en développement logiciel  
**Technologies :** Flutter, Dart, Firebase (Firestore, Auth), GitHub Actions

**Auteur :** Soussi Hicham

---

## Sommaire

1. [Concevoir un prototype de l'application](#i-concevoir-un-prototype-de-lapplication)
2. [Développer le logiciel en veillant à l'évolutivité et à la sécurisation du code](#ii-développer-le-logiciel-en-veillant-à-lévolutivité-et-à-la-sécurisation-du-code)
3. [Développer un harnais de tests unitaires](#iii-développer-un-harnais-de-tests-unitaires)
4. [Déployer le logiciel à chaque modification de code](#iv-déployer-le-logiciel-à-chaque-modification-de-code)
5. [Élaborer le cahier de recettes](#v-élaborer-le-cahier-de-recettes)
6. [Élaborer un plan de correction des bogues](#vi-élaborer-un-plan-de-correction-des-bogues)

---

## I. Concevoir un prototype de l'application

### Présentation du projet

**LeBonDeal** est une application mobile communautaire de partage de bons plans, inspirée de la plateforme Dealabs. Elle permet aux utilisateurs de publier, consulter et sauvegarder des offres promotionnelles, organisées par catégories (High-Tech, Mode, Maison, Alimentation, etc.).

L'application cible les plateformes **Android et iOS** via Flutter, avec une architecture serverless reposant sur **Firebase**.

### Architecture — Clean Architecture

Le projet suit le pattern **Clean Architecture** avec une séparation stricte en trois couches par fonctionnalité :

```
lib/
├── core/                          # Composants transverses
│   ├── di/                        # Injection de dépendances (GetIt + Injectable)
│   ├── theme/                     # Thème Material 3
│   ├── navigation/                # Routeur de l'application
│   └── widgets/shared/            # Widgets réutilisables
│
├── features/
│   ├── auth/
│   │   ├── domain/                # Entités + interfaces (UserEntity, AuthRepository)
│   │   ├── data/                  # Implémentation Firebase (AuthRepositoryImpl)
│   │   └── presentation/          # Écrans Login/Register + AuthBloc
│   │
│   ├── deals/
│   │   ├── domain/                # Entité Deal + usecases
│   │   ├── data/                  # DataService (mock → Firestore)
│   │   └── presentation/          # HomePage, DealDetailPage, AddDealPage
│   │
│   ├── categories/
│   │   ├── domain/                # Entité Category
│   │   └── presentation/          # CategoryChip widget
│   │
│   └── profile/
│       └── presentation/          # ProfilePage
```

Cette séparation garantit que la logique métier (domain) ne dépend d'aucun framework, ce qui facilite les tests unitaires et l'évolutivité vers une vraie base Firestore.

### Fonctionnalités implémentées

| Fonctionnalité | Écran | Statut |
|---|---|---|
| Authentification email/mot de passe | LoginPage | ✅ |
| Inscription utilisateur | RegisterPage | ✅ |
| Connexion anonyme (invité) | LoginPage | ✅ |
| Liste des deals avec filtres | HomePage | ✅ |
| Recherche par mot-clé | HomePage | ✅ |
| Filtrage par catégorie | HomePage | ✅ |
| Détail d'un deal | DealDetailPage | ✅ |
| Publication d'un deal | AddDealPage | ✅ |
| Sauvegarde en favoris | DealCard | ✅ |
| Profil utilisateur | ProfilePage | ✅ |
| Commentaires sur un deal | DealDetailPage | ✅ |

### Accessibilité — WCAG 2.1 AA

L'application intègre les exigences d'accessibilité du standard **WCAG 2.1 niveau AA**, conformément aux spécifications techniques de l'application mobile.

Les widgets Flutter `Semantics` ont été ajoutés sur les éléments interactifs clés, permettant la compatibilité avec les lecteurs d'écran (TalkBack Android, VoiceOver iOS) :

**DealCard — label complet pour le lecteur d'écran :**
```dart
Semantics(
  label: '${deal.title}, ${deal.storeName}, '
         '${deal.priceLabel}'
         '${deal.discountPercent > 0 ? ', -${deal.discountPercent}%' : ''}',
  hint: 'Appuyez pour voir les détails du deal',
  button: true,
  child: Card(...),
)
```

**Bouton favori — label contextuel :**
```dart
Semantics(
  label: isSaved
      ? 'Retirer ${deal.title} des favoris'
      : 'Ajouter ${deal.title} aux favoris',
  button: true,
  child: IconButton(...),
)
```

**Bouton visibilité mot de passe :**
```dart
Semantics(
  label: _obscure ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
  button: true,
  child: IconButton(...),
)
```

**FAB — publication de deal :**
```dart
Semantics(
  label: 'Publier un nouveau deal',
  button: true,
  child: FloatingActionButton(tooltip: 'Publier un deal', ...),
)
```

---

## II. Développer le logiciel en veillant à l'évolutivité et à la sécurisation du code

### Sécurisation avec Firestore Security Rules

La sécurité des données repose sur les **Firestore Security Rules**, qui s'exécutent côté serveur et ne peuvent pas être contournées par le client. Elles suivent le **principe du moindre privilège** (OWASP A01:2021).

#### Fonctions de sécurité transverses

```javascript
function isAuthenticated() {
  return request.auth != null;
}

function isOwner(authorId) {
  return isAuthenticated() && request.auth.uid == authorId;
}

function hasRole(role) {
  return isAuthenticated() &&
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
}

function isModerator() { return hasRole('moderator') || hasRole('admin'); }
function isAdmin()      { return hasRole('admin'); }
```

#### Règles par collection

**Collection `deals` — lecture publique, écriture authentifiée :**
```javascript
match /deals/{dealId} {
  allow read: if true;  // Lecture publique (deals visibles sans compte)
  allow create: if isAuthenticated()
    && request.resource.data.authorId == request.auth.uid
    && request.resource.data.price > 0
    && hasField(request.resource.data, 'title')
    && hasField(request.resource.data, 'authorId');
  allow update: if isOwner(resource.data.authorId) || isModerator();
  allow delete: if isOwner(resource.data.authorId) || isModerator();
}
```

**Collection `comments` — protection contre les contenus abusifs :**
```javascript
match /comments/{commentId} {
  allow read: if true;
  allow create: if isAuthenticated()
    && request.resource.data.content.size() <= 500;
  allow update: if isOwner(resource.data.authorId);
  allow delete: if isOwner(resource.data.authorId) || isModerator();
}
```

**Collection `users` — isolation des données personnelles :**
```javascript
match /users/{userId} {
  allow read: if isAuthenticated();
  allow create: if isOwner(userId)
    && request.resource.data.role == 'user';
  allow update: if isOwner(userId)
    && request.resource.data.role == resource.data.role;
  allow delete: if isAdmin();
}
```

### Couverture OWASP Top 10

| Menace OWASP | Mesure mise en place |
|---|---|
| A01 — Contrôle d'accès défaillant | Security Rules : `authorId == request.auth.uid` sur chaque écriture |
| A02 — Défaillances cryptographiques | Mots de passe hashés par Firebase Auth (bcrypt) |
| A03 — Injection | Firebase Firestore SDK : requêtes paramétrées, pas de SQL |
| A07 — XSS | Flutter : pas de rendu HTML, données affichées via `Text()` uniquement |
| A09 — Composants vulnérables | `flutter pub outdated` + `dart pub audit` à chaque sprint |

### Évolutivité de l'architecture

La séparation Clean Architecture permet de migrer de données mockées vers Firestore réel sans toucher aux couches `domain` et `presentation`. La couche `data` est la seule à changer :

```dart
// Actuellement : données mockées
class DataService {
  static List<Deal> getAllDeals() => _mockDeals;
}

// Migration Firestore : seule la datasource change
class FirestoreDealRepository implements DealRepository {
  Future<List<Deal>> getAllDeals() async {
    final snapshot = await _firestore.collection('deals').get();
    return snapshot.docs.map((doc) => Deal.fromJson(doc.data())).toList();
  }
}
```

---

## III. Développer un harnais de tests unitaires

### Stratégie de tests

Le projet comporte **20 tests unitaires automatisés** répartis en trois fichiers, utilisant :
- `flutter_test` — framework de tests Flutter
- `firebase_auth_mocks` — simulation Firebase Auth sans réseau
- `fake_cloud_firestore` — simulation Firestore en mémoire

Cette approche garantit des tests **déterministes, rapides et sans dépendance réseau**.

### Répartition des tests

| Fichier | Couverture | Tests |
|---|---|---|
| `test/features/deals/deal_entity_test.dart` | Entité Deal | DEAL-001 à DEAL-005 |
| `test/features/deals/create_deal_usecase_test.dart` | Persistance Firestore | DEAL-006 à DEAL-009 |
| `test/features/auth/auth_repository_test.dart` | Authentification | AUTH-001 à AUTH-005 |
| `test/features/security/deal_validation_test.dart` | Règles de sécurité | SEC-001 à SEC-005 |

### Exemple de test — AuthRepository avec mock Firebase

```dart
test('AUTH-001 : signIn avec email/password valides retourne UserEntity', () async {
  // ARRANGE
  final mockUser = MockUser(
    uid: 'uid_test_001',
    email: 'test@lebondeal.fr',
    displayName: 'Testeur LBD',
  );
  final mockAuth = MockFirebaseAuth(mockUser: mockUser);
  final repo = AuthRepositoryImpl(firebaseAuth: mockAuth);

  // ACT
  final result = await repo.signInWithEmailAndPassword(
    email: 'test@lebondeal.fr',
    password: 'password123',
  );

  // ASSERT
  expect(result.isRight(), true);
  result.fold(
    (error) => fail('Ne devrait pas retourner une erreur'),
    (user) {
      expect(user.email, 'test@lebondeal.fr');
      expect(user.id, 'uid_test_001');
    },
  );
});
```

### Résultats CI — 20/20 tests passés

```
00:04 +20: All tests passed!
```

```
✅ DEAL-001 : crée un deal avec tous les champs requis
✅ DEAL-002 : copyWith ne modifie que les champs spécifiés
✅ DEAL-003 : priceLabel retourne le prix formaté avec symbole
✅ DEAL-004 : isTrending et isPopular valent false par défaut
✅ DEAL-005 : copyWith peut passer un deal en trending
✅ DEAL-006 : un deal valide est persisté dans Firestore
✅ DEAL-007 : getDealsByCategory retourne uniquement les deals de la catégorie
✅ DEAL-008 : un deal peut être supprimé par son auteur
✅ DEAL-009 : un user anonyme est détecté et bloqué
✅ AUTH-001 : signIn avec email/password valides retourne UserEntity
✅ AUTH-002 : createUser retourne un UserEntity avec displayName
✅ AUTH-003 : signOut retourne Right(unit) et déconnecte
✅ AUTH-004 : currentUser est null quand non authentifié
✅ AUTH-005 : authStateChanges émet un UserEntity après connexion
✅ SEC-001 : commentaire > 500 chars est invalide
✅ SEC-001b : commentaire <= 500 chars est valide
✅ SEC-002 : deal avec authorId vide est invalide
✅ SEC-003 : deal avec prix à 0 ou négatif est invalide
✅ SEC-004 : authorId du deal correspond à l'uid connecté
✅ SEC-005 : les deals sont accessibles publiquement en lecture
```

---

## IV. Déployer le logiciel à chaque modification de code

### Pipeline CI/CD — GitHub Actions

Un pipeline d'intégration et de déploiement continu est configuré via **GitHub Actions** (`.github/workflows/ci.yml`). Il se déclenche automatiquement à chaque `push` sur les branches `main` et `develop`, et sur chaque Pull Request vers `main`.

```yaml
name: CI — LeBonDeal

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    name: Flutter Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --no-fatal-infos
      - run: flutter test --reporter=expanded
      - run: flutter test --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/lcov.info
```

### Étapes du pipeline

| Étape | Rôle | Statut |
|---|---|---|
| Checkout code | Récupère le code source | ✅ |
| Setup Flutter stable | Installe Flutter dernière version stable | ✅ |
| Install dependencies | `flutter pub get` | ✅ |
| Check formatting | `dart format` — vérifie le style du code | ✅ |
| Analyze code | `flutter analyze` — détection d'erreurs statiques | ✅ |
| Run unit tests | `flutter test` — 20 tests unitaires | ✅ |
| Run tests with coverage | Génération rapport de couverture lcov | ✅ |
| Upload coverage report | Artifact GitHub Actions (30 jours) | ✅ |

### Historique des exécutions

Chaque commit sur `main` déclenche automatiquement le pipeline. L'onglet **Actions** du dépôt GitHub (`github.com/yBxSs10/LeBonDeal/actions`) conserve l'historique complet des exécutions avec les logs détaillés.

---

## V. Élaborer le cahier de recettes

### Vue d'ensemble

Le cahier de recettes de LeBonDeal couvre les fonctionnalités principales à travers **27 scénarios de tests** répartis en trois catégories : 12 tests fonctionnels, 5 tests unitaires automatisés et 10 tests de sécurité/validation.

Chaque scénario est documenté avec un identifiant unique, des prérequis, les étapes détaillées, le résultat attendu et le résultat obtenu.

---

### Tests Fonctionnels — Authentification

**Scénario AUTH-F01 : Connexion avec identifiants valides.**
Prérequis : un compte existe avec l'email `test@lebondeal.fr`.
Étapes : 1. Ouvrir l'application. 2. Saisir l'email et le mot de passe. 3. Appuyer sur "Se connecter".
Résultat attendu : l'utilisateur est redirigé vers la page d'accueil, son nom s'affiche dans le profil.
Résultat obtenu : ✅ Conforme.

**Scénario AUTH-F02 : Tentative de connexion avec mot de passe incorrect.**
Prérequis : un compte existe.
Étapes : 1. Saisir un email valide. 2. Saisir un mot de passe incorrect. 3. Appuyer sur "Se connecter".
Résultat attendu : un message d'erreur "Email ou mot de passe incorrect" s'affiche, l'utilisateur reste sur la page de connexion.
Résultat obtenu : ✅ Conforme.

**Scénario AUTH-F03 : Inscription d'un nouvel utilisateur.**
Prérequis : aucun compte existant avec cet email.
Étapes : 1. Appuyer sur "Créer un compte". 2. Saisir email, mot de passe (6+ caractères) et nom. 3. Valider.
Résultat attendu : compte Firebase créé, l'utilisateur accède à l'application.
Résultat obtenu : ✅ Conforme.

**Scénario AUTH-F04 : Connexion en tant qu'invité.**
Étapes : 1. Appuyer sur "Continuer en tant qu'invité".
Résultat attendu : l'utilisateur accède à l'application en mode lecture, le bouton de publication de deal est masqué.
Résultat obtenu : ✅ Conforme.

**Scénario AUTH-F05 : Déconnexion.**
Prérequis : utilisateur connecté.
Étapes : 1. Aller sur la page Profil. 2. Appuyer sur "Se déconnecter".
Résultat attendu : l'utilisateur est redirigé vers la page de connexion, la session est effacée.
Résultat obtenu : ✅ Conforme.

---

### Tests Fonctionnels — Deals

**Scénario DEAL-F01 : Affichage de la liste des deals.**
Étapes : 1. Ouvrir l'application (connecté ou invité).
Résultat attendu : la liste des deals s'affiche avec titre, image, prix et remise pour chaque item.
Résultat obtenu : ✅ Conforme.

**Scénario DEAL-F02 : Filtrage par catégorie.**
Étapes : 1. Sur la HomePage, appuyer sur la catégorie "High-Tech".
Résultat attendu : seuls les deals de la catégorie High-Tech s'affichent.
Résultat obtenu : ✅ Conforme.

**Scénario DEAL-F03 : Recherche par mot-clé.**
Étapes : 1. Appuyer sur la barre de recherche. 2. Saisir "iPhone".
Résultat attendu : la liste se filtre en temps réel pour n'afficher que les deals contenant "iPhone".
Résultat obtenu : ✅ Conforme.

**Scénario DEAL-F04 : Consultation du détail d'un deal.**
Étapes : 1. Appuyer sur un deal dans la liste.
Résultat attendu : la page de détail s'ouvre avec toutes les informations (description, prix barré, remise, commentaires).
Résultat obtenu : ✅ Conforme.

**Scénario DEAL-F05 : Publication d'un deal (utilisateur authentifié).**
Prérequis : utilisateur connecté (non anonyme).
Étapes : 1. Appuyer sur le bouton "+" (FAB). 2. Remplir le formulaire (titre, prix, catégorie). 3. Appuyer sur "Publier".
Résultat attendu : le deal apparaît en tête de la liste sur la HomePage.
Résultat obtenu : ✅ Conforme.

**Scénario DEAL-F06 : Tentative de publication en mode invité.**
Prérequis : utilisateur connecté en tant qu'invité.
Résultat attendu : le bouton "+" n'est pas visible, l'action est bloquée.
Résultat obtenu : ✅ Conforme.

**Scénario DEAL-F07 : Ajout et retrait d'un deal en favoris.**
Étapes : 1. Appuyer sur le bouton ♥ d'un deal.
Résultat attendu : l'icône passe en rouge (sauvegardé). En réappuyant, elle revient en gris.
Résultat obtenu : ✅ Conforme.

---

### Tests Unitaires Automatisés (AUTH-001 à SEC-005)

Les 20 tests unitaires sont exécutés automatiquement à chaque push via le pipeline CI/CD. Ils couvrent :

**Tests de l'entité Deal (DEAL-001 à DEAL-005) :**

**Scénario DEAL-001 : Création d'un deal avec données valides.**
Méthode testée : constructeur `Deal(...)`.
Résultat attendu : tous les champs sont correctement initialisés.
Résultat obtenu : ✅ 0 ms — Conforme.

**Scénario DEAL-003 : Formatage du prix.**
Méthode testée : `deal.priceLabel`.
Résultat attendu : `$49.99` pour un prix de `49.99`.
Résultat obtenu : ✅ Conforme.

**Tests de persistance Firestore (DEAL-006 à DEAL-009) :**

**Scénario DEAL-006 : Persistance d'un deal valide.**
Méthode testée : écriture dans `FakeFirebaseFirestore`.
Résultat attendu : le document existe après écriture, les champs sont corrects.
Résultat obtenu : ✅ Conforme.

**Scénario DEAL-009 : Blocage d'un utilisateur anonyme.**
Méthode testée : `MockUser(isAnonymous: true)`.
Résultat attendu : `currentUser.isAnonymous == true`.
Résultat obtenu : ✅ Conforme.

---

### Tests de Sécurité — Validation des données

**Scénario SEC-001 : Commentaire dépassant 500 caractères.**
Contexte : règle Firestore `content.size() <= 500`.
Étapes : créer un commentaire de 501 caractères.
Résultat attendu : la validation côté client détecte le dépassement (`longContent.length > 500 == true`).
Résultat obtenu : ✅ Conforme.

**Scénario SEC-002 : Deal sans authorId.**
Contexte : règle Firestore `hasField('authorId')`.
Résultat attendu : `isValidAuthorId('') == false`.
Résultat obtenu : ✅ Conforme.

**Scénario SEC-003 : Prix invalide (0 ou négatif).**
Contexte : règle Firestore `price > 0`.
Résultat attendu : `isValidPrice(0) == false`, `isValidPrice(-10) == false`.
Résultat obtenu : ✅ Conforme.

**Scénario SEC-004 : Correspondance authorId / uid connecté.**
Contexte : règle Firestore `request.resource.data.authorId == request.auth.uid`.
Résultat attendu : le champ `authorId` du document correspond à l'uid de l'utilisateur.
Résultat obtenu : ✅ Conforme.

**Scénario SEC-005 : Lecture publique des deals.**
Contexte : règle Firestore `allow read: if true`.
Résultat attendu : les deals sont lisibles sans authentification.
Résultat obtenu : ✅ Conforme.

### Critères d'acceptation globaux

Tous les tests fonctionnels doivent réussir sans régression. Les 20 tests unitaires automatisés doivent passer à 100% dans la CI. Les tests de sécurité ne doivent révéler aucune vulnérabilité permettant l'accès ou la modification de données sans autorisation. L'application doit fonctionner sur Android 8+ et iOS 13+ sans crash lors d'une session de navigation complète de 15 minutes.

---

## VI. Élaborer un plan de correction des bogues

### Analyse des anomalies détectées en recette

Lors du développement et des phases de recette de LeBonDeal, **7 anomalies** ont été identifiées, analysées et corrigées. Elles se répartissent en deux bogues critiques, trois bogues majeurs et deux bogues mineurs.

### Classification et priorisation des bogues

**Criticité 1 — Blocants :**

**BUG-001 : Incompatibilité de version `fake_cloud_firestore`.**
Description : la version `^3.0.3` déclarée dans `pubspec.yaml` était incompatible avec le Dart SDK installé, empêchant la compilation des tests.
Impact : aucun test ne pouvait être exécuté.
Correction : mise à jour vers `fake_cloud_firestore: ^4.1.0`.
Statut : ✅ Résolu — commit `7becc74`.

**BUG-002 : Champ `authorId` absent de l'entité `Deal`.**
Description : l'entité `Deal` ne comportait pas le champ `authorId`, requis par les Firestore Security Rules (`request.resource.data.authorId == request.auth.uid`). La compilation échouait dans 4 fichiers.
Impact : impossible de créer un deal, tests unitaires DEAL-006 à DEAL-009 bloqués.
Correction : ajout du champ `authorId` dans le constructeur, `copyWith()` et tous les sites d'appel (`data_service.dart`, `create_deal_usecase.dart`, `add_deal_bloc.dart`).
Statut : ✅ Résolu — commit `7becc74`.

**Criticité 2 — Majeurs :**

**BUG-003 : Test AUTH-005 en échec — stream émettait `null` en premier.**
Description : le test `authStateChanges émet un UserEntity après connexion` utilisait `emits(isNotNull)`, mais le stream Firebase émet d'abord `null` avant l'utilisateur connecté.
Impact : faux négatif sur un test de sécurité critique (surveillance de session).
Correction : remplacement de `emits(isNotNull)` par `emitsThrough(isNotNull)` et ajout de `signedIn: true` sur le mock.
Statut : ✅ Résolu — commit `7becc74`.

**BUG-004 : Test DEAL-009 en échec — utilisateur anonyme mal configuré.**
Description : `MockFirebaseAuth(signedIn: true)` crée un utilisateur non-anonyme par défaut, rendant `isAnonymous == false` au lieu de `true`.
Impact : le test de sécurité "un user anonyme est détecté et bloqué" passait pour de mauvaises raisons.
Correction : utilisation explicite de `MockUser(isAnonymous: true, uid: 'anon_uid')`.
Statut : ✅ Résolu — commit `7becc74`.

**BUG-005 : Pipeline CI échoue sur version Flutter incompatible.**
Description : le workflow spécifiait `flutter-version: '3.32.0'` (Dart 3.8.0), incompatible avec la contrainte `sdk: ^3.10.0` du `pubspec.yaml`.
Impact : le pipeline CI bloquait à l'étape "Install dependencies", rendant la CI inopérante.
Correction : suppression de la version fixée (utilisation du canal `stable`), et relâchement de la contrainte SDK à `>=3.8.0 <4.0.0`.
Statut : ✅ Résolu — commit `58456f3`.

**Criticité 3 — Mineurs :**

**BUG-006 : Formatage non conforme sur 54 fichiers Dart.**
Description : le code généré automatiquement et le code vibecoded ne respectaient pas le style Dart standard (`dart format`). Le step "Check formatting" de la CI échouait.
Impact : la CI échouait à chaque push, bloquant la validation automatique.
Correction : exécution de `dart format .` en local pour reformater les 74 fichiers concernés.
Statut : ✅ Résolu — commit `8c228f1`.

**BUG-007 : Import inutilisé dans `deal_validation_test.dart`.**
Description : import de `deal.dart` déclaré mais non utilisé, générant un warning `flutter analyze`.
Impact : warning visible dans les logs CI, dégradation de la qualité du code.
Correction : suppression de l'import inutilisé.
Statut : ✅ Résolu — commit `7becc74`.

### Plan de correction structuré

La correction a suivi un planning en deux phases sur 5 jours ouvrés.

**Phase 1 (jours 1-2) — Bogues critiques :** résolution de BUG-001 et BUG-002, unblocking de la compilation et des tests. Validation par exécution locale de `flutter test`.

**Phase 2 (jours 3-5) — Bogues majeurs et mineurs :** résolution de BUG-003, BUG-004, BUG-005, BUG-006 et BUG-007. Validation par le pipeline CI (20/20 tests verts, formatting check passé).

### Validation et conformité

Chaque correction a été validée par le pipeline CI/CD GitHub Actions qui exécute automatiquement les 20 tests unitaires à chaque push. Le pipeline est passé de 0% de réussite (BUG-001 bloquant) à **100% (20/20 tests verts)** après application de l'ensemble des corrections. Aucune régression n'a été introduite lors des corrections.
