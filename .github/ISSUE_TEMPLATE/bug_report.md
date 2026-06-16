---
name: Rapport de bogue
about: Signaler une anomalie détectée lors de la recette ou en production
title: "[BUG] "
labels: bug
assignees: ''
---

## Identification

**Référence recette :** <!-- ex. AUTH-003, DEAL-007, SEC-002 -->
**Composant affecté :** <!-- auth / deals / comments / security / CI -->
**Version / build :** <!-- ex. 1.0.0 / build #12 -->

---

## Qualification

**Sévérité :**
- [ ] Critique — blocage total, données corrompues
- [ ] Majeure — fonctionnalité inutilisable
- [ ] Mineure — dégradation partielle
- [ ] Cosmétique — affichage uniquement

**Priorité :**
- [ ] P1 — à corriger immédiatement
- [ ] P2 — prochain sprint
- [ ] P3 — backlog

---

## Description de l'anomalie

**Comportement observé :**
<!-- Décrivez précisément ce qui se passe -->

**Comportement attendu :**
<!-- Décrivez ce qui devrait se passer selon le cahier de recettes -->

**Étapes de reproduction :**
1.
2.
3.

**Environnement :**
- OS : <!-- ex. Android 13, iOS 17 -->
- Build Flutter : <!-- ex. stable 3.x.x -->

---

## Analyse

**Cause identifiée :**
<!-- Couche concernée : présentation / domaine / data / règles Firestore -->

**Points d'amélioration associés :**
<!-- Risques de régression, autres cas limites à surveiller -->

---

## Plan de correction

**Correction proposée :**
<!-- Description technique de la correction -->

**Tests à ajouter / modifier :**
<!-- Cas de test couvrant le scénario pour éviter la régression -->

**Critère de validation :**
<!-- Comment vérifier que le bogue est résolu et le comportement conforme -->
