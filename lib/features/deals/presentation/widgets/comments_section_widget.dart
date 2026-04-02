import 'package:flutter/material.dart';
import '../../../comments/data/models/comment.dart';
import 'comment_form_widget.dart';
import 'comment_item_widget.dart';

class CommentsSectionWidget extends StatelessWidget {
  const CommentsSectionWidget({
    super.key,
    required this.comments,
    required this.commentCount,
    required this.isLoadingComments,
    required this.isSubmittingComment,
    required this.onSubmitComment,
  });

  final List<Comment> comments;
  final int commentCount;
  final bool isLoadingComments;
  final bool isSubmittingComment;
  final Future<void> Function(String content) onSubmitComment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Commentaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$commentCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CommentFormWidget(
            onSubmit: onSubmitComment,
            isSubmitting: isSubmittingComment,
          ),
          const SizedBox(height: 16),
          if (isLoadingComments)
            const Center(child: CircularProgressIndicator())
          else if (comments.isEmpty)
            const Text(
              'Soyez le premier à commenter ce deal.',
              style: TextStyle(color: Colors.grey),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => CommentItemWidget(comment: comments[index]),
            ),
        ],
      ),
    );
  }
}
