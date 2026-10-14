
import 'package:flutter_test/flutter_test.dart';
import 'package:neon_web/main.dart';

void main() {
  testWidgets('La página principal se muestra correctamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TechWeekApp());

    expect(find.text('TANDIL TECH WEEK'), findsWidgets);
    expect(find.text('La agenda'), findsOneWidget);
    expect(find.text('Sponsors'), findsOneWidget);
  });
}
