class Report {
  const Report({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.targetTitle,
    required this.reason,
    required this.authorId,
    required this.status,
    required this.createdAt,
    this.resolvedBy,
    this.resolvedByName,
    this.resolvedAt,
    this.action,
  });

  final String id;
  final String targetId;
  final String targetType; // 'deal'
  final String targetTitle; // snapshot pris à la création du signalement
  final String reason;
  final String authorId;
  final String status; // 'pending' | 'resolved'
  final DateTime createdAt;
  final String? resolvedBy; // uid du modérateur ayant traité le signalement
  final String? resolvedByName; // snapshot d'affichage, comme targetTitle
  final DateTime? resolvedAt;
  final String? action; // 'dismissed' | 'deleted'

  bool get isPending => status == 'pending';
}
