// File: backend/interfaces/controllers/PostController.js

class PostController {
  constructor(postUseCases) {
    this.postUseCases = postUseCases;
  }

  // Helper to format posts with consistent date fields for frontend
  _formatPostForResponse(post) {
    if (!post) return null;
    
    const postObj = post.toObject ? post.toObject() : post;
    
    // Ensure createdAt and updatedAt exist for frontend compatibility
    if (!postObj.createdAt && postObj.postedAt) {
      postObj.createdAt = postObj.postedAt;
    }
    
    // If no updatedAt but has editHistory, use the most recent edit date
    if (!postObj.updatedAt && postObj.editHistory && postObj.editHistory.length > 0) {
      postObj.updatedAt = postObj.editHistory[postObj.editHistory.length - 1].editedAt;
    } else if (!postObj.updatedAt) {
      // Default updatedAt to createdAt if no edits
      postObj.updatedAt = postObj.createdAt || postObj.postedAt;
    }
    
    return postObj;
  }
  
  // Format an array of posts
  _formatPostsForResponse(posts) {
    return posts.map(post => this._formatPostForResponse(post));
  }

  // Create a new post. Accepts multipart/form-data via Multer.
  async createPost(req, res) {
    try {
      const user = req.user;  // from passport JWT

      // Base post data
      const data = {
        authorId: user._id,
        author:   user.name,
        text:     req.body.text,
        address:  req.body.address,
      };

      // If Multer parsed an 'image' file, save its relative path
      if (req.file) {
        data.image = `/uploads/${req.file.filename}`;
      }

      // This will trigger Mongoose schema validation: either 'image' or 'text' required
      const post = await this.postUseCases.createPost(data);
      return res.status(201).json({ 
        success: true, 
        post: this._formatPostForResponse(post)
      });
    } catch (error) {
      // Return validation or any other errors as 400
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  // Get all posts of the authenticated user
  async getAllPosts(req, res) {
    try {
      const userId = req.user._id;
      const posts = await this.postUseCases.getAllPosts(userId);
      return res.status(200).json({ 
        success: true, 
        posts: this._formatPostsForResponse(posts)
      });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  // Get a single post by ID
  async getPostById(req, res) {
    try {
      const post = await this.postUseCases.getPostById(req.params.id);
      return res.status(200).json({ 
        success: true, 
        post: this._formatPostForResponse(post)
      });
    } catch (error) {
      return res.status(404).json({ success: false, message: error.message });
    }
  }

  // Update a post by ID
  async updatePost(req, res) {
    try {
      const updated = await this.postUseCases.updatePost(req.params.id, req.body);
      return res.status(200).json({ 
        success: true, 
        post: this._formatPostForResponse(updated)
      });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  // Fetch edit history (optionally detailed)
  async getEditHistory(req, res) {
    try {
      const post = await this.postUseCases.getPostById(req.params.id);
      return res.status(200).json({
        success:   true,
        editCount: post.editCount,
        history:   req.query.detail === 'true' ? post.editHistory : undefined
      });
    } catch (error) {
      return res.status(404).json({ success: false, message: error.message });
    }
  }

  // Delete a post
  async deletePost(req, res) {
    try {
      await this.postUseCases.deletePost(req.params.id);
      return res.status(200).json({ success: true, message: "Post deleted" });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }
}

module.exports = PostController;