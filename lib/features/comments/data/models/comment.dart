class Comment {
  const Comment({
    required this.id,
    required this.dealId,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String dealId;
  final String author;
  final String content;
  final DateTime createdAt;
}
