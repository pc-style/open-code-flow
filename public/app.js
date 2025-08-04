/**
 * Traffic Monitor Dashboard JavaScript
 * Handles real-time updates via WebSocket and user interactions
 */

class TrafficDashboard {
    constructor() {
        this.socket = null;
        this.isConnected = false;
        this.lastStats = null;
        
        // Initialize dashboard
        this.init();
    }

    /**
     * Initialize the dashboard
     */
    init() {
        this.setupWebSocket();
        this.setupEventListeners();
        this.updateConnectionStatus(false);
    }

    /**
     * Setup WebSocket connection
     */
    setupWebSocket() {
        this.socket = io();

        this.socket.on('connect', () => {
            console.log('Connected to server');
            this.isConnected = true;
            this.updateConnectionStatus(true);
            this.socket.emit('requestStats');
        });

        this.socket.on('disconnect', () => {
            console.log('Disconnected from server');
            this.isConnected = false;
            this.updateConnectionStatus(false);
        });

        this.socket.on('stats', (stats) => {
            this.updateDashboard(stats);
            this.lastStats = stats;
        });

        this.socket.on('connect_error', (error) => {
            console.error('Connection error:', error);
            this.updateConnectionStatus(false);
        });
    }

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Add click animations to stat cards
        document.querySelectorAll('.stat-card').forEach(card => {
            card.addEventListener('click', () => {
                card.classList.add('pulse');
                setTimeout(() => card.classList.remove('pulse'), 2000);
            });
        });
    }

    /**
     * Update connection status indicator
     */
    updateConnectionStatus(connected) {
        const statusElement = document.getElementById('connectionStatus');
        if (connected) {
            statusElement.textContent = '🟢 Connected';
            statusElement.className = 'connection-status connected';
        } else {
            statusElement.textContent = '🔴 Disconnected';
            statusElement.className = 'connection-status disconnected';
        }
    }

    /**
     * Update dashboard with new statistics
     */
    updateDashboard(stats) {
        // Update basic metrics
        this.updateElement('totalRequests', this.formatNumber(stats.totalRequests));
        this.updateElement('requestsPerSecond', stats.requestsPerSecond);
        this.updateElement('activeConnections', stats.activeConnections);
        this.updateElement('averageResponseTime', stats.averageResponseTime);
        
        // Update bandwidth data
        const { value: bytesInValue, unit: bytesInUnit } = this.formatBytes(stats.totalBytesIn);
        const { value: bytesOutValue, unit: bytesOutUnit } = this.formatBytes(stats.totalBytesOut);
        const { value: totalBandwidthValue, unit: totalBandwidthUnit } = this.formatBytes(stats.totalBytesIn + stats.totalBytesOut);
        
        this.updateElement('totalBytesIn', bytesInValue);
        this.updateElement('bytesInUnit', bytesInUnit);
        this.updateElement('totalBytesOut', bytesOutValue);
        this.updateElement('bytesOutUnit', bytesOutUnit);
        this.updateElement('totalBandwidth', totalBandwidthValue);
        this.updateElement('bandwidthUnit', totalBandwidthUnit);
        
        // Update uptime
        this.updateElement('uptime', stats.uptimeFormatted || this.formatUptime(stats.uptime));
        
        // Update status codes
        this.updateStatusCodes(stats.statusCodes);
        
        // Update last update time
        this.updateElement('lastUpdate', `Last updated: ${new Date().toLocaleTimeString()}`);
    }

    /**
     * Update a DOM element's text content
     */
    updateElement(id, value) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        }
    }

    /**
     * Format numbers with commas
     */
    formatNumber(num) {
        return num.toLocaleString();
    }

    /**
     * Format bytes to human readable format
     */
    formatBytes(bytes) {
        if (bytes === 0) return { value: '0', unit: 'bytes' };
        
        const k = 1024;
        const sizes = ['bytes', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        const value = parseFloat((bytes / Math.pow(k, i)).toFixed(1));
        const unit = sizes[i];
        
        return { value, unit };
    }

    /**
     * Format uptime duration
     */
    formatUptime(ms) {
        const seconds = Math.floor(ms / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        const days = Math.floor(hours / 24);

        if (days > 0) {
            return `${days}d ${hours % 24}h ${minutes % 60}m`;
        } else if (hours > 0) {
            return `${hours}h ${minutes % 60}m`;
        } else if (minutes > 0) {
            return `${minutes}m ${seconds % 60}s`;
        } else {
            return `${seconds}s`;
        }
    }

    /**
     * Update status codes display
     */
    updateStatusCodes(statusCodes) {
        const container = document.getElementById('statusCodesList');
        
        if (!statusCodes || Object.keys(statusCodes).length === 0) {
            container.innerHTML = '<div class="status-item"><span>No requests yet</span><span>-</span></div>';
            return;
        }

        const statusItems = Object.entries(statusCodes)
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([code, count]) => {
                const statusClass = this.getStatusClass(code);
                return `
                    <div class="status-item ${statusClass}">
                        <span>${code}</span>
                        <span>${this.formatNumber(count)}</span>
                    </div>
                `;
            })
            .join('');

        container.innerHTML = statusItems;
    }

    /**
     * Get CSS class for status code
     */
    getStatusClass(code) {
        const num = parseInt(code);
        if (num >= 200 && num < 300) return 'status-2xx';
        if (num >= 300 && num < 400) return 'status-3xx';
        if (num >= 400 && num < 500) return 'status-4xx';
        if (num >= 500) return 'status-5xx';
        return '';
    }

    /**
     * Request fresh statistics
     */
    requestStats() {
        if (this.socket && this.isConnected) {
            this.socket.emit('requestStats');
        }
    }
}

// Global functions for button actions

/**
 * Generate test traffic
 */
async function generateTestTraffic(event) {
    const button = event?.target || document.querySelector('button:contains("Generate Test Traffic")');
    const originalText = button.textContent;
    
    try {
        button.textContent = '🔄 Generating...';
        button.disabled = true;

        // Generate multiple requests
        const requests = [];
        for (let i = 0; i < 10; i++) {
            requests.push(
                fetch('/api/test', {
                    method: Math.random() > 0.5 ? 'GET' : 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: Math.random() > 0.5 ? JSON.stringify({
                        test: true,
                        timestamp: Date.now(),
                        data: Math.random().toString(36)
                    }) : undefined
                })
            );
        }

        // Wait for all requests to complete
        await Promise.all(requests);
        
        // Show success
        button.textContent = '✅ Generated!';
        setTimeout(() => {
            button.textContent = originalText;
            button.disabled = false;
        }, 2000);

    } catch (error) {
        console.error('Error generating test traffic:', error);
        button.textContent = '❌ Failed';
        setTimeout(() => {
            button.textContent = originalText;
            button.disabled = false;
        }, 2000);
    }
}

/**
 * Refresh statistics
 */
function refreshStats() {
    if (window.dashboard) {
        window.dashboard.requestStats();
    }
}

/**
 * Reset statistics
 */
async function resetStats(event) {
    if (!confirm('Are you sure you want to reset all statistics? This action cannot be undone.')) {
        return;
    }

    const button = event?.target || document.querySelector('button:contains("Reset Stats")');
    const originalText = button.textContent;
    
    try {
        button.textContent = '🔄 Resetting...';
        button.disabled = true;

        const response = await fetch('/reset', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        });

        if (response.ok) {
            button.textContent = '✅ Reset!';
            // Request fresh stats
            setTimeout(() => {
                if (window.dashboard) {
                    window.dashboard.requestStats();
                }
            }, 500);
        } else {
            throw new Error('Reset failed');
        }

    } catch (error) {
        console.error('Error resetting stats:', error);
        button.textContent = '❌ Failed';
    } finally {
        setTimeout(() => {
            button.textContent = originalText;
            button.disabled = false;
        }, 2000);
    }
}

// Initialize dashboard when page loads
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new TrafficDashboard();
});

// Add some visual feedback for interactions
document.addEventListener('click', (e) => {
    if (e.target.classList.contains('btn')) {
        e.target.style.transform = 'scale(0.95)';
        setTimeout(() => {
            e.target.style.transform = '';
        }, 150);
    }
});

// Add keyboard shortcuts
document.addEventListener('keydown', (e) => {
    // Ctrl/Cmd + R for refresh
    if ((e.ctrlKey || e.metaKey) && e.key === 'r') {
        e.preventDefault();
        refreshStats();
    }
    
    // Ctrl/Cmd + T for test traffic
    if ((e.ctrlKey || e.metaKey) && e.key === 't') {
        e.preventDefault();
        generateTestTraffic();
    }
});

// Auto-refresh stats every 30 seconds as fallback
setInterval(() => {
    if (window.dashboard && !window.dashboard.isConnected) {
        // Try to reconnect if disconnected
        window.dashboard.setupWebSocket();
    }
}, 30000);