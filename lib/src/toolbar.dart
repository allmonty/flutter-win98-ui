import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'focus_rect.dart';
import 'theme.dart';
import 'tooltip.dart';

/// A toolbar: a row of [Win98ToolButton]s and [Win98ToolbarDivider]s under
/// the menu bar, scrolling sideways when it doesn't fit.
class Win98Toolbar extends StatelessWidget {
  /// A toolbar holding [children], left to right.
  const Win98Toolbar({super.key, required this.children});

  /// Usually [Win98ToolButton]s, grouped with [Win98ToolbarDivider]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.face,
        // The etched line Win98 draws between a menu bar and its toolbar.
        border: Border(
          top: BorderSide(color: theme.highlight),
          bottom: BorderSide(color: theme.shadow),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(2),
        child: Row(children: children),
      ),
    );
  }
}

/// An etched vertical line separating groups of tool buttons.
class Win98ToolbarDivider extends StatelessWidget {
  /// A divider as tall as the theme's control height.
  const Win98ToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: theme.controlHeight - 4,
        child: Row(
          children: [
            Container(width: 1, color: theme.shadow),
            Container(width: 1, color: theme.highlight),
          ],
        ),
      ),
    );
  }
}

/// A flat toolbar button: borderless at rest, raised under the pointer and
/// sunken while pressed or [selected].
class Win98ToolButton extends StatefulWidget {
  /// A tool button showing [child], usually a [PixelGlyph], an image or a
  /// short label.
  const Win98ToolButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.selected = false,
    this.focusNode,
    this.semanticLabel,
  });

  /// Called on tap. `null` disables the button.
  final VoidCallback? onPressed;

  /// The button's content.
  final Widget child;

  /// Shown in a [Win98Tooltip] when set (screen readers read it too).
  final String? tooltip;

  /// Draws the button sunken, for tools that stay on (bold, a paint tool).
  final bool selected;

  /// Focus node; one is created when `null`.
  final FocusNode? focusNode;

  /// Label read by screen readers.
  final String? semanticLabel;

  @override
  State<Win98ToolButton> createState() => _Win98ToolButtonState();
}

class _Win98ToolButtonState extends State<Win98ToolButton> {
  bool _hot = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final enabled = widget.onPressed != null;
    final sunken = enabled && _pressed || widget.selected;
    final style = sunken
        ? BevelStyle.status
        : enabled && _hot
        ? BevelStyle.thinRaised
        : null;

    Widget content = DefaultTextStyle.merge(
      style: enabled ? theme.textStyle : theme.disabledTextStyle,
      child: IconTheme(
        data: IconThemeData(color: enabled ? theme.text : theme.disabledText),
        child: Center(widthFactor: 1, heightFactor: 1, child: widget.child),
      ),
    );
    if (_focused && enabled) content = FocusRect(child: content);
    content = Padding(
      padding: const EdgeInsets.all(4),
      child: Transform.translate(offset: sunken ? const Offset(1, 1) : Offset.zero, child: content),
    );

    Widget button = Semantics(
      button: true,
      enabled: enabled,
      toggled: widget.selected ? true : null,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hot = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTap: widget.onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: theme.controlHeight,
              minHeight: theme.controlHeight,
            ),
            child: style == null
                ? Padding(padding: const EdgeInsets.all(1), child: content)
                : Bevel(style: style, child: content),
          ),
        ),
      ),
    );
    final tooltip = widget.tooltip;
    if (tooltip != null) button = Win98Tooltip(message: tooltip, child: button);
    return button;
  }
}
