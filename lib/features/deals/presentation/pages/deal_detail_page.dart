import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/domain/domain.dart';
import '../../../comments/domain/domain.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';
import '../widgets/deal_image_widget.dart';
import '../widgets/deal_temperature_widget.dart';
import '../widgets/deal_info_widget.dart';
import '../widgets/deal_stats_widget.dart';
import '../widgets/deal_description_widget.dart';
import '../widgets/comments_section_widget.dart';
import 'package:lebondeal/features/reports/presentation/widgets/report_dialog.dart';

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

  UserEntity? get _user => getIt<AuthRepository>().currentUser;
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
    _dealSub = GetDealUseCase(getIt<DealRepository>())(widget.deal.id).listen((
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
      _userVoteSub =
          GetUserVoteUseCase(getIt<DealRepository>())(
            _user!.id,
            widget.deal.id,
          ).listen((v) {
            if (mounted) setState(() => _userVote = v);
          });
    }
  }

  Future<void> _loadSavedState() async {
    if (!_canVote) return;
    final ids = await GetSavedDealIdsUseCase(getIt<DealRepository>())(
      _user!.id,
    ).first;
    if (mounted) setState(() => _isSaved = ids.contains(widget.deal.id));
  }

  Future<void> _toggleSave() async {
    if (!_canVote) return;
    await ToggleSavedDealUseCase(getIt<DealRepository>())(
      _user!.id,
      widget.deal.id,
      _isSaved,
    );
    if (mounted) setState(() => _isSaved = !_isSaved);
  }

  Future<void> _shareDeal() async {
    await SharePlus.instance.share(
      ShareParams(
        title: widget.deal.title,
        text:
            '${widget.deal.title} — ${widget.deal.priceLabel} chez ${widget.deal.storeName}\n\n${widget.deal.description}',
      ),
    );
    // Best-effort : le partage a déjà eu lieu côté OS, on ne bloque/alerte
    // jamais l'utilisateur si seul le compteur échoue à se mettre à jour.
    try {
      await IncrementDealShareCountUseCase(getIt<DealRepository>())(
        widget.deal.id,
      );
    } catch (_) {}
  }

  Future<void> _vote(int value) async {
    if (!_canVote) return;
    await VoteOnDealUseCase(getIt<DealRepository>())(
      _user!.id,
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
      final result = await AddCommentUseCase(getIt<CommentRepository>())(
        dealId: widget.deal.id,
        authorId: _user!.id,
        authorName: _user!.displayName ?? _user!.email,
        content: content,
      );
      if (mounted) {
        result.fold(
          (error) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error))),
          (_) {},
        );
      }
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
            tooltip: _isSaved ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: _toggleSave,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Partager ce deal',
            onPressed: _shareDeal,
          ),
          if (_user != null && _user!.id != widget.deal.authorId)
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Signaler ce deal',
              onPressed: () => showReportDealDialog(
                context,
                dealId: widget.deal.id,
                dealTitle: widget.deal.title,
              ),
            ),
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
            StreamBuilder<List<CommentEntity>>(
              stream: GetCommentsUseCase(getIt<CommentRepository>())(
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
