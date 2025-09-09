const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('../models/User');
const Post = require('../models/Post');

const connectDB = require('../config/database');

const seedData = async () => {
  try {
    await connectDB();

    // Clear existing data
    await User.deleteMany({});
    await Post.deleteMany({});

    console.log('🗑️  Cleared existing data');

    // Create admin user
    const adminUser = new User({
      email: 'admin@civicvoice.com',
      password: 'admin123',
      fullName: 'Admin User',
      username: 'admin',
      bio: 'System Administrator',
      role: 'admin',
      isVerified: true,
      isActive: true,
      interests: ['Politics', 'Education', 'Healthcare']
    });

    await adminUser.save();
    console.log('👤 Created admin user');

    // Create sample users
    const sampleUsers = [
      {
        email: 'john.doe@example.com',
        password: 'password123',
        fullName: 'John Doe',
        username: 'johndoe',
        bio: 'Political enthusiast and community advocate',
        role: 'user',
        isVerified: true,
        interests: ['Politics', 'Economy']
      },
      {
        email: 'jane.smith@example.com',
        password: 'password123',
        fullName: 'Jane Smith',
        username: 'janesmith',
        bio: 'Education reform advocate',
        role: 'user',
        isVerified: false,
        interests: ['Education', 'Healthcare']
      },
      {
        email: 'moderator@civicvoice.com',
        password: 'password123',
        fullName: 'Content Moderator',
        username: 'moderator',
        bio: 'Community moderator',
        role: 'moderator',
        isVerified: true,
        interests: ['Politics', 'Education', 'Healthcare']
      }
    ];

    const createdUsers = [];
    for (const userData of sampleUsers) {
      const user = new User(userData);
      await user.save();
      createdUsers.push(user);
      console.log(`👤 Created user: ${user.fullName}`);
    }

    // Create sample posts
    const samplePosts = [
      {
        author: createdUsers[0]._id,
        content: 'The new education policy shows promising results in improving student outcomes. What are your thoughts on the recent changes?',
        category: 'Education',
        likes: [
          { user: createdUsers[1]._id },
          { user: createdUsers[2]._id }
        ],
        comments: [
          {
            user: createdUsers[1]._id,
            content: 'I agree! The focus on practical learning is much needed.'
          }
        ]
      },
      {
        author: createdUsers[1]._id,
        content: 'Healthcare accessibility in rural areas needs immediate attention. We need better infrastructure and more healthcare workers.',
        category: 'Healthcare',
        likes: [
          { user: createdUsers[0]._id }
        ],
        comments: [
          {
            user: createdUsers[0]._id,
            content: 'Absolutely! Telemedicine could be a game-changer here.'
          }
        ]
      },
      {
        author: adminUser._id,
        content: 'Welcome to CivicVoice! This platform is designed to foster meaningful discussions about important civic issues.',
        category: 'General',
        likes: [
          { user: createdUsers[0]._id },
          { user: createdUsers[1]._id },
          { user: createdUsers[2]._id }
        ],
        comments: [
          {
            user: createdUsers[0]._id,
            content: 'Excited to be part of this community!'
          },
          {
            user: createdUsers[1]._id,
            content: 'Great initiative! Looking forward to meaningful discussions.'
          }
        ]
      }
    ];

    for (const postData of samplePosts) {
      const post = new Post(postData);
      await post.save();
      console.log(`📝 Created post: ${post.content.substring(0, 50)}...`);
    }

    // Update user stats
    for (const user of createdUsers) {
      const userPosts = await Post.countDocuments({ author: user._id });
      const userLikes = await Post.aggregate([
        { $match: { author: user._id } },
        { $project: { likeCount: { $size: '$likes' } } },
        { $group: { _id: null, total: { $sum: '$likeCount' } } }
      ]);

      user.totalPosts = userPosts;
      user.totalVotes = userLikes[0]?.total || 0;
      await user.save();
    }

    console.log('✅ Database seeded successfully!');
    console.log('\n📋 Sample Data Created:');
    console.log('- 1 Admin user (admin@civicvoice.com / admin123)');
    console.log('- 2 Regular users');
    console.log('- 1 Moderator user');
    console.log('- 3 Sample posts with engagement');
    console.log('\n🚀 You can now start the server and test the API!');

  } catch (error) {
    console.error('❌ Seeding failed:', error);
  } finally {
    await mongoose.connection.close();
    process.exit(0);
  }
};

seedData();
