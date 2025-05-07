// domain/entities/Post.js

class Post {
    constructor({ id, title, body, author, authorId, createdAt, updatedAt }) {
      this.id = id;
      this.title = title;
      this.body = body;
      this.author = author;
      this.authorId = authorId;
      this.createdAt = createdAt;
      this.updatedAt = updatedAt;
    }
  }
  
  module.exports = Post;
  