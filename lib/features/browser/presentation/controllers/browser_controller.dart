import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emsoft/core/config/app_config.dart';
import 'package:emsoft/features/browser/domain/browser_state.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'browser_controller.g.dart';

const _externalSchemes = {'tel', 'mailto', 'sms', 'whatsapp', 'geo'};

@Riverpod(keepAlive: true)
class BrowserController extends _$BrowserController {
  WebViewController? _controller;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  BrowserState build() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_handleConnectivityChange);

    ref.onDispose(() {
      _connectivitySubscription?.cancel();
    });

    return const BrowserState();
  }

  WebViewController get controller {
    final existing = _controller;
    if (existing != null) {
      return existing;
    }

    final webViewController = WebViewController(
      onPermissionRequest: _onPermissionRequest,
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8FAFC))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: _onProgress,
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.initialUrl));

    _controller = webViewController;
    return webViewController;
  }

  Future<void> initialize() async {
    final results = await Connectivity().checkConnectivity();
    if (_isOffline(results)) {
      state = state.copyWith(status: BrowserStatus.offline, progress: 0);
      return;
    }

    controller;
  }

  Future<bool> handleBackNavigation() async {
    final webViewController = _controller;
    if (webViewController == null) {
      return true;
    }

    if (await webViewController.canGoBack()) {
      await webViewController.goBack();
      return false;
    }

    return true;
  }

  Future<void> reload() async {
    final results = await Connectivity().checkConnectivity();
    if (_isOffline(results)) {
      state = state.copyWith(
        status: BrowserStatus.offline,
        progress: 0,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      status: BrowserStatus.loading,
      progress: 0,
      clearError: true,
    );
    await _controller?.reload();
  }

  void _onProgress(int value) {
    final progress = value / 100;
    state = state.copyWith(
      status: BrowserStatus.loading,
      progress: progress,
    );
  }

  void _onPageStarted(String url) {
    state = state.copyWith(
      status: BrowserStatus.loading,
      progress: 0,
      clearError: true,
    );
  }

  Future<void> _onPageFinished(String url) async {
    final webViewController = _controller;
    final canGoBack = webViewController != null
        ? await webViewController.canGoBack()
        : false;

    state = state.copyWith(
      status: BrowserStatus.ready,
      progress: 1,
      canGoBack: canGoBack,
      clearError: true,
    );
  }

  void _onWebResourceError(WebResourceError error) {
    if (error.isForMainFrame != true) {
      return;
    }

    state = state.copyWith(
      status: BrowserStatus.error,
      errorMessage: error.description,
    );
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) {
      return NavigationDecision.prevent;
    }

    // Iframe/subframe content (captcha widgets, embedded maps, payment
    // widgets, etc.) must always load inline, regardless of its host.
    if (!request.isMainFrame) {
      return NavigationDecision.navigate;
    }

    // Schemes a WebView cannot render on its own hand off to the
    // matching native app; everything else (including cross-origin
    // redirects that are part of the site's own login/payment flow)
    // stays inside the WebView so the session/cookies are preserved.
    if (_externalSchemes.contains(uri.scheme)) {
      unawaited(_launchExternally(uri));
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _launchExternally(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _onPermissionRequest(WebViewPermissionRequest request) {
    request.grant();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (_isOffline(results)) {
      state = state.copyWith(status: BrowserStatus.offline, progress: 0);
      return;
    }

    if (state.isOffline) {
      reload();
    }
  }

  bool _isOffline(List<ConnectivityResult> results) {
    return results.every((result) => result == ConnectivityResult.none);
  }
}
