import 'package:emsoft/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BrowserErrorView extends StatelessWidget {
  const BrowserErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppTheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Sayfa yuklenemedi',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceMuted,
                  ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
