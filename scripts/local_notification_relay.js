/**
 * Relais de notifications — remplaçant local de la Cloud Function
 * `notifyNewDealInCategory` (functions/index.js), pour les projets restés
 * sur le plan gratuit Spark (les Cloud Functions v2 nécessitent Blaze).
 *
 * Principe : au lieu d'un trigger Firestore serveur (Cloud Functions), ce
 * script ouvre un listener temps réel côté client (Admin SDK) sur la
 * collection `deals` — un abonnement Firestore normal, gratuit sur tous les
 * plans, aucune facturation impliquée — et envoie lui-même la notification
 * FCM au topic de la catégorie dès qu'un nouveau deal est publié. La logique
 * (message, topic ciblé, payload data) est identique à la Cloud Function.
 *
 * Usage : à lancer sur la machine de démo, en arrière-plan, avant l'oral.
 *   cd scripts
 *   npm install
 *   node local_notification_relay.js
 *
 * Nécessite scripts/serviceAccountKey.json (voir README.md).
 *
 * ⚠️ Ce script est un palliatif de démo, pas un remplacement en production :
 * il doit tourner en continu sur une machine pour fonctionner (contrairement
 * à une Cloud Function). Dès que le projet passe sur Blaze, redéployer
 * `notifyNewDealInCategory` via `firebase deploy --only functions` et
 * arrêter ce script.
 */

const admin = require('firebase-admin');
const path = require('path');

const keyPath = process.argv[2] || path.join(__dirname, 'serviceAccountKey.json');

let serviceAccount;
try {
  serviceAccount = require(keyPath);
} catch (e) {
  console.error(
    `Impossible de lire la clé de compte de service : ${keyPath}\n` +
      'Voir scripts/README.md pour l\'obtenir.',
  );
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const db = admin.firestore();
const messaging = admin.messaging();

// Ne traite que les deals créés après le démarrage du script — évite de
// renvoyer une notification pour tout l'historique existant au lancement.
const startedAt = admin.firestore.Timestamp.now();

console.log(`Relais de notifications démarré (projet ${serviceAccount.project_id}).`);
console.log(`Écoute des nouveaux deals à partir de ${startedAt.toDate().toISOString()}...`);

db.collection('deals')
  .where('createdAt', '>', startedAt)
  .onSnapshot(
    (snapshot) => {
      for (const change of snapshot.docChanges()) {
        if (change.type !== 'added') continue;
        void notifyForDeal(change.doc.id, change.doc.data());
      }
    },
    (error) => {
      console.error('Erreur du listener Firestore :', error);
    },
  );

async function notifyForDeal(dealId, deal) {
  if (!deal || !deal.categoryId || !deal.title) return;

  const price = typeof deal.price === 'number' ? `${deal.price}€` : '';
  const topic = `category_${deal.categoryId}`;

  try {
    await messaging.send({
      topic,
      notification: {
        title: 'Nouveau deal !',
        body: price ? `${deal.title} — ${price}` : deal.title,
      },
      data: {
        dealId,
        categoryId: String(deal.categoryId),
      },
    });
    console.log(`✓ Notification envoyée sur "${topic}" pour "${deal.title}" (${dealId})`);
  } catch (e) {
    console.error(`✗ Échec d'envoi pour ${dealId} sur "${topic}" :`, e.message);
  }
}

process.on('SIGINT', () => {
  console.log('\nArrêt du relais.');
  process.exit(0);
});
