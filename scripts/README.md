# Scripts

## seed_demo_data.js

Peuple Firestore + Auth avec des données de démo (deals, commentaires, un vote, un
signalement en attente, un compte utilisateur et un compte modérateur) pour que le
feed/vote/commentaire/modération soient immédiatement démontrables à l'oral, sans
dépendre d'un compte créé en direct.

### Prérequis

1. Récupérer une clé de compte de service depuis la Firebase Console :
   Paramètres du projet → Comptes de service → Générer une nouvelle clé privée.
   Sauvegarder le fichier téléchargé sous `scripts/serviceAccountKey.json`
   (déjà exclu de git — ne jamais le commiter).
2. Installer les dépendances :
   ```bash
   cd scripts
   npm install
   ```

### Exécution

```bash
node seed_demo_data.js
# ou avec un chemin de clé différent :
node seed_demo_data.js /chemin/vers/serviceAccountKey.json
```

Le script est réexécutable sans risque : les comptes déjà existants sont réutilisés
(pas de doublon), mais chaque exécution recrée un nouveau lot de 6 deals.

### Identifiants créés

| Rôle | Email | Mot de passe |
|---|---|---|
| Utilisateur | `demo.user@lebondeal.test` | `DemoUser123!` |
| Modérateur | `demo.moderator@lebondeal.test` | `DemoModo123!` |

À utiliser pour se connecter en direct pendant la démo (feature 1), publier/voter/
commenter (features 2 et 4), et accéder à l'écran Modération (feature 6, réservé au
rôle `moderator`/`admin`).

## local_notification_relay.js

Remplaçant local de la Cloud Function `notifyNewDealInCategory` (`functions/index.js`),
pour la démo tant que le projet Firebase reste sur le plan gratuit **Spark** (les
Cloud Functions v2 nécessitent le plan Blaze — voir `functions/README` / CHANGELOG).

Au lieu d'un trigger serveur, ce script ouvre un simple listener Firestore temps réel
(comme le fait l'app cliente elle-même — gratuit sur tous les plans) et envoie la
notification FCM au topic de la catégorie dès qu'un nouveau deal apparaît. Même
logique, même format de message que la Cloud Function.

### Utilisation pour la démo

1. Sur la machine de démo, avant l'oral :
   ```bash
   cd scripts
   npm install
   node local_notification_relay.js
   ```
   Laisser tourner en arrière-plan pendant toute la présentation.
2. Sur l'appareil de démo, dans l'app : Profil → Notifications par catégorie →
   suivre une catégorie (ex. High-Tech).
3. Publier un deal dans cette catégorie (feature 2) → la notification arrive sur
   l'appareil en quelques secondes (feature 5), envoyée par ce script.

### Retour à la Cloud Function réelle

Dès que le projet passe sur Blaze :
```bash
firebase deploy --only functions
```
puis arrêter ce script — la Cloud Function prend le relais automatiquement (même
topic, même format), sans changement côté app.
