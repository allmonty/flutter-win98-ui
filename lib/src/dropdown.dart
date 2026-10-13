import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'button.dart';
import 'glyphs.dart';
import 'popup.dart';
import 'theme.dart';

/// An option of a [Win98Dropdown].
class Win98DropdownItem<T> {
  /// An option for [value] shown as [label].
  const Win98DropdownItem({required this.value, required this.label});

  /// The value reported when the option is chosen.
  final T value;

  /// The option's text.
  final String label;
}

/// A drop-down combo box: a sunken field showing the selection, an arrow
/// button, a pop-up list, and Previous/Next buttons to step through
/// [items] without opening the list.
///
/// Once tapped it takes keyboard focus: Up/Down change the selection without
/// opening the list, and Enter, Space or Alt+Down open it.
class Win98Dropdown<T> extends StatelessWidget {
  /// A drop-down showing [value]'s label.
  const Win98Dropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.maxListHeight = 260,
    this.semanticLabel,
  });

  /// The options, in list order.
  final List<Win98DropdownItem<T>> items;

  /// The selected option's value, or `null` for none.
  final T? value;

  /// `null` disables the drop-down.
  final ValueChanged<T>? onChanged;

  /// Maximum height of the open list before it scrolls.
  final double maxListHeight;

  /// Label read by screen readers.
  final String? semanticLabel;

  String get _label {
    for (final item in items) {
      if (item.value == value) return item.label;
    }
    return '';
  }

  /// Index of the current [value] in [items], or -1 if not found (or
  /// [value] is null).
  int get _index {
    for (var i = 0; i < items.length; i++) {
      if (items[i].value == value) return i;
    }
    return -1;
  }

  /// Keyboard handling while the list is closed.
  KeyEventResult _onKey(KeyEvent event, VoidCallback toggle) {
    if (event is KeyUpEvent || onChanged == null) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final down = key == LogicalKeyboardKey.arrowDown;
    if ((down && HardwareKeyboard.instance.isAltPressed) ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      toggle();
    } else if (down || key == LogicalKeyboardKey.arrowUp) {
      // Unlike the Previous/Next buttons, the arrow keys stop at the ends.
      if (items.isEmpty) return KeyEventResult.handled;
      final next = (_index + (down ? 1 : -1)).clamp(0, items.length - 1);
      if (items[next].value != value) onChanged!(items[next].value);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _step(int delta) {
    if (items.isEmpty) return;
    final next = (_index + delta) % items.length;
    onChanged?.call(items[next < 0 ? next + items.length : next].value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final enabled = onChanged != null;
    final canStep = enabled && items.length > 1;
    Widget stepButton(List<String> glyph, int delta, String label) => Win98Button(
      onPressed: canStep ? () => _step(delta) : null,
      minWidth: theme.scrollbarSize,
      minHeight: theme.controlHeight,
      padding: EdgeInsets.zero,
      semanticLabel: label,
      child: PixelGlyph(glyph, color: canStep ? theme.text : theme.disabledText, pixelSize: 1.5),
    );

    return Row(
      children: [
        Expanded(
          child: Win98PopupAnchor(
            matchWidth: true,
            builder: (context, isOpen, toggle) => Focus(
              canRequestFocus: enabled,
              onKeyEvent: (_, event) => _onKey(event, toggle),
              child: Builder(
                builder: (context) {
                  final focused = Focus.of(context).hasFocus;
                  return Semantics(
                    button: true,
                    enabled: enabled,
                    label: semanticLabel,
                    value: _label,
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: enabled
                          ? () {
                              Focus.of(context).requestFocus();
                              toggle();
                            }
                          : null,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: theme.controlHeight),
                        child: Bevel(
                          style: BevelStyle.field,
                          color: enabled ? theme.window : theme.face,
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  // Win98 highlights the focused combo box's text.
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    heightFactor: 1,
                                    child: Container(
                                      color: focused && !isOpen ? theme.selection : null,
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Text(
                                        _label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: !enabled
                                            ? theme.disabledTextStyle
                                            : focused && !isOpen
                                            ? theme.textStyle.copyWith(color: theme.selectionText)
                                            : theme.textStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: Win98Button(
                                  onPressed: enabled ? () {} : null,
                                  minWidth: theme.scrollbarSize,
                                  minHeight: theme.controlHeight - 4,
                                  padding: EdgeInsets.zero,
                                  child: PixelGlyph(
                                    Win98Glyphs.arrowDown,
                                    color: enabled ? theme.text : theme.disabledText,
                                    pixelSize: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            popupBuilder: (context, close) => _DropdownList<T>(
              items: items,
              value: value,
              maxHeight: maxListHeight,
              onSelected: (v) {
                close();
                if (v != value) onChanged?.call(v);
              },
            ),
          ),
        ),
        const SizedBox(width: 2),
        stepButton(Win98Glyphs.arrowLeft, -1, 'Previous option'),
        const SizedBox(width: 2),
        stepButton(Win98Glyphs.arrowRight, 1, 'Next option'),
      ],
    );
  }
}

class _DropdownList<T> extends StatelessWidget {
  const _DropdownList({
    required this.items,
    required this.value,
    required this.maxHeight,
    required this.onSelected,
  });

  final List<Win98DropdownItem<T>> items;
  final T? value;
  final double maxHeight;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: theme.window,
        border: Border.all(color: theme.darkShadow),
      ),
      child: SingleChildScrollView(
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in items)
                Semantics(
                  button: true,
                  selected: item.value == value,
                  label: item.label,
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelected(item.value),
                    child: Container(
                      color: item.value == value ? theme.selection : null,
                      constraints: BoxConstraints(minHeight: theme.controlHeight),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.label,
                        style: theme.textStyle.copyWith(
                          color: item.value == value ? theme.selectionText : theme.text,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
