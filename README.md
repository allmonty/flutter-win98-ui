# win98_ui

[![CI](https://github.com/allmonty/flutter-win98-ui/actions/workflows/ci.yml/badge.svg)](https://github.com/allmonty/flutter-win98-ui/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/win98_ui.svg)](https://pub.dev/packages/win98_ui)

A Windows 98 look-and-feel widget kit for Flutter: beveled windows you can
drag, menus, toolbars, tabs, lists, trees, dialogs, desktop icons and a
taskbar, drawn pixel by pixel the way Windows 98 drew them.

It depends only on `package:flutter/widgets.dart`, with no Material or
Cupertino, so it works under a `WidgetsApp`, `MaterialApp` or
`CupertinoApp`, and nothing from Material leaks into the look.

![A Win98-style window with a menu bar, toolbar, tabs, radio buttons, a slider, a drop-down and a taskbar](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/hero.png)

```sh
flutter pub add win98_ui
```

## Getting started

Put a `Win98Theme` *above* the navigator, so dialogs and menus inherit it:

```dart
import 'package:flutter/widgets.dart';
import 'package:win98_ui/win98_ui.dart';

void main() => runApp(
  WidgetsApp(
    color: const Color(0xFF008080),
    builder: (context, navigator) => Win98Theme(child: navigator!),
    pageRouteBuilder: <T>(settings, builder) =>
        PageRouteBuilder<T>(settings: settings, pageBuilder: (c, _, _) => builder(c)),
    home: Win98Desktop(
      child: Win98Window(
        title: 'Hello',
        onClose: () {},
        child: Win98Button(onPressed: () {}, child: const Text('OK')),
      ),
    ),
  ),
);
```

`MaterialApp.builder` works the same way. The [example app](example/lib/main.dart)
shows every widget.

## Components

### Windows, menus and toolbars

![A File menu open with an Export submenu](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/menus.png)

| Widget | Notes |
|---|---|
| `Win98Window`, `Win98TitleBar`, `Win98Desktop` | Gradient title bar with caption buttons; optional menu bar, toolbar and status bar; `expand` pins the status bar to the bottom |
| `Win98MenuBar`, `Win98Menu`, `Win98MenuItem`, `Win98MenuDivider` | Drop-down menus with shortcut hints, checkmarks, disabled items and cascading submenus (`children`); keyboard navigation with arrows, Enter and Escape; `maxHeight` scrolls a long menu |
| `Win98ContextMenu`, `Win98MenuPanel` | Opens a menu at the pointer on right-click or long press; the panel works in any popup |
| `Win98Toolbar`, `Win98ToolButton`, `Win98ToolbarDivider` | Flat tool buttons that raise on hover and stay sunken when `selected` |
| `Win98Taskbar`, `Win98Task` | Start button and menu, task buttons and a tray |
| `Win98WindowStack`, `Win98StackWindow` | Overlapping windows dragged by their title bars; tapping one brings it to the front with the active title bar, and `bringToFront` does it from a taskbar |
| `Win98DesktopIcon` | Icon over a white label; tap selects, double-tap opens |
| `Win98StatusBar`, `Win98StatusPane` | Sunken panes |
| `Win98Tooltip` | Yellow tooltip on hover or long press |

![Desktop icons, two overlapping windows (the front one active) and a taskbar](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/desktop.png)

```dart
Win98Desktop(
  child: Win98WindowStack(
    windows: [
      Win98StackWindow(
        id: 'notepad',
        position: const Offset(40, 20),
        size: const Size(260, 170),
        child: Win98Window(title: 'Notepad', expand: true, child: const Text('Hi')),
      ),
    ],
  ),
)
```

### Controls

![Buttons, checkboxes, radio buttons and a progress bar](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/controls.png)

| Widget | Notes |
|---|---|
| `Win98Button` | Pressed state, default-button outline, focus rectangle, etched disabled text, keyboard activation |
| `Win98Checkbox`, `Win98Radio<T>` | With labels, focus and semantics |
| `Win98GroupBox` | Etched frame with a caption |
| `Win98TabView`, `Win98Tab` | Property-sheet tabs that wrap into rows like Win98; controlled (`index`) or not |
| `Win98ProgressBar` | Blocky segments, or an indeterminate marquee |

### Input

![Text fields, a password field, a multi-line field, a drop-down, a slider, a spin box and a list box](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/inputs.png)

| Widget | Notes |
|---|---|
| `Win98TextField` | Sunken `EditableText`: password (`obscureText`), read-only, disabled, multi-line with a scrollbar, input formatters |
| `Win98Dropdown<T>` | Combo box with a pop-up list, plus Previous/Next buttons to step through options without opening it; Up/Down step while focused, Enter or Alt+Down opens |
| `Win98SpinBox` | Whole-number field with ▲/▼ buttons; Up/Down keys, typed values clamped to `min`..`max` |
| `Win98Slider` | Trackbar with ticks; drag, tap-to-jump, arrow keys |
| `Win98ListBox<T>` | Selection highlight, double-tap or Enter to activate, arrow keys move the selection |

### Lists and trees

![A folder tree beside a list view with Name, Type and Size columns](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/explorer.png)

| Widget | Notes |
|---|---|
| `Win98TreeView<T>`, `Win98TreeNode<T>` | Explorer's folder tree: dotted lines and `[+]`/`[-]` boxes; the parent controls expansion; Right/Left expand, collapse and step in or out |
| `Win98ListView<T>`, `Win98ListColumn`, `Win98ListRow<T>` | Explorer's Details view: column headers with a sort arrow, fixed or flex widths, right-aligned numeric columns |
| `Win98ScrollView`, `Win98Scrollbar` | Arrow buttons, dithered track, draggable thumb; vertical or horizontal (`scrollDirection` / `axis`) |

### Dialogs

![A Save Changes message box with a question icon and Yes, No and Cancel buttons](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/dialogs.png)

| Function / widget | Notes |
|---|---|
| `showWin98Dialog` | A modal window around any content; the close button pops `null` |
| `showWin98MessageBox`, `Win98MessageIcon` | Info, warning, error and question icons; returns the index of the pressed button |
| `showWin98ColorDialog`, `Win98ColorPicker` | Paint's "Edit Colors": the 48 basic colors and R/G/B sliders ([screenshot](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/color_dialog.png)) |
| `Win98DialogButtons` | The right-aligned button row of a dialog |

## Theming

![The same widgets in a custom brick-red and beige theme](https://raw.githubusercontent.com/allmonty/flutter-win98-ui/main/doc/screenshots/theming.png)

`Win98ThemeData` holds the colors (face, bevel highlights and shadows,
selection, title gradients, desktop, tooltip), the font and the control
metrics. Start from the classic look and change what you need:

```dart
Win98Theme(
  data: const Win98ThemeData().copyWith(
    face: const Color(0xFFD4D0C8),
    desktop: const Color(0xFF3A6EA5),
    selection: const Color(0xFF7B2D26),
    activeTitleStart: const Color(0xFF7B2D26),
    activeTitleEnd: const Color(0xFFD6A06B),
  ),
  child: navigator!,
)
```

Read the theme with `Win98Theme.of(context)`. Its `textStyle`,
`boldTextStyle` and `disabledTextStyle` match the built-in widgets.

Sizes are a bit larger than in 1998 (`controlHeight` is 32), so controls
stay usable touch targets on phones. Bevel lines stay one logical pixel
wide, which keeps the chunky look on high-DPI screens.

## Building your own controls

Every widget is built from a few public pieces you can use too:

- **`Bevel` / `BevelPainter`**: the 1- and 2-pixel borders (`raised`,
  `pressed`, `field`, `window`, `status`, `thinRaised`, `etched`, `outline`).
- **`PixelGlyph` / `Win98Glyphs`**: 1-bit bitmaps such as arrows, checks
  and caption symbols, drawn crisp at any scale. Draw your own from strings.
- **`Win98PopupAnchor`**: anchors a popup to a widget in an `OverlayPortal`,
  keeps it on screen and closes it on an outside tap.
- **`Win98MenuPanel`**, **`FocusRect`**, **`Win98Scrollbar`**.

For example, a two-state button that looks pressed while it's on:

```dart
class StickyButton extends StatelessWidget {
  const StickyButton({super.key, required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!on),
    child: Bevel(
      style: on ? BevelStyle.pressed : BevelStyle.raised,
      padding: const EdgeInsets.all(6),
      child: const PixelGlyph(Win98Glyphs.check),
    ),
  );
}
```

## Accessibility

Controls expose semantics such as button, checked, selected, expanded and
value. Buttons, tool buttons, checkboxes and radio buttons take keyboard
focus, show the dotted focus rectangle, and activate with Enter or Space.
List boxes, list views, trees, drop-downs, spin boxes, sliders and open
menus respond to arrow keys; lists take focus when tapped and scroll the
selection into view.

## Compared to other options

- **[flutter95](https://pub.dev/packages/flutter95)** brings the Windows 95
  look on top of Material (`Scaffold95`, buttons, menus, dialogs, text
  fields). It's a good fit if your app is already a `MaterialApp`.
- **win98_ui** uses no Material at all and draws Windows 98's details
  (gradient title bars, etched disabled text, dithered scrollbars). It also
  covers more of the desktop: draggable windows, desktop icons, a taskbar,
  tree and list views, tabs, submenus and context menus, a spin box and the
  color dialog.

Not included yet: resizing windows by their edges, scrolling both ways at
once (a 2D scroll view), column resizing in `Win98ListView`, three-state
checkboxes, editable combo boxes, and Alt/F10 to reach the menu bar from
the keyboard.

## Font

Ships [Pixelify Sans](https://github.com/eifetx/Pixelify-Sans) under the SIL
Open Font License (`fonts/OFL.txt`). To use your own font, declare it in
your app and set `Win98ThemeData.copyWith(fontFamily: 'YourFont')`.
Changing the family also drops the bundled `fontPackage`.

## Tests

```sh
flutter test                                    # widget and golden tests
flutter test --tags golden --update-goldens     # regenerate goldens (macOS)
```

The README screenshots are goldens too (`test/readme_images_test.dart`), so
regenerating them keeps the images in sync with the widgets.
