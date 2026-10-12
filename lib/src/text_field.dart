import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'scroll.dart';
import 'theme.dart';

/// A sunken text box built on [EditableText]: single-line by default,
/// multi-line with a Win98 scrollbar when [maxLines] is more than 1.
class Win98TextField extends StatefulWidget {
  /// A text box editing [controller]'s text.
  const Win98TextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onSubmitted,
    this.onChanged,
    this.maxLength,
    this.semanticLabel,
  });

  /// Holds the text and selection.
  final TextEditingController controller;

  /// Focus node; one is created when `null`.
  final FocusNode? focusNode;

  /// Whether to take focus when first built.
  final bool autofocus;

  /// When `false` the field is grayed out and can't be focused or edited.
  final bool enabled;

  /// When `true` the text can be selected and copied but not changed.
  final bool readOnly;

  /// Hides the text behind bullets, for passwords.
  final bool obscureText;

  /// Maximum visible lines; more scroll. `null` grows to fit the text.
  final int? maxLines;

  /// Minimum visible lines when [maxLines] is more than 1.
  final int? minLines;

  /// The on-screen keyboard to show; multi-line fields default to
  /// [TextInputType.multiline].
  final TextInputType? keyboardType;

  /// The on-screen keyboard's action button.
  final TextInputAction? textInputAction;

  /// Formatters applied to typed text, before the [maxLength] limit.
  final List<TextInputFormatter>? inputFormatters;

  /// Called when the user submits (Enter on a single-line field).
  final ValueChanged<String>? onSubmitted;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Maximum number of characters, or `null` for no limit.
  final int? maxLength;

  /// Label read by screen readers.
  final String? semanticLabel;

  @override
  State<Win98TextField> createState() => _Win98TextFieldState();
}

class _Win98TextFieldState extends State<Win98TextField> {
  FocusNode? _own;
  FocusNode get _focusNode => widget.focusNode ?? (_own ??= FocusNode());
  final _scroll = ScrollController();

  bool get _multiline => widget.maxLines != 1;

  @override
  void dispose() {
    _own?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final enabled = widget.enabled;
    _focusNode.canRequestFocus = enabled;
    final maxLength = widget.maxLength;
    final formatters = [
      ...?widget.inputFormatters,
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
    ];
    Widget field = EditableText(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus && enabled,
      readOnly: widget.readOnly || !enabled,
      obscureText: widget.obscureText,
      style: enabled ? theme.textStyle : theme.disabledTextStyle,
      cursorColor: theme.text,
      cursorWidth: 1,
      backgroundCursorColor: theme.shadow,
      selectionColor: theme.selection.withValues(alpha: 0.4),
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType ?? (_multiline ? TextInputType.multiline : null),
      textInputAction: widget.textInputAction,
      scrollController: _scroll,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      inputFormatters: formatters.isEmpty ? null : formatters,
    );
    if (_multiline && !widget.obscureText) {
      field = Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(right: theme.scrollbarSize + 2),
            child: field,
          ),
          Positioned(top: 0, bottom: 0, right: 0, child: Win98Scrollbar(controller: _scroll)),
        ],
      );
    } else {
      field = Align(alignment: Alignment.centerLeft, child: field);
    }
    return Semantics(
      textField: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: enabled ? _focusNode.requestFocus : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: theme.controlHeight),
          child: Bevel(
            style: BevelStyle.field,
            color: enabled ? null : theme.face,
            padding: _multiline
                ? const EdgeInsets.only(left: 4, top: 4, bottom: 4)
                : const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: field,
          ),
        ),
      ),
    );
  }
}
