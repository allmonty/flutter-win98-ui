import 'package:flutter/widgets.dart';

// Not exported from win98_ui.dart: an implementation detail of Win98TabView.

/// Caches label text-layout widths per `(label, style, scaler)`, so
/// [Win98TabView] doesn't re-run text shaping for unchanged labels on every
/// rebuild — previously the dominant per-rebuild cost of a tab strip with
/// several labels, since it ran on every rebuild, not just when the tab
/// selection or available width actually changed.
class TabLabelWidthCache {
  final _widths = <(String, TextStyle, TextScaler), double>{};

  /// Number of distinct `(label, style, scaler)` keys cached so far (tests
  /// only, to assert repeat lookups don't grow the cache).
  int get widthsForTest => _widths.length;

  double widthOf(String label, TextStyle style, TextScaler scaler) {
    final key = (label, style, scaler);
    final cached = _widths[key];
    if (cached != null) return cached;
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return _widths[key] = width;
  }
}
