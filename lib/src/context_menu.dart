import 'package:flutter/widgets.dart';

import 'menu.dart';
import 'popup_layout.dart';

/// Opens a pop-up menu of [items] at the pointer on a right-click or a long
/// press on [child].
class Win98ContextMenu extends StatefulWidget {
  /// A context menu for [child].
  const Win98ContextMenu({super.key, required this.items, required this.child, this.maxHeight});

  /// The menu's items and dividers. A disabled context menu has none.
  final List<Win98MenuEntry> items;

  /// The widget that opens the menu.
  final Widget child;

  /// Caps the menu's height, as [Win98Menu.maxHeight] does.
  final double? maxHeight;

  @override
  State<Win98ContextMenu> createState() => _Win98ContextMenuState();
}

class _Win98ContextMenuState extends State<Win98ContextMenu> {
  final _controller = OverlayPortalController();
  Offset _at = Offset.zero;

  void _open(Offset global) {
    if (widget.items.isEmpty) return;
    _at = overlayOffsetOf(context, global);
    setState(_controller.show);
  }

  void _close() {
    if (_controller.isShowing) setState(_controller.hide);
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              onSecondaryTap: _close,
            ),
          ),
          Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: PopupLayout(
                anchor: _at & Size.zero,
                safeArea: MediaQuery.maybePaddingOf(overlayContext) ?? EdgeInsets.zero,
              ),
              child: Win98MenuPanel(
                items: widget.items,
                onDismiss: _close,
                maxHeight: widget.maxHeight,
              ),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapUp: (d) => _open(d.globalPosition),
        onLongPressStart: (d) => _open(d.globalPosition),
        child: widget.child,
      ),
    );
  }
}
