// backend/interfaces/repositories/UserRepository.js

class UserRepository {
  async createUser(userData) { throw new Error("Not implemented"); }
  async findByName(name)    { throw new Error("Not implemented"); }
  async findById(id)        { throw new Error("Not implemented"); }
  async findByGoogleId(googleId) { throw new Error("Not implemented"); }

    // Phương thức cập nhật user
    async updateUser(id, updateData) { 
      throw new Error("Not implemented"); 
    }
    async getAllUsers() {
      throw new Error("Not implemented");
    }
    async deleteUser(id) {
      throw new Error("Not implemented");
    }
  
}

module.exports = UserRepository;
  