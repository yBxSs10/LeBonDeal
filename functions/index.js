const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();
setGlobalOptions({region: "europe-west1", maxInstances: 10});

// Envoie une notification push aux abonnés du topic de la catégorie
// concernée à chaque création d'un deal.
//
// Topic ciblé : `category_<categoryId>`. L'app s'y abonne côté client via
// NotificationService.subscribeToCategory() (lib/core/services/notification_service.dart),
// déclenché depuis l'écran "Notifications par catégorie" du profil.
exports.notifyNewDealInCategory = onDocumentCreated(
    "deals/{dealId}",
    async (event) => {
      const deal = event.data?.data();
      if (!deal || !deal.categoryId || !deal.title) return;

      const price = typeof deal.price === "number" ? `${deal.price}€` : "";

      await getMessaging().send({
        topic: `category_${deal.categoryId}`,
        notification: {
          title: "Nouveau deal !",
          body: price ? `${deal.title} — ${price}` : deal.title,
        },
        data: {
          dealId: event.params.dealId,
          categoryId: String(deal.categoryId),
        },
      });
    },
);
