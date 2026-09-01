enum BrowserStatus {
  loading,
  ready,
  offline,
  error,
}

class BrowserState {
  const BrowserState({
    this.status = BrowserStatus.loading,
    this.progress = 0,
    this.canGoBack = false,
    this.errorMessage,
  });

  final BrowserStatus status;
  final double progress;
  final bool canGoBack;
  final String? errorMessage;

  bool get isLoading => status == BrowserStatus.loading;
  bool get hasError => status == BrowserStatus.error;
  bool get isOffline => status == BrowserStatus.offline;

  BrowserState copyWith({
    BrowserStatus? status,
    double? progress,
    bool? canGoBack,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BrowserState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
