#!/bin/bash

# exifGMTfixer - A command line script that invokes exiftool to write timezone data to image files
# Usage: exifGMTfixer [OPTIONS] filename(s)
# OPTIONS:
#   --timezoneoffset OFFSET    Set timezone offset (e.g., +01:00, -05:00)
#   --resettimezone            Reset timezone to UTC (+00:00)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: exifGMTfixer [OPTIONS] filename(s)"
    echo ""
    echo "OPTIONS:"
    echo "  --timezoneoffset OFFSET    Set timezone offset (e.g., +01:00)"
    echo "  --resettimezone            Reset timezone to UTC (+00:00)"
    echo ""
    echo "Note: --timezoneoffset and --resettimezone cannot be used together."
    exit 1
}

# Function to display error
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to display success
success() {
    echo -e "${GREEN}Success: $1${NC}"
}

# Function to display warning
warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
    error "exiftool is not installed. Please install exiftool and try again."
fi

# Initialize variables
OPTION=""
OFFSET=""
FILES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --timezoneoffset)
            if [[ -n "$OPTION" ]]; then
                error "--timezoneoffset and --resettimezone cannot be used together."
            fi
            OPTION="timezoneoffset"
            OFFSET="$2"
            shift 2
            ;;
        --resettimezone)
            if [[ -n "$OPTION" ]]; then
                error "--timezoneoffset and --resettimezone cannot be used together."
            fi
            OPTION="resettimezone"
            OFFSET="+00:00"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

# Validation
if [[ -z "$OPTION" ]]; then
    error "No option specified. Use --timezoneoffset or --resettimezone."
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    error "No files specified."
fi

# Validate timezone offset format if using --timezoneoffset
if [[ "$OPTION" == "timezoneoffset" ]]; then
    if ! [[ "$OFFSET" =~ ^[+-][0-9]{2}:[0-9]{2}$ ]]; then
        error "Invalid timezone offset format. Use format like +01:00 or -05:00"
    fi
fi

# Execute exiftool command
echo "Processing ${#FILES[@]} file(s) with timezone offset: $OFFSET"

exiftool -overwrite_original \
    -OffsetTimeOriginal="$OFFSET" \
    -OffsetTime="$OFFSET" \
    -OffsetTimeDigitized="$OFFSET" \
    "${FILES[@]}"

# Check if exiftool succeeded
if [[ $? -eq 0 ]]; then
    success "Timezone data updated successfully for ${#FILES[@]} file(s)."
else
    error "exiftool command failed."
fi
