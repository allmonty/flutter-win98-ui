import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'scroll.dart';
import 'theme.dart';

/// A node of a [Win98TreeView].
class Win98TreeNode<T> {
  /// A node for [value] labeled [label], with optional [children].
  const Win98TreeNode({
    required this.value,
    required this.label,
    this.icon,
    this.children = const [],
  });

  /// The value reported when the node is selected, expanded or activated.
  final T value;

  /// The node's text.
  final String label;

  /// Shown before the label, e.g. a folder icon.
  final Widget? icon;

  /// Child nodes, shown while this node is expanded.
  final List<Win98TreeNode<T>> children;
}

/// Explorer's folder tree: a sunken list of nodes joined by dotted lines,
/// with `[+]`/`[-]` boxes that expand and collapse them.
///
/// Expansion is controlled by the parent: [expanded] holds the values of the
/// open nodes, and [onExpansionChanged] reports a toggle.
class Win98TreeView<T> extends StatelessWidget {
  /// A tree of [roots].
  const Win98TreeView({
    super.key,
    required this.roots,
    required this.expanded,
    required this.onExpansionChanged,
    required this.selected,
    required this.onSelected,
    this.onActivated,
    this.height = 200,
  });

  /// The top-level nodes.
  final List<Win98TreeNode<T>> roots;

  /// Values of the nodes currently expanded.
  final Set<T> expanded;

  /// Called with a node's value and its new expanded state when its box is
  /// tapped, or when a node with children is double-tapped.
  final void Function(T value, bool expanded)? onExpansionChanged;

  /// The selected node's value.
  final T? selected;

  /// Called with a tapped node's value.
  final ValueChanged<T>? onSelected;

  /// Double-tap on a node (Win98's "open").
  final ValueChanged<T>? onActivated;

  /// Fixed height; `null` fills the parent (e.g. inside an `Expanded`).
  final double? height;

  static const _indent = 18.0;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final rows = <Widget>[];
    void visit(List<Win98TreeNode<T>> nodes, List<bool> moreAbove) {
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final last = i == nodes.length - 1;
        final open = expanded.contains(node.value);
        rows.add(_row(theme, node, moreAbove, last, open));
        if (open && node.children.isNotEmpty) visit(node.children, [...moreAbove, !last]);
      }
    }

    visit(roots, const []);
    return SizedBox(
      height: height ?? double.infinity,
      child: Bevel(
        style: BevelStyle.field,
        child: Win98ScrollView(
          padding: const EdgeInsets.all(2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
        ),
      ),
    );
  }

  Widget _row(
    Win98ThemeData theme,
    Win98TreeNode<T> node,
    List<bool> moreAbove,
    bool last,
    bool open,
  ) {
    final hasChildren = node.children.isNotEmpty;
    final isSelected = node.value == selected;
    void toggle() => onExpansionChanged?.call(node.value, !open);
    final lines = SizedBox(
      width: _indent * (moreAbove.length + 1),
      height: theme.controlHeight,
      child: CustomPaint(
        painter: _TreeLinesPainter(
          theme: theme,
          moreAbove: moreAbove,
          last: last,
          box: hasChildren ? open : null,
          indent: _indent,
        ),
      ),
    );
    return Semantics(
      selected: isSelected,
      expanded: hasChildren ? open : null,
      button: true,
      label: node.label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The box column toggles; the rest of the indent is inert.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hasChildren ? toggle : null,
            child: lines,
          ),
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSelected == null ? null : () => onSelected!(node.value),
              onDoubleTap: () {
                if (hasChildren) toggle();
                onActivated?.call(node.value);
              },
              child: Container(
                height: theme.controlHeight,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (node.icon != null) ...[node.icon!, const SizedBox(width: 4)],
                    Flexible(
                      child: Container(
                        color: isSelected ? theme.selection : null,
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        child: Text(
                          node.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textStyle.copyWith(
                            color: isSelected ? theme.selectionText : theme.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dotted connector lines for one row, and the `[+]`/`[-]` box when [box]
/// is not `null` (`true` = expanded).
class _TreeLinesPainter extends CustomPainter {
  _TreeLinesPainter({
    required this.theme,
    required this.moreAbove,
    required this.last,
    required this.box,
    required this.indent,
  });

  final Win98ThemeData theme;
  final List<bool> moreAbove;
  final bool last;
  final bool? box;
  final double indent;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = theme.shadow;
    void vline(double x, double y0, double y1) {
      for (var y = y0; y < y1; y += 2) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), dot);
      }
    }

    void hline(double x0, double x1, double y) {
      for (var x = x0; x < x1; x += 2) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), dot);
      }
    }

    final midY = (size.height / 2).floorToDouble();
    for (var d = 0; d < moreAbove.length; d++) {
      if (moreAbove[d]) vline((d * indent + indent / 2).floorToDouble(), 0, size.height);
    }
    final x = (moreAbove.length * indent + indent / 2).floorToDouble();
    vline(x, 0, last ? midY : size.height);
    hline(x, x + indent / 2, midY);

    final open = box;
    if (open == null) return;
    final r = Rect.fromLTWH(x - 4, midY - 4, 9, 9);
    canvas.drawRect(r, Paint()..color = theme.window);
    final border = Paint()..color = theme.shadow;
    canvas.drawRect(Rect.fromLTWH(r.left, r.top, 9, 1), border);
    canvas.drawRect(Rect.fromLTWH(r.left, r.bottom - 1, 9, 1), border);
    canvas.drawRect(Rect.fromLTWH(r.left, r.top, 1, 9), border);
    canvas.drawRect(Rect.fromLTWH(r.right - 1, r.top, 1, 9), border);
    final ink = Paint()..color = theme.text;
    canvas.drawRect(Rect.fromLTWH(r.left + 2, midY, 5, 1), ink);
    if (!open) canvas.drawRect(Rect.fromLTWH(x, r.top + 2, 1, 5), ink);
  }

  @override
  bool shouldRepaint(_TreeLinesPainter old) =>
      old.theme != theme ||
      old.last != last ||
      old.box != box ||
      old.indent != indent ||
      !listEquals(old.moreAbove, moreAbove);
}
