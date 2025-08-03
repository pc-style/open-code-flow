# OpenCode Automated Workflow System

A comprehensive OpenCode configuration for automated app building with specialized AI agents and GitHub Copilot models.

## 🚀 Features

- **6 Specialized Agents**: Architect, Developer, Frontend, Backend, Tester, Documenter
- **4 Custom Modes**: Orchestrate, Plan, Build, Review
- **GitHub Copilot Integration**: Optimized model selection based on official recommendations
- **Automated Workflows**: Task delegation and coordination between agents

## 🤖 Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| **Architect** | `o3` | System design, database planning, technical decisions |
| **Developer** | `gpt-4.1` | Full-stack implementation, feature development |
| **Frontend** | `gpt-4o` | UI/UX, React components, user interfaces |
| **Backend** | `gpt-4.1` | APIs, databases, server logic, infrastructure |
| **Tester** | `o4-mini` | Testing, debugging, quality assurance |
| **Documenter** | `o4-mini` | Documentation, README files, code comments |

## 🎯 Modes

- **Orchestrate**: Full orchestration mode with all tools enabled
- **Plan**: Read-only analysis and planning mode
- **Build**: Full development mode for implementation
- **Review**: Code review and testing mode

## 📋 Setup

1. **Install OpenCode**:
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

2. **Authenticate with GitHub Copilot**:
   ```bash
   opencode auth login
   # Select "GitHub Copilot" and follow the authentication flow
   ```

3. **Clone this configuration**:
   ```bash
   git clone [your-repo-url]
   cd opencode-flow
   ```

4. **Use the configuration**:
   ```bash
   # Start interactive mode
   opencode

   # Use specific modes
   opencode --mode orchestrate
   opencode --mode build
   opencode --mode plan

   # Run quick tasks
   opencode run "Create a React todo app"
   opencode run "Review this code for security" --mode review
   ```

## 🏗️ Project Structure

```
opencode-flow/
├── opencode.json                    # Main configuration
├── prompts/                         # Agent prompt files
│   ├── architect-prompt.md
│   ├── backend-prompt.md
│   ├── developer-prompt.md
│   ├── documenter-prompt.md
│   ├── frontend-prompt.md
│   ├── orchestrator-instructions.md
│   └── tester-prompt.md
└── [individual prompt files]        # Backup prompt files
```

## 🎨 Model Selection

Based on [GitHub's official model recommendations](https://docs.github.com/en/copilot/reference/ai-models/model-comparison):

- **GPT-4.1**: General-purpose coding and writing
- **GPT-4o**: Fast completions with visual understanding
- **o3**: Deep reasoning and debugging
- **o4-mini**: Fast help with simple tasks

## 📖 Usage Examples

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

## 🔧 Customization

The configuration supports:
- Custom agent prompts in `prompts/` directory
- Mode-specific tool permissions
- Temperature control for different creativity levels
- Model overrides per agent/mode

## 📚 Documentation

- [OpenCode Documentation](https://opencode.ai/docs)
- [GitHub Copilot Models](https://docs.github.com/en/copilot/reference/ai-models/model-comparison)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This configuration is provided as-is for educational and development purposes.