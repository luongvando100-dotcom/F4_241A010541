# Lab F4 – Điều hướng đa màn hình trong Flutter

Project độc lập `f4_danhba`, thực hành Navigator và luồng danh bạ mini.

## Chạy ứng dụng

```sh
flutter pub get
flutter run
```

## Kiểm tra

```sh
flutter analyze
flutter test
```

## Chức năng

- Danh sách liên hệ, xem chi tiết, thêm, sửa, xóa.
- Truyền liên hệ bằng constructor; nhận kết quả với `await Navigator.push`
  và trả dữ liệu qua `Navigator.pop`.
- Bỏ qua kết quả `null` khi quay lại và kiểm tra `mounted` sau `await`.
- Named route `/about` và `PopScope` xác nhận khi rời biểu mẫu có thay đổi.
- Nâng cao NC1: tìm kiếm liên hệ và trả liên hệ đã chọn về danh sách.
- Nâng cao NC2: hiệu ứng `Hero` cho avatar giữa danh sách và chi tiết.

Báo cáo kiểm thử và đối chiếu Android nằm tại [docs/bao_cao.md](docs/bao_cao.md).
