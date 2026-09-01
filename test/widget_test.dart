import 'package:emsoft/core/config/app_config.dart';
import 'package:emsoft/features/browser/domain/browser_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('baslangic url dogru', () {
    expect(
      AppConfig.initialUrl,
      'https://www.emsoft.com.tr/giris_yap',
    );
  });

  test('browser varsayilan durumu yukleniyor', () {
    const state = BrowserState();
    expect(state.isLoading, isTrue);
    expect(state.progress, 0);
    expect(state.canGoBack, isFalse);
  });
}
