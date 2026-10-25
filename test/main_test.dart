import 'package:f4_danhba/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the selected contact detail and returns null on back', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Nguyễn Văn A'));
    await tester.pumpAndSettle();

    expect(find.text('a@vhu.edu.vn'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Danh bạ mini'), findsOneWidget);
    expect(find.text('Đã cập nhật'), findsNothing);
  });

  testWidgets('editing a contact returns the change to the list', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Nguyễn Văn A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sửa liên hệ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Nguyễn Văn Mới');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Nguyễn Văn Mới'), findsOneWidget);
    expect(find.text('Đã cập nhật'), findsOneWidget);
  });

  testWidgets('deleting a contact removes it from the list', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Nguyễn Văn A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa liên hệ'));
    await tester.pumpAndSettle();

    expect(find.text('Nguyễn Văn A'), findsNothing);
    expect(find.text('Đã xóa liên hệ'), findsOneWidget);
  });

  testWidgets('empty required fields show validation errors', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Thêm liên hệ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);
    expect(
      find.text('Số điện thoại phải có từ 9 đến 11 chữ số'),
      findsOneWidget,
    );
  });

  testWidgets('dirty edit asks before leaving and can be discarded', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Thêm liên hệ'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Liên hệ mới');
    await tester.pump();
    expect(
      tester.widget<PopScope<Contact>>(find.byType(PopScope<Contact>)).canPop,
      isFalse,
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Bỏ thay đổi?'), findsOneWidget);
    await tester.tap(find.text('Thoát'));
    await tester.pumpAndSettle();
    expect(find.text('Danh bạ mini'), findsOneWidget);
  });

  testWidgets('about page is opened with a named route', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Giới thiệu'));
    await tester.pumpAndSettle();

    expect(find.text('Giới thiệu'), findsOneWidget);
    expect(find.textContaining('Lab F4'), findsOneWidget);
  });

  testWidgets('search returns the selected contact and opens its detail', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Tìm kiếm'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Trần Thị B');
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Trần Thị B'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0912345678'), findsOneWidget);
  });
}
