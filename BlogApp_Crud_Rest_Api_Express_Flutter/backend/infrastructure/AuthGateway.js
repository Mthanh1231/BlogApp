// infracture\AuthGateway.js

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

class AuthGateway {
  constructor(secret) {
    this.secret = secret;
  }

  async hashPassword(password) {
    const saltRounds = 10;
    return await bcrypt.hash(password, saltRounds);
  }

  async comparePassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }

  generateToken(user) {
    // Loại bỏ các thông tin nhạy cảm trước khi tạo payload
    const payload = {
      id: user._id,
      name: user.name,
    };
    return jwt.sign(payload, this.secret, { expiresIn: '1h' });
  }
}

module.exports = AuthGateway;
