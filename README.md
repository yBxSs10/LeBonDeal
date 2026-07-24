# 🛍️ LeBonDeal — Application mobile de bons plans
 
> Application mobile communautaire de partage de bons plans, développée avec Flutter et Firebase
 
## 📋 Table des matières
- [🖥️ Environnement & installation](#️-environnement--installation)
- [🧪 Tests](#-tests)
- [⚙️ CI/CD](#️-cicd)
- [🔐 Sécurité & Accessibilité](#-sécurité--accessibilité)
- [🗂️ Architecture](#️-architecture)
- [📚 Fonctionnalités](#-fonctionnalités)
- [🧭 Choix technologiques](#-choix-technologiques)
- [📝 Rapport de bogue](#-rapport-de-bogue)
- [📋 Changelog](CHANGELOG.md)
---
 
## 🖥️ Environnement & installation
 
| Outil | Version |
|---|---|
| Flutter / Dart | 3.x stable (CI : 3.44.2) |
| Android SDK | API 34 |
| Firebase CLI | 13.x |
| Firestore + Cloud Functions | `europe-west1` |
 
> Architecture serverless : Firebase (Firestore, Auth, Cloud Functions) joue le rôle de serveur d'application, managé par Google Cloud.
 
```bash
flutter pub get              # installer les dépendances
flutter doctor                # vérifier l'installation
 
flutter run                   # lancer (device détecté automatiquement, ou -d chrome / iOS simulator)
flutter build apk --release   # build de production
```
 
---
 
## 🧪 Tests
 
**98 tests** (68 unitaires domain/data + 30 widgets presentation), tous verts en CI.
 
```bash
flutter test --coverage
```
 
```
test/
├── features/auth/          # USER-001→007, AUTH-001→007, AUTH-P01→07
├── features/categories/    # CAT-001
├── features/comments/      # COM-001→002
├── features/reports/       # REP-001→003
├── features/profile/       # PROF-001→002
├── features/deals/         # DEAL-001→024, BLOC-001→005
└── features/security/      # SEC-001→010
```
 
---
 
## ⚙️ CI/CD
 
Pipeline GitHub Actions (`.github/workflows/ci.yml`), déclenché sur push (`main`, `develop`) et PR vers `main` :
 
```
checkout → flutter setup → pub get → format → analyze → test (98, bloquant) → coverage → upload artifact → verify monitoring deps
      └── job build (si test ✅) : APK debug → artefact GitHub Actions (7 jours)
```
 
Développement actuellement en solo (push direct sur `main`) ; le pipeline sert de garde-fou avant chaque évolution. Le modèle `develop`/`feature`/`hotfix` est déjà pris en charge par la CI, en anticipation d'une équipe à plusieurs contributeurs.
 
---
 
## 🔐 Sécurité & Accessibilité
 
- Firestore Security Rules : deny-by-default, `authorId == request.auth.uid` à chaque écriture, comptes anonymes bloqués serveur (pas seulement client) pour vote/commentaire/publication
- Rôles `user`/`moderator`/`admin`, attribution manuelle uniquement (Firebase Console)
- Anti-spam : limite de fréquence de publication + détection automatique (`SpamDetector`)
- **WCAG 2.1 AA** : labels `Semantics`, compatible TalkBack / VoiceOver
Détail complet (OWASP Mobile Top 10, règles Firestore) : voir dossier de certification §4.
 
---
 
## 🗂️ Architecture
 
```
lib/
├── core/                    # DI (GetIt), thème Material 3, navigation
└── features/
    ├── auth/ deals/ categories/ comments/ reports/ profile/
    #  domain (repository, usecases) / data / presentation — par feature
```
 
Clean Architecture stricte sur les 6 features : la présentation ne dépend que d'interfaces domain (usecases), jamais directement de Firestore/FirebaseAuth.
 
---
 
## 📚 Fonctionnalités
 
Authentification (email + Google + anonyme) · Feed temps réel, recherche, filtres · Publication de deal · Favoris · Commentaires · Signalement + modération · Détection de spam · Notifications push par catégorie (code complet, déploiement Cloud Function en attente — voir CHANGELOG).
 
Suivi détaillé fonctionnalité ↔ user story (MoSCoW) : voir dossier de certification.
 
---
 
## 🧭 Choix technologiques
 
| Choix | Face à | Raison principale |
|---|---|---|
| Flutter/Dart | React Native, natif | Un seul codebase, perf proche du natif, Semantics natif (WCAG) |
| Firebase | Backend custom, Supabase | Serverless, temps réel natif, tier gratuit suffisant en MVP |
| Clean Architecture | Couches simples | Domain testable sans mock Firebase |
| GetIt/Injectable | Provider seul | Singleton Firestore par session, mocks facilités en test |
 
Justification complète : dossier de certification §10.2.
 
---
 
## 📝 Rapport de bogue
 
Template GitHub Issue : référence recette (AUTH-XXX/DEAL-XXX/SEC-XXX), sévérité, priorité, cause, plan de correction, critère de validation.
 
→ [Créer un rapport de bogue](.github/ISSUE_TEMPLATE/bug_report.md)
