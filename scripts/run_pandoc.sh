#!/bin/bash
#===================================================================================================
# CyborgAI
# CC BY-NC-ND 4.0 Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
# github: https://github.com/cyborg-ai-git
#===================================================================================================
DIRECTORY_BASE=$(dirname "$(realpath "$0")")
PACKAGE_NAME="$(basename "$(pwd)")"
#---------------------------------------------------------------------------------------------------
clear
#---------------------------------------------------------------------------------------------------
CURRENT_TIME=$(date +"%Y.%-m.%-d%H%M")
CURRENT_DIRECTORY=$(pwd)
#---------------------------------------------------------------------------------------------------
cd "$DIRECTORY_BASE" || exit
cd ..
#---------------------------------------------------------------------------------------------------
echo "🟢 $CURRENT_TIME - RUN PANDOC EXPORT: $PACKAGE_NAME"
#---------------------------------------------------------------------------------------------------

# Read configuration from config.toml
CONFIG_FILE="config.toml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: config.toml not found!"
    exit 1
fi

# Parse TOML values (simple approach for basic key-value pairs)
VERSION=$(grep '^version' "$CONFIG_FILE" | sed 's/version = "\(.*\)"/\1/')
TITLE=$(grep '^title' "$CONFIG_FILE" | sed 's/title = "\(.*\)"/\1/')
SUBTITLE=$(grep '^subtitle' "$CONFIG_FILE" | sed 's/subtitle = "\(.*\)"/\1/')
AUTHOR=$(grep '^author' "$CONFIG_FILE" | sed 's/author = "\(.*\)"/\1/')
LOGO=$(grep '^logo' "$CONFIG_FILE" | sed 's/logo = "\(.*\)"/\1/')
OUTPUT_DIR=$(grep '^output_dir' "$CONFIG_FILE" | sed 's/output_dir = "\(.*\)"/\1/')
TEMPLATE=$(grep '^template' "$CONFIG_FILE" | sed 's/template = "\(.*\)"/\1/')
EMOJI_CONFIG=$(grep '^emoji_config' "$CONFIG_FILE" | sed 's/emoji_config = "\(.*\)"/\1/')
PDF_ENGINE=$(grep '^pdf_engine' "$CONFIG_FILE" | sed 's/pdf_engine = "\(.*\)"/\1/')
MAINFONT=$(grep '^mainfont' "$CONFIG_FILE" | sed 's/mainfont = "\(.*\)"/\1/')
MATHFONT=$(grep '^mathfont' "$CONFIG_FILE" | sed 's/mathfont = "\(.*\)"/\1/')
CJKMAINFONT=$(grep '^CJKmainfont' "$CONFIG_FILE" | sed 's/CJKmainfont = "\(.*\)"/\1/')
CJKMONOFONT=$(grep '^CJKmonofont' "$CONFIG_FILE" | sed 's/CJKmonofont = "\(.*\)"/\1/')

# Validate required configuration values
if [ -z "$VERSION" ] || [ -z "$TITLE" ] || [ -z "$AUTHOR" ]; then
    echo "❌ Error: Missing required configuration values in $CONFIG_FILE"
    echo "   Required: version, title, author"
    exit 1
fi

# Set defaults for optional values
SUBTITLE=${SUBTITLE:-"Documentation"}
LOGO=${LOGO:-"./data/logo.png"}
OUTPUT_DIR=${OUTPUT_DIR:-"./output"}
TEMPLATE=${TEMPLATE:-"data/dark.tex"}
# Platform-specific emoji configuration (override config file setting)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    EMOJI_CONFIG="data/emoji_macos.tex"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    EMOJI_CONFIG="data/emoji_linux.tex"
else
    # Fallback - use config file setting or default
    EMOJI_CONFIG=${EMOJI_CONFIG:-"data/working_emoji.tex"}
fi
PDF_ENGINE=${PDF_ENGINE:-"lualatex"}

# Display loaded configuration
echo "📋 Configuration loaded from $CONFIG_FILE:"
echo "   Version: $VERSION"
echo "   Title: $TITLE"
echo "   Subtitle: $SUBTITLE"
echo "   Author: $AUTHOR"
echo "   Emoji Config: $EMOJI_CONFIG"
echo "   Logo: $LOGO"
echo "   Output Dir: $OUTPUT_DIR"
echo "   Template: $TEMPLATE"
echo "   PDF Engine: $PDF_ENGINE"
echo "   Main Font: $MAINFONT"
echo "   Math Font: $MATHFONT"
echo "   CJK Main Font: $CJKMAINFONT"
echo "   CJK Mono Font: $CJKMONOFONT"
echo ""

#---------------------------------------------------------------------------------------------------
#sudo apt install -y pandoc texlive-latex-base texlive-xetex librsvg2-bin

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

PATH_INPUT="doc"
PATH_OUTPUT="$OUTPUT_DIR/evo_framework_doc_$VERSION.pdf"

#rm -Rf "$OUTPUT_DIR/*.pdf"

rm -f "$PATH_OUTPUT"

pandoc \
  $PATH_INPUT/*.md \
  -o "$PATH_OUTPUT" \
  --pdf-engine="$PDF_ENGINE" \
  --template="$TEMPLATE" \
  --metadata logo="$LOGO" \
  --metadata title="$TITLE" \
  --metadata subtitle="$SUBTITLE" \
  --metadata author="$AUTHOR" \
  --metadata version="$VERSION" \
  --variable geometry:left=1.5cm \
  --variable geometry:right=1.5cm \
  --variable geometry:top=2cm \
  --variable geometry:bottom=2cm \
  --no-highlight \
  --number-sections \
  --toc \
  --include-in-header="$EMOJI_CONFIG" \
  --variable mainfont="$MAINFONT" \
  --variable mathfont="$MATHFONT" \
  --variable CJKmainfont="$CJKMAINFONT" \
  --variable CJKmonofont="$CJKMONOFONT" \
  --pdf-engine-opt=-shell-escape

PANDOC_EXIT_CODE=$?

if [ $PANDOC_EXIT_CODE -eq 0 ] && [ -f "$PATH_OUTPUT" ]; then
    echo "✅ PDF generated successfully: $PATH_OUTPUT"
    # open "$PATH_OUTPUT" # Commented out as we are in an agent environment
else
    echo "❌ Error: PDF generation failed with exit code $PANDOC_EXIT_CODE"
    exit 1
fi

  rm -Rf "../luatex.*"
#---------------------------------------------------------------------------------------------------
cd "$CURRENT_DIRECTORY" || exit
#===================================================================================================
