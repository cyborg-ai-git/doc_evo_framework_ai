# Pandoc Installation Guide

Pandoc is a universal document converter that can convert between many markup formats. This guide covers installation on macOS and Ubuntu Linux, including all necessary dependencies for PDF generation.

## macOS Installation

### Method 1: Using Homebrew (Recommended)

1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Pandoc**:
   ```bash
   brew install pandoc
   ```

3. **Install LaTeX (for PDF generation)**:
   ```bash
   # Option A: Full MacTeX (large but complete)
   brew install --cask mactex
   
   # Option B: BasicTeX (smaller, minimal installation)
   brew install --cask basictex
   ```

4. **Install additional dependencies**:
   ```bash
   # For SVG support
   brew install librsvg
   
   # For fonts
   brew install --cask font-noto-sans
   brew install --cask font-noto-color-emoji
   ```

5. **Update PATH** (if using BasicTeX):
   ```bash
   echo 'export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

6. **Install additional LaTeX packages** (if needed):
   ```bash
   sudo tlmgr update --self
   sudo tlmgr install adjustbox collectbox
   ```

### Method 2: Manual Installation

1. **Download Pandoc**:
   - Visit [Pandoc releases](https://github.com/jgm/pandoc/releases)
   - Download the macOS installer (.pkg file)
   - Run the installer

2. **Install LaTeX manually**:
   - Download MacTeX from [tug.org](https://tug.org/mactex/)
   - Run the installer

## Ubuntu Linux Installation

### Method 1: Using APT (Recommended)

1. **Update package list**:
   ```bash
   sudo apt update
   ```

2. **Install Pandoc**:
   ```bash
   sudo apt install pandoc
   ```

3. **Install LaTeX (for PDF generation)**:
   ```bash
   # Full TeX Live installation
   sudo apt install texlive-full
   
   # Or minimal installation
   sudo apt install texlive-latex-base texlive-latex-recommended texlive-latex-extra texlive-xetex
   ```

4. **Install additional dependencies**:
   ```bash
   # For SVG support
   sudo apt install librsvg2-bin
   
   # For fonts
   sudo apt install fonts-noto fonts-noto-color-emoji
   
   # Additional tools
   sudo apt install imagemagick
   ```

### Method 2: Using Snap

1. **Install Pandoc via Snap**:
   ```bash
   sudo snap install pandoc
   ```

2. **Install LaTeX**:
   ```bash
   sudo apt install texlive-full
   ```

### Method 3: Latest Version from GitHub

1. **Download latest Pandoc**:
   ```bash
   wget https://github.com/jgm/pandoc/releases/latest/download/pandoc-3.1.9-1-amd64.deb
   sudo dpkg -i pandoc-3.1.9-1-amd64.deb
   ```

2. **Install dependencies**:
   ```bash
   sudo apt install -f
   ```

## Verification

### Test Pandoc Installation
```bash
# Check version
pandoc --version

# Test basic conversion
echo "# Hello World" | pandoc -f markdown -t html
```

### Test PDF Generation
```bash
# Create a test markdown file
echo "# Test Document

This is a test document for PDF generation.

## Features
- Markdown to PDF conversion
- LaTeX support
- Font rendering" > test.md

# Convert to PDF
pandoc test.md -o test.pdf --pdf-engine=xelatex

# Open the PDF (macOS)
open test.pdf

# Open the PDF (Ubuntu)
xdg-open test.pdf
```

## Common PDF Generation Options

### Basic PDF Generation
```bash
pandoc input.md -o output.pdf
```

### Advanced PDF Generation
```bash
pandoc input.md -o output.pdf \
  --pdf-engine=xelatex \
  --template=template.tex \
  --toc \
  --number-sections \
  --highlight-style=github
```

### With Custom Fonts
```bash
pandoc input.md -o output.pdf \
  --pdf-engine=xelatex \
  --variable mainfont="Noto Sans" \
  --variable monofont="Noto Sans Mono"
```

## Troubleshooting

### Common Issues

1. **LaTeX not found**:
   ```bash
   # Check if LaTeX is in PATH
   which xelatex
   
   # Add to PATH if needed (macOS)
   export PATH="/usr/local/texlive/2025/bin/universal-darwin:$PATH"
   ```

2. **Missing LaTeX packages**:
   ```bash
   # Install missing packages
   sudo tlmgr install package-name
   
   # Update all packages
   sudo tlmgr update --all
   ```

3. **Font issues**:
   ```bash
   # List available fonts
   fc-list | grep -i noto
   
   # Refresh font cache
   fc-cache -f -v
   ```

4. **SVG conversion issues**:
   ```bash
   # Check if rsvg-convert is available
   which rsvg-convert
   
   # Install if missing (Ubuntu)
   sudo apt install librsvg2-bin
   
   # Install if missing (macOS)
   brew install librsvg
   ```

### Memory Issues
For large documents, increase memory:
```bash
pandoc large-doc.md -o output.pdf --pdf-engine-opt=-interaction=nonstopmode
```

## Templates and Styling

### Using Custom Templates
```bash
# Download a template
curl -L -o template.tex https://example.com/template.tex

# Use the template
pandoc input.md -o output.pdf --template=template.tex
```

### CSS for HTML Output
```bash
pandoc input.md -o output.html --css=style.css
```

## Integration Examples

### Batch Processing
```bash
# Convert all markdown files to PDF
for file in *.md; do
    pandoc "$file" -o "${file%.md}.pdf" --pdf-engine=xelatex
done
```

### With Makefile
```makefile
%.pdf: %.md
	pandoc $< -o $@ --pdf-engine=xelatex --toc

all: $(patsubst %.md,%.pdf,$(wildcard *.md))
```

## Additional Resources

- [Pandoc User's Guide](https://pandoc.org/MANUAL.html)
- [Pandoc Templates](https://github.com/jgm/pandoc-templates)
- [LaTeX Font Catalog](https://tug.org/FontCatalogue/)
- [Pandoc Filters](https://pandoc.org/filters.html)

For more advanced usage and customization options, refer to the official Pandoc documentation.