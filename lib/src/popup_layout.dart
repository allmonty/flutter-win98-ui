import 'dart:math' as math;

import 'package:flutter/widgets.dart';

// Not exported: shared by the popup, tooltip, context menu and submenus.

/// Places a popup next to `anchor` (in overlay coordinates) and keeps it on
/// screen: below the anchor, or above it when there is more room there; with
/// [side], to the right of it, or to the left when it doesn't fit.
class PopupLayout extends SingleChildLayoutDelegate {
  PopupLayout({
    required this.anchor,
    required this.safeArea,
    this.matchWidth = false,
    this.side = false,
  });

  final Rect anchor;
  final bool matchWidth;
  final EdgeInsets safeArea;
  final bool side;

  static const _margin = 4.0;

  double _below(Size size) => size.height - safeArea.bottom - _margin - anchor.bottom;
  double _above(Size size) => anchor.top - safeArea.top - _margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final size = constraints.biggest;
    final maxWidth = math.max(0.0, size.width - _margin * 2);
    final maxHeight = side
        ? math.max(0.0, size.height - safeArea.vertical - _margin * 2)
        : math.max(0.0, math.max(_below(size), _above(size)));
    return BoxConstraints(
      minWidth: matchWidth ? math.min(anchor.width, maxWidth) : 0,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    if (side) {
      final fitsRight = anchor.right + childSize.width <= size.width - _margin;
      final x = fitsRight ? anchor.right : math.max(_margin, anchor.left - childSize.width);
      final maxY = size.height - safeArea.bottom - _margin - childSize.height;
      return Offset(
        x,
        anchor.top.clamp(safeArea.top + _margin, math.max(safeArea.top + _margin, maxY)),
      );
    }
    final fitsBelow = childSize.height <= _below(size);
    final y = fitsBelow || _below(size) >= _above(size)
        ? anchor.bottom
        : anchor.top - childSize.height;
    final x = anchor.left
        .clamp(_margin, math.max(_margin, size.width - _margin - childSize.width))
        .toDouble();
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(PopupLayout old) =>
      old.anchor != anchor ||
      old.matchWidth != matchWidth ||
      old.safeArea != safeArea ||
      old.side != side;
}

/// The bounds of `context`'s render box in its overlay's coordinates, or
/// `null` before it has been laid out.
Rect? overlayRectOf(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  final overlay = Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
}

/// Converts a global pointer position to `context`'s overlay coordinates.
Offset overlayOffsetOf(BuildContext context, Offset global) {
  final overlay = Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
  return overlay?.globalToLocal(global) ?? global;
}
