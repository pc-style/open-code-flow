/**
 * Traffic Tracking Middleware
 * Monitors HTTP requests and calculates real-time statistics
 */

class TrafficTracker {
  constructor() {
    // Initialize statistics storage
    this.stats = {
      totalRequests: 0,
      activeConnections: 0,
      totalBytesIn: 0,
      totalBytesOut: 0,
      requestsPerSecond: 0,
      averageResponseTime: 0,
      statusCodes: {},
      requestHistory: [], // For calculating RPS
      responseTimeHistory: [], // For calculating average response time
      startTime: Date.now()
    };

    // Rolling window configuration (keep last 60 seconds)
    this.windowSize = 60;
    this.updateInterval = 1000; // 1 second

    // Start periodic cleanup and calculations
    this.startPeriodicUpdates();
  }

  /**
   * Express middleware function
   */
  middleware() {
    return (req, res, next) => {
      const startTime = Date.now();
      
      // Track incoming request
      this.trackRequest(req);

      // Override res.end to track response
      const originalEnd = res.end;
      const originalWrite = res.write;
      
      let bytesOut = 0;

      // Track bytes written
      res.write = function(chunk, encoding) {
        if (chunk) {
          bytesOut += Buffer.isBuffer(chunk) ? chunk.length : Buffer.byteLength(chunk, encoding);
        }
        return originalWrite.call(this, chunk, encoding);
      };

      // Track response completion
      res.end = (chunk, encoding) => {
        // Calculate final bytes
        if (chunk) {
          bytesOut += Buffer.isBuffer(chunk) ? chunk.length : Buffer.byteLength(chunk, encoding);
        }

        // Track response
        this.trackResponse(res, startTime, bytesOut);
        
        // Call original end
        return originalEnd.call(res, chunk, encoding);
      };

      next();
    };
  }

  /**
   * Track incoming request
   */
  trackRequest(req) {
    this.stats.totalRequests++;
    this.stats.activeConnections++;

    // Track bytes in (approximate from headers and body)
    const bytesIn = this.calculateRequestSize(req);
    this.stats.totalBytesIn += bytesIn;

    // Add to request history for RPS calculation
    this.stats.requestHistory.push({
      timestamp: Date.now(),
      bytesIn: bytesIn
    });

    // Clean old entries (keep only last 60 seconds)
    this.cleanupHistory();
  }

  /**
   * Track response completion
   */
  trackResponse(res, startTime, bytesOut) {
    const responseTime = Date.now() - startTime;
    const statusCode = res.statusCode;

    // Update statistics
    this.stats.activeConnections--;
    this.stats.totalBytesOut += bytesOut;

    // Track status codes
    this.stats.statusCodes[statusCode] = (this.stats.statusCodes[statusCode] || 0) + 1;

    // Add to response time history
    this.stats.responseTimeHistory.push({
      timestamp: Date.now(),
      responseTime: responseTime,
      bytesOut: bytesOut
    });

    // Calculate average response time
    this.calculateAverageResponseTime();
  }

  /**
   * Calculate approximate request size
   */
  calculateRequestSize(req) {
    let size = 0;
    
    // Request line (method + URL + HTTP version)
    size += Buffer.byteLength(`${req.method} ${req.url} HTTP/1.1\r\n`);
    
    // Headers
    for (const [key, value] of Object.entries(req.headers)) {
      size += Buffer.byteLength(`${key}: ${value}\r\n`);
    }
    
    // Header terminator
    size += 2; // \r\n
    
    // Body size (if available)
    if (req.get('content-length')) {
      size += parseInt(req.get('content-length'), 10);
    }
    
    return size;
  }

  /**
   * Calculate average response time from recent responses
   */
  calculateAverageResponseTime() {
    const now = Date.now();
    const recentResponses = this.stats.responseTimeHistory.filter(
      entry => now - entry.timestamp <= this.windowSize * 1000
    );

    if (recentResponses.length > 0) {
      const totalTime = recentResponses.reduce((sum, entry) => sum + entry.responseTime, 0);
      this.stats.averageResponseTime = Math.round(totalTime / recentResponses.length);
    }
  }

  /**
   * Clean up old entries from history arrays
   */
  cleanupHistory() {
    const now = Date.now();
    const cutoff = now - (this.windowSize * 1000);

    // Clean request history
    this.stats.requestHistory = this.stats.requestHistory.filter(
      entry => entry.timestamp > cutoff
    );

    // Clean response time history
    this.stats.responseTimeHistory = this.stats.responseTimeHistory.filter(
      entry => entry.timestamp > cutoff
    );
  }

  /**
   * Calculate requests per second
   */
  calculateRequestsPerSecond() {
    const now = Date.now();
    const oneSecondAgo = now - 1000;
    
    const recentRequests = this.stats.requestHistory.filter(
      entry => entry.timestamp > oneSecondAgo
    );
    
    this.stats.requestsPerSecond = recentRequests.length;
  }

  /**
   * Start periodic updates for calculated metrics
   */
  startPeriodicUpdates() {
    setInterval(() => {
      this.calculateRequestsPerSecond();
      this.cleanupHistory();
    }, this.updateInterval);
  }

  /**
   * Get current statistics
   */
  getStats() {
    const uptime = Date.now() - this.stats.startTime;
    
    return {
      ...this.stats,
      uptime: uptime,
      uptimeFormatted: this.formatUptime(uptime),
      timestamp: Date.now()
    };
  }

  /**
   * Format uptime in human readable format
   */
  formatUptime(ms) {
    const seconds = Math.floor(ms / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) {
      return `${days}d ${hours % 24}h ${minutes % 60}m ${seconds % 60}s`;
    } else if (hours > 0) {
      return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    } else {
      return `${seconds}s`;
    }
  }

  /**
   * Reset statistics
   */
  reset() {
    this.stats = {
      totalRequests: 0,
      activeConnections: 0,
      totalBytesIn: 0,
      totalBytesOut: 0,
      requestsPerSecond: 0,
      averageResponseTime: 0,
      statusCodes: {},
      requestHistory: [],
      responseTimeHistory: [],
      startTime: Date.now()
    };
  }
}

module.exports = TrafficTracker;