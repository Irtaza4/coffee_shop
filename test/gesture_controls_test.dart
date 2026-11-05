import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_shop/presentation/widgets/controls.dart';
import 'package:coffee_shop/presentation/widgets/floating_tab_bar.dart';

void main() {
  testWidgets(
    'slider ignores taps, resets short and cancelled drags, completes once',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 340,
                child: SlideAction(title: 'Continue', onTap: () => calls++),
              ),
            ),
          ),
        ),
      );
      final handle = find.byKey(const ValueKey('slide-handle-Continue'));
      final origin = tester.getTopLeft(handle);
      await tester.tap(find.text('Continue'));
      await tester.tap(handle);
      expect(calls, 0);
      await tester.drag(handle, const Offset(75, 0));
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(tester.getTopLeft(handle), origin);
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await gesture.moveBy(const Offset(200, 0));
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(tester.getTopLeft(handle), origin);
      await tester.drag(handle, const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(tester.getTopLeft(handle), origin);
    },
  );

  testWidgets('disabled slider does not proceed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: SlideAction(title: 'Disabled', onTap: null),
          ),
        ),
      ),
    );
    final handle = find.byKey(const ValueKey('slide-handle-Disabled'));
    final origin = tester.getTopLeft(handle);
    await tester.drag(handle, const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(handle), origin);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dock keeps fixed slots and moves highlight on tap and drag', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Center(
              child: SizedBox(
                width: 350,
                child: FloatingTabBar(
                  selected: selected,
                  cartCount: 3,
                  onSelected: (value) => setState(() => selected = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final dock = find.byKey(const ValueKey('floating-tab-dock'));
    final left = tester.getTopLeft(dock).dx;
    double slotX(int tab) => left + (tab + .5) * 70;
    void expectFixedSlots() {
      for (var tab = 0; tab < 5; tab++) {
        expect(
          tester.getCenter(find.byKey(ValueKey('tab-position-$tab'))).dx,
          slotX(tab),
        );
      }
    }

    expectFixedSlots();
    for (final tab in [3, 4, 0, 1, 2, 3]) {
      await tester.tap(find.byKey(ValueKey('tab-position-$tab')));
      await tester.pumpAndSettle();
      expect(selected, tab);
      expectFixedSlots();
      expect(
        tester.getCenter(find.byKey(const ValueKey('tab-highlight'))).dx,
        slotX(tab),
      );
      final shape = tester.widget<PhysicalShape>(
        find.byKey(const ValueKey('dock-cutout')),
      );
      final path = shape.clipper.getClip(const Size(350, 72));
      expect(path.contains(Offset((tab + .5) * 70, 25)), isFalse);
      expect(path.contains(Offset((tab + .5) * 70, 70)), isTrue);
    }
    final drag = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('tab-position-3'))),
    );
    await drag.moveBy(const Offset(70, 0));
    await tester.pumpAndSettle();
    expect(selected, 3);
    expectFixedSlots();
    expect(
      tester.getCenter(find.byKey(const ValueKey('tab-highlight'))).dx,
      slotX(4),
    );
    await drag.up();
    await tester.pumpAndSettle();
    expect(selected, 4);
    expectFixedSlots();
    final cancel = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('tab-position-4'))),
    );
    await cancel.moveBy(const Offset(-70, 0));
    await cancel.cancel();
    await tester.pumpAndSettle();
    expect(selected, 4);
    expect(
      tester.getCenter(find.byKey(const ValueKey('tab-highlight'))).dx,
      slotX(4),
    );
    expect(tester.takeException(), isNull);
  });
}
