import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vistor_ai_mobile/app/theme.dart';

enum SyncState { synced, syncing, pending }

class SyncIndicator extends StatefulWidget {
  final SyncState state;
  final int? pendingCount;

  const SyncIndicator({
    super.key,
    required this.state,
    this.pendingCount,
  });

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.state == SyncState.syncing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SyncIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == SyncState.syncing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case SyncState.synced:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(LucideIcons.checkCircle, color: AppColors.success),
        );
      case SyncState.syncing:
        return RotationTransition(
          turns: _controller,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(LucideIcons.refreshCcw, color: AppColors.offline.withValues(alpha: 0.8)),
          ),
        );
      case SyncState.pending:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Badge(
            label: Text(widget.pendingCount?.toString() ?? '0'),
            isLabelVisible: widget.pendingCount != null && widget.pendingCount! > 0,
            child: const Icon(LucideIcons.alertCircle, color: AppColors.error),
          ),
        );
    }
  }
}
