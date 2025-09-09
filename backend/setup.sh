#!/bin/bash

echo "🚀 Setting up CivicVoice Backend..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "✅ Node.js and npm are installed"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp env.example .env
    echo "✅ .env file created. Please edit it with your configuration."
else
    echo "✅ .env file already exists"
fi

# Check if MongoDB is running (optional)
if command -v mongod &> /dev/null; then
    echo "✅ MongoDB is available"
else
    echo "⚠️  MongoDB not found locally. Make sure to:"
    echo "   1. Install MongoDB locally, OR"
    echo "   2. Use MongoDB Atlas (cloud), OR"
    echo "   3. Update DATABASE_URL in .env file"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your configuration"
echo "2. Start MongoDB (if using local instance)"
echo "3. Run 'npm run seed' to populate database with sample data"
echo "4. Run 'npm run dev' to start the development server"
echo ""
echo "📚 API will be available at: http://localhost:3000"
echo "🔗 Health check: http://localhost:3000/health"
echo ""
echo "Happy coding! 🚀"
