// infrastructure/MongoPostRepository.js
const PostRepository = require('../interfaces/repositories/PostRepository');
const PostModel      = require('../models/PostModel');

class MongoPostRepository extends PostRepository {
  // Tạo post (data đã bao gồm authorId/author)
  async createPost(data) {
    return await new PostModel(data).save();
  }

  /**
   * Lấy danh sách post của 1 author cụ thể
   * @param {String} authorId
   */
  async getAllPosts(authorId) {
    // Chỉ tìm những post có authorId bằng ID truyền vào
    return await PostModel.find({ authorId });
  }

  // Lấy chi tiết 1 post theo _id
  async getPostById(id) {
    return await PostModel.findById(id);
  }

  // Cập nhật post (giữ lịch sử sửa đổi)
  async updatePost(id, data) {
    const original = await PostModel.findById(id);
    if (!original) throw new Error('Post not found');

    const diff = {};
    ['image','text','address'].forEach(field => {
      if (data[field] != null && data[field] !== original[field]) {
        diff[field] = { from: original[field], to: data[field] };
      }
    });

    data.$inc  = { editCount: 1 };
    data.$push = { editHistory: { diff, editedAt: new Date() } };

    return await PostModel.findByIdAndUpdate(id, data, { new: true });
  }

  // Xoá post
  async deletePost(id) {
    return await PostModel.findByIdAndDelete(id);
  }

  // Đếm số post của author
  async countPostsByAuthorId(aid) {
    return await PostModel.countDocuments({ authorId: aid });
  }
}

module.exports = MongoPostRepository;
