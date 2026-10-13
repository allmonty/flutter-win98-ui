import 'package:flutter/widgets.dart';
import 'package:win98_ui/win98_ui.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'win98_ui gallery',
      color: const Color(0xFF008080),
      debugShowCheckedModeBanner: false,
      builder: (context, navigator) => Win98Theme(child: navigator!),
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          PageRouteBuilder<T>(settings: settings, pageBuilder: (c, _, _) => builder(c)),
      home: const Gallery(),
    );
  }
}

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  bool _checked = true;
  String _radio = 'average';
  double _slider = 0.5;
  String _dropdown = 'floyd_steinberg';
  String? _listSelection = 'Gameboy';
  String? _file = 'win';
  int _copies = 1;
  String? _icon;
  Set<String> _expanded = {'c'};
  String? _node = 'win';
  int _sortColumn = 0;
  bool _sortAscending = true;
  bool _bold = false;
  bool _italic = false;
  Color _color = const Color(0xFF008080);
  final _text = TextEditingController(text: 'Hello, 1998');
  final _password = TextEditingController(text: 'hunter2');
  final _notes = TextEditingController(
    text:
        'A multi-line field.\nIt scrolls with a Win98 scrollbar\nonce the text\nis longer\nthan its\nmaxLines.',
  );

  @override
  void dispose() {
    _text.dispose();
    _password.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _about() =>
      showWin98MessageBox(context: context, title: 'About', message: 'win98_ui gallery');

  @override
  Widget build(BuildContext context) {
    return Win98Desktop(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Win98Window(
                  title: 'win98_ui gallery',
                  expand: true,
                  onClose: _about,
                  menuBar: Win98MenuBar(
                    menus: [
                      Win98Menu(
                        label: 'File',
                        items: [
                          Win98MenuItem(label: 'About...', onSelected: _about, shortcut: 'F1'),
                          Win98MenuItem(
                            label: 'Recent',
                            children: [
                              Win98MenuItem(label: 'photo.png', onSelected: _about),
                              Win98MenuItem(label: 'sprite.bmp', onSelected: _about),
                            ],
                          ),
                          const Win98MenuDivider(),
                          const Win98MenuItem(label: 'Exit'),
                        ],
                      ),
                      Win98Menu(
                        label: 'View',
                        items: [
                          Win98MenuItem(
                            label: 'Bold',
                            checked: _bold,
                            onSelected: () => setState(() => _bold = !_bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  toolbar: Win98Toolbar(
                    children: [
                      Win98ToolButton(
                        tooltip: 'Bold',
                        selected: _bold,
                        onPressed: () => setState(() => _bold = !_bold),
                        child: const Text('B', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Win98ToolButton(
                        tooltip: 'Italic',
                        selected: _italic,
                        onPressed: () => setState(() => _italic = !_italic),
                        child: const Text('I', style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                      const Win98ToolbarDivider(),
                      Win98ToolButton(tooltip: 'About', onPressed: _about, child: const Text('?')),
                      const Win98ToolButton(tooltip: 'Disabled', onPressed: null, child: Text('X')),
                    ],
                  ),
                  statusBar: Win98StatusBar(
                    panes: [
                      const Win98StatusPane(Text('Ready'), flex: 2),
                      Win98StatusPane(Text('${(_slider * 100).round()}%')),
                    ],
                  ),
                  child: Win98TabView(
                    tabs: [
                      Win98Tab(label: 'Controls', builder: (_) => _controls()),
                      Win98Tab(label: 'Lists', builder: (_) => _lists()),
                      Win98Tab(label: 'Explorer', builder: (_) => _explorer()),
                      Win98Tab(label: 'Dialogs', builder: (_) => _dialogs()),
                      Win98Tab(label: 'Desktop', builder: (_) => _desktop()),
                    ],
                  ),
                ),
              ),
            ),
            Win98Taskbar(
              startMenu: [
                Win98MenuItem(
                  label: 'Programs',
                  children: [Win98MenuItem(label: 'Gallery', onSelected: _about)],
                ),
                const Win98MenuDivider(),
                Win98MenuItem(label: 'Shut Down...', onSelected: _about),
              ],
              tasks: [Win98Task(label: 'win98_ui gallery', active: true, onPressed: () {})],
              tray: const Text('12:00'),
            ),
          ],
        ),
      ),
    );
  }

  static const _files = [
    ('win', 'WINDOWS', 'Folder', 0),
    ('cmd', 'COMMAND.COM', 'Application', 93),
    ('cfg', 'CONFIG.SYS', 'System file', 1),
    ('bat', 'AUTOEXEC.BAT', 'Batch file', 1),
  ];

  Widget _explorer() {
    final files = [..._files]
      ..sort((a, b) {
        final c = switch (_sortColumn) {
          0 => a.$2.compareTo(b.$2),
          1 => a.$3.compareTo(b.$3),
          _ => a.$4.compareTo(b.$4),
        };
        return _sortAscending ? c : -c;
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Win98TreeView<String>(
          height: 150,
          roots: const [
            Win98TreeNode(
              value: 'c',
              label: '(C:)',
              children: [
                Win98TreeNode(
                  value: 'win',
                  label: 'WINDOWS',
                  children: [Win98TreeNode(value: 'sys', label: 'SYSTEM')],
                ),
                Win98TreeNode(value: 'docs', label: 'My Documents'),
              ],
            ),
            Win98TreeNode(value: 'd', label: '(D:)'),
          ],
          expanded: _expanded,
          onExpansionChanged: (v, open) =>
              setState(() => _expanded = open ? {..._expanded, v} : ({..._expanded}..remove(v))),
          selected: _node,
          onSelected: (v) => setState(() => _node = v),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Win98ListView<String>(
            height: null,
            columns: const [
              Win98ListColumn(label: 'Name', flex: 3),
              Win98ListColumn(label: 'Type', flex: 2),
              Win98ListColumn(label: 'Size', width: 70, numeric: true),
            ],
            rows: [
              for (final f in files)
                Win98ListRow(
                  value: f.$1,
                  cells: [f.$2, f.$3, f.$3 == 'Folder' ? '' : '${f.$4} KB'],
                ),
            ],
            selected: _file,
            onSelected: (v) => setState(() => _file = v),
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
            onSort: (i) => setState(() {
              _sortAscending = i == _sortColumn ? !_sortAscending : true;
              _sortColumn = i;
            }),
          ),
        ),
      ],
    );
  }

  Widget _controls() => Win98ScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Win98GroupBox(
          label: 'Toggles',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Win98Checkbox(
                value: _checked,
                label: 'Checkbox',
                onChanged: (v) => setState(() => _checked = v),
              ),
              for (final v in ['average', 'nearest'])
                Win98Radio<String>(
                  value: v,
                  groupValue: _radio,
                  label: v,
                  onChanged: (x) => setState(() => _radio = x),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Win98Slider(value: _slider, divisions: 10, onChanged: (v) => setState(() => _slider = v)),
        Row(
          children: [
            const Text('Copies: '),
            SizedBox(
              width: 100,
              child: Win98SpinBox(
                value: _copies,
                min: 1,
                max: 99,
                onChanged: (v) => setState(() => _copies = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: Win98ScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < 16; i++)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Win98Button(onPressed: () {}, child: Text('Item $i')),
                  ),
              ],
            ),
          ),
        ),
        Win98ProgressBar(value: _slider),
        const SizedBox(height: 8),
        Win98Dropdown<String>(
          value: _dropdown,
          items: const [
            Win98DropdownItem(value: 'none', label: 'None'),
            Win98DropdownItem(value: 'floyd_steinberg', label: 'Floyd-Steinberg'),
            Win98DropdownItem(value: 'atkinson', label: 'Atkinson'),
          ],
          onChanged: (v) => setState(() => _dropdown = v),
        ),
        const SizedBox(height: 8),
        Win98TextField(controller: _text),
        const SizedBox(height: 8),
        Win98TextField(controller: _password, obscureText: true),
        const SizedBox(height: 8),
        Win98TextField(controller: _notes, maxLines: 4),
        const SizedBox(height: 8),
        Row(
          children: [
            Win98Button(isDefault: true, onPressed: () {}, child: const Text('OK')),
            const SizedBox(width: 6),
            const Win98Button(onPressed: null, child: Text('Disabled')),
          ],
        ),
      ],
    ),
  );

  // Right-click (or long-press) the list for a context menu.
  Widget _lists() => Win98ContextMenu(
    items: [
      Win98MenuItem(
        label: 'Select Gameboy',
        onSelected: () => setState(() => _listSelection = 'Gameboy'),
      ),
      const Win98MenuDivider(),
      Win98MenuItem(
        label: 'Clear selection',
        onSelected: () => setState(() => _listSelection = null),
      ),
    ],
    child: Win98ListBox<String>(
      height: 220,
      items: [
        for (final name in ['Gameboy', 'CGA', 'EGA', 'C64', 'NES', 'PICO-8', 'Teletext', 'Sepia'])
          Win98ListItem(value: name, label: name),
      ],
      selected: _listSelection,
      onSelected: (v) => setState(() => _listSelection = v),
    ),
  );

  // Desktop icons and windows that drag by their title bars.
  Widget _desktop() => Win98Desktop(
    child: Stack(
      children: [
        Win98WindowStack(
          windows: [
            Win98StackWindow(
              id: 'notepad',
              position: const Offset(90, 10),
              size: const Size(220, 140),
              child: Win98Window(
                title: 'Notepad',
                expand: true,
                child: const Text('Drag me by the title bar.'),
              ),
            ),
            Win98StackWindow(
              id: 'paint',
              position: const Offset(140, 70),
              size: const Size(220, 140),
              child: Win98Window(
                title: 'Paint',
                expand: true,
                child: const Text('Tap a window to bring it to the front.'),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Wrap(
            direction: Axis.vertical,
            children: [
              for (final name in ['My Computer', 'Recycle Bin'])
                Win98DesktopIcon(
                  icon: const _PixelFolder(),
                  label: name,
                  selected: _icon == name,
                  onSelected: () => setState(() => _icon = name),
                  onActivated: _about,
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _dialogs() => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final icon in Win98MessageIconType.values)
        Win98Button(
          onPressed: () => showWin98MessageBox(
            context: context,
            title: icon.name,
            message: 'A ${icon.name} message.',
            icon: icon,
            buttons: const ['OK', 'Cancel'],
          ),
          child: Text(icon.name),
        ),
      Win98Button(
        onPressed: () async {
          final c = await showWin98ColorDialog(context: context, initial: _color);
          if (c != null) setState(() => _color = c);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 14, height: 14, child: ColoredBox(color: _color)),
            const SizedBox(width: 6),
            const Text('Color...'),
          ],
        ),
      ),
    ],
  );
}

/// A 16×16 yellow folder drawn with PixelGlyph, shown at 2x.
class _PixelFolder extends StatelessWidget {
  const _PixelFolder();

  @override
  Widget build(BuildContext context) => const PixelGlyph([
    '................',
    '..#####.........',
    '.#.....#........',
    '#.......#######.',
    '#..............#',
    '#..............#',
    '#..............#',
    '#..............#',
    '#..............#',
    '#..............#',
    '#..............#',
    '.##############.',
  ], color: Color(0xFFE8C840));
}
