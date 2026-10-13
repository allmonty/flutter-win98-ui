import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'button.dart';
import 'glyphs.dart';
import 'theme.dart';
import 'window_scope.dart';

/// A window: raised frame, gradient title bar with caption buttons, an
/// optional menu bar, the body, and an optional status bar.
class Win98Window extends StatelessWidget {
  /// A window titled [title] around [child].
  const Win98Window({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.active = true,
    this.menuBar,
    this.toolbar,
    this.statusBar,
    this.onMinimize,
    this.onMaximize,
    this.onClose,
    this.bodyPadding = const EdgeInsets.all(4),
    this.expand = false,
  });

  /// Text in the title bar.
  final String title;

  /// Small icon before the title.
  final Widget? icon;

  /// Draws the title bar in the active (blue) or inactive (gray) colors.
  final bool active;

  /// Shown under the title bar, usually a `Win98MenuBar`.
  final Widget? menuBar;

  /// Shown under [menuBar], usually a `Win98Toolbar`.
  final Widget? toolbar;

  /// Shown at the bottom, usually a `Win98StatusBar`.
  final Widget? statusBar;

  /// Caption buttons are shown only for non-null callbacks.
  final VoidCallback? onMinimize;

  /// Shows a maximize button when set.
  final VoidCallback? onMaximize;

  /// Shows a close button when set.
  final VoidCallback? onClose;

  /// Padding around [child].
  final EdgeInsetsGeometry bodyPadding;

  /// Fill the available height, pinning the status bar to the bottom (for
  /// a maximized main window). Dialogs leave this off to size to content.
  final bool expand;

  /// The window's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Bevel(
      style: BevelStyle.window,
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Win98TitleBar(
            title: title,
            icon: icon,
            active: active,
            onMinimize: onMinimize,
            onMaximize: onMaximize,
            onClose: onClose,
          ),
          ?menuBar,
          ?toolbar,
          Flexible(
            fit: expand ? FlexFit.tight : FlexFit.loose,
            child: Padding(padding: bodyPadding, child: child),
          ),
          ?statusBar,
        ],
      ),
    );
  }
}

/// The gradient title bar of a [Win98Window].
class Win98TitleBar extends StatelessWidget {
  /// A title bar for [title] with caption buttons for the set callbacks.
  const Win98TitleBar({
    super.key,
    required this.title,
    this.icon,
    this.active = true,
    this.onMinimize,
    this.onMaximize,
    this.onClose,
  });

  /// The title text.
  final String title;

  /// Small icon before the title.
  final Widget? icon;

  /// Uses the active (blue) or inactive (gray) gradient. Inside a
  /// `Win98WindowStack` the stack decides instead: the front window is active.
  final bool active;

  /// Shows a minimize button when set.
  final VoidCallback? onMinimize;

  /// Shows a maximize button when set.
  final VoidCallback? onMaximize;

  /// Shows a close button when set.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final scope = WindowScope.maybeOf(context);
    final active = scope?.active ?? this.active;
    final size = theme.titleBarHeight - 6;
    Widget caption(List<String> glyph, VoidCallback onTap, String label) => Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Win98Button(
        onPressed: onTap,
        minWidth: size + 4,
        minHeight: size,
        padding: EdgeInsets.zero,
        semanticLabel: label,
        child: PixelGlyph(glyph, color: theme.text, pixelSize: 1.5),
      ),
    );

    final bar = Container(
      height: theme.titleBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? [theme.activeTitleStart, theme.activeTitleEnd]
              : [theme.inactiveTitleStart, theme.inactiveTitleEnd],
        ),
      ),
      child: Row(
        children: [
          if (icon != null) Padding(padding: const EdgeInsets.only(right: 4), child: icon),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.boldTextStyle.copyWith(color: theme.titleText),
            ),
          ),
          if (onMinimize != null) caption(Win98Glyphs.minimize, onMinimize!, 'Minimize'),
          if (onMaximize != null) caption(Win98Glyphs.maximize, onMaximize!, 'Maximize'),
          if (onClose != null) ...[
            const SizedBox(width: 2),
            caption(Win98Glyphs.close, onClose!, 'Close'),
          ],
        ],
      ),
    );
    if (scope == null) return bar;
    // In a window stack, dragging the title bar moves the window.
    return GestureDetector(
      onPanStart: (_) => scope.onDragStart(),
      onPanUpdate: (d) => scope.onDrag(d.delta),
      child: bar,
    );
  }
}

/// A teal desktop background.
class Win98Desktop extends StatelessWidget {
  /// A desktop behind [child].
  const Win98Desktop({super.key, required this.child});

  /// Usually windows, or a column with a `Win98Taskbar` at the bottom.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Win98Theme.of(context).desktop, child: child);
}
