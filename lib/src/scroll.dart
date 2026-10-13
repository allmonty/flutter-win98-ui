import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'button.dart';
import 'glyphs.dart';
import 'theme.dart';

/// A scrolling area with a Win98 scrollbar (arrow buttons, dithered track,
/// draggable raised thumb): on the right when vertical, at the bottom when
/// [scrollDirection] is horizontal. The bar is only shown when the content
/// overflows.
///
/// shortcut: one axis at a time; content scrolling both ways (a large image)
/// needs a 2D version with the corner box.
class Win98ScrollView extends StatefulWidget {
  /// A scroll view around [child].
  const Win98ScrollView({
    super.key,
    required this.child,
    this.controller,
    this.padding,
    this.scrollDirection = Axis.vertical,
  });

  /// The scrolled content.
  final Widget child;

  /// Scroll controller; one is created when `null`.
  final ScrollController? controller;

  /// Padding inside the scrolled area.
  final EdgeInsetsGeometry? padding;

  /// The axis the content scrolls along.
  final Axis scrollDirection;

  @override
  State<Win98ScrollView> createState() => _Win98ScrollViewState();
}

class _Win98ScrollViewState extends State<Win98ScrollView> {
  ScrollController? _own;
  ScrollController get _controller => widget.controller ?? (_own ??= ScrollController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final axis = widget.scrollDirection;
    return Flex(
      // The bar sits across the scroll axis: right of vertical content,
      // below horizontal content.
      direction: axis == Axis.vertical ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: const _NoGlowBehavior(),
            child: SingleChildScrollView(
              controller: _controller,
              padding: widget.padding,
              scrollDirection: axis,
              child: widget.child,
            ),
          ),
        ),
        Win98Scrollbar(controller: _controller, axis: axis),
      ],
    );
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();
}

/// A scrollbar driving `controller`: vertical by default, horizontal when
/// [axis] is. Place it next to (or under) the scrollable that uses the same
/// controller.
class Win98Scrollbar extends StatefulWidget {
  /// A scrollbar for [controller].
  const Win98Scrollbar({
    super.key,
    required this.controller,
    this.step = 40,
    this.axis = Axis.vertical,
  });

  /// The controller of the scrollable this bar drives.
  final ScrollController controller;

  /// Pixels scrolled per arrow tap.
  final double step;

  /// The scroll axis of the scrollable this bar drives.
  final Axis axis;

  @override
  State<Win98Scrollbar> createState() => _Win98ScrollbarState();
}

class _Win98ScrollbarState extends State<Win98Scrollbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    // Metrics only exist after the scrollable's first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _changed());
  }

  @override
  void didUpdateWidget(Win98Scrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _changed());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  ScrollPosition? get _position =>
      widget.controller.hasClients && widget.controller.positions.length == 1
      ? widget.controller.position
      : null;

  void _scrollBy(double delta) {
    final p = _position;
    if (p == null) return;
    p.jumpTo((p.pixels + delta).clamp(p.minScrollExtent, p.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final p = _position;
    if (p == null || !p.hasContentDimensions || p.maxScrollExtent <= 0) {
      return const SizedBox.shrink();
    }
    final size = theme.scrollbarSize;
    final vertical = widget.axis == Axis.vertical;
    Widget arrow(List<String> glyph, double delta, String label) => Win98Button(
      onPressed: () => _scrollBy(delta),
      minWidth: size,
      minHeight: size,
      padding: EdgeInsets.zero,
      semanticLabel: label,
      child: PixelGlyph(glyph, color: theme.text, pixelSize: 1.5),
    );

    return SizedBox(
      width: vertical ? size : null,
      height: vertical ? null : size,
      child: Flex(
        direction: widget.axis,
        children: [
          vertical
              ? arrow(Win98Glyphs.arrowUp, -widget.step, 'Scroll up')
              : arrow(Win98Glyphs.arrowLeft, -widget.step, 'Scroll left'),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final track = vertical ? constraints.maxHeight : constraints.maxWidth;
                final content = p.maxScrollExtent + p.viewportDimension;
                final thumb = math
                    .max(size, track * p.viewportDimension / content)
                    .clamp(0.0, track);
                final range = track - thumb;
                final offset = p.maxScrollExtent == 0
                    ? 0.0
                    : range * (p.pixels / p.maxScrollExtent);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Clicking the track pages up/down, as in Win98.
                  onTapDown: (d) => _scrollBy(
                    (vertical ? d.localPosition.dy : d.localPosition.dx) < offset
                        ? -p.viewportDimension
                        : p.viewportDimension,
                  ),
                  child: CustomPaint(
                    painter: _TrackPainter(theme),
                    child: Stack(
                      children: [
                        Positioned(
                          top: vertical ? offset : 0,
                          bottom: vertical ? null : 0,
                          left: vertical ? 0 : offset,
                          right: vertical ? 0 : null,
                          height: vertical ? thumb : null,
                          width: vertical ? null : thumb,
                          child: GestureDetector(
                            onVerticalDragUpdate: vertical
                                ? (d) {
                                    if (range <= 0) return;
                                    _scrollBy(d.delta.dy / range * p.maxScrollExtent);
                                  }
                                : null,
                            onHorizontalDragUpdate: vertical
                                ? null
                                : (d) {
                                    if (range <= 0) return;
                                    _scrollBy(d.delta.dx / range * p.maxScrollExtent);
                                  },
                            child: const Bevel(style: BevelStyle.raised),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          vertical
              ? arrow(Win98Glyphs.arrowDown, widget.step, 'Scroll down')
              : arrow(Win98Glyphs.arrowRight, widget.step, 'Scroll right'),
        ],
      ),
    );
  }
}

/// The checkerboard of face and highlight pixels behind the thumb.
class _TrackPainter extends CustomPainter {
  _TrackPainter(this.theme);
  final Win98ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.face);
    final dots = Paint()..color = theme.highlight;
    for (var y = 0; y < size.height; y++) {
      for (var x = y.isEven ? 0 : 1; x < size.width; x += 2) {
        canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), dots);
      }
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) => old.theme != theme;
}
