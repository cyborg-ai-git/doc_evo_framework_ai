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
EMOJI_CONFIG=${EMOJI_CONFIG:-"data/working_emoji.tex"}
PDF_ENGINE=${PDF_ENGINE:-"xelatex"}

# Display loaded configuration
echo "📋 Configuration loaded from $CONFIG_FILE:"
echo "   Version: $VERSION"
echo "   Title: $TITLE"
echo "   Subtitle: $SUBTITLE"
echo "   Author: $AUTHOR"
echo "   Logo: $LOGO"
echo "   Output Dir: $OUTPUT_DIR"
echo "   Template: $TEMPLATE"
echo "   PDF Engine: $PDF_ENGINE"
echo ""

#---------------------------------------------------------------------------------------------------
#sudo apt install -y pandoc texlive-latex-base texlive-xetex librsvg2-bin

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

PATH_INPUT="doc"
PATH_OUTPUT="$OUTPUT_DIR/evo_framework_doc_$VERSION.pdf"

#rm -Rf "$OUTPUT_DIR/*.pdf"

# Build PDF from modular markdown sections
# Each .md file is on a separate line for easy addition/removal
pandoc \
  "$PATH_INPUT/0_abstract.md" \
  "$PATH_INPUT/1_introduction.md" \
  "$PATH_INPUT/2_evo_framework.md" \
  "$PATH_INPUT/3_architecture.md" \
  "$PATH_INPUT/4_software_architecture.md" \
  "$PATH_INPUT/5_evo_principles_adda.md" \
  "$PATH_INPUT/6_evo_framework_next_generation_software_architecture.md" \
  "$PATH_INPUT/7_architectural_layers.md" \
  "$PATH_INPUT/8_control_layer_icontrol.md" \
  "$PATH_INPUT/9_0_evo_api_layer_iapi.md" \
  "$PATH_INPUT/9_1_ai_tokenization.md" \
  "$PATH_INPUT/10_evo_ai_module_iai.md" \
  "$PATH_INPUT/11_evo_api_module_iapi.md" \
  "$PATH_INPUT/12_memory_layer_imemory.md" \
  "$PATH_INPUT/13_memory_management_system_big_o_complexity_analysis.md" \
  "$PATH_INPUT/14_evo_framework_file_storage_strategy.md" \
  "$PATH_INPUT/15_bridge_layer_ibridge.md" \
  "$PATH_INPUT/16_nist_post_quantum_cryptography_standards.md" \
  "$PATH_INPUT/17_cryptographic_signatures_comparison.md" \
  "$PATH_INPUT/18_network_protocols_technologies_comparison.md" \
  "$PATH_INPUT/19_gui_layer_unified_cross_platform_interface_generation.md" \
  "$PATH_INPUT/20_utility_modules.md" \
  "$PATH_INPUT/21_evo_framework_utility_module_documentation.md" \
  "$PATH_INPUT/22_why_rust.md" \
  "$PATH_INPUT/23_conclusion.md" \
  "$PATH_INPUT/24_references.md" \
  "$PATH_INPUT/25_additional_resources.md" \
  -o "$PATH_OUTPUT" \
  --pdf-engine="$PDF_ENGINE" \
  --template="$TEMPLATE" \
  --metadata logo="$LOGO" \
  --metadata title="$TITLE" \
  --metadata subtitle="$SUBTITLE" \
  --metadata author="$AUTHOR" \
  --metadata version="$VERSION" \
  --no-highlight \
  --number-sections \
  --toc \
  --include-in-header="$EMOJI_CONFIG" \
  --pdf-engine-opt=-shell-escape

echo "✅ PDF generated successfully: $PATH_OUTPUT"
#open "$PATH_OUTPUT"
#---------------------------------------------------------------------------------------------------
cd "$CURRENT_DIRECTORY" || exit
#===================================================================================================