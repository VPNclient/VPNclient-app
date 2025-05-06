// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:provider/provider.dart';

// import 'package:vpn_client/main.dart';
// import 'package:vpn_client/theme_provider.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       MultiProvider(
//         providers: [
//           ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
//         ],
//         child: const MaterialApp(home: App()),
//       ),
//     );
//                                             <-- This test is designed for Flutter's default counter app, which are not using. So ours app doesn’t show '0' or '1', which leads to: error test

//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vpn_client/main.dart';
import 'package:vpn_client/theme_provider.dart';

void main() {
  testWidgets('App shows VPN status on launch', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: App()),
      ),
    );

    // Check that 'CONNECTED' or 'DISCONNECTED' appears on screen
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data == 'CONNECTED' || widget.data == 'DISCONNECTED'),
      ),
      findsOneWidget,
    );
  });
}
