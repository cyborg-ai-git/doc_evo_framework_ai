#!/bin/bash

# Installation script for Git Flow, Pandoc, and PlantUML
# Supports macOS and Ubuntu Linux

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_info "Detected macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            OS="ubuntu"
            log_info "Detected Ubuntu Linux"
        else
            log_error "Unsupported Linux distribution. This script supports Ubuntu only."
            exit 1
        fi
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Install Homebrew on macOS
install_homebrew() {
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log_success "Homebrew installed successfully"
    else
        log_info "Homebrew already installed"
    fi
}

# Update package managers
update_packages() {
    if [[ "$OS" == "macos" ]]; then
        log_info "Updating Homebrew..."
        brew update
    elif [[ "$OS" == "ubuntu" ]]; then
        log_info "Updating APT packages..."
        sudo apt update
    fi
}

# Install Git Flow
install_gitflow() {
    log_info "Installing Git Flow..."
    
    if command_exists git-flow; then
        log_warning "Git Flow already installed"
        return
    fi
    
    if [[ "$OS" == "macos" ]]; then
        brew install git-flow-avh
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt install -y git-flow
    fi
    
    if command_exists git-flow; then
        log_success "Git Flow installed successfully"
        git flow version
    else
        log_error "Git Flow installation failed"
        exit 1
    fi
}

# Install Java (required for PlantUML)
install_java() {
    if command_exists java; then
        log_info "Java already installed"
        java -version
        return
    fi
    
    log_info "Installing Java..."
    
    if [[ "$OS" == "macos" ]]; then
        brew install openjdk
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt install -y default-jre default-jdk
    fi
    
    if command_exists java; then
        log_success "Java installed successfully"
    else
        log_error "Java installation failed"
        exit 1
    fi
}

# Install PlantUML
install_plantuml() {
    log_info "Installing PlantUML..."
    
    if command_exists plantuml; then
        log_warning "PlantUML already installed"
        return
    fi
    
    # Install Java first if needed
    install_java
    
    if [[ "$OS" == "macos" ]]; then
        brew install plantuml
        # Install Graphviz for better rendering
        brew install graphviz
    elif [[ "$OS" == "ubuntu" ]]; then
        sudo apt install -y plantuml graphviz
    fi
    
    if command_exists plantuml; then
        log_success "PlantUML installed successfully"
        plantuml -version
    else
        log_error "PlantUML installation failed"
        exit 1
    fi
}

# Install Pandoc and dependencies
install_pandoc() {
    log_info "Installing Pandoc..."
    
    if command_exists pandoc; then
        log_warning "Pandoc already installed"
        pandoc --version | head -1
        return
    fi
    
    if [[ "$OS" == "macos" ]]; then
        # Install Pandoc
        brew install pandoc
        
        # Install LaTeX for PDF generation
        log_info "Installing LaTeX (BasicTeX)..."
        brew install --cask basictex
        
        # Install additional dependencies
        brew install librsvg
        brew install --cask font-noto-sans
        brew install --cask font-noto-color-emoji
        
        # Update PATH for LaTeX
        echo 'export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"' >> ~/.zshrc
        export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"
        
    elif [[ "$OS" == "ubuntu" ]]; then
        # Install Pandoc
        sudo apt install -y pandoc
        
        # Install LaTeX for PDF generation
        log_info "Installing LaTeX packages..."
        sudo apt install -y texlive-latex-base texlive-latex-recommended texlive-latex-extra texlive-xetex
        
        # Install additional dependencies
        sudo apt install -y librsvg2-bin fonts-noto fonts-noto-color-emoji imagemagick
    fi
    
    if command_exists pandoc; then
        log_success "Pandoc installed successfully"
        pandoc --version | head -1
    else
        log_error "Pandoc installation failed"
        exit 1
    fi
}

# Test installations
test_installations() {
    log_info "Testing installations..."
    
    # Test Git Flow
    if command_exists git-flow; then
        log_success "✓ Git Flow is working"
    else
        log_error "✗ Git Flow test failed"
    fi
    
    # Test PlantUML
    if command_exists plantuml; then
        log_success "✓ PlantUML is working"
    else
        log_error "✗ PlantUML test failed"
    fi
    
    # Test Pandoc
    if command_exists pandoc; then
        log_success "✓ Pandoc is working"
        
        # Test PDF generation capability
        if command_exists xelatex || command_exists pdflatex; then
            log_success "✓ PDF generation capability available"
        else
            log_warning "⚠ PDF generation may not work (LaTeX not found)"
        fi
    else
        log_error "✗ Pandoc test failed"
    fi
}

# Main installation function
main() {
    log_info "Starting installation of Git Flow, Pandoc, and PlantUML..."
    
    # Detect OS
    detect_os
    
    # Install package manager if needed (macOS)
    if [[ "$OS" == "macos" ]]; then
        install_homebrew
    fi
    
    # Update packages
    update_packages
    
    # Install tools
    install_gitflow
    install_plantuml
    install_pandoc
    
    # Test installations
    test_installations
    
    log_success "Installation completed successfully!"
    echo
    log_info "Next steps:"
    echo "  1. Restart your terminal or run 'source ~/.zshrc' (macOS)"
    echo "  2. Initialize Git Flow in your repository: 'git flow init'"
    echo "  3. Test Pandoc: 'echo \"# Test\" | pandoc -f markdown -t html'"
    echo "  4. Test PlantUML: Create a .puml file and run 'plantuml file.puml'"
    echo
    log_info "For detailed usage instructions, see the documentation in the install/ directory"
}

# Run main function
main "$@"