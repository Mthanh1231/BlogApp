// File: lib/utils/validators.dart
class Validators {
  static String? validateEmail(String? v) {
    return (v==null||!v.contains('@')) ? 'Nhập email hợp lệ' : null;
  }
  static String? validatePassword(String? v) {
    return (v==null||v.length<6) ? 'Tối thiểu 6 ký tự' : null;
  }
}