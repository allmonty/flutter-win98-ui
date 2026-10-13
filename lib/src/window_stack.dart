import 'package:flutter/widgets.dart';

import 'window_scope.dart';

/// A window floating in a [Win98WindowStack].
class Win98StackWindow {
  /// A window identified by [id], first shown at [position] with [size].
  const Win98StackWindow({
    required this.id,
    required this.position,
    required this.size,
    required this.child,
  });

  /// Identifies the window across rebuilds, e.g. a document name.
  final Object id;

  /// Where the window first appears; after that the user moves it.
  final Offset position;

  /// The window's size.
  final Size size;

  /// The window, usually a `Win98Window` with `expand: true`.
  final Widget child;
}

/// Overlapping windows that can be dragged by their title bars, as on a
/// Win98 desktop. Tapping a window brings it to the front; the front window
/// has the active title bar.
///
/// Windows added later open in front. To bring one forward from outside
/// (e.g. a taskbar button), call [Win98WindowStackState.bringToFront] through a
/// `GlobalKey<Win98WindowStackState>`.
///
/// shortcut: windows can't be resized by their edges; add resize handles if
/// an app needs them.
class Win98WindowStack extends StatefulWidget {
  /// A stack of [windows].
  const Win98WindowStack({super.key, required this.windows, this.onActivated});

  /// The windows, in any order; the stack keeps their front-to-back order.
  final List<Win98StackWindow> windows;

  /// Called with a window's id when it comes to the front.
  final ValueChanged<Object>? onActivated;

  @override
  State<Win98WindowStack> createState() => Win98WindowStackState();
}

/// State of a [Win98WindowStack], for bringing windows to the front.
class Win98WindowStackState extends State<Win98WindowStack> {
  final _positions = <Object, Offset>{};
  final _order = <Object>[]; // back to front
  Size _bounds = Size.infinite;

  /// The id of the front window, or `null` when there are none.
  Object? get activeId => _order.isEmpty ? null : _order.last;

  /// Brings the window with [id] to the front.
  void bringToFront(Object id) {
    if (activeId == id || !_order.contains(id)) return;
    setState(
      () => _order
        ..remove(id)
        ..add(id),
    );
    widget.onActivated?.call(id);
  }

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(Win98WindowStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// Adds new windows in front and forgets removed ones.
  void _sync() {
    final ids = {for (final w in widget.windows) w.id};
    _order.removeWhere((id) => !ids.contains(id));
    _positions.removeWhere((id, _) => !ids.contains(id));
    for (final w in widget.windows) {
      if (_positions.containsKey(w.id)) continue;
      _positions[w.id] = w.position;
      _order.add(w.id);
    }
  }

  void _drag(Win98StackWindow window, Offset delta) {
    // Keep a strip of the title bar on screen so the window can be grabbed.
    const grip = 40.0;
    final p = _positions[window.id]! + delta;
    setState(() {
      _positions[window.id] = Offset(
        p.dx.clamp(grip - window.size.width, _bounds.width - grip),
        p.dy.clamp(0.0, _bounds.height - grip),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final byId = {for (final w in widget.windows) w.id: w};
    return LayoutBuilder(
      builder: (context, constraints) {
        _bounds = constraints.biggest;
        return Stack(
          children: [
            for (final id in _order)
              Positioned(
                // Keyed so a window keeps its state when it moves forward.
                key: ValueKey(id),
                left: _positions[id]!.dx,
                top: _positions[id]!.dy,
                width: byId[id]!.size.width,
                height: byId[id]!.size.height,
                child: Listener(
                  onPointerDown: (_) => bringToFront(id),
                  child: WindowScope(
                    active: id == activeId,
                    onDragStart: () => bringToFront(id),
                    onDrag: (delta) => _drag(byId[id]!, delta),
                    child: byId[id]!.child,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
