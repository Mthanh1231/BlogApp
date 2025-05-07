// backend/usecases/UserUseCases.js

class UserUseCases {
    constructor(userRepository, authGateway, postRepository) {
      this.userRepository = userRepository;
      this.authGateway = authGateway;
      this.postRepository = postRepository; 
    }
  
    async registerUser(userData) {
      // Validate input
      if (!userData.name || !userData.password) {
        throw new Error("Name and password are required");
      }
      const existingUser = await this.userRepository.findByName(userData.name);
      if (existingUser) {
        throw new Error("Username already exists");
      }
      // Hash password
      userData.password = await this.authGateway.hashPassword(userData.password);
      return await this.userRepository.createUser(userData);
    }
  
    async authenticateUser({ name, password }) {
      const user = await this.userRepository.findByName(name);
      if (!user) {
        throw new Error("User not found");
      }
      const valid = await this.authGateway.comparePassword(password, user.password);
      if (!valid) {
        throw new Error("Invalid credentials");
      }
      return this.authGateway.generateToken(user);
    }
     // Thêm hàm cập nhật user
  async updateUser(id, updateData) {
    // Nếu có mật khẩu mới, cần băm lại
    if (updateData.password) {
      updateData.password = await this.authGateway.hashPassword(updateData.password);
    }
    // Các trường khác có thể trực tiếp update, bạn có thể thêm validate nếu cần.
    const updatedUser = await this.userRepository.updateUser(id, updateData);
    if (!updatedUser) {
      throw new Error("Failed to update user");
    }
    return updatedUser;
  }
  async listUsers() {
    return await this.userRepository.getAllUsers();
  }

  // 2. Xem user theo ID kèm tổng số post
  async getUserProfile(id) {
    const user = await this.userRepository.findById(id);
    if (!user) throw new Error("User not found");
    const postCount = await this.postRepository.countPostsByAuthorId(id);
    // Ẩn mật khẩu
    const { password, ...safeUser } = user.toObject();
    return { user: safeUser, postCount };
  }

  // 3. Xóa user
  async deleteUser(id) {
    const deleted = await this.userRepository.deleteUser(id);
    if (!deleted) throw new Error("Failed to delete user");
    return deleted;
  }
  async execute(userId) {
    return await this.postRepository.getPostsByAuthorId(userId);
  }
}
  module.exports = UserUseCases;
  