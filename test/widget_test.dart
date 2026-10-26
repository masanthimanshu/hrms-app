import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hrms/models/attendance_model.dart";
import "package:hrms/models/store_model.dart";
import "package:hrms/models/user_model.dart";
import "package:hrms/utils/formatters.dart";
import "package:hrms/widgets/monochrome_button.dart";
import "package:hrms/widgets/monochrome_card.dart";
import "package:hrms/widgets/stat_card.dart";
import "package:hrms/widgets/status_pill.dart";

void main() {
  testWidgets("Monochrome design components render correctly", (
    WidgetTester tester,
  ) async {
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
              const MonochromeCard(child: Text("Card Content")),
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

  test("AppFormatters formats coordinates and strings properly", () {
    expect(
      AppFormatters.formatCoordinates(
        "28.513591395116627",
        "77.37388950784926",
      ),
      "28.5136, 77.3739",
    );
    expect(AppFormatters.formatCoordinates(null, null), "Unavailable");
    expect(AppFormatters.getInitials("Himanshu Masant"), "HM");
    expect(
      AppFormatters.maskToken("671d1234567890abcdef", prefix: 4, suffix: 4),
      "671d...cdef",
    );
  });

  test("Real API data models parse properly without static dummy data", () {
    // 1. User model test
    final userJson = {
      "_id": "6adf241b05b5a590aabe065f",
      "storeId": "6adf238105b5a590aabe065e",
      "email": "himanshu.masant@scoobies.ai",
      "isValid": true,
      "name": "Himanshu Masant",
    };
    final user = UserModel.fromJson(userJson);
    expect(user.id, "6adf241b05b5a590aabe065f");
    expect(user.name, "Himanshu Masant");
    expect(user.email, "himanshu.masant@scoobies.ai");
    expect(user.storeId, "6adf238105b5a590aabe065e");
    expect(user.isValid, isTrue);

    // 2. Store model test
    final storeJson = {
      "_id": "6adf238105b5a590aabe065e",
      "name": "DLF Mall of India",
      "latitude": "28.51346641762474",
      "longitude": "77.37375200456508",
      "address": "Sector-18 Noida",
    };
    final store = StoreModel.fromJson(storeJson);
    expect(store.id, "6adf238105b5a590aabe065e");
    expect(store.name, "DLF Mall of India");
    expect(store.address, "Sector-18 Noida");

    // 3. Attendance model test with real API payload
    final attendanceJson = {
      "_id": "6adf39bf8596ffd227a5fe23",
      "userId": "6adf241b05b5a590aabe065f",
      "latitude": "28.513339",
      "longitude": "77.373073",
      "distance": "68",
      "imageUrl": "images/e9edbffa-ad3c-4900-95df-602c24f4433b.webp",
      "createdAt": "2026-10-26T11:30:07.411Z",
    };
    final attendance = AttendanceModel.fromJson(attendanceJson);
    expect(attendance.id, "6adf39bf8596ffd227a5fe23");
    expect(attendance.userId, "6adf241b05b5a590aabe065f");
    expect(attendance.distance, "68");
    expect(attendance.isVerified, isTrue); // 68m <= 1000m geofence
    expect(
      attendance.imageUrl,
      "images/e9edbffa-ad3c-4900-95df-602c24f4433b.webp",
    );
  });
}
