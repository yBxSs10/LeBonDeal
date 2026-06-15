import 'package:flutter/material.dart';

class DealTemperatureWidget extends StatelessWidget {
  const DealTemperatureWidget({
    super.key,
    required this.temperature,
    required this.userVote,
    required this.onUpvote,
    required this.onDownvote,
    required this.canVote,
  });

  final int temperature;
  final int userVote; // 1 = upvoté, -1 = downvoté, 0 = pas voté
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final bool canVote; // false si non connecté ou anonyme

  bool get _isHot => temperature > 50;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _isHot ? Colors.red[50] : Colors.blue[50],
      child: Row(
        children: [
          // ── Bouton downvote ────────────────────────────────────────────
          _VoteButton(
            icon: Icons.ac_unit,
            activeColor: Colors.blue,
            isActive: userVote == -1,
            enabled: canVote,
            onTap: onDownvote,
            tooltip: 'Mauvais deal',
          ),
          const SizedBox(width: 12),

          // ── Température ───────────────────────────────────────────────
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isHot ? Icons.local_fire_department : Icons.ac_unit,
                  color: _isHot ? Colors.red : Colors.blue,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  '$temperature°',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isHot ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // ── Bouton upvote ─────────────────────────────────────────────
          _VoteButton(
            icon: Icons.local_fire_department,
            activeColor: Colors.red,
            isActive: userVote == 1,
            enabled: canVote,
            onTap: onUpvote,
            tooltip: 'Super deal !',
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.activeColor,
    required this.isActive,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color activeColor;
  final bool isActive;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : Colors.grey[400]!;
    return Tooltip(
      message: enabled ? tooltip : 'Connectez-vous pour voter',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
