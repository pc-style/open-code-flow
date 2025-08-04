#!/bin/bash

# OpenCode Automated Workflow System Setup Script
# This script downloads the configuration, installs OpenCode, and sets up your workflow

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
ROBOT="🤖"
DOWNLOAD="📥"
CONFIG="🔧"

print_header() {
    echo ""
    echo -e "${PURPLE}█▀▀█ █▀▀█ █▀▀ █▀▀▄ █▀▀ █▀▀█ █▀▀▄ █▀▀${NC}"
    echo -e "${PURPLE}█░░█ █░░█ █▀▀ █░░█ █░░ █░░█ █░░█ █▀▀${NC}"
    echo -e "${PURPLE}▀▀▀▀ █▀▀▀ ▀▀▀ ▀  ▀ ▀▀▀ ▀▀▀▀ ▀▀▀  ▀▀▀${NC}"
    echo ""
    echo -e "${CYAN}${ROBOT} OpenCode Automated Workflow System Setup${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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

# Get user input with default value
get_input() {
    local prompt="$1"
    local default="$2"
    local input
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        echo "${input:-$default}"
    else
        read -p "$prompt: " input
        echo "$input"
    fi
}

# Validate directory name
validate_directory() {
    local dir="$1"
    if [[ "$dir" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Main setup function
main() {
    print_header
    
    # Step 1: Check prerequisites
    print_step "${GEAR}" "Checking prerequisites..."
    
    if ! command_exists git; then
        print_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    if ! command_exists curl; then
        print_error "curl is not installed. Please install curl first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
    echo ""
    
    # Step 2: Get setup preferences
    print_step "${CONFIG}" "Configuration Setup"
    echo ""
    
    # Get directory name
    while true; do
        PROJECT_DIR=$(get_input "Enter project directory name" "opencode-workflow")
        if validate_directory "$PROJECT_DIR"; then
            break
        else
            print_error "Invalid directory name. Use only letters, numbers, hyphens, and underscores."
        fi
    done
    
    # Check if directory exists
    if [ -d "$PROJECT_DIR" ]; then
        echo ""
        print_info "Directory '$PROJECT_DIR' already exists."
        OVERWRITE=$(get_input "Do you want to overwrite it? (y/N)" "N")
        if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR"
            print_success "Removed existing directory"
        else
            print_error "Setup cancelled"
            exit 1
        fi
    fi
    
    echo ""
    print_info "Available GitHub Copilot Models:"
    echo "  • gpt-4.1     - General-purpose coding (recommended default)"
    echo "  • gpt-4o      - Fast completions with visual understanding"
    echo "  • o3          - Deep reasoning and debugging"
    echo "  • o4-mini     - Fast help with simple tasks"
    echo "  • claude-opus-4      - Most powerful reasoning"
    echo "  • claude-sonnet-4    - Balanced performance"
    echo "  • claude-3.5-sonnet  - Quick responses"
    echo "  • gemini-2.5-pro     - Complex code generation"
    echo ""
    
    # Model configuration
    DEFAULT_MODEL=$(get_input "Primary model for complex tasks" "gpt-4.1")
    SMALL_MODEL=$(get_input "Small model for quick tasks" "o4-mini")
    ARCHITECT_MODEL=$(get_input "Architect agent model (for system design)" "o3")
    FRONTEND_MODEL=$(get_input "Frontend agent model (supports visual)" "gpt-4o")
    
    echo ""
    
    # Step 3: Download repository
    print_step "${DOWNLOAD}" "Downloading OpenCode configuration..."
    
    # Clone the repository
    if git clone https://github.com/pc-style/open-code-flow.git "$PROJECT_DIR"; then
        cd "$PROJECT_DIR"
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository. Creating structure manually..."
        mkdir -p "$PROJECT_DIR"
        cd "$PROJECT_DIR"
        git init -q
        git branch -m main 2>/dev/null || true
        mkdir -p prompts
    fi
    
    print_success "Project structure created"
    
    # Step 4: Download/create configuration files
    print_step "${CONFIG}" "Setting up configuration files..."
    
    # Create the main configuration with user's model preferences
    cat > opencode.json << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "github-copilot/${DEFAULT_MODEL}",
  "small_model": "github-copilot/${SMALL_MODEL}",
  
  "instructions": [
    "./prompts/orchestrator-instructions.md"
  ],
  
  "mode": {
    "orchestrate": {
      "description": "Full orchestration mode for automated app building workflow",
      "model": "github-copilot/${ARCHITECT_MODEL}",
      "temperature": 0.1,
      "tools": {
        "write": true,
        "edit": true,
        "bash": true,
        "read": true,
        "grep": true,
        "patch": true
      }
    },
    "plan": {
      "description": "Planning and architecture mode - read-only analysis",
      "model": "github-copilot/${DEFAULT_MODEL}",
      "temperature": 0,
      "tools": {
        "write": false,
        "edit": false,
        "bash": false,
        "read": true,
        "grep": true,
        "glob": true
      }
    },
    "build": {
      "description": "Full development mode with all tools enabled",
      "model": "github-copilot/${DEFAULT_MODEL}",
      "temperature": 0.1,
      "tools": {
        "write": true,
        "edit": true,
        "bash": true,
        "read": true,
        "grep": true,
        "glob": true,
        "patch": true
      }
    },
    "review": {
      "description": "Code review and testing mode",
      "model": "github-copilot/${DEFAULT_MODEL}",
      "temperature": 0,
      "tools": {
        "write": true,
        "edit": false,
        "bash": true,
        "read": true,
        "grep": true
      }
    }
  },

  "agent": {
    "architect": {
      "description": "System architect for planning application structure, database design, and technical decisions",
      "model": "github-copilot/${ARCHITECT_MODEL}",
      "temperature": 0,
      "prompt": "{file:./prompts/architect-prompt.md}",
      "tools": {
        "read": true,
        "write": true,
        "edit": false,
        "bash": false
      }
    },
    
    "developer": {
      "description": "Full-stack developer for implementing features, writing code, and handling technical implementation",
      "model": "github-copilot/${DEFAULT_MODEL}",
      "temperature": 0.1,
      "prompt": "{file:./prompts/developer-prompt.md}",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": true,
        "grep": true
      }
    },
    
    "frontend": {
      "description": "Frontend specialist for UI/UX implementation, React components, and user interfaces",
      "model": "github-copilot/${FRONTEND_MODEL}",
      "temperature": 0.2,
      "prompt": "{file:./prompts/frontend-prompt.md}",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": false
      }
    },
    
    "backend": {
      "description": "Backend specialist for APIs, database operations, server logic, and infrastructure",
      "model": "github-copilot/${DEFAULT_MODEL}",
      "temperature": 0.1,
      "prompt": "{file:./prompts/backend-prompt.md}",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": true,
        "grep": true
      }
    },
    
    "tester": {
      "description": "Quality assurance specialist for writing tests, debugging, and ensuring code quality",
      "model": "github-copilot/${SMALL_MODEL}",
      "temperature": 0,
      "prompt": "{file:./prompts/tester-prompt.md}",
      "tools": {
        "read": true,
        "write": true,
        "bash": true,
        "grep": true
      }
    },
    
    "documenter": {
      "description": "Technical writer for creating documentation, README files, and code comments",
      "model": "github-copilot/${SMALL_MODEL}",
      "temperature": 0.3,
      "prompt": "{file:./prompts/documenter-prompt.md}",
      "tools": {
        "read": true,
        "write": true,
        "edit": false,
        "bash": false
      }
    }
  },

  "permissions": {
    "edit": "allow",
    "bash": "allow"
  },

  "autoupdate": false,
  "theme": "dark"
}
EOF
    
    print_success "Configuration file created with your model preferences"
    
    # Step 5: Install OpenCode
    print_step "${DOWNLOAD}" "Installing OpenCode..."
    
    if command_exists opencode; then
        print_info "OpenCode is already installed"
    else
        print_info "Downloading and installing OpenCode..."
        curl -fsSL https://opencode.ai/install | bash
        
        # Add to PATH for current session
        export PATH="$HOME/.opencode/bin:$PATH"
        
        if command_exists opencode; then
            print_success "OpenCode installed successfully"
        else
            print_error "OpenCode installation failed. Please install manually."
            echo "Run: curl -fsSL https://opencode.ai/install | bash"
            exit 1
        fi
    fi
    
    # Step 6: Create prompt files (simplified versions)
    print_step "${CONFIG}" "Creating agent prompt files..."
    
    # Create basic prompt files
    cat > prompts/orchestrator-instructions.md << 'EOF'
# Orchestrator Instructions

You are the main orchestrator for an automated development workflow system. Your role is to:

## Core Responsibilities
1. **Analyze Requirements**: Break down user requests into actionable tasks
2. **Delegate Tasks**: Assign work to specialized agents based on their expertise
3. **Coordinate Workflow**: Ensure smooth handoffs between agents
4. **Track Progress**: Monitor task completion and quality
5. **Final Integration**: Ensure all components work together

## Available Agents
- **Architect**: System design, database planning, technical decisions
- **Developer**: Full-stack implementation, core development
- **Frontend**: UI/UX, React components, user interfaces  
- **Backend**: APIs, databases, server logic, infrastructure
- **Tester**: Testing, debugging, quality assurance
- **Documenter**: Documentation, README files, code comments

## Workflow Patterns
1. Start with **Architect** for system design
2. Use **Developer** for core implementation
3. Delegate **Frontend** and **Backend** for specialized work
4. Always include **Tester** for quality assurance
5. End with **Documenter** for documentation

## Communication Style
- Be clear and specific in task delegation
- Provide context and requirements to agents
- Coordinate handoffs between agents
- Maintain project coherence and quality standards
EOF

    cat > prompts/architect-prompt.md << 'EOF'
# System Architect Agent

You are a senior system architect specializing in application design, database architecture, and technical decision-making.

## Your Expertise
- System architecture and design patterns
- Database design and optimization
- Technology stack selection
- Scalability and performance planning
- Security architecture
- API design and microservices

## Your Role
1. **Analyze Requirements**: Understand business needs and technical constraints
2. **Design Systems**: Create scalable, maintainable architectures
3. **Make Technical Decisions**: Choose appropriate technologies and patterns
4. **Plan Database Schema**: Design efficient data models
5. **Document Architecture**: Create clear technical specifications

## Output Format
Always provide:
- Clear architectural decisions with reasoning
- Database schema designs when applicable
- Technology recommendations
- Scalability considerations
- Security implications
- Integration points and APIs

Focus on creating robust, scalable solutions that can grow with the project needs.
EOF

    cat > prompts/developer-prompt.md << 'EOF'
# Full-Stack Developer Agent

You are an experienced full-stack developer capable of implementing features across the entire technology stack.

## Your Expertise
- Frontend and backend development
- Database integration
- API development and integration
- Code optimization and refactoring
- Problem-solving and debugging
- Multiple programming languages and frameworks

## Your Role
1. **Implement Features**: Write clean, efficient code
2. **Integrate Components**: Connect frontend, backend, and databases
3. **Debug Issues**: Identify and fix problems
4. **Optimize Performance**: Improve code efficiency
5. **Follow Best Practices**: Write maintainable, testable code

## Coding Standards
- Write clean, readable code with proper comments
- Follow established patterns and conventions
- Include error handling and validation
- Consider performance and scalability
- Write code that is easy to test and maintain

## Output Format
- Provide complete, working code implementations
- Include necessary imports and dependencies
- Add clear comments explaining complex logic
- Suggest improvements and optimizations
- Consider edge cases and error scenarios
EOF

    cat > prompts/frontend-prompt.md << 'EOF'
# Frontend Specialist Agent

You are a frontend specialist focused on creating exceptional user interfaces and user experiences.

## Your Expertise
- Modern frontend frameworks (React, Vue, Angular)
- HTML5, CSS3, JavaScript/TypeScript
- Responsive design and mobile-first development
- UI/UX best practices
- Performance optimization
- Accessibility standards
- State management

## Your Role
1. **Create UI Components**: Build reusable, accessible components
2. **Implement Designs**: Convert designs into functional interfaces
3. **Optimize Performance**: Ensure fast loading and smooth interactions
4. **Ensure Accessibility**: Make interfaces usable for everyone
5. **Mobile Responsiveness**: Create designs that work on all devices

## Best Practices
- Use semantic HTML and proper ARIA labels
- Implement responsive design principles
- Optimize images and assets
- Follow component-based architecture
- Ensure cross-browser compatibility
- Write maintainable CSS/SCSS

## Output Format
- Provide complete component implementations
- Include styling (CSS/SCSS/styled-components)
- Add proper TypeScript types when applicable
- Include responsive design considerations
- Suggest UX improvements and accessibility enhancements
EOF

    cat > prompts/backend-prompt.md << 'EOF'
# Backend Specialist Agent

You are a backend specialist focused on server-side development, APIs, databases, and infrastructure.

## Your Expertise
- RESTful API design and implementation
- Database design and optimization
- Server architecture and deployment
- Authentication and authorization
- Performance optimization
- Security best practices
- Microservices and distributed systems

## Your Role
1. **API Development**: Create robust, scalable APIs
2. **Database Management**: Design and optimize database schemas
3. **Security Implementation**: Ensure secure data handling
4. **Performance Optimization**: Create efficient server-side logic
5. **Infrastructure Setup**: Configure deployment and hosting

## Best Practices
- Design RESTful APIs with proper HTTP methods
- Implement proper authentication and authorization
- Use database best practices (indexing, normalization)
- Handle errors gracefully with proper status codes
- Implement logging and monitoring
- Follow security best practices (validation, sanitization)

## Output Format
- Provide complete API implementations
- Include database schema designs
- Add proper error handling and validation
- Include security considerations
- Suggest performance optimizations
- Document API endpoints clearly
EOF

    cat > prompts/tester-prompt.md << 'EOF'
# Quality Assurance Specialist Agent

You are a QA specialist focused on testing, debugging, and ensuring code quality across the entire application.

## Your Expertise
- Unit testing and integration testing
- Test-driven development (TDD)
- Debugging and troubleshooting
- Code quality analysis
- Performance testing
- Security testing
- Test automation

## Your Role
1. **Write Tests**: Create comprehensive test suites
2. **Debug Issues**: Identify and help resolve bugs
3. **Quality Assurance**: Ensure code meets quality standards
4. **Performance Testing**: Verify application performance
5. **Security Testing**: Check for vulnerabilities

## Testing Strategies
- Write unit tests for individual functions/components
- Create integration tests for API endpoints
- Implement end-to-end tests for user workflows
- Test edge cases and error conditions
- Verify security and performance requirements

## Output Format
- Provide complete test implementations
- Include test data and mock objects
- Add clear test descriptions and assertions
- Suggest additional test scenarios
- Identify potential bugs and quality issues
- Recommend testing tools and frameworks
EOF

    cat > prompts/documenter-prompt.md << 'EOF'
# Technical Writer Agent

You are a technical writer specializing in creating clear, comprehensive documentation for software projects.

## Your Expertise
- Technical writing and documentation
- API documentation
- User guides and tutorials
- Code commenting and inline documentation
- README files and project documentation
- Process documentation

## Your Role
1. **Create Documentation**: Write clear, comprehensive docs
2. **Code Comments**: Add meaningful comments to code
3. **User Guides**: Create tutorials and how-to guides
4. **API Documentation**: Document endpoints and usage
5. **Project Documentation**: Maintain README and setup guides

## Documentation Standards
- Write in clear, concise language
- Use proper markdown formatting
- Include code examples and usage
- Organize information logically
- Keep documentation up-to-date
- Consider the audience (developers, users, stakeholders)

## Output Format
- Provide well-structured markdown documentation
- Include code examples with syntax highlighting
- Add clear headings and organization
- Include setup and usage instructions
- Suggest improvements to existing documentation
- Create comprehensive README files
EOF

    print_success "Agent prompt files created"
    
    # Step 7: Create additional files
    print_step "${CONFIG}" "Creating additional project files..."
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
# OpenCode specific
.opencode/
*.log

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Temporary files
*.tmp
*.temp

# Node modules (if using Node.js projects)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Python (if using Python projects)
__pycache__/
*.py[cod]
*$py.class
.env
venv/
EOF

    # Create README
    cat > README.md << EOF
# OpenCode Automated Workflow System

A comprehensive OpenCode configuration for automated app building with specialized AI agents and GitHub Copilot models.

## 🚀 Quick Start

Your configuration is ready to use! Here's how to get started:

### 1. Authenticate with GitHub Copilot
\`\`\`bash
opencode auth login
# Select "GitHub Copilot" and follow the authentication flow
\`\`\`

### 2. Start Using OpenCode
\`\`\`bash
# Start interactive mode
opencode

# Use specific modes
opencode --mode orchestrate    # Full workflow orchestration
opencode --mode build         # Development mode
opencode --mode plan          # Planning and analysis
opencode --mode review        # Code review mode

# Quick tasks
opencode run "Create a React todo app"
opencode run "Review this code for security issues" --mode review
\`\`\`

## 🤖 Your Configured Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| **Architect** | \`${ARCHITECT_MODEL}\` | System design, database planning |
| **Developer** | \`${DEFAULT_MODEL}\` | Full-stack implementation |
| **Frontend** | \`${FRONTEND_MODEL}\` | UI/UX, React components |
| **Backend** | \`${DEFAULT_MODEL}\` | APIs, databases, server logic |
| **Tester** | \`${SMALL_MODEL}\` | Testing, debugging, QA |
| **Documenter** | \`${SMALL_MODEL}\` | Documentation, README files |

## 🎯 Your Configured Models

- **Primary Model**: \`${DEFAULT_MODEL}\` - For complex development tasks
- **Small Model**: \`${SMALL_MODEL}\` - For quick, simple tasks
- **Architect Model**: \`${ARCHITECT_MODEL}\` - For system design and architecture
- **Frontend Model**: \`${FRONTEND_MODEL}\` - For UI/UX work with visual support

## 📁 Project Structure

\`\`\`
${PROJECT_DIR}/
├── opencode.json              # Main OpenCode configuration
├── prompts/                   # Agent prompt files
│   ├── architect-prompt.md
│   ├── backend-prompt.md
│   ├── developer-prompt.md
│   ├── documenter-prompt.md
│   ├── frontend-prompt.md
│   ├── orchestrator-instructions.md
│   └── tester-prompt.md
├── .gitignore                # Git ignore rules
└── README.md                 # This file
\`\`\`

## 🔧 Customization

You can customize your setup by editing:

- **\`opencode.json\`**: Main configuration, models, and agent settings
- **\`prompts/\`**: Individual agent prompts and instructions
- Add your own modes and agents as needed

## 📚 Documentation

- [OpenCode Documentation](https://opencode.ai/docs)
- [GitHub Copilot Models](https://docs.github.com/en/copilot/reference/ai-models/model-comparison)

## 🎉 Example Usage

### Create a Full Application
\`\`\`bash
opencode --mode orchestrate
"Create a task management app with user authentication, real-time updates, and mobile-responsive design"
\`\`\`

### Code Review
\`\`\`bash
opencode --mode review
"Review this codebase for security vulnerabilities and performance issues"
\`\`\`

### Architecture Planning
\`\`\`bash
opencode run "Design a microservices architecture for an e-commerce platform" --mode plan
\`\`\`

Happy coding with your AI-powered workflow system! 🚀
EOF

    print_success "Project files created"
    
    # Step 8: Initialize git repository
    print_step "${CONFIG}" "Initializing Git repository..."
    
    git add .
    git commit -q -m "Initial setup: OpenCode automated workflow system

- Configured with user-selected models: ${DEFAULT_MODEL}, ${SMALL_MODEL}, ${ARCHITECT_MODEL}, ${FRONTEND_MODEL}
- 6 specialized agents with custom prompts
- 4 workflow modes: orchestrate, plan, build, review
- Ready-to-use automated development workflow"
    
    print_success "Git repository initialized"
    
    # Step 9: Final setup
    echo ""
    print_step "${ROCKET}" "Setup Complete!"
    echo ""
    
    print_success "OpenCode automated workflow system is ready!"
    print_info "Project location: $(pwd)"
    print_info "Configuration file: opencode.json"
    print_info "Agent prompts: prompts/ directory"
    
    echo ""
    echo -e "${CYAN}🎯 Next Steps:${NC}"
    echo "1. Authenticate with GitHub Copilot:"
    echo -e "   ${YELLOW}opencode auth login${NC}"
    echo ""
    echo "2. Start using your workflow system:"
    echo -e "   ${YELLOW}opencode --mode orchestrate${NC}"
    echo -e "   ${YELLOW}opencode run \"Create a React todo app\"${NC}"
    echo ""
    echo "3. Customize your agents by editing files in the prompts/ directory"
    echo ""
    
    print_success "Setup completed successfully! 🎉"
}

# Run the main function
main "$@"