import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_scrollbar_modified/flutter_scrollbar_modified.dart';

void main() {
  const viewSize = Size(400.0, 800.0);
  const holdDuration = Duration(milliseconds: 80);
  const afterHold = Duration(milliseconds: 150);
  const onTrack = Offset(396.0, 400.0);
  const besideTrack = Offset(375.0, 400.0);

  Future<ScrollController> pumpList(WidgetTester tester, ScrollbarTrackMode trackMode) async {
    tester.view.physicalSize = viewSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CupertinoScrollbar(
          controller: controller,
          thumbVisibility: true,
          pressDuration: holdDuration,
          trackMode: () => trackMode,
          child: ListView.builder(
            controller: controller,
            itemExtent: 50.0,
            itemCount: 200,
            itemBuilder: (context, index) => Text('$index'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  Future<void> holdThenDrag(WidgetTester tester, Offset start) async {
    final gesture = await tester.createGesture();
    await gesture.down(start);
    await tester.pump(afterHold);
    await gesture.moveBy(const Offset(0.0, 20.0), timeStamp: afterHold);
    await tester.pump();
    await gesture.up(timeStamp: afterHold);
    await tester.pumpAndSettle();
  }

  testWidgets('jump to touch: a held drag on the track jumps the thumb under the finger', (tester) async {
    final controller = await pumpList(tester, ScrollbarTrackMode.jumpToTouch);
    await holdThenDrag(tester, onTrack);
    expect(controller.offset, inInclusiveRange(4400.0, 5200.0));
  });

  testWidgets('jump to touch: drags start beside the narrow track too', (tester) async {
    final controller = await pumpList(tester, ScrollbarTrackMode.jumpToTouch);
    await holdThenDrag(tester, besideTrack);
    expect(controller.offset, inInclusiveRange(4400.0, 5200.0));
  });

  testWidgets('jump to touch: a tap centers the thumb under it', (tester) async {
    final controller = await pumpList(tester, ScrollbarTrackMode.jumpToTouch);
    await tester.tapAt(const Offset(396.0, 600.0));
    await tester.pumpAndSettle();
    expect(controller.offset, inInclusiveRange(6800.0, 7400.0));
  });

  testWidgets('drag anywhere: a held drag on the track moves from where the thumb is', (tester) async {
    final controller = await pumpList(tester, ScrollbarTrackMode.dragAnywhere);
    await holdThenDrag(tester, onTrack);
    expect(controller.offset, inInclusiveRange(1.0, 600.0));
  });

  testWidgets('drag anywhere: beside the narrow track it still moves from where the thumb is', (tester) async {
    final controller = await pumpList(tester, ScrollbarTrackMode.dragAnywhere);
    await holdThenDrag(tester, besideTrack);
    expect(controller.offset, inInclusiveRange(1.0, 600.0));
  });

  testWidgets('drag anywhere: taps stay with the list', (tester) async {
    final controller = await pumpList(tester, ScrollbarTrackMode.dragAnywhere);
    await tester.tapAt(const Offset(396.0, 600.0));
    await tester.pumpAndSettle();
    expect(controller.offset, 0.0);
  });

  testWidgets('thumb only: the track does nothing', (tester) async {
    final controller = await pumpList(tester, ScrollbarTrackMode.thumbOnly);
    await holdThenDrag(tester, onTrack);
    expect(controller.offset, 0.0);
  });
}
