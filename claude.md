# Contexte projet — LeBonDeal / RNCP39583

## Profil

- **Étudiant** : Master 2 Développement Logiciel — YNOV Campus (filière Info)
- **Certification visée** : RNCP39583 "Expert en développement logiciel" (4 blocs, évaluation par jury externe)
- **Alternance** : Développeur Mainframe/COBOL chez CGI Bordeaux — client La Banque Postale (projet KYC/conformité), depuis octobre 2024, fin septembre 2026
- **Diplôme précédent** : Bachelor Cybersécurité — YNOV Bordeaux

## Projet support de la certification : LeBonDeal

App mobile communautaire de partage de bons plans (inspirée de Dealabs).

**Stack technique** :
- Flutter / Dart (frontend mobile)
- Firebase : Firestore, Auth, FCM, Cloud Functions (architecture serverless)

**État du code** : vibecoded sans historique Git propre → rétro-gitification nécessaire.

---

## Bloc 1 — Cadrer un projet

**Format** : oral 30 min (20 min exposé + 10 min jury)

**Compétences éliminatoires** : C1.1.1, C1.2.2, C1.3.2, C1.4.1, C1.6

**Statut** : dossier globalement validé ✅

**Corrections restantes** :
- Incohérence budgétaire : 25 300 € HT vs 27 830 € (avec maintenance)
- Commanditaire absent de la fiche C1.1.1
- Justification de la méthode de criticité des risques à renforcer

**Points à préparer pour l'oral** :
- Absence d'entretien client réel
- Estimations volumétriques Firestore
- Décomposition du scoring Flutter/Firebase 5/5
- Clarification de l'abréviation "j/h"

---

## Bloc 2 — Concevoir et développer

**Format** : dossier écrit (max 30 pages)

**Compétences éliminatoires** : C2.2.1, C2.2.2, C2.2.3, C2.3.1

**Points critiques en cours** :
- Tests unitaires : mockito + fake_cloud_firestore
- CI/CD : GitHub Actions
- Firestore Security Rules à documenter
- Accessibilité : WCAG 2.1 AA (pas RGAA — app mobile)
- Cahier de recettes : modèle AMQuiz, conventions AUTH-XXX, QUIZ-XXX, SEC-XXX

---

## Bloc 3 — Coordonner et piloter

**Format** : oral 45 min (30 min + 15 min jury + démo live)

**Compétences éliminatoires** : C3.1, C3.2.1, C3.4.2

**Livrables attendus** : méthodologie, planning, allocation ressources, outils de suivi, cas d'arbitrage, grille de compétences, indicateurs de satisfaction, démo logicielle live.

---

## Bloc 4 — Maintenir en condition opérationnelle

**Format** : dossier écrit (max 20 pages)

**Compétences éliminatoires** : C4.1.2, C4.2.1, C4.3.2

**Livrables attendus** : processus de mise à jour des dépendances, système de supervision/alertes, collecte et journalisation des anomalies, recommandations d'amélioration, journal des versions, exemple de ticket support résolu.

---

## Règles de validation RNCP

- 50 %+ de compétences acquises par bloc, aucune éliminatoire échouée
- Résultats possibles : **Admis** / **Ajourné** (rattrapage session suivante) / **Refusé** (< 50 % dans un bloc, pas de rattrapage)