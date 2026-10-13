import 'package:flutter/widgets.dart';

/// Colors, typography and metrics of the Windows 98 look.
///
/// Metrics are in logical pixels and a bit larger than the 1998 originals so
/// controls stay comfortable touch targets on phones; bevel lines stay one
/// logical pixel wide, which keeps the chunky look on high-DPI screens.
@immutable
class Win98ThemeData {
  /// The classic Windows 98 colors and the bundled Pixelify Sans font.
  const Win98ThemeData({
    this.face = const Color(0xFFC0C0C0),
    this.highlight = const Color(0xFFFFFFFF),
    this.light = const Color(0xFFDFDFDF),
    this.shadow = const Color(0xFF808080),
    this.darkShadow = const Color(0xFF000000),
    this.window = const Color(0xFFFFFFFF),
    this.text = const Color(0xFF000000),
    this.disabledText = const Color(0xFF808080),
    this.selection = const Color(0xFF000080),
    this.selectionText = const Color(0xFFFFFFFF),
    this.desktop = const Color(0xFF008080),
    this.activeTitleStart = const Color(0xFF000080),
    this.activeTitleEnd = const Color(0xFF1084D0),
    this.inactiveTitleStart = const Color(0xFF808080),
    this.inactiveTitleEnd = const Color(0xFFB5B5B5),
    this.titleText = const Color(0xFFFFFFFF),
    this.tooltip = const Color(0xFFFFFFE1),
    this.fontFamily = 'PixelifySans',
    this.fontPackage = 'win98_ui',
    this.fontSize = 15,
    this.controlHeight = 32,
    this.titleBarHeight = 28,
    this.scrollbarSize = 20,
  });

  /// Face of buttons, windows and other raised surfaces.
  final Color face;

  /// Outer top-left bevel line of raised surfaces.
  final Color highlight;

  /// Inner top-left bevel line of raised surfaces.
  final Color light;

  /// Inner bottom-right bevel line, and gray text and glyphs.
  final Color shadow;

  /// Outer bottom-right bevel line.
  final Color darkShadow;

  /// Background of text fields, list boxes and other "field" surfaces.
  final Color window;

  /// Text and glyph color.
  final Color text;

  /// Color of disabled text (drawn etched, see [disabledTextStyle]).
  final Color disabledText;

  /// Background of selected list rows and highlighted menu items.
  final Color selection;

  /// Text on [selection].
  final Color selectionText;

  /// Background of `Win98Desktop`.
  final Color desktop;

  /// Left end of an active window's title-bar gradient.
  final Color activeTitleStart;

  /// Right end of an active window's title-bar gradient.
  final Color activeTitleEnd;

  /// Left end of an inactive window's title-bar gradient.
  final Color inactiveTitleStart;

  /// Right end of an inactive window's title-bar gradient.
  final Color inactiveTitleEnd;

  /// Title-bar text.
  final Color titleText;

  /// Background of tooltips.
  final Color tooltip;

  /// Font family of all text.
  final String fontFamily;

  /// Package that bundles [fontFamily]; `null` for a font declared by the app.
  final String? fontPackage;

  /// Font size of all text, in logical pixels.
  final double fontSize;

  /// Minimum height of buttons, fields and list rows.
  final double controlHeight;

  /// Height of window title bars.
  final double titleBarHeight;

  /// Width of vertical (and height of horizontal) scrollbars.
  final double scrollbarSize;

  /// The default text style: [fontFamily], [fontSize] and [text].
  TextStyle get textStyle => TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: fontSize,
    color: text,
    height: 1.2,
    // Pixelify Sans's "fi" ligature reads as an "A".
    fontFeatures: const [FontFeature.disable('liga')],
  );

  /// [textStyle] in bold, for default buttons and captions.
  TextStyle get boldTextStyle => textStyle.copyWith(fontWeight: FontWeight.w700);

  /// Win98's "etched" disabled text: gray with a white drop shadow.
  TextStyle get disabledTextStyle => textStyle.copyWith(
    color: disabledText,
    shadows: [Shadow(color: highlight, offset: const Offset(1, 1))],
  );

  /// A copy with the given fields replaced.
  ///
  /// Passing [fontFamily] without [fontPackage] clears [fontPackage], since a
  /// new family is the app's own font, not one bundled with this package.
  Win98ThemeData copyWith({
    Color? face,
    Color? highlight,
    Color? light,
    Color? shadow,
    Color? darkShadow,
    Color? window,
    Color? text,
    Color? disabledText,
    Color? selection,
    Color? selectionText,
    Color? desktop,
    Color? activeTitleStart,
    Color? activeTitleEnd,
    Color? inactiveTitleStart,
    Color? inactiveTitleEnd,
    Color? titleText,
    Color? tooltip,
    String? fontFamily,
    String? fontPackage,
    double? fontSize,
    double? controlHeight,
    double? titleBarHeight,
    double? scrollbarSize,
  }) {
    return Win98ThemeData(
      face: face ?? this.face,
      highlight: highlight ?? this.highlight,
      light: light ?? this.light,
      shadow: shadow ?? this.shadow,
      darkShadow: darkShadow ?? this.darkShadow,
      window: window ?? this.window,
      text: text ?? this.text,
      disabledText: disabledText ?? this.disabledText,
      selection: selection ?? this.selection,
      selectionText: selectionText ?? this.selectionText,
      desktop: desktop ?? this.desktop,
      activeTitleStart: activeTitleStart ?? this.activeTitleStart,
      activeTitleEnd: activeTitleEnd ?? this.activeTitleEnd,
      inactiveTitleStart: inactiveTitleStart ?? this.inactiveTitleStart,
      inactiveTitleEnd: inactiveTitleEnd ?? this.inactiveTitleEnd,
      titleText: titleText ?? this.titleText,
      tooltip: tooltip ?? this.tooltip,
      fontFamily: fontFamily ?? this.fontFamily,
      fontPackage: fontFamily != null ? fontPackage : fontPackage ?? this.fontPackage,
      fontSize: fontSize ?? this.fontSize,
      controlHeight: controlHeight ?? this.controlHeight,
      titleBarHeight: titleBarHeight ?? this.titleBarHeight,
      scrollbarSize: scrollbarSize ?? this.scrollbarSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Win98ThemeData &&
      other.face == face &&
      other.highlight == highlight &&
      other.light == light &&
      other.shadow == shadow &&
      other.darkShadow == darkShadow &&
      other.window == window &&
      other.text == text &&
      other.disabledText == disabledText &&
      other.selection == selection &&
      other.selectionText == selectionText &&
      other.desktop == desktop &&
      other.activeTitleStart == activeTitleStart &&
      other.activeTitleEnd == activeTitleEnd &&
      other.inactiveTitleStart == inactiveTitleStart &&
      other.inactiveTitleEnd == inactiveTitleEnd &&
      other.titleText == titleText &&
      other.tooltip == tooltip &&
      other.fontFamily == fontFamily &&
      other.fontPackage == fontPackage &&
      other.fontSize == fontSize &&
      other.controlHeight == controlHeight &&
      other.titleBarHeight == titleBarHeight &&
      other.scrollbarSize == scrollbarSize;

  @override
  int get hashCode => Object.hashAll([
    face,
    highlight,
    light,
    shadow,
    darkShadow,
    window,
    text,
    disabledText,
    selection,
    selectionText,
    desktop,
    activeTitleStart,
    activeTitleEnd,
    inactiveTitleStart,
    inactiveTitleEnd,
    titleText,
    tooltip,
    fontFamily,
    fontPackage,
    fontSize,
    controlHeight,
    titleBarHeight,
    scrollbarSize,
  ]);
}

/// Provides [Win98ThemeData] to descendants and sets the default text style.
class Win98Theme extends StatelessWidget {
  /// Provides [data] (the classic look by default) to [child].
  const Win98Theme({super.key, this.data = const Win98ThemeData(), required this.child});

  /// The theme for descendants.
  final Win98ThemeData data;

  /// The widget below this one.
  final Widget child;

  /// The nearest theme, or the default theme when there is none.
  static Win98ThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InheritedWin98Theme>()?.data ??
      const Win98ThemeData();

  @override
  Widget build(BuildContext context) {
    return _InheritedWin98Theme(
      data: data,
      child: DefaultTextStyle(style: data.textStyle, child: child),
    );
  }
}

class _InheritedWin98Theme extends InheritedWidget {
  const _InheritedWin98Theme({required this.data, required super.child});

  final Win98ThemeData data;

  @override
  bool updateShouldNotify(_InheritedWin98Theme oldWidget) => data != oldWidget.data;
}
