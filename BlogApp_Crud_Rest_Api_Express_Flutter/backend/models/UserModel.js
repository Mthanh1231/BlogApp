// backend/models/UserModel.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name:      { type: String, required: true },    // Tên thật
  birthYear: { type: Number },                    // Năm sinh
  email:     { type: String, unique: true, sparse: true },
  phone:     { type: String, unique: true, sparse: true },
  gender:    { type: String, enum: ['male','female','other'] },
  nickname:  { type: String, unique: true },      // Username hiển thị
  password:  { type: String },                    // Có thể null khi đăng nhập Google
  googleId:  { type: String, unique: true, sparse: true },
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
