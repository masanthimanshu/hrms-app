import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hrms/widgets/monochrome_button.dart";
import "package:hrms/widgets/monochrome_card.dart";
import "package:hrms/widgets/stat_card.dart";
import "package:hrms/widgets/status_pill.dart";

void main() {
  testWidgets("Monochrome design components render correctly", (WidgetTester tester) async {
    bool buttonTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              MonochromeButton(
                text: "Test Button",
                onPressed: () => buttonTapped = true,
              ),
              const StatusPill(
                label: "Live Active",
                type: StatusPillType.active,
              ),
              const MonochromeCard(
                child: Text("Card Content"),
              ),
              const StatCard(
                title: "Branches",
                value: "12",
                icon: Icons.storefront,
              ),
            ],
          ),
        ),
      ),
    );

    // Verify all components rendered with correct text
    expect(find.text("Test Button"), findsOneWidget);
    expect(find.text("Live Active"), findsOneWidget);
    expect(find.text("Card Content"), findsOneWidget);
    expect(find.text("BRANCHES"), findsOneWidget);
    expect(find.text("12"), findsOneWidget);

    // Verify button interaction
    await tester.tap(find.text("Test Button"));
    expect(buttonTapped, isTrue);
  });
}
