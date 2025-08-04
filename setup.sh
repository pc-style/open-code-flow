#!/bin/bash

# HTTP Traffic Monitor Setup Script
# This script installs dependencies and starts the traffic monitoring server

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis
ROCKET="🚀"
CHECK="✅"
GEAR="⚙️"
MONITOR="📊"
SERVER="🖥️"
INSTALL="📦"

print_header() {
    echo ""
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                           ║${NC}"
    echo -e "${PURPLE}║           📊 HTTP TRAFFIC MONITOR SERVER 📊              ║${NC}"
    echo -e "${PURPLE}║                                                           ║${NC}"
    echo -e "${PURPLE}║       Real-time HTTP traffic monitoring dashboard         ║${NC}"
    echo -e "${PURPLE}║                                                           ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}${1} ${2}${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK} ${1}${NC}"
}

print_error() {
    echo -e "${RED}❌ ${1}${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  ${1}${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Node.js version
check_node_version() {
    if command_exists node; then
        local node_version=$(node --version | cut -d'v' -f2)
        local major_version=$(echo $node_version | cut -d'.' -f1)
        
        if [ "$major_version" -ge 14 ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Main setup function
main() {
    print_header
    
    # Step 1: Check prerequisites
    print_step "${GEAR}" "Checking prerequisites..."
    
    if ! check_node_version; then
        print_error "Node.js 14.0.0 or higher is required"
        echo "Please install Node.js from: https://nodejs.org/"
        exit 1
    fi
    
    if ! command_exists npm; then
        print_error "npm is not installed. Please install Node.js first."
        exit 1
    fi
    
    print_success "Node.js $(node --version) detected"
    print_success "npm $(npm --version) detected"
    echo ""
    
    # Step 2: Install dependencies
    print_step "${INSTALL}" "Installing dependencies..."
    
    if [ -f "package.json" ]; then
        npm install
        print_success "Dependencies installed successfully"
    else
        print_error "package.json not found. Please run this script from the project directory."
        exit 1
    fi
    
    echo ""
    
    # Step 3: Display information
    print_step "${MONITOR}" "Server Information"
    echo ""
    print_info "Server will start on: http://localhost:3000"
    print_info "Dashboard URL: http://localhost:3000"
    print_info "API Stats: http://localhost:3000/stats"
    print_info "Health Check: http://localhost:3000/health"
    print_info "Test Endpoint: http://localhost:3000/api/test"
    echo ""
    
    # Step 4: Start server
    print_step "${ROCKET}" "Starting HTTP Traffic Monitor Server..."
    echo ""
    print_success "Setup completed! Starting server..."
    echo ""
    echo -e "${CYAN}📊 Dashboard Features:${NC}"
    echo "• Real-time traffic monitoring"
    echo "• WebSocket live updates"
    echo "• Bandwidth tracking"
    echo "• Response time analysis"
    echo "• HTTP status code monitoring"
    echo "• Interactive test traffic generation"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
    echo ""
    
    # Start the server
    npm start
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}Server stopped by user${NC}"; exit 0' INT

# Check if we're in the right directory
if [ ! -f "server.js" ]; then
    print_error "server.js not found. Please run this script from the project directory."
    exit 1
fi

# Run the main function
main "$@"