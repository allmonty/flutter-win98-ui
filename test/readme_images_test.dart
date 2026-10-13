// Renders the README screenshots into doc/screenshots/. Regenerate with:
//   flutter test --tags golden --update-goldens test/readme_images_test.dart
@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win98_ui/win98_ui.dart';

import 'harness.dart';

void main() {
  setUpAll(loadWin98Font);

  /// Pumps `scene` filling a `size` screen, runs `act` (to open menus or
  /// dialogs), and compares the whole screen, overlays included, with
  /// `doc/screenshots/<name>.png`. Painted at 2x so it stays crisp on high-DPI
  /// displays (golden capture ignores devicePixelRatio, so scale instead).
  Future<void> shot(
    WidgetTester tester,
    String name,
    Size size,
    Widget scene, {
    Future<void> Function()? act,
    Win98ThemeData? theme,
  }) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      RepaintBoundary(
        child: Transform.scale(
          scale: 2,
          alignment: Alignment.topLeft,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: size.width,
            maxWidth: size.width,
            minHeight: size.height,
            maxHeight: size.height,
            child: harness(scene, size: size, theme: theme),
          ),
        ),
      ),
    );
    await tester.pump();
    await act?.call();
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../doc/screenshots/$name.png'),
    );
  }

  testWidgets('hero', (tester) async {
    await shot(tester, 'hero', const Size(560, 420), const _HeroScene());
  });

  testWidgets('controls', (tester) async {
    await shot(
      tester,
      'controls',
      const Size(480, 300),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Win98Window(
          title: 'Controls',
          bodyPadding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Win98Button(isDefault: true, onPressed: () {}, child: const Text('OK')),
                    const SizedBox(height: 6),
                    Win98Button(onPressed: () {}, child: const Text('Cancel')),
                    const SizedBox(height: 6),
                    const Win98Button(onPressed: null, child: Text('Disabled')),
                    const SizedBox(height: 10),
                    const Win98ProgressBar(value: 0.45),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Win98GroupBox(
                  label: 'Options',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Win98Checkbox(value: true, label: 'Checked', onChanged: (_) {}),
                      Win98Checkbox(value: false, label: 'Unchecked', onChanged: (_) {}),
                      const Win98Checkbox(value: true, label: 'Disabled', onChanged: null),
                      Win98Radio<int>(
                        value: 1,
                        groupValue: 1,
                        label: 'Selected',
                        onChanged: (_) {},
                      ),
                      Win98Radio<int>(
                        value: 2,
                        groupValue: 1,
                        label: 'Not selected',
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });

  testWidgets('inputs', (tester) async {
    final name = TextEditingController(text: 'Hello, 1998');
    final password = TextEditingController(text: 'hunter2');
    final notes = TextEditingController(
      text:
          'Multi-line fields scroll\nwith a Win98 scrollbar\nonce the text\nis longer than\nmaxLines.',
    );
    addTearDown(name.dispose);
    addTearDown(password.dispose);
    addTearDown(notes.dispose);
    await shot(
      tester,
      'inputs',
      const Size(480, 330),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Win98Window(
          title: 'Inputs',
          bodyPadding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Win98TextField(controller: name),
                    const SizedBox(height: 6),
                    Win98TextField(controller: password, obscureText: true),
                    const SizedBox(height: 6),
                    Win98TextField(controller: notes, maxLines: 3),
                    const SizedBox(height: 6),
                    Win98Dropdown<int>(
                      value: 1,
                      items: const [Win98DropdownItem(value: 1, label: 'Floyd-Steinberg')],
                      onChanged: (_) {},
                    ),
                    Win98Slider(value: 0.6, divisions: 10, onChanged: (_) {}),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Win98ListBox<String>(
                  height: 230,
                  items: [
                    for (final name in ['Gameboy', 'CGA', 'EGA', 'C64', 'NES', 'PICO-8', 'Sepia'])
                      Win98ListItem(value: name, label: name),
                  ],
                  selected: 'EGA',
                  onSelected: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });

  testWidgets('menus', (tester) async {
    await shot(
      tester,
      'menus',
      const Size(480, 280),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Win98Window(
          title: 'Menus',
          expand: true,
          menuBar: Win98MenuBar(
            menus: [
              Win98Menu(
                label: 'File',
                items: [
                  Win98MenuItem(label: 'New', shortcut: 'Ctrl+N', onSelected: () {}),
                  Win98MenuItem(label: 'Open...', shortcut: 'Ctrl+O', onSelected: () {}),
                  Win98MenuItem(
                    label: 'Export',
                    children: [
                      Win98MenuItem(label: 'PNG', onSelected: () {}),
                      Win98MenuItem(label: 'GIF', onSelected: () {}),
                    ],
                  ),
                  const Win98MenuDivider(),
                  Win98MenuItem(label: 'Grid', checked: true, onSelected: () {}),
                  const Win98MenuItem(label: 'Print'),
                ],
              ),
              const Win98Menu(label: 'Edit', items: []),
              const Win98Menu(label: 'Help', items: []),
            ],
          ),
          child: const SizedBox.expand(),
        ),
      ),
      act: () async {
        await tester.tap(find.text('File'));
        await tester.pump();
        await tester.tap(find.text('Export'));
        await tester.pump();
      },
    );
  });

  testWidgets('dialogs', (tester) async {
    await shot(
      tester,
      'dialogs',
      const Size(480, 220),
      const SizedBox.expand(
        child: Text('anchor', style: TextStyle(color: Color(0x00000000))),
      ),
      act: () async {
        showWin98MessageBox(
          context: tester.element(find.text('anchor')),
          title: 'Save Changes',
          message: 'The image has changed.\nDo you want to save the changes?',
          icon: Win98MessageIconType.question,
          buttons: const ['Yes', 'No', 'Cancel'],
        );
        await tester.pump();
      },
    );
  });

  testWidgets('color dialog', (tester) async {
    await shot(
      tester,
      'color_dialog',
      const Size(480, 640),
      const SizedBox.expand(
        child: Text('anchor', style: TextStyle(color: Color(0x00000000))),
      ),
      act: () async {
        showWin98ColorDialog(
          context: tester.element(find.text('anchor')),
          initial: const Color(0xFF008080),
        );
        await tester.pump();
      },
    );
  });

  testWidgets('explorer', (tester) async {
    await shot(tester, 'explorer', const Size(560, 300), const _ExplorerScene());
  });

  testWidgets('theming', (tester) async {
    await shot(
      tester,
      'theming',
      const Size(480, 230),
      const _ThemedWindow(),
      theme: const Win98ThemeData().copyWith(
        face: const Color(0xFFD4D0C8),
        desktop: const Color(0xFF3A6EA5),
        selection: const Color(0xFF7B2D26),
        activeTitleStart: const Color(0xFF7B2D26),
        activeTitleEnd: const Color(0xFFD6A06B),
      ),
    );
  });
}

class _HeroScene extends StatelessWidget {
  const _HeroScene();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Win98Window(
              title: 'Bitmapper - photo.png',
              expand: true,
              onMinimize: () {},
              onMaximize: () {},
              onClose: () {},
              menuBar: const Win98MenuBar(
                menus: [
                  Win98Menu(label: 'File', items: []),
                  Win98Menu(label: 'Edit', items: []),
                  Win98Menu(label: 'View', items: []),
                  Win98Menu(label: 'Help', items: []),
                ],
              ),
              toolbar: Win98Toolbar(
                children: [
                  Win98ToolButton(onPressed: () {}, child: const Text('B')),
                  Win98ToolButton(onPressed: () {}, selected: true, child: const Text('I')),
                  Win98ToolButton(onPressed: () {}, child: const Text('U')),
                  const Win98ToolbarDivider(),
                  Win98ToolButton(onPressed: () {}, child: const PixelGlyph(Win98Glyphs.arrowLeft)),
                  Win98ToolButton(
                    onPressed: () {},
                    child: const PixelGlyph(Win98Glyphs.arrowRight),
                  ),
                ],
              ),
              statusBar: const Win98StatusBar(
                panes: [
                  Win98StatusPane(Text('Ready'), flex: 3),
                  Win98StatusPane(Text('16 colors')),
                ],
              ),
              child: Win98TabView(
                tabs: [
                  Win98Tab(label: 'Palette', builder: (_) => const _PalettePage()),
                  Win98Tab(label: 'Dither', builder: (_) => const SizedBox()),
                  Win98Tab(label: 'Grid', builder: (_) => const SizedBox()),
                ],
              ),
            ),
          ),
        ),
        Win98Taskbar(
          startMenu: const [],
          tasks: [
            Win98Task(label: 'Bitmapper - photo.png', active: true, onPressed: () {}),
            Win98Task(label: 'Notepad', onPressed: () {}),
          ],
          tray: const Text('12:00'),
        ),
      ],
    );
  }
}

class _PalettePage extends StatelessWidget {
  const _PalettePage();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Win98GroupBox(
            label: 'Mode',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Win98Radio<int>(value: 1, groupValue: 1, label: 'Automatic', onChanged: (_) {}),
                Win98Radio<int>(value: 2, groupValue: 1, label: 'Preset', onChanged: (_) {}),
                Win98Checkbox(value: true, label: 'Keep black', onChanged: (_) {}),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Colors'),
              Win98Slider(value: 0.4, divisions: 8, onChanged: (_) {}),
              Win98Dropdown<int>(
                value: 1,
                items: const [Win98DropdownItem(value: 1, label: 'Floyd-Steinberg')],
                onChanged: (_) {},
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Win98Button(isDefault: true, onPressed: () {}, child: const Text('Apply')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExplorerScene extends StatelessWidget {
  const _ExplorerScene();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Win98Window(
        title: 'Exploring - (C:)',
        expand: true,
        onClose: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Win98TreeView<String>(
                height: null,
                roots: const [
                  Win98TreeNode(
                    value: 'c',
                    label: '(C:)',
                    children: [
                      Win98TreeNode(
                        value: 'win',
                        label: 'WINDOWS',
                        children: [
                          Win98TreeNode(value: 'sys', label: 'SYSTEM'),
                          Win98TreeNode(value: 'fonts', label: 'Fonts'),
                        ],
                      ),
                      Win98TreeNode(
                        value: 'docs',
                        label: 'My Documents',
                        children: [Win98TreeNode(value: 'pics', label: 'Pictures')],
                      ),
                      Win98TreeNode(value: 'prog', label: 'Program Files'),
                    ],
                  ),
                  Win98TreeNode(value: 'd', label: '(D:)'),
                ],
                expanded: const {'c', 'win'},
                onExpansionChanged: (_, _) {},
                selected: 'win',
                onSelected: (_) {},
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: Win98ListView<String>(
                height: null,
                columns: const [
                  Win98ListColumn(label: 'Name', flex: 3),
                  Win98ListColumn(label: 'Type', flex: 2),
                  Win98ListColumn(label: 'Size', width: 64, numeric: true),
                ],
                rows: const [
                  Win98ListRow(value: 'a', cells: ['AUTOEXEC.BAT', 'Batch file', '1 KB']),
                  Win98ListRow(value: 'b', cells: ['COMMAND.COM', 'Application', '93 KB']),
                  Win98ListRow(value: 'c', cells: ['CONFIG.SYS', 'System file', '1 KB']),
                  Win98ListRow(value: 'd', cells: ['SETUP.LOG', 'Text file', '12 KB']),
                ],
                selected: 'b',
                onSelected: (_) {},
                sortColumn: 0,
                onSort: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemedWindow extends StatelessWidget {
  const _ThemedWindow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Win98Window(
        title: 'A custom Win98ThemeData',
        onClose: () {},
        bodyPadding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Win98ListBox<int>(
                height: 120,
                items: const [
                  Win98ListItem(value: 1, label: 'Brick'),
                  Win98ListItem(value: 2, label: 'Desert'),
                  Win98ListItem(value: 3, label: 'Rainy Day'),
                ],
                selected: 1,
                onSelected: (_) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Win98Checkbox(value: true, label: 'Copy with copyWith', onChanged: (_) {}),
                  const SizedBox(height: 8),
                  const Win98ProgressBar(value: 0.7),
                  const SizedBox(height: 8),
                  Win98Button(isDefault: true, onPressed: () {}, child: const Text('OK')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
