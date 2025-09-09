const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Post = require('../models/Post');
const { authenticateToken, requireOwnershipOrAdmin } = require('../middleware/auth');

const router = express.Router();

// Get user profile by ID
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get user's posts
    const posts = await Post.find({ author: user._id, isPublic: true })
      .sort({ createdAt: -1 })
      .limit(20)
      .populate('author', 'fullName username profileImage');

    // Get user's stats
    const stats = user.getStats();

    res.json({
      success: true,
      data: {
        user: user.toJSON(),
        posts,
        stats
      }
    });

  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user profile',
      error: error.message
    });
  }
});

// Update user profile
router.put('/:id', authenticateToken, requireOwnershipOrAdmin('id'), [
  body('fullName').optional().trim().isLength({ min: 2 }),
  body('bio').optional().isLength({ max: 500 }),
  body('interests').optional().isArray()
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

    const { fullName, bio, interests, profileImage, coverImage } = req.body;
    const userId = req.params.id;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Update fields
    if (fullName) user.fullName = fullName;
    if (bio !== undefined) user.bio = bio;
    if (interests) user.interests = interests;
    if (profileImage) user.profileImage = profileImage;
    if (coverImage) user.coverImage = coverImage;

    await user.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        user: user.toJSON()
      }
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile',
      error: error.message
    });
  }
});

// Follow user
router.post('/:id/follow', authenticateToken, async (req, res) => {
  try {
    const targetUserId = req.params.id;
    const currentUserId = req.user._id;

    if (targetUserId === currentUserId.toString()) {
      return res.status(400).json({
        success: false,
        message: 'Cannot follow yourself'
      });
    }

    const targetUser = await User.findById(targetUserId);
    const currentUser = await User.findById(currentUserId);

    if (!targetUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if already following
    if (currentUser.following.includes(targetUserId)) {
      return res.status(400).json({
        success: false,
        message: 'Already following this user'
      });
    }

    // Add to following and followers
    currentUser.following.push(targetUserId);
    targetUser.followers.push(currentUserId);

    await Promise.all([currentUser.save(), targetUser.save()]);

    res.json({
      success: true,
      message: 'User followed successfully',
      data: {
        following: currentUser.following.length,
        followers: targetUser.followers.length
      }
    });

  } catch (error) {
    console.error('Follow user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to follow user',
      error: error.message
    });
  }
});

// Unfollow user
router.delete('/:id/follow', authenticateToken, async (req, res) => {
  try {
    const targetUserId = req.params.id;
    const currentUserId = req.user._id;

    const targetUser = await User.findById(targetUserId);
    const currentUser = await User.findById(currentUserId);

    if (!targetUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if following
    if (!currentUser.following.includes(targetUserId)) {
      return res.status(400).json({
        success: false,
        message: 'Not following this user'
      });
    }

    // Remove from following and followers
    currentUser.following = currentUser.following.filter(
      id => id.toString() !== targetUserId
    );
    targetUser.followers = targetUser.followers.filter(
      id => id.toString() !== currentUserId.toString()
    );

    await Promise.all([currentUser.save(), targetUser.save()]);

    res.json({
      success: true,
      message: 'User unfollowed successfully',
      data: {
        following: currentUser.following.length,
        followers: targetUser.followers.length
      }
    });

  } catch (error) {
    console.error('Unfollow user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to unfollow user',
      error: error.message
    });
  }
});

// Get user's followers
router.get('/:id/followers', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const user = await User.findById(req.params.id)
      .populate({
        path: 'followers',
        select: 'fullName username profileImage bio',
        options: { skip, limit, sort: { createdAt: -1 } }
      });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const total = user.followers.length;

    res.json({
      success: true,
      data: {
        followers: user.followers,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    console.error('Get followers error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch followers',
      error: error.message
    });
  }
});

// Get user's following
router.get('/:id/following', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const user = await User.findById(req.params.id)
      .populate({
        path: 'following',
        select: 'fullName username profileImage bio',
        options: { skip, limit, sort: { createdAt: -1 } }
      });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const total = user.following.length;

    res.json({
      success: true,
      data: {
        following: user.following,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    console.error('Get following error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch following',
      error: error.message
    });
  }
});

// Get user's posts
router.get('/:id/posts', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const posts = await Post.find({ 
      author: req.params.id, 
      isPublic: true 
    })
      .populate('author', 'fullName username profileImage')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments({ 
      author: req.params.id, 
      isPublic: true 
    });

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
    console.error('Get user posts error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user posts',
      error: error.message
    });
  }
});

// Search users
router.get('/search', async (req, res) => {
  try {
    const query = req.query.q || '';
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    if (!query.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    const users = await User.find({
      $or: [
        { fullName: { $regex: query, $options: 'i' } },
        { username: { $regex: query, $options: 'i' } }
      ],
      isActive: true
    })
      .select('-password')
      .sort({ fullName: 1 })
      .skip(skip)
      .limit(limit);

    const total = await User.countDocuments({
      $or: [
        { fullName: { $regex: query, $options: 'i' } },
        { username: { $regex: query, $options: 'i' } }
      ],
      isActive: true
    });

    res.json({
      success: true,
      data: {
        users,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search users',
      error: error.message
    });
  }
});

module.exports = router;
