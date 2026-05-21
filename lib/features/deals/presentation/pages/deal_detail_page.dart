import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../comments/data/models/comment.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';
import '../../data/datasources/remote/firestore_service.dart';
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
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    final ids = await FirestoreService.getSavedDealIdsStream(user.uid).first;
    if (mounted) setState(() => _isSaved = ids.contains(widget.deal.id));
  }

  Future<void> _toggleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    await FirestoreService.toggleSavedDeal(user.uid, widget.deal.id, _isSaved);
    if (mounted) setState(() => _isSaved = !_isSaved);
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
        id: '',
        dealId: widget.deal.id,
        author: user.displayName ?? user.email ?? 'Utilisateur',
        content: content,
        createdAt: DateTime.now(),
      );
      await FirestoreService.addComment(comment, user.uid);
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
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
            onPressed: _toggleSave,
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DealImageWidget(imageUrl: widget.deal.imageUrl),
            DealTemperatureWidget(temperature: _temperature),
            DealInfoWidget(deal: widget.deal),
            StreamBuilder<List<Comment>>(
              stream: FirestoreService.getCommentsStream(widget.deal.id),
              builder: (context, snapshot) {
                final comments = snapshot.data ?? [];
                final count = comments.length;
                return Column(
                  children: [
                    DealStatsWidget(
                      commentCount: count,
                      favorites: widget.deal.favorites,
                      shares: widget.deal.shares,
                    ),
                    DealDescriptionWidget(deal: widget.deal),
                    CommentsSectionWidget(
                      comments: comments,
                      commentCount: count,
                      isLoadingComments:
                          snapshot.connectionState == ConnectionState.waiting,
                      isSubmittingComment: _isSubmittingComment,
                      onSubmitComment: _submitComment,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
