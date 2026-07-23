# Changelog — LeBonDeal

Toutes les évolutions notables du projet sont documentées ici.  
Format : [version] — date — description

---

## [1.1.0] — 2026-07-23

### Ajouté
- Notifications push FCM (`firebase_messaging`) — permission, token, handlers foreground/background/terminated, guard non-mobile
- Ciblage des notifications par catégorie : écran "Notifications par catégorie" (profil), abonnement/désabonnement aux topics FCM par catégorie, persistance `users/{uid}.followedCategoryIds`
- Cloud Function `notifyNewDealInCategory` (`functions/index.js`) — publie sur le topic de la catégorie à chaque création de deal (non déployée — code testé via émulateurs Firestore + Functions)
- Traçabilité fonctionnalités ↔ user stories MoSCoW (C1.4.1) dans le README

### Corrigé
- Incompatibilité `fake_cloud_firestore` (^4.1.0 → ^4.2.0) avec la signature générique `WriteBatch.update<T>` de `cloud_firestore` 6.7.x — cause réelle du conflit précédemment attribué à `firebase_core ^4.x` (voir revert `37aa4c0`)
- Blocage de reconnexion après déconnexion (invité ou email) : `login_page.dart` remplaçait `_AuthGate` (le routeur réactif basé sur `authStateChanges()`) via un `Navigator.pushReplacement` manuel, et le bouton "Se connecter" de l'état déconnecté ciblait une route nommée `/login` jamais enregistrée
- Étiquette "NEW" affichée indéfiniment sur les anciens deals et ancienneté affichée uniquement en heures (ex. "il y a 888h") — ajout de `Deal.timeAgoLabel` (h/j/semaines/mois) et `Deal.shouldShowBadge` (le badge NEW expire après 24h, HOT reste permanent)

### Documenté
- Serveur d'application identifié explicitement (Firestore + Cloud Functions, architecture serverless)
- Périmètre réel du déploiement continu (build + artefact APK, pas encore de livraison automatisée vers un store)
- Protocole de branches aligné sur le workflow réel (développement solo, push direct sur `main`)

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
- Pipeline CI/CD GitHub Actions — format, lint, 47 tests unitaires, build APK
- Template de rapport de bogue GitHub Issue
- 47 tests unitaires : USER-001→007, AUTH-001→005, AUTH-P01→P06, DEAL-001→018, BLOC-001→005, SEC-001→005

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
