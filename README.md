# HTTP Traffic Monitor Server

A real-time HTTP traffic monitoring server with WebSocket dashboard built with Node.js, Express, and Socket.IO.

## 🚀 Features

- **Real-time Traffic Monitoring**: Track incoming HTTP requests in real-time
- **Comprehensive Metrics**: Monitor bandwidth, response times, requests per second, and more
- **WebSocket Dashboard**: Live updating dashboard with beautiful UI
- **Status Code Tracking**: Monitor HTTP response status codes
- **Memory-based Storage**: Fast in-memory statistics with rolling windows
- **RESTful API**: JSON API for accessing statistics programmatically

## 📊 Monitored Metrics

- Total requests processed
- Requests per second (RPS)
- Active connections
- Average response time
- Total bandwidth (in/out)
- HTTP status code distribution
- Server uptime
- Rolling window calculations

## 🛠️ Installation & Setup

### Prerequisites
- Node.js 14.0.0 or higher
- npm or yarn package manager

### Quick Start

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start the server**:
   ```bash
   npm start
   ```

3. **Access the dashboard**:
   Open your browser and go to: `http://localhost:3000`

### Development Mode

For development with auto-restart:
```bash
npm run dev
```

## 🌐 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Traffic monitoring dashboard |
| `GET` | `/stats` | Current traffic statistics (JSON) |
| `POST` | `/reset` | Reset all statistics |
| `GET` | `/health` | Server health check |
| `GET` | `/api/test` | Test endpoint for generating traffic |
| `POST` | `/api/test` | Test endpoint for POST requests |

### Example API Response

```json
{
  "success": true,
  "data": {
    "totalRequests": 1523,
    "requestsPerSecond": 12,
    "activeConnections": 3,
    "averageResponseTime": 45,
    "totalBytesIn": 2048576,
    "totalBytesOut": 5242880,
    "uptime": 3600000,
    "uptimeFormatted": "1h 0m 0s",
    "statusCodes": {
      "200": 1420,
      "404": 85,
      "500": 18
    },
    "timestamp": 1641234567890
  }
}
```

## 🎛️ Dashboard Features

- **Real-time Updates**: Statistics update every second via WebSocket
- **Interactive Controls**: Generate test traffic, refresh stats, reset counters
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Visual Status Indicators**: Color-coded status codes and connection status
- **Keyboard Shortcuts**: 
  - `Ctrl/Cmd + R`: Refresh statistics
  - `Ctrl/Cmd + T`: Generate test traffic

## 🏗️ Architecture

### Core Components

1. **Traffic Tracker Middleware** (`middleware/traffic-tracker.js`)
   - Monitors all incoming requests
   - Calculates real-time metrics
   - Manages rolling window data

2. **Express Server** (`server.js`)
   - HTTP server with routing
   - WebSocket integration
   - API endpoints

3. **Dashboard** (`public/index.html` + `public/app.js`)
   - Real-time visualization
   - WebSocket client
   - Interactive controls

### Data Flow

```
HTTP Request → Traffic Tracker → Express Routes → Response
     ↓              ↓                              ↓
Statistics → WebSocket → Dashboard Updates → User Interface
```

## 📁 Project Structure

```
traffic-monitor-server/
├── package.json              # Dependencies and scripts
├── server.js                 # Main server file
├── middleware/
│   └── traffic-tracker.js    # Traffic monitoring middleware
├── public/
│   ├── index.html            # Dashboard HTML
│   └── app.js               # Dashboard JavaScript
└── README.md                # This file
```

## ⚙️ Configuration

### Environment Variables

- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment mode (development/production)

### Server Configuration

You can modify these settings in `server.js`:
- `UPDATE_INTERVAL`: WebSocket broadcast frequency (default: 1000ms)
- `windowSize`: Statistics rolling window size (default: 60 seconds)

## 🧪 Testing & Development

### Generate Test Traffic

Use the dashboard button or make direct API calls:

```bash
# Generate GET requests
curl http://localhost:3000/api/test

# Generate POST requests
curl -X POST http://localhost:3000/api/test \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Check statistics
curl http://localhost:3000/stats
```

### Load Testing

For performance testing, you can use tools like:

```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:3000/api/test

# Using curl in a loop
for i in {1..100}; do curl http://localhost:3000/api/test & done
```

## 🔒 Security Considerations

- CORS is enabled for all origins (configure as needed)
- No authentication required (add as needed for production)
- Rate limiting not implemented (consider adding for production)
- Input validation minimal (enhance for production use)

## 🚀 Production Deployment

### Recommendations

1. **Process Management**: Use PM2 or similar
2. **Reverse Proxy**: Use Nginx or Apache
3. **Environment Variables**: Configure properly
4. **Monitoring**: Add external monitoring
5. **Security**: Implement authentication and rate limiting

### PM2 Example

```bash
# Install PM2
npm install -g pm2

# Start with PM2
pm2 start server.js --name "traffic-monitor"

# View logs
pm2 logs traffic-monitor
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the package.json file for details.

## 🎯 Use Cases

- **Development**: Monitor API usage during development
- **Testing**: Track performance during load testing  
- **Debugging**: Identify traffic patterns and issues
- **Analytics**: Understand application usage
- **Monitoring**: Real-time server health monitoring

---

Built with ❤️ using Node.js, Express, and Socket.IO
