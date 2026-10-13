import 'package:flutter/widgets.dart';

// Not exported: links a Win98TitleBar to the Win98WindowStack it floats in.

/// Provided by `Win98WindowStack` around each window: whether the window is
/// in front, and how its title bar moves it.
class WindowScope extends InheritedWidget {
  /// Scope for one stacked window.
  const WindowScope({
    super.key,
    required this.active,
    required this.onDragStart,
    required this.onDrag,
    required super.child,
  });

  /// Whether the window is the front one.
  final bool active;

  /// Called when a title-bar drag starts (raises the window).
  final VoidCallback onDragStart;

  /// Called with each drag movement.
  final ValueChanged<Offset> onDrag;

  /// The nearest scope, or `null` outside a window stack.
  static WindowScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WindowScope>();

  @override
  bool updateShouldNotify(WindowScope oldWidget) => active != oldWidget.active;
}
