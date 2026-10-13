import 'dart:async';

import 'package:flutter/widgets.dart';

import 'popup_layout.dart';
import 'theme.dart';

/// A yellow tooltip shown below [child] after the pointer rests on it, or on
/// a long press on touch screens.
class Win98Tooltip extends StatefulWidget {
  /// Shows [message] for [child].
  const Win98Tooltip({
    super.key,
    required this.message,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 500),
    this.showDuration = const Duration(seconds: 2),
  });

  /// The tooltip text, also used as the child's semantic tooltip.
  final String message;

  /// The widget the tooltip describes.
  final Widget child;

  /// How long the pointer must rest on [child] before the tooltip shows.
  final Duration waitDuration;

  /// How long a tooltip opened by a long press stays up.
  final Duration showDuration;

  @override
  State<Win98Tooltip> createState() => _Win98TooltipState();
}

class _Win98TooltipState extends State<Win98Tooltip> {
  final _controller = OverlayPortalController();
  Timer? _timer;
  Rect _anchor = Rect.zero;

  void _show() {
    _timer?.cancel();
    final anchor = overlayRectOf(context);
    if (anchor == null || !mounted) return;
    _anchor = anchor;
    setState(_controller.show);
  }

  void _hide() {
    _timer?.cancel();
    if (_controller.isShowing && mounted) setState(_controller.hide);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: widget.message,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (overlayContext) => IgnorePointer(
          child: CustomSingleChildLayout(
            delegate: PopupLayout(
              anchor: _anchor,
              safeArea: MediaQuery.maybePaddingOf(overlayContext) ?? EdgeInsets.zero,
            ),
            child: _TooltipBox(widget.message),
          ),
        ),
        child: MouseRegion(
          onEnter: (_) => _timer = Timer(widget.waitDuration, _show),
          onExit: (_) => _hide(),
          // A Listener, not a tap recognizer, so it doesn't compete with the
          // child's own gestures: any press dismisses the tooltip, as in Win98.
          child: Listener(
            onPointerDown: (_) => _hide(),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () {
                _show();
                _timer = Timer(widget.showDuration, _hide);
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipBox extends StatelessWidget {
  const _TooltipBox(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.tooltip,
          border: Border.all(color: theme.darkShadow),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Text(message, style: theme.textStyle),
        ),
      ),
    );
  }
}
