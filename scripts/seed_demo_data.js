/**
 * Seed de données de démo — LeBonDeal
 *
 * Peuple le projet Firebase (Firestore + Auth) avec :
 *  - 2 comptes de test (1 utilisateur, 1 modérateur)
 *  - 6 deals variés (catégories, prix, ancienneté) pour un feed non vide
 *  - quelques commentaires et un vote pour ne pas démarrer à zéro
 *  - 1 signalement "pending" pour démontrer la modération sans attendre
 *
 * Usage :
 *   cd scripts
 *   npm install
 *   node seed_demo_data.js /chemin/vers/serviceAccountKey.json
 *
 * Le fichier serviceAccountKey.json s'obtient dans la Firebase Console :
 * Paramètres du projet > Comptes de service > Générer une nouvelle clé privée.
 * Il ne doit jamais être commité (déjà exclu par .gitignore).
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
      'Génère-la depuis Firebase Console > Paramètres du projet > Comptes de service, ' +
      'puis relance : node seed_demo_data.js /chemin/vers/serviceAccountKey.json',
  );
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const db = admin.firestore();
const auth = admin.auth();

const DEMO_USER = {
  email: 'demo.user@lebondeal.test',
  password: 'DemoUser123!',
  displayName: 'Alex Demo',
};

const DEMO_MODERATOR = {
  email: 'demo.moderator@lebondeal.test',
  password: 'DemoModo123!',
  displayName: 'Sam Modérateur',
};

async function upsertAuthUser({ email, password, displayName }) {
  try {
    const user = await auth.createUser({ email, password, displayName, emailVerified: true });
    console.log(`✓ Compte créé : ${email} (${user.uid})`);
    return user;
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      const user = await auth.getUserByEmail(email);
      console.log(`= Compte déjà existant : ${email} (${user.uid})`);
      return user;
    }
    throw e;
  }
}

async function upsertUserProfile(uid, { email, displayName }, role) {
  await db
    .collection('users')
    .doc(uid)
    .set(
      {
        email,
        displayName,
        role,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  console.log(`✓ Profil Firestore users/${uid} (role=${role})`);
}

function hoursAgo(h) {
  return admin.firestore.Timestamp.fromDate(new Date(Date.now() - h * 3600_000));
}

function buildDeals(authorId, authorName) {
  return [
    {
      title: 'MacBook Pro M3 14" -32%',
      description: "MacBook Pro M3, 16 Go RAM, 512 Go SSD. Reconditionné grade A, garantie 2 ans.",
      price: 1699,
      originalPrice: 2499,
      discountPercent: 32,
      imageUrl: 'https://picsum.photos/seed/macbook-deal/600/400',
      storeName: 'Apple Store',
      categoryId: 'high-tech',
      badge: 'HOT',
      temperature: 187,
      hours: 3,
    },
    {
      title: 'Casque Sony WH-1000XM5 -28%',
      description: 'Réduction de bruit active, autonomie 30h, coloris noir.',
      price: 279,
      originalPrice: 389,
      discountPercent: 28,
      imageUrl: 'https://picsum.photos/seed/sony-headphones/600/400',
      storeName: 'Fnac',
      categoryId: 'high-tech',
      badge: 'NEW',
      temperature: 64,
      hours: 1,
    },
    {
      title: 'SSD interne 2 To NVMe -40%',
      description: 'Lecture 7000 Mo/s, idéal upgrade PC ou PS5.',
      price: 89,
      originalPrice: 149,
      discountPercent: 40,
      imageUrl: 'https://picsum.photos/seed/ssd-deal/600/400',
      storeName: 'LDLC',
      categoryId: 'informatique',
      badge: 'HOT',
      temperature: 142,
      hours: 6,
    },
    {
      title: 'Sneakers running -45%',
      description: 'Paire running amorti, plusieurs coloris disponibles.',
      price: 54,
      originalPrice: 99,
      discountPercent: 45,
      imageUrl: 'https://picsum.photos/seed/sneakers-deal/600/400',
      storeName: 'Decathlon',
      categoryId: 'sports',
      badge: 'NEW',
      temperature: 38,
      hours: 2,
    },
    {
      title: 'Vol Paris–Lisbonne aller-retour -35%',
      description: 'Départ flexible sur les 3 prochains mois, bagage cabine inclus.',
      price: 89,
      originalPrice: 137,
      discountPercent: 35,
      imageUrl: 'https://picsum.photos/seed/flight-deal/600/400',
      storeName: 'TAP Air Portugal',
      categoryId: 'voyages',
      badge: 'NEW',
      temperature: 51,
      hours: 5,
    },
    {
      title: 'Robot cuiseur multifonction -30%',
      description: '12 programmes automatiques, bol inox 4,5L.',
      price: 279,
      originalPrice: 399,
      discountPercent: 30,
      imageUrl: 'https://picsum.photos/seed/cooker-deal/600/400',
      storeName: 'Boulanger',
      categoryId: 'maison',
      badge: 'NEW',
      temperature: 45,
      hours: 8,
    },
  ].map((d) => ({
    ...d,
    author: authorName,
    authorId,
    comments: 0,
    favorites: 0,
    shares: 0,
    isTrending: d.temperature > 100,
    isPopular: d.temperature > 60,
    createdAt: hoursAgo(d.hours),
  }));
}

async function seedDeals(authorId, authorName) {
  const deals = buildDeals(authorId, authorName);
  const dealRefs = [];
  for (const deal of deals) {
    const { hours, ...data } = deal;
    const ref = await db.collection('deals').add(data);
    dealRefs.push({ ref, data });
    console.log(`✓ Deal créé : ${data.title} (${ref.id})`);
  }
  return dealRefs;
}

async function seedComments(dealRef, commenterId, commenterName) {
  const comments = [
    'Merci pour le partage, commandé direct !',
    'Le prix est encore dispo ce matin, code toujours valide.',
  ];
  for (const content of comments) {
    await db.collection('comments').add({
      dealId: dealRef.id,
      author: commenterName,
      authorId: commenterId,
      content,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  await dealRef.update({ comments: admin.firestore.FieldValue.increment(comments.length) });
  console.log(`✓ ${comments.length} commentaires ajoutés sur ${dealRef.id}`);
}

async function seedVote(dealRef, voterId) {
  await dealRef.collection('votes').doc(voterId).set({ value: 1 });
  console.log(`✓ Vote (+1) ajouté sur ${dealRef.id} par ${voterId}`);
}

async function seedReport(dealRef, dealTitle, reporterId) {
  await db.collection('reports').add({
    targetId: dealRef.id,
    targetType: 'deal',
    targetTitle: dealTitle,
    reason: 'Lien expiré ou invalide',
    authorId: reporterId,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log(`✓ Signalement "pending" créé sur ${dealRef.id}`);
}

async function main() {
  console.log(`Projet Firebase cible : ${serviceAccount.project_id}\n`);

  const demoUser = await upsertAuthUser(DEMO_USER);
  await upsertUserProfile(demoUser.uid, DEMO_USER, 'user');

  const demoModerator = await upsertAuthUser(DEMO_MODERATOR);
  await upsertUserProfile(demoModerator.uid, DEMO_MODERATOR, 'moderator');

  const dealRefs = await seedDeals(demoUser.uid, DEMO_USER.displayName);

  // Commentaires + vote sur le deal le plus "chaud" pour une démo vote/commentaire immédiate
  const hottest = dealRefs[0];
  await seedComments(hottest.ref, demoModerator.uid, DEMO_MODERATOR.displayName);
  await seedVote(hottest.ref, demoModerator.uid);

  // Signalement pré-existant sur un autre deal pour démontrer la modération sans attendre
  const flagged = dealRefs[3];
  await seedReport(flagged.ref, flagged.data.title, demoModerator.uid);

  console.log('\n✅ Seed terminé.');
  console.log(`Compte utilisateur démo : ${DEMO_USER.email} / ${DEMO_USER.password}`);
  console.log(`Compte modérateur démo  : ${DEMO_MODERATOR.email} / ${DEMO_MODERATOR.password}`);
  process.exit(0);
}

main().catch((e) => {
  console.error('Échec du seed :', e);
  process.exit(1);
});
