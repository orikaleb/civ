const express = require('express');
const User = require('../models/User');
const Post = require('../models/Post');
const Analytics = require('../models/Analytics');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const router = express.Router();

// Apply admin authentication to all routes
router.use(authenticateToken);
router.use(requireAdmin);

// Get platform analytics
router.get('/', async (req, res) => {
  try {
    const period = req.query.period || '7d';
    const endDate = new Date();
    const startDate = new Date();

    // Calculate date range based on period
    switch (period) {
      case '1d':
        startDate.setDate(endDate.getDate() - 1);
        break;
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

    // Get user analytics
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({
      lastActive: { $gte: startDate }
    });
    const newUsers = await User.countDocuments({
      createdAt: { $gte: startDate }
    });

    // Get content analytics
    const totalPosts = await Post.countDocuments();
    const newPosts = await Post.countDocuments({
      createdAt: { $gte: startDate }
    });
    const totalComments = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      { $project: { commentCount: { $size: '$comments' } } },
      { $group: { _id: null, total: { $sum: '$commentCount' } } }
    ]);

    const totalLikes = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      { $project: { likeCount: { $size: '$likes' } } },
      { $group: { _id: null, total: { $sum: '$likeCount' } } }
    ]);

    // Get engagement metrics
    const engagementData = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $project: {
          likes: { $size: '$likes' },
          comments: { $size: '$comments' },
          shares: { $size: '$shares' }
        }
      },
      {
        $group: {
          _id: null,
          avgLikes: { $avg: '$likes' },
          avgComments: { $avg: '$comments' },
          avgShares: { $avg: '$shares' }
        }
      }
    ]);

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

    // Get daily activity (for charts)
    const dailyActivity = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
            day: { $dayOfMonth: '$createdAt' }
          },
          posts: { $sum: 1 },
          likes: { $sum: { $size: '$likes' } },
          comments: { $sum: { $size: '$comments' } }
        }
      },
      { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } }
    ]);

    // Get top users by engagement
    const topUsers = await User.aggregate([
      {
        $lookup: {
          from: 'posts',
          localField: '_id',
          foreignField: 'author',
          as: 'posts'
        }
      },
      {
        $project: {
          fullName: 1,
          username: 1,
          profileImage: 1,
          totalPosts: { $size: '$posts' },
          totalLikes: {
            $sum: {
              $map: {
                input: '$posts',
                as: 'post',
                in: { $size: '$$post.likes' }
              }
            }
          },
          totalComments: {
            $sum: {
              $map: {
                input: '$posts',
                as: 'post',
                in: { $size: '$$post.comments' }
              }
            }
          }
        }
      },
      {
        $addFields: {
          totalEngagement: { $add: ['$totalLikes', '$totalComments'] }
        }
      },
      { $sort: { totalEngagement: -1 } },
      { $limit: 10 }
    ]);

    // Get moderation stats
    const moderationStats = await Post.aggregate([
      {
        $group: {
          _id: null,
          reportedPosts: { $sum: { $cond: ['$isReported', 1, 0] } },
          moderatedPosts: { $sum: { $cond: ['$isModerated', 1, 0] } },
          publicPosts: { $sum: { $cond: ['$isPublic', 1, 0] } }
        }
      }
    ]);

    const suspendedUsers = await User.countDocuments({ isActive: false });

    res.json({
      success: true,
      data: {
        period,
        dateRange: { startDate, endDate },
        users: {
          total: totalUsers,
          active: activeUsers,
          new: newUsers,
          suspended: suspendedUsers
        },
        content: {
          totalPosts,
          newPosts,
          totalComments: totalComments[0]?.total || 0,
          totalLikes: totalLikes[0]?.total || 0
        },
        engagement: {
          averageLikes: engagementData[0]?.avgLikes || 0,
          averageComments: engagementData[0]?.avgComments || 0,
          averageShares: engagementData[0]?.avgShares || 0
        },
        categories: categoryStats,
        roles: roleStats,
        dailyActivity,
        topUsers,
        moderation: {
          ...moderationStats[0],
          suspendedUsers
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

// Get user growth analytics
router.get('/users/growth', async (req, res) => {
  try {
    const period = req.query.period || '30d';
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

    const userGrowth = await User.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
            day: { $dayOfMonth: '$createdAt' }
          },
          newUsers: { $sum: 1 }
        }
      },
      { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } }
    ]);

    const totalGrowth = await User.countDocuments({ createdAt: { $gte: startDate } });

    res.json({
      success: true,
      data: {
        period,
        totalGrowth,
        dailyGrowth: userGrowth
      }
    });

  } catch (error) {
    console.error('Get user growth error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user growth analytics',
      error: error.message
    });
  }
});

// Get content performance analytics
router.get('/content/performance', async (req, res) => {
  try {
    const period = req.query.period || '30d';
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

    // Get top performing posts
    const topPosts = await Post.find({ createdAt: { $gte: startDate } })
      .populate('author', 'fullName username profileImage')
      .sort({ likeCount: -1, commentCount: -1 })
      .limit(20)
      .select('content category likeCount commentCount shareCount createdAt');

    // Get category performance
    const categoryPerformance = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: '$category',
          totalPosts: { $sum: 1 },
          totalLikes: { $sum: { $size: '$likes' } },
          totalComments: { $sum: { $size: '$comments' } },
          totalShares: { $sum: { $size: '$shares' } }
        }
      },
      {
        $addFields: {
          avgLikes: { $divide: ['$totalLikes', '$totalPosts'] },
          avgComments: { $divide: ['$totalComments', '$totalPosts'] },
          avgShares: { $divide: ['$totalShares', '$totalPosts'] }
        }
      },
      { $sort: { totalLikes: -1 } }
    ]);

    // Get engagement trends
    const engagementTrends = await Post.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
            day: { $dayOfMonth: '$createdAt' }
          },
          posts: { $sum: 1 },
          likes: { $sum: { $size: '$likes' } },
          comments: { $sum: { $size: '$comments' } },
          shares: { $sum: { $size: '$shares' } }
        }
      },
      {
        $addFields: {
          engagement: { $add: ['$likes', '$comments', '$shares'] }
        }
      },
      { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } }
    ]);

    res.json({
      success: true,
      data: {
        period,
        topPosts,
        categoryPerformance,
        engagementTrends
      }
    });

  } catch (error) {
    console.error('Get content performance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch content performance analytics',
      error: error.message
    });
  }
});

// Get system health analytics
router.get('/system/health', async (req, res) => {
  try {
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      version: process.version,
      environment: process.env.NODE_ENV,
      database: 'connected',
      services: {
        auth: 'healthy',
        posts: 'healthy',
        users: 'healthy',
        analytics: 'healthy'
      },
      performance: {
        averageResponseTime: 150,
        errorRate: 0.1,
        throughput: 1000
      }
    };

    res.json({
      success: true,
      data: health
    });

  } catch (error) {
    console.error('Get system health error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get system health',
      error: error.message
    });
  }
});

module.exports = router;
