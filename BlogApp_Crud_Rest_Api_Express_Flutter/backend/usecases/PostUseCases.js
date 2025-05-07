// usecases/PostUseCases.js
class PostUseCases {
  constructor(postRepository) {
    this.postRepository = postRepository;
  }

  // Tạo post (data đã kèm authorId/author)
  async createPost(data) {
    return await this.postRepository.createPost(data);
  }

  // Lấy tất cả post của userId truyền vào
  async getAllPosts(userId) {
    if (!userId) throw new Error('Missing userId');
    return await this.postRepository.getAllPosts(userId);
  }

  // Lấy chi tiết 1 post
  async getPostById(id) {
    const post = await this.postRepository.getPostById(id);
    if (!post) throw new Error('Post not found');
    return post;
  }

  // Cập nhật post
  async updatePost(id, data) {
    const updated = await this.postRepository.updatePost(id, data);
    if (!updated) throw new Error('Failed to update post');
    return updated;
  }

  // Xoá post
  async deletePost(id) {
    const deleted = await this.postRepository.deletePost(id);
    if (!deleted) throw new Error('Failed to delete post');
    return deleted;
  }
}

module.exports = PostUseCases;
