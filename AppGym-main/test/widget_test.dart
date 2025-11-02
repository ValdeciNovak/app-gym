import 'package:flutter_test/flutter_test.dart';
import 'package:app_gym/main.dart';

void main() {
  testWidgets('MyApp inicializa sem erros', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}