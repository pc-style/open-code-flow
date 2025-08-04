# OpenCode Automated Workflow System

A comprehensive OpenCode configuration for automated app building with specialized AI agents and GitHub Copilot models.

## 🚀 Quick Start

Your configuration is ready to use! Here's how to get started:

### 1. Authenticate with GitHub Copilot
```bash
opencode auth login
# Select "GitHub Copilot" and follow the authentication flow
```

### 2. Start Using OpenCode
```bash
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
```

## 🤖 Your Configured Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| **Architect** | `claude-opus-4` | System design, database planning |
| **Developer** | `claude-sonnet-4` | Full-stack implementation |
| **Frontend** | `claude-sonnet-4` | UI/UX, React components |
| **Backend** | `claude-sonnet-4` | APIs, databases, server logic |
| **Tester** | `gpt-4.1` | Testing, debugging, QA |
| **Documenter** | `gpt-4.1` | Documentation, README files |

## 🎯 Your Configured Models

- **Primary Model**: `claude-sonnet-4` - For complex development tasks
- **Small Model**: `gpt-4.1` - For quick, simple tasks
- **Architect Model**: `claude-opus-4` - For system design and architecture
- **Frontend Model**: `claude-sonnet-4` - For UI/UX work with visual support

## 📁 Project Structure

```
traffic-monitor/
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
```

## 🔧 Customization

You can customize your setup by editing:

- **`opencode.json`**: Main configuration, models, and agent settings
- **`prompts/`**: Individual agent prompts and instructions
- Add your own modes and agents as needed

## 📚 Documentation

- [OpenCode Documentation](https://opencode.ai/docs)
- [GitHub Copilot Models](https://docs.github.com/en/copilot/reference/ai-models/model-comparison)

## 🎉 Example Usage

### Create a Full Application
```bash
opencode --mode orchestrate
"Create a task management app with user authentication, real-time updates, and mobile-responsive design"
```

### Code Review
```bash
opencode --mode review
"Review this codebase for security vulnerabilities and performance issues"
```

### Architecture Planning
```bash
opencode run "Design a microservices architecture for an e-commerce platform" --mode plan
```

Happy coding with your AI-powered workflow system! 🚀
