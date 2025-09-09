const express = require('express');
const { body, validationResult } = require('express-validator');
const Post = require('../models/Post');
const User = require('../models/User');
const { authenticateToken, requireOwnershipOrAdmin } = require('../middleware/auth');

const router = express.Router();

// Get all posts with pagination and filtering
router.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const category = req.query.category || '';
    const sortBy = req.query.sortBy || 'createdAt';
    const sortOrder = req.query.sortOrder === 'asc' ? 1 : -1;

    // Build query
    let query = { isPublic: true };
    
    if (category) {
      query.category = category;
    }

    // Build sort object
    const sort = {};
    sort[sortBy] = sortOrder;

    const posts = await Post.find(query)
      .populate('author', 'fullName username profileImage role isVerified')
      .sort(sort)
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments(query);

    res.json({
      success: true,
      data: {
        posts,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    console.error('Get posts error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch posts',
      error: error.message
    });
  }
});

// Get post by ID
router.get('/:id', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id)
      .populate('author', 'fullName username profileImage role isVerified')
      .populate('comments.user', 'fullName username profileImage')
      .populate('likes.user', 'fullName username profileImage');

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    res.json({
      success: true,
      data: {
        post
      }
    });

  } catch (error) {
    console.error('Get post error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch post',
      error: error.message
    });
  }
});

// Create new post
router.post('/', authenticateToken, [
  body('content').trim().isLength({ min: 1, max: 2000 }).withMessage('Content must be between 1 and 2000 characters'),
  body('category').optional().isIn(['Politics', 'Education', 'Healthcare', 'Economy', 'Environment', 'Technology', 'Sports', 'Entertainment', 'General']),
  body('images').optional().isArray()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { content, category = 'General', images = [], performanceReference } = req.body;

    const post = new Post({
      author: req.user._id,
      content,
      category,
      images,
      performanceReference
    });

    await post.save();

    // Update user's post count
    await User.findByIdAndUpdate(req.user._id, {
      $inc: { totalPosts: 1 }
    });

    // Populate author info
    await post.populate('author', 'fullName username profileImage role isVerified');

    res.status(201).json({
      success: true,
      message: 'Post created successfully',
      data: {
        post
      }
    });

  } catch (error) {
    console.error('Create post error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create post',
      error: error.message
    });
  }
});

// Update post
router.put('/:id', authenticateToken, requireOwnershipOrAdmin('author'), [
  body('content').optional().trim().isLength({ min: 1, max: 2000 }),
  body('category').optional().isIn(['Politics', 'Education', 'Healthcare', 'Economy', 'Environment', 'Technology', 'Sports', 'Entertainment', 'General'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { content, category, images } = req.body;
    const postId = req.params.id;

    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    // Update fields
    if (content) post.content = content;
    if (category) post.category = category;
    if (images) post.images = images;

    await post.save();

    res.json({
      success: true,
      message: 'Post updated successfully',
      data: {
        post
      }
    });

  } catch (error) {
    console.error('Update post error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update post',
      error: error.message
    });
  }
});

// Delete post
router.delete('/:id', authenticateToken, requireOwnershipOrAdmin('author'), async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    await Post.findByIdAndDelete(req.params.id);

    // Update user's post count
    await User.findByIdAndUpdate(post.author, {
      $inc: { totalPosts: -1 }
    });

    res.json({
      success: true,
      message: 'Post deleted successfully'
    });

  } catch (error) {
    console.error('Delete post error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete post',
      error: error.message
    });
  }
});

// Like/Unlike post
router.post('/:id/like', authenticateToken, async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    const userId = req.user._id;
    const liked = post.addLike(userId);

    if (liked) {
      await post.save();
      res.json({
        success: true,
        message: 'Post liked successfully',
        data: {
          likeCount: post.likeCount,
          liked: true
        }
      });
    } else {
      // Unlike
      post.removeLike(userId);
      await post.save();
      res.json({
        success: true,
        message: 'Post unliked successfully',
        data: {
          likeCount: post.likeCount,
          liked: false
        }
      });
    }

  } catch (error) {
    console.error('Like post error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to like post',
      error: error.message
    });
  }
});

// Add comment to post
router.post('/:id/comments', authenticateToken, [
  body('content').trim().isLength({ min: 1, max: 500 }).withMessage('Comment must be between 1 and 500 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { content } = req.body;
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    post.addComment(req.user._id, content);
    await post.save();

    // Populate the new comment
    await post.populate('comments.user', 'fullName username profileImage');

    const newComment = post.comments[post.comments.length - 1];

    res.status(201).json({
      success: true,
      message: 'Comment added successfully',
      data: {
        comment: newComment,
        commentCount: post.commentCount
      }
    });

  } catch (error) {
    console.error('Add comment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add comment',
      error: error.message
    });
  }
});

// Report post
router.post('/:id/report', authenticateToken, [
  body('reason').isIn(['spam', 'inappropriate', 'harassment', 'false_information', 'other']),
  body('description').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { reason, description } = req.body;
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    // Check if user already reported this post
    const existingReport = post.reports.find(
      report => report.user.toString() === req.user._id.toString()
    );

    if (existingReport) {
      return res.status(400).json({
        success: false,
        message: 'You have already reported this post'
      });
    }

    post.addReport(req.user._id, reason, description);
    await post.save();

    res.json({
      success: true,
      message: 'Post reported successfully'
    });

  } catch (error) {
    console.error('Report post error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to report post',
      error: error.message
    });
  }
});

// Get post comments
router.get('/:id/comments', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const post = await Post.findById(req.params.id)
      .populate({
        path: 'comments.user',
        select: 'fullName username profileImage'
      });

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    const comments = post.comments
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      .slice(skip, skip + limit);

    res.json({
      success: true,
      data: {
        comments,
        pagination: {
          page,
          limit,
          total: post.comments.length,
          pages: Math.ceil(post.comments.length / limit)
        }
      }
    });

  } catch (error) {
    console.error('Get comments error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch comments',
      error: error.message
    });
  }
});

module.exports = router;
