// domain/entities/User.js
class User {
  constructor({ id, name, birthYear, email, phone, gender, nickname, password, createdAt, updatedAt }) {
    this.id          = id;
    this.name        = name;        // Tên thật
    this.birthYear   = birthYear;   // Năm sinh
    this.email       = email;       // Email
    this.phone       = phone;       // Số điện thoại
    this.gender      = gender;      // Giới tính
    this.nickname    = nickname;    // Username hiển thị
    this.password    = password;    // Mật khẩu (đã băm)
    this.createdAt   = createdAt;
    this.updatedAt   = updatedAt;
  }
}

module.exports = User;
