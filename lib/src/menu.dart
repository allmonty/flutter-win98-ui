import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'bevel.dart';
import 'glyphs.dart';
import 'popup_layout.dart';
import 'scroll.dart';
import 'theme.dart';

/// An entry of a [Win98Menu].
sealed class Win98MenuEntry {
  const Win98MenuEntry();
}

/// A selectable menu command, or a submenu when [children] is set.
///
/// An item with neither [onSelected] nor [children] is shown disabled.
class Win98MenuItem extends Win98MenuEntry {
  /// A menu item labeled [label].
  const Win98MenuItem({
    required this.label,
    this.onSelected,
    this.shortcut,
    this.checked = false,
    this.children,
  });

  /// The item's text.
  final String label;

  /// Called when the item is chosen, after the menu closes.
  final VoidCallback? onSelected;

  /// Right-aligned hint such as "Ctrl+S". Only a hint: the app handles the
  /// key itself.
  final String? shortcut;

  /// Shows a checkmark before the label.
  final bool checked;

  /// Entries of a submenu that opens to the side; the item then shows an
  /// arrow instead of [shortcut].
  final List<Win98MenuEntry>? children;

  /// Whether the item can be chosen or opened.
  bool get enabled => onSelected != null || (children?.isNotEmpty ?? false);
}

/// A horizontal separator line.
class Win98MenuDivider extends Win98MenuEntry {
  /// A separator line.
  const Win98MenuDivider();
}

/// A top-level menu ("File", "Edit", ...).
class Win98Menu {
  /// A menu titled [label] listing [items].
  const Win98Menu({required this.label, required this.items, this.maxHeight});

  /// The title shown in the menu bar.
  final String label;

  /// The menu's items and dividers.
  final List<Win98MenuEntry> items;

  /// Caps the drop-down panel's height and adds a scrollbar once its items
  /// overflow it, instead of the panel growing to fit them all. `null` (the
  /// default) never scrolls.
  final double? maxHeight;
}

/// The menu bar under a window's title bar.
///
/// An open menu is driven by the keyboard too: Up/Down move the highlight,
/// Enter chooses, Right/Left open and close submenus or move to the next or
/// previous menu, and Escape closes.
class Win98MenuBar extends StatefulWidget {
  /// A menu bar with [menus], left to right.
  const Win98MenuBar({super.key, required this.menus});

  /// The menus.
  final List<Win98Menu> menus;

  @override
  State<Win98MenuBar> createState() => _Win98MenuBarState();
}

class _Win98MenuBarState extends State<Win98MenuBar> {
  int? _open;
  final _controllers = <Win98Menu, OverlayPortalController>{};

  OverlayPortalController _controllerOf(int i) =>
      _controllers.putIfAbsent(widget.menus[i], OverlayPortalController.new);

  void _set(int? index) {
    final open = _open;
    if (open != null && open < widget.menus.length) _controllerOf(open).hide();
    if (index != null) _controllerOf(index).show();
    setState(() => _open = index);
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.menus.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      // Wraps onto a second line when narrow, as Win98 menu bars did.
      child: Wrap(
        children: [
          for (var i = 0; i < n; i++)
            _MenuBarButton(
              menu: widget.menus[i],
              controller: _controllerOf(i),
              isOpen: _open == i,
              onTap: () => _set(_open == i ? null : i),
              onDismiss: () => _set(null),
              onPrevious: () => _set((i - 1) % n),
              onNext: () => _set((i + 1) % n),
            ),
        ],
      ),
    );
  }
}

class _MenuBarButton extends StatelessWidget {
  const _MenuBarButton({
    required this.menu,
    required this.controller,
    required this.isOpen,
    required this.onTap,
    required this.onDismiss,
    required this.onPrevious,
    required this.onNext,
  });

  final Win98Menu menu;
  final OverlayPortalController controller;
  final bool isOpen;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    return OverlayPortal(
      controller: controller,
      overlayChildBuilder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onDismiss),
          ),
          Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: PopupLayout(
                anchor: overlayRectOf(context) ?? Rect.zero,
                safeArea: MediaQuery.maybePaddingOf(overlayContext) ?? EdgeInsets.zero,
              ),
              child: _MenuPanel(
                // A new panel per menu, so keyboard focus and highlight reset.
                key: ValueKey(menu),
                items: menu.items,
                onDismiss: onDismiss,
                maxHeight: menu.maxHeight,
                onLeft: onPrevious,
                onRight: onNext,
              ),
            ),
          ),
        ],
      ),
      child: Semantics(
        button: true,
        label: menu.label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: theme.controlHeight - 4,
            child: Center(
              widthFactor: 1,
              child: isOpen
                  ? Bevel(
                      style: BevelStyle.status,
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      child: Text(menu.label),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Text(menu.label),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The raised drop-down panel listing menu entries. Also usable on its own,
/// e.g. in a custom popup; see also `Win98ContextMenu`.
///
/// It takes keyboard focus when shown: Up/Down move the highlight, Enter or
/// Space chooses, Right opens a submenu, Left or Escape closes one, and
/// Escape on the panel itself calls [onDismiss].
class Win98MenuPanel extends StatelessWidget {
  /// A panel listing [items].
  const Win98MenuPanel({super.key, required this.items, required this.onDismiss, this.maxHeight});

  /// The panel's items and dividers.
  final List<Win98MenuEntry> items;

  /// Called before an item's callback, to close the panel.
  final VoidCallback onDismiss;

  /// Caps the panel's height and adds a scrollbar once its items overflow
  /// it. `null` (the default) never scrolls, sizing to fit all items.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) =>
      _MenuPanel(items: items, onDismiss: onDismiss, maxHeight: maxHeight);
}

class _MenuPanel extends StatefulWidget {
  const _MenuPanel({
    super.key,
    required this.items,
    required this.onDismiss,
    this.maxHeight,
    this.onLeft,
    this.onRight,
    this.onEscape,
  });

  final List<Win98MenuEntry> items;

  /// Closes the whole menu (every open panel).
  final VoidCallback onDismiss;
  final double? maxHeight;

  /// Left on this panel: close it (a submenu) or go to the previous menu.
  final VoidCallback? onLeft;

  /// Right on an item without a submenu: go to the next menu.
  final VoidCallback? onRight;

  /// Escape: close this submenu. `null` calls [onDismiss].
  final VoidCallback? onEscape;

  @override
  State<_MenuPanel> createState() => _MenuPanelState();
}

class _MenuPanelState extends State<_MenuPanel> {
  final _focus = FocusNode(debugLabel: 'Win98MenuPanel');
  int? _hot;
  int? _sub;
  final _subs = <int, OverlayPortalController>{};

  OverlayPortalController _subController(int i) =>
      _subs.putIfAbsent(i, OverlayPortalController.new);

  /// Opens the submenu of item `i` (closing any other); `null` closes it.
  /// Called from event handlers: portals can't be shown during build.
  void _setSub(int? i) {
    if (_sub == i) return;
    if (_sub != null) _subController(_sub!).hide();
    if (i != null) _subController(i).show();
    _sub = i;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Win98MenuItem? _item(int? i) {
    if (i == null || i < 0 || i >= widget.items.length) return null;
    final entry = widget.items[i];
    return entry is Win98MenuItem ? entry : null;
  }

  bool _hasSub(int? i) => _item(i)?.children?.isNotEmpty ?? false;

  void _hover(int i) {
    if (_hot == i) return;
    setState(() {
      _hot = i;
      _setSub(_hasSub(i) ? i : null);
    });
  }

  void _activate(int i) {
    final item = _item(i);
    if (item == null || !item.enabled) return;
    if (_hasSub(i)) {
      setState(() {
        _hot = i;
        _setSub(i);
      });
      return;
    }
    widget.onDismiss();
    item.onSelected?.call();
  }

  void _closeSub() {
    setState(() => _setSub(null));
    _focus.requestFocus();
  }

  void _move(int step) {
    final n = widget.items.length;
    var i = _hot ?? (step > 0 ? -1 : n);
    for (var tries = 0; tries < n; tries++) {
      i = (i + step) % n;
      if (_item(i)?.enabled ?? false) {
        setState(() {
          _hot = i;
          _setSub(null);
        });
        return;
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      final hot = _hot;
      if (hot != null) _activate(hot);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (_hasSub(_hot)) {
        _activate(_hot!);
      } else {
        widget.onRight?.call();
      }
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      widget.onLeft?.call();
    } else if (key == LogicalKeyboardKey.escape) {
      (widget.onEscape ?? widget.onDismiss)();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.items.length; i++)
          switch (widget.items[i]) {
            final Win98MenuItem item => _MenuItemRow(
              item: item,
              hot: _hot == i,
              subOpen: _sub == i,
              subController: _subController(i),
              onHover: () => _hover(i),
              onTap: () => _activate(i),
              submenu: (_) => _MenuPanel(
                items: item.children!,
                onDismiss: widget.onDismiss,
                onLeft: _closeSub,
                onEscape: _closeSub,
              ),
            ),
            Win98MenuDivider() => const _MenuDividerRow(),
          },
      ],
    );
    final maxHeight = widget.maxHeight;
    final body = maxHeight == null
        ? SingleChildScrollView(child: IntrinsicWidth(child: column))
        : ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: IntrinsicWidth(child: Win98ScrollView(child: column)),
          );
    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: Bevel(style: BevelStyle.window, padding: const EdgeInsets.all(1), child: body),
      ),
    );
  }
}

class _MenuDividerRow extends StatelessWidget {
  const _MenuDividerRow();

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        children: [
          Container(height: 1, color: theme.shadow),
          Container(height: 1, color: theme.highlight),
        ],
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({
    required this.item,
    required this.hot,
    required this.subOpen,
    required this.subController,
    required this.onHover,
    required this.onTap,
    required this.submenu,
  });

  final Win98MenuItem item;
  final bool hot;
  final bool subOpen;
  final OverlayPortalController subController;
  final VoidCallback onHover;
  final VoidCallback onTap;
  final WidgetBuilder submenu;

  @override
  Widget build(BuildContext context) {
    final theme = Win98Theme.of(context);
    final enabled = item.enabled;
    final hasSub = item.children?.isNotEmpty ?? false;
    final isHot = hot && enabled;
    final style = !enabled
        ? theme.disabledTextStyle
        : theme.textStyle.copyWith(color: isHot ? theme.selectionText : theme.text);

    final row = Semantics(
      button: true,
      enabled: enabled,
      checked: item.checked ? true : null,
      expanded: hasSub ? subOpen : null,
      label: item.label,
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => onHover(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => onHover(),
          onTap: enabled ? onTap : null,
          child: Container(
            color: isHot ? theme.selection : null,
            constraints: BoxConstraints(minHeight: theme.controlHeight),
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: item.checked ? Text('✓', style: style, textAlign: TextAlign.center) : null,
                ),
                Expanded(child: Text(item.label, style: style)),
                if (hasSub) ...[
                  const SizedBox(width: 16),
                  PixelGlyph(Win98Glyphs.arrowRight, color: style.color, pixelSize: 1.5),
                ] else if (item.shortcut != null) ...[
                  const SizedBox(width: 24),
                  Text(item.shortcut!, style: style),
                  const SizedBox(width: 8),
                ] else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
    if (!hasSub) return row;
    return OverlayPortal(
      controller: subController,
      overlayChildBuilder: (overlayContext) => CustomSingleChildLayout(
        delegate: PopupLayout(
          anchor: overlayRectOf(context) ?? Rect.zero,
          safeArea: MediaQuery.maybePaddingOf(overlayContext) ?? EdgeInsets.zero,
          side: true,
        ),
        child: submenu(overlayContext),
      ),
      child: row,
    );
  }
}
