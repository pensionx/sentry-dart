import 'dart:async';

import '../platform_checker.dart';

import '../protocol.dart';
import 'enricher.dart';
import 'dart:html' as html show window, Window;

final Enricher instance = WebEnricher(
  html.window,
  PlatformChecker(),
);

class WebEnricher implements Enricher {
  WebEnricher(
    this._window,
    this._platformChecker,
  );

  final html.Window _window;
  final PlatformChecker _platformChecker;

  @override
  FutureOr<SentryEvent> apply(
      SentryEvent event, bool hasNativeIntegration) async {
    // Web has no native integration, so no need to check for it

    final contexts = event.contexts.copyWith(
      device: await _getDevice(event.contexts.device),
      operatingSystem: _getOperatingSystem(event.contexts.operatingSystem),
      runtimes: _getRuntimes(event.contexts.runtimes),
    );

    return event.copyWith(
      contexts: contexts,
    );
  }

  Future<SentryDevice> _getDevice(SentryDevice? device) async {
    return (device ?? SentryDevice()).copyWith(
      online: _window.navigator.onLine,
      memorySize: _getMemorySize(),
      orientation: _getScreenOrientation(),
      screenHeightPixels: _window.screen?.available.height.toInt(),
      screenWidthPixels: _window.screen?.available.width.toInt(),
      screenDensity: _window.devicePixelRatio.toDouble(),
      timezone: DateTime.now().timeZoneName,
    );
  }

  SentryOperatingSystem _getOperatingSystem(SentryOperatingSystem? os) {
    return (os ?? SentryOperatingSystem()).copyWith(
      name: _platformChecker.platform.operatingSystem,
    );
  }

  List<SentryRuntime> _getRuntimes(List<SentryRuntime>? runtimes) {
    // Pure Dart doesn't have specific runtimes per build mode
    // like Flutter: https://flutter.dev/docs/testing/build-modes
    final dartRuntime = SentryRuntime(
      name: 'Dart',
      rawDescription: 'Dart on browser',
    );

    final browserRuntime = SentryRuntime(
      name: 'Browser',
      version: _window.navigator.userAgent,
    );
    return [
      if (runtimes?.isNotEmpty ?? false) ...runtimes!,
      dartRuntime,
      browserRuntime,
    ];
  }

  int? _getMemorySize() {
    // https://developer.mozilla.org/en-US/docs/Web/API/Navigator/deviceMemory
    final size = _window.navigator.deviceMemory?.toDouble();
    final memoryByteSize = size != null ? size * 1024 * 1024 * 1024 : null;
    return memoryByteSize?.toInt();
  }

  SentryOrientation? _getScreenOrientation() {
    // https://developer.mozilla.org/en-US/docs/Web/API/ScreenOrientation
    final screenOrientation = _window.screen?.orientation;
    if (screenOrientation != null) {
      if (screenOrientation.type?.startsWith('portrait') ?? false) {
        return SentryOrientation.portrait;
      }
      if (screenOrientation.type?.startsWith('landscape') ?? false) {
        return SentryOrientation.landscape;
      }
    }
    return null;
  }
}