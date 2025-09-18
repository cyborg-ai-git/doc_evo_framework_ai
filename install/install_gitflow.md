# Git Flow Installation Guide

Git Flow is a branching model for Git that provides a robust framework for managing larger projects. This guide covers installation on macOS and Ubuntu Linux.

## What is Git Flow?

Git Flow defines a strict branching model designed around the project release. It assigns very specific roles to different branches and defines how and when they should interact.

### Branch Types:
- **master/main**: Production-ready code
- **develop**: Integration branch for features
- **feature**: New features (feature/*)
- **release**: Release preparation (release/*)
- **hotfix**: Critical fixes (hotfix/*)

## macOS Installation

### Method 1: Using Homebrew (Recommended)

1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Git Flow**:
   ```bash
   brew install git-flow-avh
   ```

3. **Verify installation**:
   ```bash
   git flow version
   ```

### Method 2: Manual Installation

1. **Clone the repository**:
   ```bash
   git clone --recursive https://github.com/petervanderdoes/gitflow-avh.git
   cd gitflow-avh
   ```

2. **Install**:
   ```bash
   sudo make install
   ```

## Ubuntu Linux Installation

### Method 1: Using APT (Recommended)

1. **Update package list**:
   ```bash
   sudo apt update
   ```

2. **Install Git Flow**:
   ```bash
   sudo apt install git-flow
   ```

3. **Verify installation**:
   ```bash
   git flow version
   ```

### Method 2: Manual Installation

1. **Install dependencies**:
   ```bash
   sudo apt install git curl
   ```

2. **Download and install**:
   ```bash
   curl -OL https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh
   chmod +x gitflow-installer.sh
   sudo ./gitflow-installer.sh
   ```

### Method 3: Using Git Flow AVH (Advanced)

1. **Clone the repository**:
   ```bash
   git clone --recursive https://github.com/petervanderdoes/gitflow-avh.git
   cd gitflow-avh
   ```

2. **Install**:
   ```bash
   sudo make install
   ```

## Getting Started

### Initialize Git Flow in a Repository

1. **Navigate to your Git repository**:
   ```bash
   cd your-project
   ```

2. **Initialize Git Flow**:
   ```bash
   git flow init
   ```

   This will prompt you to configure branch names (you can accept defaults):
   - Production branch: `master` or `main`
   - Development branch: `develop`
   - Feature prefix: `feature/`
   - Release prefix: `release/`
   - Hotfix prefix: `hotfix/`
   - Support prefix: `support/`
   - Version tag prefix: (empty)

## Basic Git Flow Commands

### Feature Development

1. **Start a new feature**:
   ```bash
   git flow feature start feature-name
   ```

2. **Finish a feature**:
   ```bash
   git flow feature finish feature-name
   ```

3. **Publish a feature** (push to remote):
   ```bash
   git flow feature publish feature-name
   ```

### Release Management

1. **Start a release**:
   ```bash
   git flow release start 1.0.0
   ```

2. **Finish a release**:
   ```bash
   git flow release finish 1.0.0
   ```

### Hotfix Management

1. **Start a hotfix**:
   ```bash
   git flow hotfix start hotfix-name
   ```

2. **Finish a hotfix**:
   ```bash
   git flow hotfix finish hotfix-name
   ```

## Configuration

### Global Configuration
```bash
# Set default branch names globally
git config --global gitflow.branch.master main
git config --global gitflow.branch.develop develop
git config --global gitflow.prefix.feature feature/
git config --global gitflow.prefix.release release/
git config --global gitflow.prefix.hotfix hotfix/
```

### Project-specific Configuration
```bash
# Configure for current repository only
git config gitflow.branch.master main
git config gitflow.branch.develop develop
```

## Best Practices

### 1. Branch Naming
- Use descriptive names: `feature/user-authentication`
- Use hyphens instead of underscores
- Keep names concise but clear

### 2. Commit Messages
- Use conventional commit format
- Start with a verb: "Add", "Fix", "Update"
- Keep first line under 50 characters

### 3. Feature Development
```bash
# Start feature
git flow feature start user-login

# Work on feature
git add .
git commit -m "Add login form validation"

# Publish for collaboration
git flow feature publish user-login

# Finish feature
git flow feature finish user-login
```

### 4. Release Process
```bash
# Start release
git flow release start 1.2.0

# Update version numbers, changelog
git add .
git commit -m "Bump version to 1.2.0"

# Finish release (creates tag)
git flow release finish 1.2.0
```

## Integration with IDEs

### VS Code
- Install "Git Flow" extension
- Use Command Palette: `Git Flow: Initialize`

### IntelliJ IDEA
- Built-in Git Flow support
- VCS → Git → Git Flow

### Sourcetree
- Built-in Git Flow support
- Repository → Git Flow

## Troubleshooting

### Common Issues

1. **Git Flow not found**:
   ```bash
   # Check if git-flow is in PATH
   which git-flow
   
   # Reinstall if needed
   brew reinstall git-flow-avh  # macOS
   sudo apt reinstall git-flow  # Ubuntu
   ```

2. **Permission denied**:
   ```bash
   # Check Git configuration
   git config --list | grep user
   
   # Set user if needed
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

3. **Branch conflicts**:
   ```bash
   # Check current branch
   git branch
   
   # Switch to develop before starting features
   git checkout develop
   git flow feature start new-feature
   ```

### Verification
```bash
# Check Git Flow installation
git flow version

# Check available commands
git flow help

# Check repository status
git flow status
```

## Alternative Tools

### Git Flow Alternatives
- **GitHub Flow**: Simpler, feature branches to main
- **GitLab Flow**: Environment-based branching
- **OneFlow**: Simplified Git Flow variant

### GUI Tools with Git Flow Support
- **Sourcetree**: Free Git GUI with Git Flow integration
- **GitKraken**: Commercial Git GUI with Git Flow support
- **Tower**: macOS/Windows Git client with Git Flow

## Additional Resources

- [Git Flow Cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/)
- [A Successful Git Branching Model](https://nvie.com/posts/a-successful-git-branching-model/)
- [Git Flow AVH Documentation](https://github.com/petervanderdoes/gitflow-avh)
- [Atlassian Git Flow Tutorial](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)

For more advanced usage and team collaboration strategies, refer to the official Git Flow documentation and your team's specific workflow requirements.