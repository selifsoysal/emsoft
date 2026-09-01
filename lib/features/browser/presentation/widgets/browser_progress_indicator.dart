import 'package:emsoft/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BrowserProgressIndicator extends StatelessWidget {
  const BrowserProgressIndicator({
    super.key,
    required this.progress,
    required this.visible,
  });

  final double progress;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(
      value: progress > 0 && progress < 1 ? progress : null,
      minHeight: 2,
      backgroundColor: AppTheme.background,
      color: AppTheme.primary,
    );
  }
}
