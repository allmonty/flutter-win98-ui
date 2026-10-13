import 'package:flutter/widgets.dart';

import 'popup_layout.dart';

/// Anchors a popup (menu, drop-down list) to a widget using an
/// [OverlayPortal]. The popup opens below the anchor, or above it when there
/// is more room there, and is kept on screen. Tapping outside closes it.
class Win98PopupAnchor extends StatefulWidget {
  const Win98PopupAnchor({
    super.key,
    required this.builder,
    required this.popupBuilder,
    this.matchWidth = false,
    this.onClosed,
  });

  /// Builds the anchor; call `toggle` to open or close the popup.
  final Widget Function(BuildContext context, bool isOpen, VoidCallback toggle) builder;

  /// Builds the popup; call `close` to dismiss it.
  final Widget Function(BuildContext context, VoidCallback close) popupBuilder;

  /// Make the popup at least as wide as the anchor (drop-down lists).
  final bool matchWidth;
  final VoidCallback? onClosed;

  @override
  State<Win98PopupAnchor> createState() => _Win98PopupAnchorState();
}

class _Win98PopupAnchorState extends State<Win98PopupAnchor> {
  final _controller = OverlayPortalController();
  Rect _anchor = Rect.zero;

  void _toggle() {
    if (_controller.isShowing) {
      _close();
      return;
    }
    final anchor = overlayRectOf(context);
    if (anchor == null) return;
    _anchor = anchor;
    setState(_controller.show);
  }

  void _close() {
    if (!_controller.isShowing) return;
    setState(_controller.hide);
    widget.onClosed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (overlayContext) {
        final padding = MediaQuery.maybePaddingOf(overlayContext) ?? EdgeInsets.zero;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _close),
            ),
            Positioned.fill(
              child: CustomSingleChildLayout(
                delegate: PopupLayout(
                  anchor: _anchor,
                  matchWidth: widget.matchWidth,
                  safeArea: padding,
                ),
                child: widget.popupBuilder(overlayContext, _close),
              ),
            ),
          ],
        );
      },
      child: widget.builder(context, _controller.isShowing, _toggle),
    );
  }
}
