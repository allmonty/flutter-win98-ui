import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'menu.dart';
import 'popup.dart';
import 'theme.dart';

/// A window button on a [Win98Taskbar].
class Win98Task {
  /// A task labeled [label].
  const Win98Task({required this.label, this.icon, this.active = false, this.onPressed});

  /// The window's title.
  final String label;

  /// Shown before the label, e.g. the window's icon.
  final Widget? icon;

  /// Draws the button pressed in, for the window in front.
  final bool active;

  /// Called on tap (usually: bring the window to the front or minimize it).
  final VoidCallback? onPressed;
}

/// The Windows 98 taskbar: a Start button opening [startMenu], a button per
/// task, and a sunken tray on the right. Place it at the bottom of a
/// `Win98Desktop`; the Start menu opens upward.
class Win98Taskbar extends StatelessWidget {
  /// A taskbar with [startMenu], [tasks] and an optional [tray].
  const Win98Taskbar({
    super.key,
    required this.startMenu,
    this.tasks = const [],
    this.tray,
    this.startLabel = 'Start',
    this.startIcon,
  });

  /// Entries of the Start menu; items with `children` open submenus.
  final List<Win98MenuEntry> startMenu;

  /// One button per task, left to right.
  final List<Win98Task> tasks;

  /// Content of the sunken tray, e.g. a clock.
  final Widget? tray;

  /// The Start button's text.
  final String startLabel;

  /// Shown before [startLabel].
  final Widget? startIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final height = theme.controlHeight + 6;
    final tray = this.tray;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.face,
        border: Border(top: BorderSide(color: theme.light)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.highlight)),
        ),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
            child: Row(
              children: [
                Win98PopupAnchor(
                  builder: (context, isOpen, toggle) => _TaskbarButton(
                    pressed: isOpen,
                    onPressed: toggle,
                    semanticLabel: startLabel,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (startIcon != null) ...[startIcon!, const SizedBox(width: 4)],
                        Text(startLabel, style: theme.boldTextStyle),
                      ],
                    ),
                  ),
                  popupBuilder: (context, close) =>
                      Win98MenuPanel(items: startMenu, onDismiss: close),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Win98 shrinks task buttons evenly once they don't fit.
                      final width = tasks.isEmpty
                          ? 0.0
                          : (constraints.maxWidth / tasks.length - 3).clamp(24.0, 160.0);
                      return Row(
                        children: [
                          for (final task in tasks)
                            Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: SizedBox(
                                width: width,
                                child: _TaskbarButton(
                                  pressed: task.active,
                                  onPressed: task.onPressed,
                                  semanticLabel: task.label,
                                  child: Row(
                                    children: [
                                      if (task.icon != null) ...[
                                        task.icon!,
                                        const SizedBox(width: 4),
                                      ],
                                      Expanded(
                                        child: Text(
                                          task.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: task.active
                                              ? theme.boldTextStyle
                                              : theme.textStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                if (tray != null)
                  Bevel(
                    style: BevelStyle.status,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(widthFactor: 1, child: tray),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A raised taskbar button that stays pressed in while [pressed].
class _TaskbarButton extends StatefulWidget {
  const _TaskbarButton({
    required this.pressed,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
  });

  final bool pressed;
  final VoidCallback? onPressed;
  final Widget child;
  final String semanticLabel;

  @override
  State<_TaskbarButton> createState() => _TaskbarButtonState();
}

class _TaskbarButtonState extends State<_TaskbarButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final pressed = widget.pressed || _down;
    return Semantics(
      button: true,
      selected: widget.pressed,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: Bevel(
          style: pressed ? BevelStyle.pressed : BevelStyle.raised,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.translate(
            offset: pressed ? const Offset(1, 1) : Offset.zero,
            child: Center(widthFactor: 1, child: widget.child),
          ),
        ),
      ),
    );
  }
}
