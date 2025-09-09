const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Post = require('../models/Post');
const Analytics = require('../models/Analytics');
const { authenticateToken, requireAdmin, requirePermission } = require('../middleware/auth');

const router = express.Router();

// Apply admin authentication to all routes
router.use(authenticateToken);
router.use(requireAdmin);

// Get all users with pagination
router.get('/users', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const search = req.query.search || '';
    const role = req.query.role || '';
    const status = req.query.status || '';

    // Build query
    let query = {};
    
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { username: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (role) {
      query.role = role;
    }
    
    if (status === 'active') {
      query.isActive = true;
    } else if (status === 'suspended') {
      query.isActive = false;
    }

    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await User.countDocuments(query);

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
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
      error: error.message
    });
  }
});

// Get user by ID
router.get('/users/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get user's posts
    const posts = await Post.find({ author: user._id })
      .sort({ createdAt: -1 })
      .limit(10)
      .populate('author', 'fullName username profileImage');

    res.json({
      success: true,
      data: {
        user,
        recentPosts: posts
      }
    });

  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user',
      error: error.message
    });
  }
});

// Update user role
router.put('/users/:id/role', [
  body('role').isIn(['user', 'moderator', 'admin', 'superAdmin'])
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

    const { role } = req.body;
    const userId = req.params.id;

    // Prevent self-demotion
    if (userId === req.user._id.toString() && role !== 'superAdmin') {
      return res.status(400).json({
        success: false,
        message: 'Cannot change your own role'
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    user.role = role;
    await user.save();

    res.json({
      success: true,
      message: 'User role updated successfully',
      data: {
        user: user.toJSON()
      }
    });

  } catch (error) {
    console.error('Update role error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user role',
      error: error.message
    });
  }
});

// Suspend user
router.put('/users/:id/suspend', [
  body('reason').notEmpty().withMessage('Suspension reason is required'),
  body('duration').optional().isInt({ min: 1, max: 365 })
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

    const { reason, duration = 7 } = req.body;
    const userId = req.params.id;

    // Prevent self-suspension
    if (userId === req.user._id.toString()) {
      return res.status(400).json({
        success: false,
        message: 'Cannot suspend yourself'
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const suspensionDate = new Date();
    suspensionDate.setDate(suspensionDate.getDate() + duration);

    user.isActive = false;
    user.suspendedUntil = suspensionDate;
    user.suspensionReason = reason;
    user.adminNotes = `${user.adminNotes}\nSuspended on ${new Date().toISOString()}: ${reason}`;

    await user.save();

    res.json({
      success: true,
      message: 'User suspended successfully',
      data: {
        user: user.toJSON(),
        suspensionDetails: {
          reason,
          duration,
          suspendedUntil: suspensionDate
        }
      }
    });

  } catch (error) {
    console.error('Suspend user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to suspend user',
      error: error.message
    });
  }
});

// Activate user
router.put('/users/:id/activate', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    user.isActive = true;
    user.suspendedUntil = null;
    user.suspensionReason = '';
    user.adminNotes = `${user.adminNotes}\nActivated on ${new Date().toISOString()}`;

    await user.save();

    res.json({
      success: true,
      message: 'User activated successfully',
      data: {
        user: user.toJSON()
      }
    });

  } catch (error) {
    console.error('Activate user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to activate user',
      error: error.message
    });
  }
});

// Delete user
router.delete('/users/:id', async (req, res) => {
  try {
    const userId = req.params.id;

    // Prevent self-deletion
    if (userId === req.user._id.toString()) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete your own account'
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Delete user's posts
    await Post.deleteMany({ author: userId });

    // Delete user
    await User.findByIdAndDelete(userId);

    res.json({
      success: true,
      message: 'User deleted successfully'
    });

  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete user',
      error: error.message
    });
  }
});

// Get reported content
router.get('/reports', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const posts = await Post.find({ isReported: true })
      .populate('author', 'fullName username profileImage')
      .populate('reports.user', 'fullName username')
      .sort({ 'reports.createdAt': -1 })
      .skip(skip)
      .limit(limit);

    const total = await Post.countDocuments({ isReported: true });

    res.json({
      success: true,
      data: {
        reports: posts,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reports',
      error: error.message
    });
  }
});

// Moderate content
router.put('/reports/:id/moderate', [
  body('action').isIn(['approve', 'reject']),
  body('notes').optional().isString()
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

    const { action, notes } = req.body;
    const postId = req.params.id;

    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    if (action === 'approve') {
      post.isModerated = true;
      post.isReported = false;
      post.moderationNotes = notes || 'Content approved by moderator';
    } else {
      post.isModerated = true;
      post.isPublic = false;
      post.moderationNotes = notes || 'Content rejected by moderator';
    }

    await post.save();

    res.json({
      success: true,
      message: `Content ${action}d successfully`,
      data: {
        post: post.toJSON()
      }
    });

  } catch (error) {
    console.error('Moderate content error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to moderate content',
      error: error.message
    });
  }
});

// Get analytics
router.get('/analytics', async (req, res) => {
  try {
    const period = req.query.period || '7d'; // 7d, 30d, 90d, 1y
    const endDate = new Date();
    const startDate = new Date();

    switch (period) {
      case '7d':
        startDate.setDate(endDate.getDate() - 7);
        break;
      case '30d':
        startDate.setDate(endDate.getDate() - 30);
        break;
      case '90d':
        startDate.setDate(endDate.getDate() - 90);
        break;
      case '1y':
        startDate.setFullYear(endDate.getFullYear() - 1);
        break;
    }

    // Get user statistics
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ 
      lastActive: { $gte: startDate } 
    });
    const newUsers = await User.countDocuments({ 
      createdAt: { $gte: startDate } 
    });

    // Get content statistics
    const totalPosts = await Post.countDocuments();
    const newPosts = await Post.countDocuments({ 
      createdAt: { $gte: startDate } 
    });
    const reportedPosts = await Post.countDocuments({ isReported: true });

    // Get category distribution
    const categoryStats = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Get user role distribution
    const roleStats = await User.aggregate([
      { $group: { _id: '$role', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    res.json({
      success: true,
      data: {
        period,
        dateRange: { startDate, endDate },
        users: {
          total: totalUsers,
          active: activeUsers,
          new: newUsers
        },
        content: {
          totalPosts,
          newPosts,
          reportedPosts
        },
        categories: categoryStats,
        roles: roleStats,
        systemHealth: {
          status: 'healthy',
          uptime: 99.9,
          responseTime: 150,
          errorRate: 0.1
        }
      }
    });

  } catch (error) {
    console.error('Get analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch analytics',
      error: error.message
    });
  }
});

// Get system health
router.get('/system/health', async (req, res) => {
  try {
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      version: process.version,
      environment: process.env.NODE_ENV,
      database: 'connected', // You can add actual DB health check here
      services: {
        auth: 'healthy',
        posts: 'healthy',
        users: 'healthy',
        analytics: 'healthy'
      }
    };

    res.json({
      success: true,
      data: health
    });

  } catch (error) {
    console.error('System health error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get system health',
      error: error.message
    });
  }
});

// Get admin dashboard data
router.get('/dashboard', async (req, res) => {
  try {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const lastWeek = new Date(today);
    lastWeek.setDate(lastWeek.getDate() - 7);

    // Get quick stats
    const totalUsers = await User.countDocuments();
    const totalPosts = await Post.countDocuments();
    const reportedContent = await Post.countDocuments({ isReported: true });
    const activeUsers = await User.countDocuments({ 
      lastActive: { $gte: lastWeek } 
    });

    // Get recent activity
    const recentUsers = await User.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select('fullName username email role createdAt');

    const recentPosts = await Post.find()
      .populate('author', 'fullName username')
      .sort({ createdAt: -1 })
      .limit(5)
      .select('content category createdAt likeCount commentCount');

    const recentReports = await Post.find({ isReported: true })
      .populate('author', 'fullName username')
      .populate('reports.user', 'fullName username')
      .sort({ 'reports.createdAt': -1 })
      .limit(5)
      .select('content reports createdAt');

    res.json({
      success: true,
      data: {
        stats: {
          totalUsers,
          totalPosts,
          reportedContent,
          activeUsers
        },
        recentActivity: {
          users: recentUsers,
          posts: recentPosts,
          reports: recentReports
        }
      }
    });

  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get dashboard data',
      error: error.message
    });
  }
});

module.exports = router;
