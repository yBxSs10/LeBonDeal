import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../comments/data/models/comment.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';
import '../../data/datasources/remote/data_service.dart';
import '../widgets/deal_image_widget.dart';
import '../widgets/deal_temperature_widget.dart';
import '../widgets/deal_info_widget.dart';
import '../widgets/deal_stats_widget.dart';
import '../widgets/deal_description_widget.dart';
import '../widgets/comments_section_widget.dart';

class DealDetailPage extends StatefulWidget {
  const DealDetailPage({super.key, required this.deal});

  final Deal deal;

  @override
  State<DealDetailPage> createState() => _DealDetailPageState();
}

class _DealDetailPageState extends State<DealDetailPage> {
  bool _isSaved = false;
  int _temperature = 50;
  late int _commentCount;

  List<Comment> _comments = const [];
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.deal.comments;
    _loadComments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadComments() {
    final comments = DataService.getCommentsByDealId(widget.deal.id);
    setState(() {
      _comments = comments;
      _isLoadingComments = false;
    });
  }

  Future<void> _submitComment(String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connectez-vous pour commenter.')),
      );
      return;
    }

    setState(() => _isSubmittingComment = true);
    try {
      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dealId: widget.deal.id,
        author: user.displayName ?? user.email ?? 'Utilisateur',
        content: content,
        createdAt: DateTime.now(),
      );

      DataService.addComment(comment);

      setState(() {
        _comments = [comment, ..._comments];
        _commentCount += 1;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deal.title),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.favorite : Icons.favorite_border),
            onPressed: () => setState(() => _isSaved = !_isSaved),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DealImageWidget(imageUrl: widget.deal.imageUrl),
            DealTemperatureWidget(temperature: _temperature),
            DealInfoWidget(deal: widget.deal),
            DealStatsWidget(
              commentCount: _commentCount,
              favorites: widget.deal.favorites,
              shares: widget.deal.shares,
            ),
            DealDescriptionWidget(deal: widget.deal),
            CommentsSectionWidget(
              comments: _comments,
              commentCount: _commentCount,
              isLoadingComments: _isLoadingComments,
              isSubmittingComment: _isSubmittingComment,
              onSubmitComment: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}