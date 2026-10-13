import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win98_ui_example/main.dart';

void main() {
  // A phone and a desktop window: every page must lay out without overflow.
  for (final size in [const Size(390, 844), const Size(1024, 768)]) {
    testWidgets('every gallery page builds at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const GalleryApp());
      for (final tab in ['Lists', 'Explorer', 'Dialogs', 'Desktop', 'Controls']) {
        await tester.tap(find.text(tab));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$tab page');
      }

      // Menus: File > Recent opens on hover, like Win98.
      await tester.tap(find.text('File'));
      await tester.pump();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Recent')));
      await tester.pump();
      expect(find.text('photo.png'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      // The Start menu and its Programs submenu.
      await tester.tapAt(Offset.zero);
      await tester.pump();
      await tester.tap(find.text('Start'));
      await tester.pump();
      await tester.tap(find.text('Programs'));
      await tester.pump();
      expect(find.text('Gallery'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
