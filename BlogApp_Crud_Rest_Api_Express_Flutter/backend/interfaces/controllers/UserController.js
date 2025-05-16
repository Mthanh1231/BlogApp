// backend\interfaces\controllers\UserController.js

class UserController {
    constructor(userUseCases) {
      this.userUseCases = userUseCases;
    }
  
    async register(req, res) {
      try {
        const newUser = await this.userUseCases.registerUser(req.body);
        res.status(201).json({ success: true, user: newUser });
      } catch (error) {
        res.status(400).json({ success: false, message: error.message });
      }
    }
  
    async authenticate(req, res) {
      try {
        const token = await this.userUseCases.authenticateUser(req.body);
        res.status(200).json({ success: true, token });
      } catch (error) {
        res.status(403).json({ success: false, message: error.message });
      }
    }

    async updateUser(req, res) {
      try {
        // Lấy userId từ req.user do Passport JWT đã gắn trước đó
        const userId = req.user._id;
        const updated = await this.userUseCases.updateUser(userId, req.body);
        // Ẩn mật khẩu khi trả về
        const { password, ...safeUser } = updated.toObject();
        res.status(200).json({ success: true, user: safeUser });
      } catch (error) {
        res.status(400).json({ success: false, message: error.message });
      }
    }
    // GET /users
  async listUsers(req, res) {
    try {
      const users = await this.userUseCases.listUsers();
      res.status(200).json({ success: true, users });
    } catch (err) {
      res.status(400).json({ success: false, message: err.message });
    }
  }

  // GET /users/:id
  async getUserProfile(req, res) {
    try {
      const { user, postCount } = await this.userUseCases.getUserProfile(req.params.id);
      res.status(200).json({ success: true, user, postCount });
    } catch (err) {
      res.status(404).json({ success: false, message: err.message });
    }
  }

  // DELETE /users/:id
  async deleteUser(req, res) {
    try {
      await this.userUseCases.deleteUser(req.params.id);
      res.status(200).json({ success: true, message: "User deleted" });
    } catch (err) {
      res.status(400).json({ success: false, message: err.message });
    }
  }
  // GET /users/me
  async getCurrentUserProfile(req, res) {
    try {
      console.log('DEBUG /users/me req.user:', req.user);
      // Get current user ID from the authenticated request
      const userId = req.user._id;
      console.log('DEBUG /users/me userId:', userId);
      const { user, postCount } = await this.userUseCases.getUserProfile(userId);
      res.status(200).json({ success: true, user, postCount });
    } catch (err) {
      console.error('ERROR /users/me:', err);
      res.status(404).json({ success: false, message: err.message });
    }
  }
}
  
  module.exports = UserController;
  