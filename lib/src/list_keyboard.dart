import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Not exported: keyboard selection shared by Win98ListBox, Win98ListView and
// Win98TreeView.

/// Makes a list focusable (a tap focuses it) and moves its selection with
/// Up/Down/Home/End, activating it with Enter. The child gives the selected
/// row [selectedKey] so keyboard moves can scroll it into view.
class ListKeyboard<T> extends StatefulWidget {
  /// Keyboard selection over [values], the rows in display order.
  const ListKeyboard({
    super.key,
    required this.values,
    required this.selected,
    required this.onSelected,
    required this.onActivated,
    required this.builder,
    this.onOtherKey,
  });

  /// The selectable values, top to bottom.
  final List<T> values;

  /// The selected value.
  final T? selected;

  /// Called with the newly selected value.
  final ValueChanged<T>? onSelected;

  /// Called with the selected value on Enter.
  final ValueChanged<T>? onActivated;

  /// Builds the list; attach `selectedKey` to the selected row.
  final Widget Function(BuildContext context, GlobalKey selectedKey) builder;

  /// Handles keys beyond the common ones (a tree's Left/Right).
  final KeyEventResult Function(LogicalKeyboardKey key)? onOtherKey;

  @override
  State<ListKeyboard<T>> createState() => _ListKeyboardState<T>();
}

class _ListKeyboardState<T> extends State<ListKeyboard<T>> {
  final _focus = FocusNode(debugLabel: 'Win98 list');
  final _selectedKey = GlobalKey();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// Index of the selected value, or -1 when nothing (shown) is selected.
  int get _current {
    final selected = widget.selected;
    return selected == null ? -1 : widget.values.indexOf(selected);
  }

  void _select(int index) {
    final values = widget.values;
    if (values.isEmpty) return;
    final current = _current;
    final next = index.clamp(0, values.length - 1);
    if (next != current) widget.onSelected?.call(values[next]);
    // After the parent rebuilds with the new selection, scroll just enough to
    // show it: moving down keeps it at the bottom edge, up at the top.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final row = _selectedKey.currentContext;
      if (row == null || !row.mounted) return;
      Scrollable.ensureVisible(
        row,
        alignmentPolicy: next > current
            ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
            : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || widget.onSelected == null) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final index = _current;
    if (key == LogicalKeyboardKey.arrowDown) {
      _select(index + 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _select(index < 0 ? 0 : index - 1);
    } else if (key == LogicalKeyboardKey.home) {
      _select(0);
    } else if (key == LogicalKeyboardKey.end) {
      _select(widget.values.length - 1);
    } else if (key == LogicalKeyboardKey.enter && index >= 0) {
      widget.onActivated?.call(widget.values[index]);
    } else {
      return widget.onOtherKey?.call(key) ?? KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      canRequestFocus: widget.onSelected != null,
      onKeyEvent: _onKey,
      child: Listener(
        onPointerDown: (_) {
          if (widget.onSelected != null) _focus.requestFocus();
        },
        child: widget.builder(context, _selectedKey),
      ),
    );
  }
}
