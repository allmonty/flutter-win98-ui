import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'list_keyboard.dart';
import 'scroll.dart';
import 'theme.dart';

/// One row of a [Win98ListBox].
class Win98ListItem<T> {
  /// A row for [value] showing [label].
  const Win98ListItem({required this.value, required this.label, this.leading});

  /// The value reported when the row is selected or activated.
  final T value;

  /// The row's text.
  final String label;

  /// Shown before the label, e.g. a small icon.
  final Widget? leading;
}

/// A sunken white list with a navy selection highlight.
///
/// Once tapped it takes keyboard focus: Up/Down/Home/End move the selection
/// and Enter activates it.
class Win98ListBox<T> extends StatelessWidget {
  /// A list of [items] with [selected] highlighted.
  const Win98ListBox({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.onActivated,
    this.height = 160,
  });

  /// The rows, top to bottom.
  final List<Win98ListItem<T>> items;

  /// The selected row's value, or `null` for none.
  final T? selected;

  /// Called with a tapped row's value.
  final ValueChanged<T>? onSelected;

  /// Double-tap on a row (Win98's "open").
  final ValueChanged<T>? onActivated;

  /// Fixed height; `null` fills the parent (e.g. inside an `Expanded`).
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    return ListKeyboard<T>(
      values: [for (final item in items) item.value],
      selected: selected,
      onSelected: onSelected,
      onActivated: onActivated,
      builder: (context, selectedKey) => SizedBox(
        height: height ?? double.infinity,
        child: Bevel(
          style: BevelStyle.field,
          child: Win98ScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in items)
                  item.value == selected
                      ? KeyedSubtree(key: selectedKey, child: _row(theme, item, true))
                      : _row(theme, item, false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(Win98ThemeData theme, Win98ListItem<T> item, bool isSelected) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected == null ? null : () => onSelected!(item.value),
        onDoubleTap: onActivated == null ? null : () => onActivated!(item.value),
        child: Container(
          constraints: BoxConstraints(minHeight: theme.controlHeight),
          color: isSelected ? theme.selection : null,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              if (item.leading != null) ...[item.leading!, const SizedBox(width: 6)],
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textStyle.copyWith(
                    color: isSelected ? theme.selectionText : theme.text,
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
