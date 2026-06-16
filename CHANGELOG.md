# Changelog — LeBonDeal

Toutes les évolutions notables du projet sont documentées ici.  
Format : [version] — date — description

---

## [1.0.0] — 2026-06-16

### Ajouté
- Authentification email/mot de passe (Firebase Auth)
- Feed de deals avec streaming Firestore temps réel
- Détail d'un deal : prix, remise, commentaires
- Publication de deal (utilisateurs authentifiés uniquement)
- Favoris — sauvegarde et retrait de deals
- Page profil utilisateur
- Navigation par onglets : Accueil, Tendances, Sauvegardés, Profil
- Firestore Security Rules — modèle de rôles user / moderator / admin
- Accessibilité WCAG 2.1 AA — labels Semantics Flutter
- Firebase Crashlytics — remontée automatique des crashs
- Firebase Performance Monitoring — suivi des temps de réponse
- Pipeline CI/CD GitHub Actions — format, lint, 20 tests unitaires, build APK
- Template de rapport de bogue GitHub Issue
- 20 tests unitaires : AUTH-001→005, DEAL-001→009, SEC-001→005

### Modifié
- Migration de la couche data : mock DataService → streams Firestore réels
- Suppression du mock data layer après stabilisation des tests

### Corrigé
- Incompatibilité `font_awesome_flutter` avec Flutter 3.44 (`IconData` final)

---

## [0.3.0] — 2026-05-20

### Ajouté
- Architecture Clean Architecture — séparation domain / data / presentation
- Injection de dépendances GetIt / Injectable
- Modèle de commentaires

---

## [0.2.0] — 2026-04-15

### Ajouté
- Configuration Firebase (Android, iOS, Web)
- Modèles de données : Deal, Category, User
- Navigation principale

---

## [0.1.0] — 2026-03-01

### Ajouté
- Initialisation du projet Flutter
- Configuration des cibles Android, iOS et Web
- Intégration des assets (logo, images)
