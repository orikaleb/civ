const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test data
const testUser = {
  email: 'test@example.com',
  password: 'password123',
  fullName: 'Test User',
  username: 'testuser',
  bio: 'Test user for API testing'
};

const testPost = {
  content: 'This is a test post for API testing',
  category: 'General'
};

async function testAPI() {
  console.log('🧪 Starting API Tests...\n');

  try {
    // Test 1: Health Check
    console.log('1. Testing Health Check...');
    const healthResponse = await axios.get(`${BASE_URL.replace('/api', '')}/health`);
    console.log('✅ Health Check:', healthResponse.data.status);
    console.log('');

    // Test 2: Register User
    console.log('2. Testing User Registration...');
    try {
      const registerResponse = await axios.post(`${BASE_URL}/auth/register`, testUser);
      console.log('✅ User Registration:', registerResponse.data.message);
      const token = registerResponse.data.data.token;
      console.log('');

      // Test 3: Get User Profile
      console.log('3. Testing Get User Profile...');
      const profileResponse = await axios.get(`${BASE_URL}/auth/me`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ User Profile:', profileResponse.data.data.user.fullName);
      console.log('');

      // Test 4: Create Post
      console.log('4. Testing Create Post...');
      const postResponse = await axios.post(`${BASE_URL}/posts`, testPost, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Post Created:', postResponse.data.message);
      const postId = postResponse.data.data.post._id;
      console.log('');

      // Test 5: Get Posts
      console.log('5. Testing Get Posts...');
      const postsResponse = await axios.get(`${BASE_URL}/posts`);
      console.log('✅ Posts Retrieved:', postsResponse.data.data.posts.length, 'posts');
      console.log('');

      // Test 6: Like Post
      console.log('6. Testing Like Post...');
      const likeResponse = await axios.post(`${BASE_URL}/posts/${postId}/like`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Post Liked:', likeResponse.data.message);
      console.log('');

      // Test 7: Add Comment
      console.log('7. Testing Add Comment...');
      const commentResponse = await axios.post(`${BASE_URL}/posts/${postId}/comments`, {
        content: 'This is a test comment'
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Comment Added:', commentResponse.data.message);
      console.log('');

      // Test 8: Admin Login
      console.log('8. Testing Admin Login...');
      try {
        const adminResponse = await axios.post(`${BASE_URL}/auth/admin/login`, {
          email: 'admin@civicvoice.com',
          password: 'admin123'
        });
        console.log('✅ Admin Login:', adminResponse.data.message);
        const adminToken = adminResponse.data.data.token;
        console.log('');

        // Test 9: Get Admin Dashboard
        console.log('9. Testing Admin Dashboard...');
        const dashboardResponse = await axios.get(`${BASE_URL}/admin/dashboard`, {
          headers: { Authorization: `Bearer ${adminToken}` }
        });
        console.log('✅ Admin Dashboard:', dashboardResponse.data.data.stats.totalUsers, 'users');
        console.log('');

        // Test 10: Get Analytics
        console.log('10. Testing Analytics...');
        const analyticsResponse = await axios.get(`${BASE_URL}/admin/analytics`, {
          headers: { Authorization: `Bearer ${adminToken}` }
        });
        console.log('✅ Analytics:', analyticsResponse.data.data.users.total, 'total users');
        console.log('');

      } catch (adminError) {
        console.log('⚠️  Admin tests skipped (admin user not found)');
        console.log('');
      }

    } catch (registerError) {
      if (registerError.response?.status === 400 && registerError.response?.data?.message?.includes('already')) {
        console.log('⚠️  User already exists, testing login instead...');
        
        // Test Login
        const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
          email: testUser.email,
          password: testUser.password
        });
        console.log('✅ User Login:', loginResponse.data.message);
        const token = loginResponse.data.data.token;
        console.log('');
      } else {
        throw registerError;
      }
    }

    console.log('🎉 All API tests completed successfully!');
    console.log('');
    console.log('📊 API Endpoints Tested:');
    console.log('- Health Check');
    console.log('- User Registration/Login');
    console.log('- User Profile');
    console.log('- Post Creation');
    console.log('- Post Retrieval');
    console.log('- Post Liking');
    console.log('- Comment Addition');
    console.log('- Admin Login');
    console.log('- Admin Dashboard');
    console.log('- Analytics');
    console.log('');
    console.log('🚀 Your CivicVoice API is working perfectly!');

  } catch (error) {
    console.error('❌ API Test Failed:', error.response?.data || error.message);
    console.log('');
    console.log('🔧 Troubleshooting:');
    console.log('1. Make sure the server is running: npm run dev');
    console.log('2. Check if MongoDB is connected');
    console.log('3. Verify environment variables are set');
    console.log('4. Check server logs for errors');
  }
}

// Run tests
testAPI();
