class ReportEntity {
  const ReportEntity({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.targetTitle,
    required this.reason,
    required this.authorId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String targetId;
  final String targetType; // 'deal'
  final String targetTitle; // snapshot pris à la création du signalement
  final String reason;
  final String authorId;
  final String status; // 'pending' | 'resolved'
  final DateTime createdAt;

  bool get isPending => status == 'pending';
}
