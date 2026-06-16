import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
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
  bool _isSubmittingComment = false;

  // ── Streams vote ────────────────────────────────────────────────────────────
  StreamSubscription<int>? _temperatureSub;
  StreamSubscription<int>? _userVoteSub;
  StreamSubscription<Deal?>? _dealSub;
  int _temperature = 50;
  int _userVote = 0;
  int _favorites = 0;
  int _shares = 0;

  User? get _user => FirebaseAuth.instance.currentUser;
  bool get _canVote => _user != null && !_user!.isAnonymous;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
    _subscribeToTemperature();
  }

  @override
  void dispose() {
    _temperatureSub?.cancel();
    _userVoteSub?.cancel();
    _dealSub?.cancel();
    super.dispose();
  }

  void _subscribeToTemperature() {
    // Stream direct sur le deal — température + favoris + partages en temps réel
    _dealSub = getIt<FirestoreService>().getDealStream(widget.deal.id).listen((
      deal,
    ) {
      if (mounted && deal != null) {
        setState(() {
          _temperature = deal.temperature;
          _favorites = deal.favorites;
          _shares = deal.shares;
        });
      }
    });

    // Stream sur le vote de l'utilisateur courant
    if (_canVote) {
      _userVoteSub = getIt<FirestoreService>()
          .getUserVoteStream(_user!.uid, widget.deal.id)
          .listen((v) {
            if (mounted) setState(() => _userVote = v);
          });
    }
  }

  Future<void> _loadSavedState() async {
    if (!_canVote) return;
    final ids = await getIt<FirestoreService>()
        .getSavedDealIdsStream(_user!.uid)
        .first;
    if (mounted) setState(() => _isSaved = ids.contains(widget.deal.id));
  }

  Future<void> _toggleSave() async {
    if (!_canVote) return;
    await getIt<FirestoreService>().toggleSavedDeal(
      _user!.uid,
      widget.deal.id,
      _isSaved,
    );
    if (mounted) setState(() => _isSaved = !_isSaved);
  }

  Future<void> _vote(int value) async {
    if (!_canVote) return;
    await getIt<FirestoreService>().voteOnDeal(
      _user!.uid,
      widget.deal.id,
      value,
    );
  }

  Future<void> _submitComment(String content) async {
    if (_user == null || _user!.isAnonymous) {
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
        author: _user!.displayName ?? _user!.email ?? 'Utilisateur',
        content: content,
        createdAt: DateTime.now(),
      );
      await getIt<FirestoreService>().addComment(comment, _user!.uid);
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
            DealTemperatureWidget(
              temperature: _temperature,
              userVote: _userVote,
              onUpvote: () => _vote(1),
              onDownvote: () => _vote(-1),
              canVote: _canVote,
            ),
            DealInfoWidget(deal: widget.deal),
            StreamBuilder<List<Comment>>(
              stream: getIt<FirestoreService>().getCommentsStream(
                widget.deal.id,
              ),
              builder: (context, snapshot) {
                final comments = snapshot.data ?? [];
                final count = comments.length;
                return Column(
                  children: [
                    DealStatsWidget(
                      commentCount: count,
                      favorites: _favorites,
                      shares: _shares,
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
