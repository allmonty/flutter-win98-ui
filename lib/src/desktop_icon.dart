import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A desktop shortcut: an icon over a white label, highlighted when
/// [selected]. Tap selects it, double-tap opens it.
///
/// Lay several out with a `Wrap(direction: Axis.vertical)` on a
/// `Win98Desktop`, as Win98 lined them up down the left edge.
class Win98DesktopIcon extends StatelessWidget {
  /// An icon labeled [label].
  const Win98DesktopIcon({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onActivated,
    this.width = 92,
  });

  /// The picture, usually 32×32: an image or a `PixelGlyph`.
  final Widget icon;

  /// The text under the icon; wraps to two lines.
  final String label;

  /// Highlights the label and tints the icon with the selection color.
  final bool selected;

  /// Called on tap.
  final VoidCallback? onSelected;

  /// Called on double-tap (Win98's "open").
  final VoidCallback? onActivated;

  /// Width of the icon's cell; the label wraps inside it.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final label = Container(
      color: selected ? theme.selection : null,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        this.label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        // White on the desktop, as in Win98, whether selected or not.
        style: theme.textStyle.copyWith(color: theme.selectionText),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: this.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected,
        onDoubleTap: onActivated,
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                selected
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          theme.selection.withValues(alpha: 0.5),
                          BlendMode.srcATop,
                        ),
                        child: icon,
                      )
                    : icon,
                const SizedBox(height: 4),
                label,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
