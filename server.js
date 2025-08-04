/**
 * HTTP Traffic Monitoring Server
 * Main server file with Express, WebSocket, and traffic monitoring
 */

const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const path = require('path');
const TrafficTracker = require('./middleware/traffic-tracker');

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Configuration
const PORT = process.env.PORT || 3000;
const UPDATE_INTERVAL = 1000; // 1 second

// Initialize traffic tracker
const trafficTracker = new TrafficTracker();

// Middleware setup
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Apply traffic tracking middleware to all routes
app.use(trafficTracker.middleware());

// Serve static files (dashboard)
app.use(express.static(path.join(__dirname, 'public')));

// API Routes

/**
 * GET /stats - Return current traffic statistics
 */
app.get('/stats', (req, res) => {
  try {
    const stats = trafficTracker.getStats();
    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve statistics',
      message: error.message
    });
  }
});

/**
 * POST /reset - Reset all statistics
 */
app.post('/reset', (req, res) => {
  try {
    trafficTracker.reset();
    res.json({
      success: true,
      message: 'Statistics reset successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to reset statistics',
      message: error.message
    });
  }
});

/**
 * GET /health - Health check endpoint
 */
app.get('/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

/**
 * GET /api/test - Test endpoint for generating traffic
 */
app.get('/api/test', (req, res) => {
  // Simulate some processing time
  const delay = Math.random() * 100 + 50;
  
  setTimeout(() => {
    res.json({
      success: true,
      message: 'Test endpoint response',
      timestamp: new Date().toISOString(),
      delay: delay,
      randomData: {
        number: Math.random(),
        string: Math.random().toString(36).substring(7),
        array: Array.from({ length: 5 }, () => Math.random())
      }
    });
  }, delay);
});

/**
 * POST /api/test - Test endpoint for POST requests
 */
app.post('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'POST request received',
    receivedData: req.body,
    timestamp: new Date().toISOString()
  });
});

/**
 * GET / - Serve dashboard
 */
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.originalUrl,
    method: req.method
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server Error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: err.message
  });
});

// WebSocket connection handling
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Send initial stats
  socket.emit('stats', trafficTracker.getStats());

  // Handle client disconnect
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });

  // Handle stats request
  socket.on('requestStats', () => {
    socket.emit('stats', trafficTracker.getStats());
  });
});

// Broadcast statistics to all connected clients every second
const broadcastStats = () => {
  const stats = trafficTracker.getStats();
  io.emit('stats', stats);
};

// Start broadcasting statistics
const statsInterval = setInterval(broadcastStats, UPDATE_INTERVAL);

// Graceful shutdown
const gracefulShutdown = () => {
  console.log('Shutting down gracefully...');
  
  // Clear intervals
  clearInterval(statsInterval);
  
  // Close server
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
};

// Handle shutdown signals
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Start server
server.listen(PORT, () => {
  console.log(`\n🚀 Traffic Monitor Server Started`);
  console.log(`📊 Dashboard: http://localhost:${PORT}`);
  console.log(`📡 API Stats: http://localhost:${PORT}/stats`);
  console.log(`🔧 Health Check: http://localhost:${PORT}/health`);
  console.log(`🧪 Test Endpoint: http://localhost:${PORT}/api/test`);
  console.log(`⚡ WebSocket: Enabled for real-time updates`);
  console.log(`\nPress Ctrl+C to stop the server\n`);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

module.exports = { app, server, trafficTracker };