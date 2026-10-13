import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'focus_rect.dart';
import 'theme.dart';

/// A classic push button: raised at rest, pressed while held, a dotted focus
/// rectangle when keyboard-focused, and etched text when disabled.
class Win98Button extends StatefulWidget {
  /// A push button showing [child].
  const Win98Button({
    super.key,
    required this.onPressed,
    required this.child,
    this.isDefault = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.minWidth = 76,
    this.minHeight,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Called on tap. `null` disables the button.
  final VoidCallback? onPressed;

  /// The label, usually a [Text].
  final Widget child;

  /// Draws the extra dark outline of a dialog's default button.
  final bool isDefault;

  /// Padding around [child], inside the bevel.
  final EdgeInsetsGeometry padding;

  /// Minimum width; Win98 dialog buttons share one width.
  final double minWidth;

  /// Defaults to the theme's control height.
  final double? minHeight;

  /// Focus node; one is created when `null`.
  final FocusNode? focusNode;

  /// Whether to take focus when first built.
  final bool autofocus;

  /// Label read by screen readers.
  final String? semanticLabel;

  /// Whether [onPressed] is set.
  bool get enabled => onPressed != null;

  @override
  State<Win98Button> createState() => _Win98ButtonState();
}

class _Win98ButtonState extends State<Win98Button> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final enabled = widget.enabled;
    final pressed = _pressed && enabled;

    Widget content = DefaultTextStyle.merge(
      style: enabled ? theme.textStyle : theme.disabledTextStyle,
      textAlign: TextAlign.center,
      child: IconTheme(
        data: IconThemeData(color: enabled ? theme.text : theme.disabledText),
        child: widget.child,
      ),
    );
    if (_focused && enabled) content = FocusRect(child: content);

    Widget button = Bevel(
      style: pressed ? BevelStyle.pressed : BevelStyle.raised,
      padding: widget.padding,
      child: Transform.translate(
        // Win98 nudges the label one pixel down-right while pressed.
        offset: pressed ? const Offset(1, 1) : Offset.zero,
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      ),
    );
    if (widget.isDefault) {
      button = Bevel(style: BevelStyle.outline, child: button);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
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
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTap: widget.onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minWidth,
              minHeight: widget.minHeight ?? theme.controlHeight,
            ),
            child: button,
          ),
        ),
      ),
    );
  }
}
