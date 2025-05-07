// interfaces/repositories/PostRepository.js
class PostRepository {
  async createPost(data)           { throw new Error('Not implemented'); }
  async getAllPosts()              { throw new Error('Not implemented'); }
  async getPostById(id)            { throw new Error('Not implemented'); }
  async updatePost(id, data)       { throw new Error('Not implemented'); }
  async deletePost(id)             { throw new Error('Not implemented'); }
  async countPostsByAuthorId(aid)  { throw new Error('Not implemented'); }
}
module.exports = PostRepository;
