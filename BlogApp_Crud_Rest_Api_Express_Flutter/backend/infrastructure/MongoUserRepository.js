// backend\infrastructure\MongoUserRepository.js

const UserRepository = require('../interfaces/repositories/UserRepository');
const UserModel      = require('../models/UserModel');
const mongoose = require('mongoose');
const ObjectId = mongoose.Types.ObjectId;

class MongoUserRepository extends UserRepository {
  async createUser(userData) {
    const user = new UserModel(userData);
    return await user.save();
  }

  async findByName(name) {
    return await UserModel.findOne({ name });
  }

  async findById(id) {
    // Convert id sang ObjectId nếu là string 24 ký tự
    if (typeof id === 'string' && id.length === 24) {
      try {
        id = new ObjectId(id);
      } catch (e) {
        // Nếu không convert được thì thôi, dùng string
      }
    }
    return await UserModel.findById(id);
  }

  async findByGoogleId(googleId) {
    return await UserModel.findOne({ googleId });
  }

  // Triển khai cập nhật user
  async updateUser(id, updateData) {
    return await UserModel.findByIdAndUpdate(id, updateData, { new: true });
  }
  async getAllUsers() {
    return await UserModel.find().select('-password');  // ẩn password
  }

  async deleteUser(id) {
    return await UserModel.findByIdAndDelete(id);
  }
}

module.exports = MongoUserRepository;
