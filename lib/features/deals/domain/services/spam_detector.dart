/// Détection heuristique de deals suspects — pas de blocage : un deal
/// détecté comme suspect est publié normalement puis signalé automatiquement
/// pour revue par un modérateur (voir AddDealBloc.submitDeal), afin d'éviter
/// qu'un faux positif ne bloque un auteur légitime sans recours.
class SpamCheckResult {
  const SpamCheckResult({required this.isSuspicious, required this.reasons});

  final bool isSuspicious;
  final List<String> reasons;
}

class SpamDetector {
  const SpamDetector._();

  static const _bannedPhrases = [
    'argent facile',
    'gagnez de l\'argent',
    'gagner au loto',
    'crédit immédiat',
    'prêt facile',
    'cliquez ici',
    'gratuit garanti',
    'bitcoin gratuit',
    'casino',
    'viagra',
  ];

  static SpamCheckResult check({
    required String title,
    required String description,
  }) {
    final reasons = <String>[];
    final combined = '$title $description';
    final lower = combined.toLowerCase();

    for (final phrase in _bannedPhrases) {
      if (lower.contains(phrase)) {
        reasons.add('Expression suspecte détectée : "$phrase"');
      }
    }

    final letters = title.replaceAll(RegExp('[^a-zA-ZÀ-ÿ]'), '');
    if (letters.length >= 8) {
      final upper = letters.replaceAll(RegExp('[^A-ZÀ-Þ]'), '');
      if (upper.length / letters.length > 0.7) {
        reasons.add('Titre majoritairement en majuscules');
      }
    }

    if (RegExp(r'(.)\1{4,}').hasMatch(combined)) {
      reasons.add('Caractères répétés de façon suspecte');
    }

    return SpamCheckResult(isSuspicious: reasons.isNotEmpty, reasons: reasons);
  }
}
