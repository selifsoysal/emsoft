import 'package:emsoft/features/browser/presentation/controllers/browser_controller.dart';
import 'package:emsoft/features/browser/presentation/widgets/browser_error_view.dart';
import 'package:emsoft/features/browser/presentation/widgets/browser_offline_view.dart';
import 'package:emsoft/features/browser/presentation/widgets/browser_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class BrowserPage extends ConsumerStatefulWidget {
  const BrowserPage({super.key});

  @override
  ConsumerState<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(browserControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(browserControllerProvider);
    final controller = ref.read(browserControllerProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldPop = await controller.handleBackNavigation();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BrowserProgressIndicator(
                progress: state.progress,
                visible: state.isLoading,
              ),
              Expanded(
                child: _BrowserBody(
                  controller: controller.controller,
                  isOffline: state.isOffline,
                  hasError: state.hasError,
                  errorMessage: state.errorMessage,
                  onRetry: controller.reload,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrowserBody extends StatefulWidget {
  const _BrowserBody({
    required this.controller,
    required this.isOffline,
    required this.hasError,
    required this.errorMessage,
    required this.onRetry,
  });

  final WebViewController controller;
  final bool isOffline;
  final bool hasError;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  State<_BrowserBody> createState() => _BrowserBodyState();
}

class _BrowserBodyState extends State<_BrowserBody> {
  @override
  void initState() {
    super.initState();
    _configurePlatformController();
  }

  void _configurePlatformController() {
    final platformController = widget.controller.platform;
    if (platformController is AndroidWebViewController) {
      platformController.setMediaPlaybackRequiresUserGesture(false);
    }

    if (platformController is WebKitWebViewController) {
      platformController.setAllowsBackForwardNavigationGestures(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOffline) {
      return BrowserOfflineView(
        onRetry: () => widget.onRetry(),
      );
    }

    if (widget.hasError) {
      return BrowserErrorView(
        message: widget.errorMessage ?? 'Beklenmeyen bir hata olustu.',
        onRetry: () => widget.onRetry(),
      );
    }

    return WebViewWidget(controller: widget.controller);
  }
}
