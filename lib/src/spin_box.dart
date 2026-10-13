import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'button.dart';
import 'glyphs.dart';
import 'text_field.dart';
import 'theme.dart';

/// A whole-number field with ▲/▼ buttons (Win98's "up-down" control).
///
/// Typing commits on Enter or when the field loses focus; the value is
/// clamped to [min]..[max]. The arrow buttons and the Up/Down keys step by
/// [step].
class Win98SpinBox extends StatefulWidget {
  /// A spin box showing [value].
  const Win98SpinBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.semanticLabel,
  }) : assert(min <= max);

  /// The current value, between [min] and [max].
  final int value;

  /// Called with the new value; `null` disables the spin box.
  final ValueChanged<int>? onChanged;

  /// The smallest value.
  final int min;

  /// The largest value.
  final int max;

  /// How much one arrow press changes the value.
  final int step;

  /// Label read by screen readers.
  final String? semanticLabel;

  @override
  State<Win98SpinBox> createState() => _Win98SpinBoxState();
}

class _Win98SpinBoxState extends State<Win98SpinBox> {
  late final _text = TextEditingController(text: '${widget.value}');
  late final _focus = FocusNode(onKeyEvent: _onKey)..addListener(_onFocusChange);

  /// The last value reported to (or received from) the parent, so a submit
  /// followed by the focus loss it causes reports once.
  late int _reported = widget.value;

  bool get _enabled => widget.onChanged != null;

  @override
  void didUpdateWidget(Win98SpinBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reported = widget.value;
    // Don't overwrite what the user is typing.
    if (!_focus.hasFocus && _text.text != '${widget.value}') _text.text = '${widget.value}';
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _set(int value) {
    final v = value.clamp(widget.min, widget.max);
    _text.text = '$v';
    if (v == _reported) return;
    _reported = v;
    widget.onChanged?.call(v);
  }

  /// Applies typed text; anything unparsable restores the current value.
  void _commit() => _set(int.tryParse(_text.text) ?? _reported);

  void _onFocusChange() {
    if (!_focus.hasFocus) _commit();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_enabled || event is KeyUpEvent) return KeyEventResult.ignored;
    final current = int.tryParse(_text.text) ?? _reported;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _set(current + widget.step);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _set(current - widget.step);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final enabled = _enabled;
    final half = theme.controlHeight / 2;
    Widget arrow(List<String> glyph, int delta, String label) => Win98Button(
      onPressed: enabled ? () => _set((int.tryParse(_text.text) ?? _reported) + delta) : null,
      minWidth: theme.scrollbarSize,
      minHeight: half,
      padding: EdgeInsets.zero,
      semanticLabel: label,
      child: PixelGlyph(glyph, color: enabled ? theme.text : theme.disabledText, pixelSize: 1),
    );
    return Semantics(
      label: widget.semanticLabel,
      value: '${widget.value}',
      child: Row(
        children: [
          Expanded(
            child: Win98TextField(
              controller: _text,
              focusNode: _focus,
              enabled: enabled,
              keyboardType: TextInputType.numberWithOptions(signed: widget.min < 0),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(widget.min < 0 ? r'^-?\d*' : r'^\d*')),
              ],
              onSubmitted: (_) => _commit(),
            ),
          ),
          SizedBox(
            height: half * 2,
            child: Column(
              children: [
                arrow(Win98Glyphs.arrowUp, widget.step, 'Increase'),
                arrow(Win98Glyphs.arrowDown, -widget.step, 'Decrease'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
