import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'glyphs.dart';
import 'list_keyboard.dart';
import 'scroll.dart';
import 'theme.dart';

/// A column of a [Win98ListView].
class Win98ListColumn {
  /// A column headed [label], [width] pixels wide, or sharing the leftover
  /// width by [flex] when [width] is `null`.
  const Win98ListColumn({required this.label, this.width, this.flex = 1, this.numeric = false});

  /// The header text.
  final String label;

  /// Fixed width in logical pixels, or `null` to share the space left.
  final double? width;

  /// Share of the leftover width when [width] is `null`.
  final int flex;

  /// Right-aligns the column, for numbers and sizes.
  final bool numeric;
}

/// A row of a [Win98ListView].
class Win98ListRow<T> {
  /// A row for [value] with one entry in [cells] per column.
  const Win98ListRow({required this.value, required this.cells, this.leading});

  /// The value reported when the row is selected or activated.
  final T value;

  /// The text of each column, in column order.
  final List<String> cells;

  /// Shown before the first cell, e.g. a small icon.
  final Widget? leading;
}

/// Explorer's "Details" view: a sunken list with column headers and a full
/// row selection highlight. Tapping a header calls [onSort].
///
/// Once tapped it takes keyboard focus: Up/Down/Home/End move the selection
/// and Enter activates it.
///
/// shortcut: columns can't be resized or scrolled sideways, and flex columns
/// shift by the scrollbar's width against their headers once rows overflow;
/// add resizing and a shared width if an app needs wide tables.
class Win98ListView<T> extends StatelessWidget {
  /// A list of [rows] under [columns].
  const Win98ListView({
    super.key,
    required this.columns,
    required this.rows,
    required this.selected,
    required this.onSelected,
    this.onActivated,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
    this.height = 200,
  });

  /// The columns, left to right.
  final List<Win98ListColumn> columns;

  /// The rows, top to bottom. Sort them yourself in [onSort].
  final List<Win98ListRow<T>> rows;

  /// The selected row's value.
  final T? selected;

  /// Called with a tapped row's value.
  final ValueChanged<T>? onSelected;

  /// Double-tap on a row (Win98's "open").
  final ValueChanged<T>? onActivated;

  /// The column showing a sort arrow, or `null` for none.
  final int? sortColumn;

  /// Whether [sortColumn]'s arrow points up (ascending).
  final bool sortAscending;

  /// Called with a tapped header's column index; `null` makes headers inert.
  final ValueChanged<int>? onSort;

  /// Fixed height; `null` fills the parent (e.g. inside an `Expanded`).
  final double? height;

  Widget _cell(Win98ListColumn column, Widget child) {
    final aligned = Align(
      alignment: column.numeric ? Alignment.centerRight : Alignment.centerLeft,
      child: child,
    );
    final width = column.width;
    return width != null
        ? SizedBox(width: width, child: aligned)
        : Expanded(flex: column.flex, child: aligned);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final header = Row(
      children: [for (var i = 0; i < columns.length; i++) _cell(columns[i], _header(theme, i))],
    );
    return ListKeyboard<T>(
      values: [for (final row in rows) row.value],
      selected: selected,
      onSelected: onSelected,
      onActivated: onActivated,
      builder: (context, selectedKey) => SizedBox(
        height: height ?? double.infinity,
        child: Bevel(
          style: BevelStyle.field,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(
                child: Win98ScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final row in rows)
                        row.value == selected
                            ? KeyedSubtree(key: selectedKey, child: _row(theme, row, true))
                            : _row(theme, row, false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(Win98ThemeData theme, int i) {
    final column = columns[i];
    final sorted = sortColumn == i;
    return Semantics(
      button: onSort != null,
      label: column.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSort == null ? null : () => onSort!(i),
        child: Bevel(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  column.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: column.numeric ? TextAlign.right : TextAlign.left,
                ),
              ),
              if (sorted) ...[
                const SizedBox(width: 4),
                PixelGlyph(
                  sortAscending ? Win98Glyphs.arrowUp : Win98Glyphs.arrowDown,
                  color: theme.shadow,
                  pixelSize: 1,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(Win98ThemeData theme, Win98ListRow<T> row, bool isSelected) {
    final style = theme.textStyle.copyWith(color: isSelected ? theme.selectionText : theme.text);
    return Semantics(
      selected: isSelected,
      button: true,
      label: row.cells.join(', '),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected == null ? null : () => onSelected!(row.value),
        onDoubleTap: onActivated == null ? null : () => onActivated!(row.value),
        child: Container(
          constraints: BoxConstraints(minHeight: theme.controlHeight),
          color: isSelected ? theme.selection : null,
          child: Row(
            children: [
              for (var i = 0; i < columns.length; i++)
                _cell(
                  columns[i],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (i == 0 && row.leading != null) ...[
                          row.leading!,
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            i < row.cells.length ? row.cells[i] : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style,
                          ),
                        ),
                      ],
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
