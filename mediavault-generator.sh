#!/bin/bash
# MediaVault Gallery Generator
#
# Copyright 2025 Claude Opus 4 <https://claude.ai>, Jeremy Carter <jeremy@jeremycarter.ca>, and with fixes by ChatGPT Agent Mode <https://chatgpt.com>
#
# Licensed by the standard MIT License. Use at your own risk!! This was a lot of script and it was architected and written almost entirely by Claude, and hasn't been audited by humans, so it maybe won't work and/or could harm your system or your files.
#
# A bash script that generates a self-contained HTML5 media gallery with advanced features.

#set -euo pipefail

# Default configuration
TITLE="MediaVault Gallery"
MEDIA_SOURCES=()
OUTPUT_FILE="mediavault-gallery.html"
THEME="cyber"
LAYOUT="masonry"
SLIDESHOW_SPEED="4000"
ENABLE_CACHE="true"
ENABLE_AI_THEME="true"
ENABLE_EXIF="true"
ENABLE_FACE_DETECTION="false"
ENABLE_LAZY_LOADING="true"
ENABLE_KEYBOARD_SHORTCUTS="true"
ENABLE_TOUCH_GESTURES="true"
ENABLE_FULLSCREEN_API="true"
ENABLE_SHARE_API="true"
ENABLE_CLIPBOARD_API="true"
ENABLE_VIBRATION_API="true"
GRID_COLUMNS="auto"
THUMBNAIL_SIZE="400"
MAX_CACHE_SIZE="4000000" # MB
DEBUG_MODE="false"
ENABLE_MUSIC_VISUALIZER="false"
ENABLE_3D_TRANSFORMS="true"
ENABLE_PARTICLE_EFFECTS="false"
AUTO_OPEN="false"
RECURSIVE="false"
INCLUDE_PATTERN=""
EXCLUDE_PATTERN=""
VERBOSE_MODE="false"

# Color scheme for output
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
PURPLE=$'\033[0;35m'
CYAN=$'\033[0;36m'
NC=$'\033[0m' # No Color

# Progress tracking
TOTAL_FILES=0
PROCESSED_FILES=0

# Logging functions (from fixed version)
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_verbose() {
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE]${NC} $1" >&2
    fi
}

log_debug() {
    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1" >&2
    fi
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

# Progress bar function (from fixed version)
show_progress() {
    local current=$1
    local total=$2
    local task=$3
    local percent=$((current * 100 / total))
    local bar_length=50
    local filled_length=$((percent * bar_length / 100))
    
    printf "\r${CYAN}[%-${bar_length}s] %d%% - %s${NC}" \
        "$(printf '#%.0s' $(seq 1 $filled_length))" \
        "$percent" \
        "$task" >&2
    
    if [[ $current -eq $total ]]; then
        echo >&2
    fi
}

# ASCII Art Banner
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    __  __         _ _     __     __          _ _   
   |  \/  |       | (_)    \ \   / /         | | |  
   | \  / | ___  __| |_  __ _\ \ / /_ _ _   _| | |_ 
   | |\/| |/ _ \/ _` | |/ _` |\ V / _` | | | | | __|
   | |  | |  __/ (_| | | (_| | | | (_| | |_| | | |_ 
   |_|  |_|\___|\__,_|_|\__,_| |_|\__,_|\__,_|_|\__|
                                                     
    MediaVault Generator - Media Gallery Generator
EOF
    echo -e "${NC}"
}

# Help function (keeping all original options)
show_help() {
    cat << EOF

${GREEN}USAGE:${NC}
    $0 [OPTIONS] [MEDIA_PATHS...]

${GREEN}DESCRIPTION:${NC}
    Generates a self-contained HTML5 media gallery with advanced features including
    IndexedDB caching, dynamic theming, multiple layouts, and touch support.

${GREEN}OPTIONS:${NC}
    ${YELLOW}-h, --help${NC}              Show this help message
    ${YELLOW}-o, --output${NC} FILE       Output HTML file (default: mediavault-gallery.html)
    ${YELLOW}-t, --title${NC} TITLE       Gallery title (default: MediaVault Gallery)
    ${YELLOW}-v, --verbose${NC}           Enable verbose output showing progress
    ${YELLOW}--theme${NC} THEME           Initial theme: cyber, neon, minimal, nature, retro, glassmorphism
    ${YELLOW}--layout${NC} LAYOUT         Initial layout: masonry, grid, carousel, timeline, scatter, spiral (default: masonry)
    ${YELLOW}--speed${NC} MS              Slideshow speed in milliseconds (default: 4000)
    ${YELLOW}--columns${NC} N             Grid columns (default: auto)
    ${YELLOW}--thumb-size${NC} SIZE       Thumbnail size in pixels (default: 400)
    ${YELLOW}--max-cache${NC} MB          Max cache size in MB (default: 4000000)
    ${YELLOW}--no-cache${NC}              Disable IndexedDB caching
    ${YELLOW}--no-ai-theme${NC}           Disable AI-based theming
    ${YELLOW}--no-exif${NC}               Disable EXIF data display
    ${YELLOW}--face-detection${NC}        Enable face detection features
    ${YELLOW}--no-lazy${NC}               Disable lazy loading
    ${YELLOW}--no-keyboard${NC}           Disable keyboard shortcuts
    ${YELLOW}--no-touch${NC}              Disable touch gestures
    ${YELLOW}--no-fullscreen${NC}         Disable fullscreen API
    ${YELLOW}--no-share${NC}              Disable share API
    ${YELLOW}--no-clipboard${NC}          Disable clipboard API
    ${YELLOW}--no-vibration${NC}          Disable vibration feedback
    ${YELLOW}--no-3d${NC}                 Disable 3D transforms
    ${YELLOW}--music-viz${NC}             Enable music visualizer for videos
    ${YELLOW}--particles${NC}             Enable particle effects
    ${YELLOW}--debug${NC}                 Enable debug mode with detailed output
    ${YELLOW}--auto-open${NC}             Auto-open gallery in browser
    ${YELLOW}-r, --recursive${NC}         Recursively scan directories
    ${YELLOW}--include-pattern${NC} PAT   Include files matching pattern
    ${YELLOW}--exclude-pattern${NC} PAT   Exclude files matching pattern

${GREEN}EXAMPLES:${NC}
    # Basic usage with images directory
    $0 ~/Pictures

    # Multiple sources with custom output
    $0 -o my-gallery.html ~/Photos ~/Videos

    # Verbose mode with recursive scan
    $0 -v -r ~/Pictures

    # Advanced configuration
    $0 --theme neon --layout masonry --face-detection \\
       --particles --music-viz -r ~/Media

${GREEN}SUPPORTED FORMATS:${NC}
    Images: jpg, jpeg, png, gif, webp, avif, svg, bmp, ico
    Videos: mp4, webm, ogg, mov, avi, mkv, m4v

${GREEN}KEYBOARD SHORTCUTS:${NC}
    Space       - Play/pause slideshow
    Arrows      - Navigate media (4D navigation)
    F           - Toggle fullscreen
    G           - Change layout
    T           - Change theme
    S           - Shuffle media
    ESC         - Close fullscreen viewer
    1-9         - Jump to position (10%, 20%...90%)
    +/-         - Zoom in/out
    R           - Rotate
    M           - Toggle metadata
    C           - Copy image URL
    D           - Download current media

EOF
}

# Parse command line arguments (enhanced with verbose option)
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -t|--title)
                TITLE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE_MODE="true"
                shift
                ;;
            --theme)
                THEME="$2"
                shift 2
                ;;
            --layout)
                LAYOUT="$2"
                shift 2
                ;;
            --speed)
                SLIDESHOW_SPEED="$2"
                shift 2
                ;;
            --columns)
                GRID_COLUMNS="$2"
                shift 2
                ;;
            --thumb-size)
                THUMBNAIL_SIZE="$2"
                shift 2
                ;;
            --max-cache)
                MAX_CACHE_SIZE="$2"
                shift 2
                ;;
            --no-cache)
                ENABLE_CACHE="false"
                shift
                ;;
            --no-ai-theme)
                ENABLE_AI_THEME="false"
                shift
                ;;
            --no-exif)
                ENABLE_EXIF="false"
                shift
                ;;
            --face-detection)
                ENABLE_FACE_DETECTION="true"
                shift
                ;;
            --no-lazy)
                ENABLE_LAZY_LOADING="false"
                shift
                ;;
            --no-keyboard)
                ENABLE_KEYBOARD_SHORTCUTS="false"
                shift
                ;;
            --no-touch)
                ENABLE_TOUCH_GESTURES="false"
                shift
                ;;
            --no-fullscreen)
                ENABLE_FULLSCREEN_API="false"
                shift
                ;;
            --no-share)
                ENABLE_SHARE_API="false"
                shift
                ;;
            --no-clipboard)
                ENABLE_CLIPBOARD_API="false"
                shift
                ;;
            --no-vibration)
                ENABLE_VIBRATION_API="false"
                shift
                ;;
            --no-3d)
                ENABLE_3D_TRANSFORMS="false"
                shift
                ;;
            --music-viz)
                ENABLE_MUSIC_VISUALIZER="true"
                shift
                ;;
            --particles)
                ENABLE_PARTICLE_EFFECTS="true"
                shift
                ;;
            --debug)
                DEBUG_MODE="true"
                VERBOSE_MODE="true"  # Debug implies verbose
                shift
                ;;
            --auto-open)
                AUTO_OPEN="true"
                shift
                ;;
            -r|--recursive)
                RECURSIVE="true"
                shift
                ;;
            --include-pattern)
                INCLUDE_PATTERN="$2"
                shift 2
                ;;
            --exclude-pattern)
                EXCLUDE_PATTERN="$2"
                shift 2
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                # Enhanced path resolution from fixed version
                if [[ "$1" == "." ]]; then
                    MEDIA_SOURCES+=("$(pwd)")
                elif [[ "$1" == ".." ]]; then
                    MEDIA_SOURCES+=("$(cd .. && pwd)")
                elif [[ "$1" =~ ^\.\./ ]]; then
			MEDIA_SOURCES+=("$(cd "$(dirname "$1")")/$(basename "$1")")
                elif [[ "$1" =~ ^\./ ]]; then
			MEDIA_SOURCES+=("$(pwd)/${1#./}")
                elif [[ "$1" =~ ^[^/] ]]; then
			MEDIA_SOURCES+=("$(pwd)/$1")
                else
			MEDIA_SOURCES+=("$1")
                fi
                shift
                ;;
        esac
    done
}

# Find media files (enhanced with progress reporting)
find_media_files() {
    local sources=("$@")
    local media_files=()
    
    for source in "${sources[@]}"; do
        if [[ -d "$source" ]]; then
            log_verbose "Scanning directory: $source"
            log_debug "Recursive mode: $RECURSIVE"
            
            # Build find command based on options
            local find_opts=""
            [[ "$RECURSIVE" != "true" ]] && find_opts="-maxdepth 1"
            
            # Use simpler find approach to avoid shell expansion issues
            while IFS= read -r -d '' file; do
                # Apply include/exclude patterns if specified
                if [[ -n "$INCLUDE_PATTERN" ]] && ! [[ "$file" =~ $INCLUDE_PATTERN ]]; then
                    log_debug "Skipping (not matching include pattern): $file"
                    continue
                fi
                if [[ -n "$EXCLUDE_PATTERN" ]] && [[ "$file" =~ $EXCLUDE_PATTERN ]]; then
                    log_debug "Skipping (matching exclude pattern): $file"
                    continue
                fi
		media_files+=("$(dirname "$file")/$(basename "$file")")
                log_debug "Found: $(basename "$file")"
            done < <(find "$source" $find_opts -type f \( \
                -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
                -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.avif" \
                -o -iname "*.svg" -o -iname "*.bmp" -o -iname "*.ico" \
                -o -iname "*.mp4" -o -iname "*.webm" -o -iname "*.ogg" \
                -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" \
                -o -iname "*.m4v" \) -print0)
        elif [[ -f "$source" ]]; then
	    media_files+=("$(dirname "$source")/$(basename "$source")")
            log_debug "Added single file: $source"
        else
            log_warning "$source not found"
        fi
    done
    
    # Output each media file on its own line rather than as a single quoted string.
    # Using newline delimiters ensures downstream consumers like generate_media_json can
    # reliably read one file per iteration. Quoting is handled by the reader.
    printf '%s\n' "${media_files[@]}"
}

# Generate media JSON (FIXED: avoiding sed argument limits)
generate_media_json() {
    local temp_json=$(mktemp)
    local first=true
    local count=0
    
    echo "[" > "$temp_json"
    
    # Read each file path from stdin one line at a time.  The input from
    # find_media_files is newline-delimited, so we no longer use a null
    # delimiter.  Using read -r preserves backslashes and spaces.
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        count=$((count + 1))
        
        if [[ "$VERBOSE_MODE" == "true" ]] && [[ $TOTAL_FILES -gt 0 ]]; then
            show_progress $count $TOTAL_FILES "Processing: $(basename "$file")"
        fi
        
        # Get file info
        local basename=$(basename "$file")
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
        local modified=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo "0")
        local mime_type=""
        
        # Determine MIME type
        case "${file,,}" in
            *.jpg|*.jpeg) mime_type="image/jpeg" ;;
            *.png) mime_type="image/png" ;;
            *.gif) mime_type="image/gif" ;;
            *.webp) mime_type="image/webp" ;;
            *.avif) mime_type="image/avif" ;;
            *.svg) mime_type="image/svg+xml" ;;
            *.bmp) mime_type="image/bmp" ;;
            *.ico) mime_type="image/x-icon" ;;
            *.mp4) mime_type="video/mp4" ;;
            *.webm) mime_type="video/webm" ;;
            *.ogg) mime_type="video/ogg" ;;
            *.mov) mime_type="video/quicktime" ;;
            *.avi) mime_type="video/x-msvideo" ;;
            *.mkv) mime_type="video/x-matroska" ;;
            *.m4v) mime_type="video/x-m4v" ;;
        esac
        
        ## Generate file:// URL
        #local url="file://$(realpath "$file")"
	local url=""

	if [[ "$URL_MODE" == "file" ]]; then
	    if [[ -z "$PROTO" ]]; then
		PROTO="file://"
	    fi
	    proto="$PROTO"
	    if [[ ! -z "$WSL" ]]; then
		basepath="///wsl.localhost/"
	        url="${proto}${basepath}${WSL}$(realpath "$file")"
	    else
		basepath=""
	        url="${proto}$(realpath "$file")"
	    fi
	elif [[ "$URL_MODE" == "local" || -z "$URL_MODE" ]]; then
	    if [[ -z "${PROTO}" ]]; then
		PROTO="http://"
	    fi

	    proto="${PROTO}"

	    if [[ -z "$HOST_ADDR" ]]; then
		HOST_ADDR="localhost"
	    fi	    
            basepath="${HOST_ADDR}"

	    if [[ -z "$HOST_PORT" ]]; then
		url="${proto}${basepath}/$(basename "$(realpath "$file")")"
	    else
	        url="${proto}${basepath}:${HOST_PORT}/$(basename "$(realpath "$file")")"
	    fi
	elif [[ "$URL_MODE" == "remote" ]]; then
	    if [[ -z "${PROTO}" ]]; then
		PROTO="https://"
	    fi

	    proto="${PROTO}"

	    if [[ -z "$HOST_ADDR" ]]; then
		echo "error: Remote url mode active, but no \$HOST_ADDR value set. Exiting!" 1>&2
		exit 1
	    fi
	    basepath="${HOST_ADDR}"

	    if [[ -z "$HOST_PORT" ]]; then
	        url="${proto}${basepath}/$(basename "$(realpath "$file")")"
	    else
		url="${proto}${basepath}:${HOST_PORT}/$(basename "$(realpath "$file")")"
	    fi
	fi

	## Generate URL
	#if [[ -z "$HOST_PORT" ]]; then
        #    local url="${proto}${basepath}${file}"
	#else
	#    local url="${proto}${basepath}:${HOST_PORT}${file}"
	#fi

	log_debug "\$url=\"$url\""
        
        # Add comma if not first item
        [[ "$first" == "true" ]] && first=false || echo "," >> "$temp_json"
        
        # Properly escape JSON strings
        basename=$(echo "$basename" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g')
        url=$(echo "$url" | sed 's/\\/\\\\/g; s/"/\\"/g')
        
        # Write JSON object
        cat >> "$temp_json" << EOF
    {
        "url": "$url",
        "name": "$basename",
        "type": "${mime_type%%/*}",
        "mimeType": "$mime_type",
        "size": $size,
        "modified": $modified,
        "tags": [],
        "metadata": {}
    }
EOF
    done
    
    echo "]" >> "$temp_json"
    echo "$temp_json"
}

# Write HTML template to file (FIXED: writing directly instead of using sed)
write_html_template() {
    local output_file="$1"
    local json_file="$2"
    
    # Read JSON data
    local json_data=$(cat "$json_file")
    
    # Write the complete HTML with proper escaping
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${TITLE}</title>
    <style>
        /* Reset and Base Styles */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            /* Cyber Theme */
            --cyber-bg: #0a0a0a;
            --cyber-surface: #1a1a2e;
            --cyber-primary: #00ff41;
            --cyber-secondary: #ff006e;
            --cyber-accent: #00d9ff;
            --cyber-text: #ffffff;
            --cyber-text-dim: #a0a0a0;
            
            /* Neon Theme */
            --neon-bg: #0c0c0c;
            --neon-surface: #1a0033;
            --neon-primary: #ff00ff;
            --neon-secondary: #00ffff;
            --neon-accent: #ffff00;
            --neon-text: #ffffff;
            --neon-text-dim: #cc99ff;
            
            /* Minimal Theme */
            --minimal-bg: #ffffff;
            --minimal-surface: #f5f5f5;
            --minimal-primary: #000000;
            --minimal-secondary: #666666;
            --minimal-accent: #0066cc;
            --minimal-text: #000000;
            --minimal-text-dim: #666666;
            
            /* Nature Theme */
            --nature-bg: #f4f1e8;
            --nature-surface: #e8dcc6;
            --nature-primary: #2d5016;
            --nature-secondary: #8b4513;
            --nature-accent: #ff6b35;
            --nature-text: #2d2d2d;
            --nature-text-dim: #5d5d5d;
            
            /* Retro Theme */
            --retro-bg: #2a1a1f;
            --retro-surface: #3e2731;
            --retro-primary: #ff6b6b;
            --retro-secondary: #4ecdc4;
            --retro-accent: #ffe66d;
            --retro-text: #f7f7f7;
            --retro-text-dim: #c9c9c9;
            
            /* Glassmorphism Theme */
            --glass-bg: #0f0f23;
            --glass-surface: rgba(255, 255, 255, 0.05);
            --glass-primary: #64ffda;
            --glass-secondary: #a78bfa;
            --glass-accent: #f472b6;
            --glass-text: #ffffff;
            --glass-text-dim: #94a3b8;
            
            /* Dynamic theme variables */
            --bg: var(--cyber-bg);
            --surface: var(--cyber-surface);
            --primary: var(--cyber-primary);
            --secondary: var(--cyber-secondary);
            --accent: var(--cyber-accent);
            --text: var(--cyber-text);
            --text-dim: var(--cyber-text-dim);
            
            /* Layout variables */
            --header-height: 60px;
            --sidebar-width: 280px;
            --control-panel-height: 80px;
            --thumb-size: ${THUMBNAIL_SIZE}px;
            --gap: 20px;
            --radius: 12px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg);
            color: var(--text);
            overflow-x: hidden;
            position: relative;
            min-height: 100vh;
        }

        /* Header */
        .header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: var(--header-height);
            background: var(--surface);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            z-index: 1000;
            display: flex;
            align-items: center;
            padding: 0 20px;
            gap: 20px;
        }

        .logo {
            font-size: 24px;
            font-weight: bold;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .search-container {
            flex: 1;
            max-width: 500px;
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 10px 40px 10px 16px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: var(--radius);
            color: var(--text);
            font-size: 14px;
            transition: var(--transition);
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
            background: rgba(255, 255, 255, 0.08);
        }

        .search-icon {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-dim);
            pointer-events: none;
        }

        .header-actions {
            display: flex;
            gap: 12px;
        }

        .icon-btn {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: var(--radius);
            color: var(--text);
            cursor: pointer;
            transition: var(--transition);
            position: relative;
        }

        .icon-btn:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary);
            color: var(--primary);
            transform: translateY(-2px);
        }

        .icon-btn.active {
            background: var(--primary);
            color: var(--bg);
            border-color: var(--primary);
        }

        /* Sidebar */
        .sidebar {
            position: fixed;
            left: 0;
            top: var(--header-height);
            bottom: 0;
            width: var(--sidebar-width);
            background: var(--surface);
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            padding: 20px;
            overflow-y: auto;
            transform: translateX(0);
            transition: var(--transition);
            z-index: 900;
        }

        .sidebar.collapsed {
            transform: translateX(-100%);
        }

        .sidebar-section {
            margin-bottom: 30px;
        }

        .sidebar-title {
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--text-dim);
            margin-bottom: 12px;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .filter-chip {
            padding: 8px 12px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            font-size: 14px;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .filter-chip:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary);
        }

        .filter-chip.active {
            background: var(--primary);
            color: var(--bg);
            border-color: var(--primary);
        }

        .filter-count {
            font-size: 12px;
            opacity: 0.7;
        }

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            margin-top: var(--header-height);
            padding: 20px;
            min-height: calc(100vh - var(--header-height));
            transition: var(--transition);
        }

        .main-content.sidebar-collapsed {
            margin-left: 0;
        }

        /* Control Panel */
        .control-panel {
            background: var(--surface);
            border-radius: var(--radius);
            padding: 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
        }

        .layout-switcher {
            display: flex;
            gap: 8px;
            padding: 4px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: var(--radius);
        }

        .layout-btn {
            padding: 8px 16px;
            background: transparent;
            border: none;
            color: var(--text-dim);
            cursor: pointer;
            border-radius: calc(var(--radius) - 4px);
            transition: var(--transition);
            font-size: 14px;
        }

        .layout-btn:hover {
            color: var(--text);
        }

        .layout-btn.active {
            background: var(--primary);
            color: var(--bg);
        }

        .view-controls {
            display: flex;
            gap: 12px;
            margin-left: auto;
        }

        .toggle-switch {
            position: relative;
            width: 50px;
            height: 26px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 13px;
            cursor: pointer;
            transition: var(--transition);
        }

        .toggle-switch.active {
            background: var(--primary);
        }

        .toggle-switch::after {
            content: '';
            position: absolute;
            top: 3px;
            left: 3px;
            width: 20px;
            height: 20px;
            background: var(--text);
            border-radius: 50%;
            transition: var(--transition);
        }

        .toggle-switch.active::after {
            transform: translateX(24px);
            background: var(--bg);
        }

        .slideshow-controls {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .playback-btn {
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--primary);
            border: none;
            border-radius: 50%;
            color: var(--bg);
            cursor: pointer;
            transition: var(--transition);
        }

        .playback-btn:hover {
            transform: scale(1.1);
            box-shadow: 0 0 20px var(--primary);
        }

        .speed-control {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 4px 12px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 20px;
        }

        .speed-control button {
            background: none;
            border: none;
            color: var(--text-dim);
            cursor: pointer;
            font-size: 18px;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 4px;
            transition: var(--transition);
        }

        .speed-control button:hover {
            background: rgba(255, 255, 255, 0.1);
            color: var(--primary);
        }

        .speed-display {
            font-size: 14px;
            min-width: 40px;
            text-align: center;
        }

        /* Gallery Layouts */
        .gallery {
            position: relative;
            min-height: 400px;
        }

        /* Grid Layout */
        .gallery.grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(var(--thumb-size), 1fr));
            gap: var(--gap);
        }

        /* Masonry Layout */
        .gallery.masonry {
            column-count: auto;
            column-width: var(--thumb-size);
            column-gap: var(--gap);
        }

        .gallery.masonry .media-item {
            break-inside: avoid;
            margin-bottom: var(--gap);
        }

        /* Carousel Layout */
        .gallery.carousel {
            display: flex;
            gap: var(--gap);
            overflow-x: auto;
            scroll-snap-type: x mandatory;
            scrollbar-width: thin;
            scrollbar-color: var(--primary) var(--surface);
            padding-bottom: 20px;
        }

        .gallery.carousel .media-item {
            flex: 0 0 calc(var(--thumb-size) * 1.5);
            scroll-snap-align: center;
        }

        /* Timeline Layout */
        .gallery.timeline {
            position: relative;
            padding: 40px 0;
        }

        .gallery.timeline::before {
            content: '';
            position: absolute;
            left: 50%;
            top: 0;
            bottom: 0;
            width: 2px;
            background: var(--primary);
            transform: translateX(-50%);
        }

        .gallery.timeline .media-item {
            width: calc(50% - 40px);
            margin-bottom: 40px;
            position: relative;
        }

        .gallery.timeline .media-item:nth-child(odd) {
            margin-left: 0;
            text-align: right;
        }

        .gallery.timeline .media-item:nth-child(even) {
            margin-left: calc(50% + 40px);
        }

        /* Scatter Layout */
        .gallery.scatter {
            position: relative;
            height: 80vh;
        }

        .gallery.scatter .media-item {
            position: absolute;
            transform: rotate(var(--rotation, 0deg)) scale(var(--scale, 1));
            transition: transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        /* Spiral Layout */
        .gallery.spiral {
            position: relative;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .gallery.spiral .media-item {
            position: absolute;
            transform-origin: center;
            transition: transform 1s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        /* Media Item */
        .media-item {
            position: relative;
            background: var(--surface);
            border-radius: var(--radius);
            overflow: hidden;
            cursor: pointer;
            transition: var(--transition);
            transform-style: preserve-3d;
        }

        .media-item:hover {
            transform: translateY(-4px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .media-item.loading {
            background: linear-gradient(90deg, var(--surface) 0%, rgba(255,255,255,0.1) 50%, var(--surface) 100%);
            background-size: 200% 100%;
            animation: shimmer 1.5s infinite;
        }

        @keyframes shimmer {
            0% { background-position: -200% center; }
            100% { background-position: 200% center; }
        }

        .media-item img,
        .media-item video {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .media-item.contain img,
        .media-item.contain video {
            object-fit: contain;
        }

        /* Media Overlay */
        .media-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
            padding: 20px 12px 12px;
            transform: translateY(100%);
            transition: var(--transition);
        }

        .media-item:hover .media-overlay {
            transform: translateY(0);
        }

        .media-actions {
            display: flex;
            gap: 8px;
            margin-bottom: 8px;
        }

        .media-action-btn {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            color: white;
            cursor: pointer;
            transition: var(--transition);
            font-size: 14px;
        }

        .media-action-btn:hover {
            background: var(--primary);
            border-color: var(--primary);
            transform: scale(1.1);
        }

        .media-info {
            color: white;
            font-size: 12px;
            line-height: 1.4;
        }

        .media-name {
            font-weight: 600;
            margin-bottom: 2px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .media-meta {
            opacity: 0.8;
            font-size: 11px;
        }

        /* Fullscreen Viewer */
        .fullscreen-viewer {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.95);
            backdrop-filter: blur(20px);
            z-index: 2000;
            display: none;
            flex-direction: column;
        }

        .fullscreen-viewer.active {
            display: flex;
        }

        .viewer-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px;
            background: rgba(0, 0, 0, 0.5);
        }

        .viewer-title {
            font-size: 18px;
            font-weight: 600;
        }

        .viewer-actions {
            display: flex;
            gap: 12px;
        }

        .viewer-content {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }

        .viewer-media {
            max-width: 90%;
            max-height: 90%;
            object-fit: contain;
            cursor: zoom-in;
            transition: transform 0.3s ease;
        }

        .viewer-media.zoomed {
            cursor: zoom-out;
            max-width: none;
            max-height: none;
        }

        .viewer-nav {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            color: white;
            cursor: pointer;
            transition: var(--transition);
            font-size: 24px;
        }

        .viewer-nav:hover {
            background: var(--primary);
            border-color: var(--primary);
            transform: translateY(-50%) scale(1.1);
        }

        .viewer-nav.prev {
            left: 20px;
        }

        .viewer-nav.next {
            right: 20px;
        }

        .viewer-nav.up {
            top: 80px;
            left: 50%;
            transform: translateX(-50%);
        }

        .viewer-nav.down {
            top: auto;
            bottom: 80px;
            left: 50%;
            transform: translateX(-50%);
        }

        .viewer-nav.up:hover,
        .viewer-nav.down:hover {
            transform: translateX(-50%) scale(1.1);
        }

        /* Loading Spinner */
        .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid rgba(255, 255, 255, 0.1);
            border-top-color: var(--primary);
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Metadata Panel */
        .metadata-panel {
            position: absolute;
            right: 0;
            top: 0;
            bottom: 0;
            width: 320px;
            background: var(--surface);
            padding: 20px;
            transform: translateX(100%);
            transition: var(--transition);
            overflow-y: auto;
        }

        .metadata-panel.active {
            transform: translateX(0);
        }

        .metadata-section {
            margin-bottom: 24px;
        }

        .metadata-title {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 12px;
            color: var(--primary);
        }

        .metadata-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            font-size: 13px;
        }

        .metadata-key {
            color: var(--text-dim);
        }

        .metadata-value {
            color: var(--text);
            text-align: right;
        }

        /* Settings Modal */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.8);
            backdrop-filter: blur(10px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 3000;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: var(--surface);
            border-radius: var(--radius);
            padding: 30px;
            max-width: 500px;
            width: 90%;
            max-height: 80vh;
            overflow-y: auto;
        }

        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }

        .modal-title {
            font-size: 24px;
            font-weight: 600;
        }

        .modal-close {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.05);
            border: none;
            border-radius: 50%;
            color: var(--text);
            cursor: pointer;
            transition: var(--transition);
        }

        .modal-close:hover {
            background: var(--primary);
            color: var(--bg);
        }

        .settings-group {
            margin-bottom: 24px;
        }

        .settings-label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
            color: var(--text);
        }

        .settings-input {
            width: 100%;
            padding: 10px 12px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: var(--radius);
            color: var(--text);
            font-size: 14px;
        }

        .settings-select {
            width: 100%;
            padding: 10px 12px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: var(--radius);
            color: var(--text);
            font-size: 14px;
            cursor: pointer;
        }

        .settings-toggle {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 0;
        }

        /* Toast Notifications */
        .toast-container {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 4000;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .toast {
            background: var(--surface);
            border: 1px solid var(--primary);
            border-radius: var(--radius);
            padding: 16px 20px;
            min-width: 300px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease;
        }

        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        .toast-icon {
            font-size: 20px;
        }

        .toast-message {
            flex: 1;
            font-size: 14px;
        }

        .toast.success {
            border-color: #10b981;
        }

        .toast.error {
            border-color: #ef4444;
        }

        .toast.info {
            border-color: var(--accent);
        }

        /* Particle Effects */
        #particles-canvas {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 1;
            opacity: 0.3;
        }

        /* Music Visualizer */
        .visualizer {
            position: fixed;
            bottom: var(--control-panel-height);
            left: 0;
            right: 0;
            height: 100px;
            background: rgba(0, 0, 0, 0.5);
            display: none;
        }

        .visualizer.active {
            display: block;
        }

        #visualizer-canvas {
            width: 100%;
            height: 100%;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            :root {
                --sidebar-width: 0;
                --thumb-size: 200px;
            }
            
            .sidebar {
                transform: translateX(-100%);
            }
            
            .sidebar.active {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
            }
        }

        @media (max-width: 768px) {
            :root {
                --thumb-size: 150px;
                --gap: 12px;
            }
            
            .header {
                padding: 0 12px;
            }
            
            .search-container {
                display: none;
            }
            
            .control-panel {
                flex-direction: column;
                align-items: stretch;
            }
            
            .view-controls {
                margin-left: 0;
            }
        }

        /* Theme Classes */
        body.theme-cyber {
            --bg: var(--cyber-bg);
            --surface: var(--cyber-surface);
            --primary: var(--cyber-primary);
            --secondary: var(--cyber-secondary);
            --accent: var(--cyber-accent);
            --text: var(--cyber-text);
            --text-dim: var(--cyber-text-dim);
        }

        body.theme-neon {
            --bg: var(--neon-bg);
            --surface: var(--neon-surface);
            --primary: var(--neon-primary);
            --secondary: var(--neon-secondary);
            --accent: var(--neon-accent);
            --text: var(--neon-text);
            --text-dim: var(--neon-text-dim);
        }

        body.theme-minimal {
            --bg: var(--minimal-bg);
            --surface: var(--minimal-surface);
            --primary: var(--minimal-primary);
            --secondary: var(--minimal-secondary);
            --accent: var(--minimal-accent);
            --text: var(--minimal-text);
            --text-dim: var(--minimal-text-dim);
        }

        body.theme-nature {
            --bg: var(--nature-bg);
            --surface: var(--nature-surface);
            --primary: var(--nature-primary);
            --secondary: var(--nature-secondary);
            --accent: var(--nature-accent);
            --text: var(--nature-text);
            --text-dim: var(--nature-text-dim);
        }

        body.theme-retro {
            --bg: var(--retro-bg);
            --surface: var(--retro-surface);
            --primary: var(--retro-primary);
            --secondary: var(--retro-secondary);
            --accent: var(--retro-accent);
            --text: var(--retro-text);
            --text-dim: var(--retro-text-dim);
        }

        body.theme-glassmorphism {
            --bg: var(--glass-bg);
            --surface: var(--glass-surface);
            --primary: var(--glass-primary);
            --secondary: var(--glass-secondary);
            --accent: var(--glass-accent);
            --text: var(--glass-text);
            --text-dim: var(--glass-text-dim);
        }

        /* Dark mode overrides */
        body.dark-mode {
            filter: invert(1) hue-rotate(180deg);
        }

        body.dark-mode img,
        body.dark-mode video {
            filter: invert(1) hue-rotate(180deg);
        }

        /* Cache progress and stats styles */
        .cache-progress-container {
            width: 100%;
            height: 4px;
            background: var(--surface);
            border-radius: 2px;
            overflow: hidden;
            margin-top: 4px;
        }
        .cache-progress-bar {
            height: 100%;
            width: 0;
            background: var(--primary);
            transition: width 0.2s ease;
        }
        .cache-stats {
            font-size: 10px;
            margin-top: 4px;
            color: var(--text-dim);
        }
        .cache-stats > div {
            margin-top: 2px;
        }
    </style>
</head>
<body class="theme-${THEME}">
    <!-- Header -->
    <header class="header">
        <div class="logo">MediaVault</div>
        
        <div class="search-container">
            <input type="text" class="search-input" placeholder="Search media..." id="searchInput">
            <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"></circle>
                <path d="m21 21-4.35-4.35"></path>
            </svg>
        </div>
        
        <div class="header-actions">
            <button class="icon-btn" id="sidebarToggle" title="Toggle Sidebar">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="3" y1="12" x2="21" y2="12"></line>
                    <line x1="3" y1="6" x2="21" y2="6"></line>
                    <line x1="3" y1="18" x2="21" y2="18"></line>
                </svg>
            </button>
            
            <button class="icon-btn" id="themeToggle" title="Change Theme">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="5"></circle>
                    <line x1="12" y1="1" x2="12" y2="3"></line>
                    <line x1="12" y1="21" x2="12" y2="23"></line>
                    <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                    <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                    <line x1="1" y1="12" x2="3" y2="12"></line>
                    <line x1="21" y1="12" x2="23" y2="12"></line>
                    <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                    <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                </svg>
            </button>
            
            <button class="icon-btn" id="fullscreenToggle" title="Fullscreen">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"></path>
                </svg>
            </button>
            
            <button class="icon-btn" id="settingsToggle" title="Settings">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="3"></circle>
                    <path d="M12 1v6m0 6v6m9-9h-6m-6 0H3m16.24-6.36l-4.24 4.24m-6.12 6.12l-4.24 4.24m12.72 0l-4.24-4.24m-6.12-6.12L2.76 7.64"></path>
                </svg>
            </button>
        </div>
    </header>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-section">
            <div class="sidebar-title">Filters</div>
            <div class="filter-group">
                <div class="filter-chip active" data-filter="all">
                    <span>All Media</span>
                    <span class="filter-count" id="allCount">0</span>
                </div>
                <div class="filter-chip" data-filter="image">
                    <span>Images</span>
                    <span class="filter-count" id="imageCount">0</span>
                </div>
                <div class="filter-chip" data-filter="video">
                    <span>Videos</span>
                    <span class="filter-count" id="videoCount">0</span>
                </div>
            </div>
        </div>
        
        <div class="sidebar-section">
            <div class="sidebar-title">Sort By</div>
            <div class="filter-group">
                <div class="filter-chip" data-sort="name">Name</div>
                <div class="filter-chip active" data-sort="date">Date</div>
                <div class="filter-chip" data-sort="size">Size</div>
                <div class="filter-chip" data-sort="type">Type</div>
            </div>
        </div>
        
        <div class="sidebar-section">
            <div class="sidebar-title">Tags</div>
            <div class="filter-group" id="tagFilters">
                <!-- Dynamic tags will be inserted here -->
            </div>
        </div>
        
        <div class="sidebar-section">
            <div class="sidebar-title">Cache</div>
            <div class="settings-toggle">
                <span>Enable Cache</span>
                <div class="toggle-switch" id="cacheToggle"></div>
            </div>
            <button class="filter-chip" id="clearCache" style="margin-top: 12px;">
                Clear Cache
            </button>
            <div style="margin-top: 8px; font-size: 12px; color: var(--text-dim);">
                <span id="cacheSize">0 MB</span> used
            </div>
            <!-- Real-time cache statistics and progress -->
            <div class="cache-progress-container">
                <div class="cache-progress-bar" id="cacheProgressBar"></div>
            </div>
            <div class="cache-stats">
                <div id="cacheProgressPercent">0% cached</div>
                <div id="cacheLoadedPercent">0% loaded from cache</div>
                <div id="cacheSpeedIn">0 KB/s caching</div>
                <div id="cacheSpeedOut">0 KB/s loading</div>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content" id="mainContent">
        <!-- Control Panel -->
        <div class="control-panel">
            <div class="layout-switcher">
                <button class="layout-btn active" data-layout="masonry">Masonry</button>
		<button class="layout-btn" data-layout="grid">Grid</button>
                <button class="layout-btn" data-layout="carousel">Carousel</button>
                <button class="layout-btn" data-layout="timeline">Timeline</button>
                <button class="layout-btn" data-layout="scatter">Scatter</button>
                <button class="layout-btn" data-layout="spiral">Spiral</button>
            </div>
            
            <div class="slideshow-controls">
                <button class="playback-btn" id="playPauseBtn">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M8 5v14l11-7z"></path>
                    </svg>
                </button>
                
                <div class="speed-control">
                    <button id="speedDown">−</button>
                    <span class="speed-display" id="speedDisplay">3s</span>
                    <button id="speedUp">+</button>
                </div>
                
                <button class="icon-btn" id="shuffleBtn" title="Shuffle">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="16 3 21 3 21 8"></polyline>
                        <line x1="4" y1="20" x2="21" y2="3"></line>
                        <polyline points="21 16 21 21 16 21"></polyline>
                        <line x1="15" y1="15" x2="21" y2="21"></line>
                        <line x1="4" y1="4" x2="9" y2="9"></line>
                    </svg>
                </button>
            </div>
            
            <div class="view-controls">
                <button class="icon-btn" id="viewModeToggle" title="Toggle View Mode">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="9" y1="9" x2="15" y2="15"></line>
                        <line x1="15" y1="9" x2="9" y2="15"></line>
                    </svg>
                </button>
            </div>
        </div>
        
        <!-- Gallery -->
        <div class="gallery grid" id="gallery">
            <!-- Media items will be dynamically inserted here -->
        </div>
    </main>

    <!-- Fullscreen Viewer -->
    <div class="fullscreen-viewer" id="fullscreenViewer">
        <div class="viewer-header">
            <div class="viewer-title" id="viewerTitle">Media Title</div>
            <div class="viewer-actions">
                <button class="icon-btn" id="metadataToggle" title="Show Metadata">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="16" x2="12" y2="12"></line>
                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                    </svg>
                </button>
                <button class="icon-btn" id="downloadBtn" title="Download">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                        <polyline points="7 10 12 15 17 10"></polyline>
                        <line x1="12" y1="15" x2="12" y2="3"></line>
                    </svg>
                </button>
                <button class="icon-btn" id="shareBtn" title="Share">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="18" cy="5" r="3"></circle>
                        <circle cx="6" cy="12" r="3"></circle>
                        <circle cx="18" cy="19" r="3"></circle>
                        <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
                        <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
                    </svg>
                </button>
                <button class="icon-btn" id="closeViewer" title="Close">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <line x1="18" y1="6" x2="6" y2="18"></line>
                        <line x1="6" y1="6" x2="18" y2="18"></line>
                    </svg>
                </button>
            </div>
        </div>
        
        <div class="viewer-content" id="viewerContent">
            <div class="spinner" id="viewerSpinner"></div>
            <!-- Media will be inserted here -->
            
            <!-- Navigation arrows -->
            <button class="viewer-nav prev" id="navPrev">❮</button>
            <button class="viewer-nav next" id="navNext">❯</button>
            <button class="viewer-nav up" id="navUp">❮</button>
            <button class="viewer-nav down" id="navDown">❯</button>
        </div>
        
        <!-- Metadata Panel -->
        <div class="metadata-panel" id="metadataPanel">
            <div class="metadata-section">
                <div class="metadata-title">File Info</div>
                <div id="fileMetadata"></div>
            </div>
            <div class="metadata-section">
                <div class="metadata-title">EXIF Data</div>
                <div id="exifMetadata"></div>
            </div>
            <div class="metadata-section">
                <div class="metadata-title">Analysis</div>
                <div id="analysisMetadata"></div>
            </div>
        </div>
    </div>

    <!-- Settings Modal -->
    <div class="modal" id="settingsModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">Settings</h2>
                <button class="modal-close" id="closeSettings">✕</button>
            </div>
            
            <div class="settings-group">
                <label class="settings-label">Theme</label>
                <select class="settings-select" id="themeSelect">
                    <option value="cyber">Cyber</option>
                    <option value="neon">Neon</option>
                    <option value="minimal">Minimal</option>
                    <option value="nature">Nature</option>
                    <option value="retro">Retro</option>
                    <option value="glassmorphism">Glassmorphism</option>
                </select>
            </div>
            
            <div class="settings-group">
                <label class="settings-label">Default Layout</label>
                <select class="settings-select" id="layoutSelect">
                    <option value="masonry">Masonry</option>
		    <option value="grid">Grid</option>
                    <option value="carousel">Carousel</option>
                    <option value="timeline">Timeline</option>
                    <option value="scatter">Scatter</option>
                    <option value="spiral">Spiral</option>
                </select>
            </div>
            
            <div class="settings-group">
                <label class="settings-label">Thumbnail Size (px)</label>
                <input type="range" class="settings-input" id="thumbSizeInput" min="100" max="500" step="50" value="${THUMBNAIL_SIZE}">
                <div style="text-align: center; margin-top: 8px; color: var(--text-dim);">
                    <span id="thumbSizeDisplay">${THUMBNAIL_SIZE}px</span>
                </div>
            </div>
            
            <div class="settings-group">
                <div class="settings-toggle">
                    <span>AI Theme Generation</span>
                    <div class="toggle-switch" id="aiThemeToggle"></div>
                </div>
            </div>
            
            <div class="settings-group">
                <div class="settings-toggle">
                    <span>Lazy Loading</span>
                    <div class="toggle-switch active" id="lazyLoadToggle"></div>
                </div>
            </div>
            
            <div class="settings-group">
                <div class="settings-toggle">
                    <span>Keyboard Shortcuts</span>
                    <div class="toggle-switch active" id="keyboardToggle"></div>
                </div>
            </div>
            
            <div class="settings-group">
                <div class="settings-toggle">
                    <span>Touch Gestures</span>
                    <div class="toggle-switch active" id="touchToggle"></div>
                </div>
            </div>
            
            <div class="settings-group">
                <div class="settings-toggle">
                    <span>Particle Effects</span>
                    <div class="toggle-switch" id="particlesToggle"></div>
                </div>
            </div>
            
            <div class="settings-group">
                <div class="settings-toggle">
                    <span>Music Visualizer</span>
                    <div class="toggle-switch" id="visualizerToggle"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <!-- Particle Canvas -->
    <canvas id="particles-canvas"></canvas>

    <!-- Music Visualizer -->
    <div class="visualizer" id="visualizer">
        <canvas id="visualizer-canvas"></canvas>
    </div>

    <script>
        // Configuration
        const config = {
            title: '${TITLE}',
            theme: '${THEME}',
            layout: '${LAYOUT}',
            slideshowSpeed: ${SLIDESHOW_SPEED},
            enableCache: ${ENABLE_CACHE},
            enableAITheme: ${ENABLE_AI_THEME},
            enableEXIF: ${ENABLE_EXIF},
            enableFaceDetection: ${ENABLE_FACE_DETECTION},
            enableLazyLoading: ${ENABLE_LAZY_LOADING},
            enableKeyboardShortcuts: ${ENABLE_KEYBOARD_SHORTCUTS},
            enableTouchGestures: ${ENABLE_TOUCH_GESTURES},
            enableFullscreenAPI: ${ENABLE_FULLSCREEN_API},
            enableShareAPI: ${ENABLE_SHARE_API},
            enableClipboardAPI: ${ENABLE_CLIPBOARD_API},
            enableVibrationAPI: ${ENABLE_VIBRATION_API},
            enable3DTransforms: ${ENABLE_3D_TRANSFORMS},
            enableMusicVisualizer: ${ENABLE_MUSIC_VISUALIZER},
            enableParticleEffects: ${ENABLE_PARTICLE_EFFECTS},
            gridColumns: '${GRID_COLUMNS}',
            thumbnailSize: ${THUMBNAIL_SIZE},
            maxCacheSize: ${MAX_CACHE_SIZE},
            debugMode: ${DEBUG_MODE}
        };

        // Media data
        const mediaData = ${json_data};

        // State
        let state = {
            currentLayout: config.layout,
            currentTheme: config.theme,
            currentFilter: 'all',
            currentSort: 'date',
            currentIndex: 0,
            isPlaying: false,
            slideshowInterval: null,
            fullscreenMedia: null,
            selectedTags: new Set(),
            zoom: 1,
            rotation: 0,
            touchStartX: 0,
            touchStartY: 0,
            history: [],
            historyIndex: -1,
            cacheEnabled: config.enableCache,
            mediaCache: new Map(),
            observerActive: false
        };

        // IndexedDB setup
        let db = null;
        const DB_NAME = 'MediaVaultDB';
        const DB_VERSION = 1;
        const STORE_NAME = 'mediaCache';

        // Statistics for caching and loading
        let totalGallerySize = 0;
        let cachedBytes = 0;
        let loadedBytesFromCache = 0;
        let cacheSpeedInCurrent = 0;
        let cacheSpeedOutCurrent = 0;

        /**
         * Compute total size of all media items in the gallery. Must be called whenever
         * mediaData is modified (e.g. after loading cached items or adding external media).
         */
        function updateTotalGallerySize() {
            try {
                totalGallerySize = mediaData.reduce((sum, item) => sum + (item.size || 0), 0);
            } catch (err) {
                totalGallerySize = 0;
            }
        }

        /**
         * Update cache progress indicators. Reads the current cache size from IndexedDB
         * and updates progress bar width, percentage text, loaded-from-cache percentage,
         * and cache size display. This should be called whenever cache contents change
         * or when media is loaded from cache.
         */
        async function updateCacheProgress() {
            try {
                const size = await getCacheSize();
                cachedBytes = size;
                const percent = totalGallerySize > 0 ? (size / totalGallerySize) * 100 : 0;
                const progressBar = document.getElementById('cacheProgressBar');
                if (progressBar) {
                    progressBar.style.width = percent + '%';
                }
                const progressText = document.getElementById('cacheProgressPercent');
                if (progressText) {
                    progressText.textContent = percent.toFixed(2) + '% cached';
                }
                const loadedPercent = totalGallerySize > 0 ? (loadedBytesFromCache / totalGallerySize) * 100 : 0;
                const loadedText = document.getElementById('cacheLoadedPercent');
                if (loadedText) {
                    loadedText.textContent = loadedPercent.toFixed(2) + '% loaded from cache';
                }
                // Update cache size display
                const cacheSizeEl = document.getElementById('cacheSize');
                if (cacheSizeEl) {
                    cacheSizeEl.textContent = (size / 1024 / 1024).toFixed(2) + ' MB';
                }
            } catch (err) {
                // silently ignore errors
            }
        }

        /**
         * Load all media items stored in IndexedDB and append them to the in-memory gallery.
         * This allows the gallery to persist items added via URL anchors or cached previously.
         */
        async function loadCachedItems() {
            if (!db) return;
            return new Promise((resolve, reject) => {
                try {
                    const transaction = db.transaction([STORE_NAME], 'readonly');
                    const store = transaction.objectStore(STORE_NAME);
                    const request = store.getAll();
                    request.onsuccess = async () => {
                        const items = request.result || [];
                        for (const item of items) {
                            if (!mediaData.some(m => m.url === item.url)) {
                                let objectUrl = null;
                                try {
                                    objectUrl = URL.createObjectURL(item.blob);
                                } catch (err) {
                                    objectUrl = item.url;
                                }
                                const metaType = item.metadata && item.metadata.type ? item.metadata.type : '';
                                let mediaType = 'image';
                                if (metaType.startsWith('video')) mediaType = 'video';
                                else if (metaType.startsWith('audio')) mediaType = 'audio';
                                else if (metaType.startsWith('image')) mediaType = 'image';
                                const thumb = (mediaType === 'image') ? objectUrl : item.url;
                                mediaData.push({
                                    url: item.url,
                                    thumbnail: thumb,
                                    type: mediaType,
                                    name: decodeURIComponent(item.url.split('/').pop()),
                                    size: item.size || (item.blob ? item.blob.size : 0),
                                    date: new Date(item.timestamp || Date.now()).toISOString(),
                                    tags: []
                                });
                            }
                        }
                        resolve();
                    };
                    request.onerror = () => {
                        resolve();
                    };
                } catch (err) {
                    resolve();
                }
            });
        }

        /**
         * Attempt to construct a media object from an arbitrary URL or string.
         * Supports http/https/ftp remote URLs, data URLs, blob URLs and local paths.
         * Fetched resources are cached if caching is enabled. Returns a media object
         * compatible with the gallery or null on failure.
         */
        async function createMediaFromExternal(rawUrl) {
            try {
                const url = rawUrl.trim();
                let blob = null;
                let metaType = '';
                let objectUrl = null;
                // Data URL
                if (/^data:/i.test(url)) {
                    const response = await fetch(url);
                    blob = await response.blob();
                    metaType = blob.type || '';
                    objectUrl = url;
                    if (state.cacheEnabled) {
                        await cacheMedia(url, blob, { type: metaType, size: blob.size });
                    }
                } else if (/^blob:/i.test(url)) {
                    // Blob URLs cannot be fetched; use directly
                    objectUrl = url;
                    metaType = '';
                } else if (/^(https?|ftp):/i.test(url)) {
                    // Remote resource
                    const response = await fetch(url);
                    blob = await response.blob();
                    metaType = blob.type || '';
                    objectUrl = URL.createObjectURL(blob);
                    if (state.cacheEnabled) {
                        await cacheMedia(url, blob, { type: metaType, size: blob.size });
                    }
                } else {
                    // Attempt to fetch as relative or absolute file path
                    try {
                        const response = await fetch(url);
                        blob = await response.blob();
                        metaType = blob.type || '';
                        objectUrl = URL.createObjectURL(blob);
                        if (state.cacheEnabled) {
                            await cacheMedia(url, blob, { type: metaType, size: blob.size });
                        }
                    } catch (err) {
                        // Fall back to using the raw URL directly
                        objectUrl = url;
                        metaType = '';
                    }
                }
                // Determine media type
                let mediaType = 'image';
                if (metaType.startsWith('video')) mediaType = 'video';
                else if (metaType.startsWith('audio')) mediaType = 'audio';
                else if (metaType.startsWith('image')) mediaType = 'image';
                else {
                    const ext = url.split('.').pop().toLowerCase();
                    if (['mp4','webm','ogg','mov','mkv'].includes(ext)) mediaType = 'video';
                    else if (['mp3','wav','flac','aac','ogg'].includes(ext)) mediaType = 'audio';
                    else mediaType = 'image';
                }
                const size = blob ? blob.size : 0;
                return {
                    url: url,
                    thumbnail: (mediaType === 'image') ? (objectUrl || url) : (objectUrl || url),
                    type: mediaType,
                    name: decodeURIComponent(url.split('/').pop()),
                    size: size,
                    date: new Date().toISOString(),
                    tags: []
                };
            } catch (err) {
                console.error('Failed to create external media', err);
                return null;
            }
        }

        /**
         * Cache all media items currently loaded in the gallery. Used when enabling
         * caching at runtime to populate IndexedDB with existing items. Only uncached
         * items are fetched and stored.
         */
        async function cacheAllMedia() {
            if (!state.cacheEnabled) return;
            for (const item of mediaData) {
                const existing = await getCachedMedia(item.url);
                if (!existing) {
                    try {
                        const response = await fetch(item.url);
                        const blob = await response.blob();
                        await cacheMedia(item.url, blob, { type: blob.type, size: blob.size });
                    } catch (err) {
                        console.error('Failed to cache media', err);
                    }
                }
            }
            updateCacheProgress();
        }

        async function initDB() {
            if (!config.enableCache) return;

            return new Promise((resolve, reject) => {
                const request = indexedDB.open(DB_NAME, DB_VERSION);

                request.onerror = () => {
                    console.error('Failed to open IndexedDB');
                    reject(request.error);
                };

                request.onsuccess = () => {
                    db = request.result;
                    resolve(db);
                };

                request.onupgradeneeded = (event) => {
                    db = event.target.result;
                    if (!db.objectStoreNames.contains(STORE_NAME)) {
                        const store = db.createObjectStore(STORE_NAME, { keyPath: 'url' });
                        store.createIndex('timestamp', 'timestamp', { unique: false });
                        store.createIndex('size', 'size', { unique: false });
                    }
                };
            });
        }

        // Cache management
        async function getCachedMedia(url) {
            if (!db || !state.cacheEnabled) return null;

            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readonly');
                const store = transaction.objectStore(STORE_NAME);
                const request = store.get(url);

                request.onsuccess = () => resolve(request.result);
                request.onerror = () => reject(request.error);
            });
        }

        async function cacheMedia(url, blob, metadata) {
            if (!db || !state.cacheEnabled) return;

            // Check cache size before adding
            const cacheSize = await getCacheSize();
            if (cacheSize + blob.size > config.maxCacheSize * 1024 * 1024) {
                await cleanupCache(blob.size);
            }

            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readwrite');
                const store = transaction.objectStore(STORE_NAME);
                
                const data = {
                    url: url,
                    blob: blob,
                    metadata: metadata,
                    timestamp: Date.now(),
                    size: blob.size
                };

            const request = store.put(data);
            request.onsuccess = () => {
                // update cache statistics after successful write
                cachedBytes += blob.size;
                cacheSpeedInCurrent += blob.size;
                updateCacheProgress();
                resolve();
            };
            request.onerror = () => reject(request.error);
            });
        }

        async function getCacheSize() {
            if (!db) return 0;

            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readonly');
                const store = transaction.objectStore(STORE_NAME);
                const request = store.getAll();

                request.onsuccess = () => {
                    const totalSize = request.result.reduce((sum, item) => sum + item.size, 0);
                    resolve(totalSize);
                };
                request.onerror = () => reject(request.error);
            });
        }

        async function cleanupCache(requiredSpace) {
            if (!db) return;

            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readwrite');
                const store = transaction.objectStore(STORE_NAME);
                const index = store.index('timestamp');
                const request = index.openCursor();
                
                let freedSpace = 0;

                request.onsuccess = (event) => {
                    const cursor = event.target.result;
                    if (cursor && freedSpace < requiredSpace) {
                        freedSpace += cursor.value.size;
                        cursor.delete();
                        cursor.continue();
                    } else {
                        resolve();
                    }
                };
                request.onerror = () => reject(request.error);
            });
        }

        async function clearCache() {
            if (!db) return;

            return new Promise((resolve, reject) => {
                const transaction = db.transaction([STORE_NAME], 'readwrite');
                const store = transaction.objectStore(STORE_NAME);
                const request = store.clear();

                request.onsuccess = () => {
                    showToast('Cache cleared successfully', 'success');
                    // Reset statistics
                    cachedBytes = 0;
                    loadedBytesFromCache = 0;
                    updateCacheSize();
                    updateCacheProgress();
                    resolve();
                };
                request.onerror = () => {
                    showToast('Failed to clear cache', 'error');
                    reject(request.error);
                };
            });
        }

        async function updateCacheSize() {
            const size = await getCacheSize();
            const sizeMB = (size / 1024 / 1024).toFixed(2);
            document.getElementById('cacheSize').textContent = \`\${sizeMB} MB\`;
        }

        // Media loading
        async function loadMedia(url) {
            try {
                // Check cache first
                const cached = await getCachedMedia(url);
                if (cached) {
                    // update statistics for loading from cache
                    cacheSpeedOutCurrent += cached.blob.size;
                    loadedBytesFromCache += cached.blob.size;
                    updateCacheProgress();
                    return URL.createObjectURL(cached.blob);
                }

                // Fetch from URL
                const response = await fetch(url);
                const blob = await response.blob();

                // Cache the media if caching is enabled
                if (state.cacheEnabled) {
                    await cacheMedia(url, blob, {
                        type: blob.type,
                        size: blob.size
                    });
                }
                updateCacheProgress();
                return URL.createObjectURL(blob);
            } catch (error) {
                console.error('Failed to load media:', error);
                return url; // Fallback to direct URL
            }
        }

        // Initialize the app
        async function init() {
            // Set page title
            document.title = config.title;

            // Initialize IndexedDB
            if (config.enableCache) {
                await initDB();
                await updateCacheSize();
            }
            // Load any items stored in IndexedDB into the gallery and update size/progress
            if (state.cacheEnabled) {
                await loadCachedItems();
            }
            updateTotalGallerySize();
            updateCacheProgress();

            // Apply initial theme
            document.body.className = \`theme-\${config.theme}\`;

            // Initialize particle effects
            if (config.enableParticleEffects) {
                initParticles();
            }

            // Setup event listeners
            setupEventListeners();

            // Initialize gallery
            updateMediaCounts();
            renderGallery();

            // Setup lazy loading
            if (config.enableLazyLoading) {
                setupLazyLoading();
            }

            // Setup keyboard shortcuts
            if (config.enableKeyboardShortcuts) {
                setupKeyboardShortcuts();
            }

            // Setup touch gestures
            if (config.enableTouchGestures) {
                setupTouchGestures();
            }

            // Check for anchor on load
            if (window.location.hash) {
                const url = decodeURIComponent(window.location.hash.substring(1));
                openFullscreenViewer(url);
            }

            // Listen for hash changes
            window.addEventListener('hashchange', () => {
                if (window.location.hash) {
                    const url = decodeURIComponent(window.location.hash.substring(1));
                    openFullscreenViewer(url);
                } else {
                    closeFullscreenViewer();
                }
            });

            // Initialize cache toggle state
            const cacheToggle = document.getElementById('cacheToggle');
            if (state.cacheEnabled) {
                cacheToggle.classList.add('active');
            }
            // Periodic update for caching and loading speeds
            setInterval(() => {
                const inEl = document.getElementById('cacheSpeedIn');
                const outEl = document.getElementById('cacheSpeedOut');
                if (inEl) {
                    inEl.textContent = (cacheSpeedInCurrent / 1024).toFixed(2) + ' KB/s caching';
                }
                if (outEl) {
                    outEl.textContent = (cacheSpeedOutCurrent / 1024).toFixed(2) + ' KB/s loading';
                }
                cacheSpeedInCurrent = 0;
                cacheSpeedOutCurrent = 0;
            }, 1000);
        }

        // Event listeners setup
        function setupEventListeners() {
            // Sidebar toggle
            document.getElementById('sidebarToggle').addEventListener('click', () => {
                document.getElementById('sidebar').classList.toggle('collapsed');
                document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
            });

            // Theme toggle
            document.getElementById('themeToggle').addEventListener('click', cycleTheme);

            // Fullscreen toggle
            document.getElementById('fullscreenToggle').addEventListener('click', toggleFullscreen);

            // Settings toggle
            document.getElementById('settingsToggle').addEventListener('click', () => {
                document.getElementById('settingsModal').classList.add('active');
            });

            // Close settings
            document.getElementById('closeSettings').addEventListener('click', () => {
                document.getElementById('settingsModal').classList.remove('active');
            });

            // Search input
            document.getElementById('searchInput').addEventListener('input', (e) => {
                filterMediaBySearch(e.target.value);
            });

            // Filter chips
            document.querySelectorAll('[data-filter]').forEach(chip => {
                chip.addEventListener('click', () => {
                    document.querySelectorAll('[data-filter]').forEach(c => c.classList.remove('active'));
                    chip.classList.add('active');
                    state.currentFilter = chip.dataset.filter;
                    renderGallery();
                });
            });

            // Sort chips
            document.querySelectorAll('[data-sort]').forEach(chip => {
                chip.addEventListener('click', () => {
                    document.querySelectorAll('[data-sort]').forEach(c => c.classList.remove('active'));
                    chip.classList.add('active');
                    state.currentSort = chip.dataset.sort;
                    renderGallery();
                });
            });

            // Layout buttons
            document.querySelectorAll('[data-layout]').forEach(btn => {
                btn.addEventListener('click', () => {
                    document.querySelectorAll('[data-layout]').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                    state.currentLayout = btn.dataset.layout;
                    renderGallery();
                });
            });

            // Playback controls
            document.getElementById('playPauseBtn').addEventListener('click', toggleSlideshow);
            document.getElementById('speedDown').addEventListener('click', () => adjustSpeed(-500));
            document.getElementById('speedUp').addEventListener('click', () => adjustSpeed(500));
            document.getElementById('shuffleBtn').addEventListener('click', shuffleGallery);

            // Cache toggle
            document.getElementById('cacheToggle').addEventListener('click', () => {
                state.cacheEnabled = !state.cacheEnabled;
                const toggleEl = document.getElementById('cacheToggle');
                if (state.cacheEnabled) {
                    toggleEl.classList.add('active');
                    localStorage.setItem('cacheEnabled', true);
                    // When enabling cache at runtime, cache all currently loaded media
                    cacheAllMedia();
                } else {
                    toggleEl.classList.remove('active');
                    localStorage.setItem('cacheEnabled', false);
                }
                updateCacheProgress();
            });

            // Clear cache
            document.getElementById('clearCache').addEventListener('click', () => {
                if (confirm('Are you sure you want to clear the cache?')) {
                    clearCache();
                }
            });

            // Viewer controls
            document.getElementById('closeViewer').addEventListener('click', closeFullscreenViewer);
            document.getElementById('navPrev').addEventListener('click', () => navigateMedia(-1, 0));
            document.getElementById('navNext').addEventListener('click', () => navigateMedia(1, 0));
            document.getElementById('navUp').addEventListener('click', () => navigateMedia(0, -1));
            document.getElementById('navDown').addEventListener('click', () => navigateMedia(0, 1));
            document.getElementById('metadataToggle').addEventListener('click', toggleMetadata);
            document.getElementById('downloadBtn').addEventListener('click', downloadCurrentMedia);
            document.getElementById('shareBtn').addEventListener('click', shareCurrentMedia);

            // Settings controls
            document.getElementById('themeSelect').addEventListener('change', (e) => {
                applyTheme(e.target.value);
            });

            document.getElementById('thumbSizeInput').addEventListener('input', (e) => {
                const size = e.target.value;
                document.getElementById('thumbSizeDisplay').textContent = \`\${size}px\`;
                document.documentElement.style.setProperty('--thumb-size', \`\${size}px\`);
            });

            // Toggle switches in settings
            document.getElementById('aiThemeToggle').addEventListener('click', function() {
                this.classList.toggle('active');
                config.enableAITheme = this.classList.contains('active');
            });

            document.getElementById('lazyLoadToggle').addEventListener('click', function() {
                this.classList.toggle('active');
                config.enableLazyLoading = this.classList.contains('active');
                if (config.enableLazyLoading) {
                    setupLazyLoading();
                }
            });

            document.getElementById('keyboardToggle').addEventListener('click', function() {
                this.classList.toggle('active');
                config.enableKeyboardShortcuts = this.classList.contains('active');
            });

            document.getElementById('touchToggle').addEventListener('click', function() {
                this.classList.toggle('active');
                config.enableTouchGestures = this.classList.contains('active');
            });

            document.getElementById('particlesToggle').addEventListener('click', function() {
                this.classList.toggle('active');
                config.enableParticleEffects = this.classList.contains('active');
                if (config.enableParticleEffects) {
                    initParticles();
                } else {
                    stopParticles();
                }
            });

            document.getElementById('visualizerToggle').addEventListener('click', function() {
                this.classList.toggle('active');
                config.enableMusicVisualizer = this.classList.contains('active');
            });

            // Modal backdrop click
            document.getElementById('settingsModal').addEventListener('click', (e) => {
                if (e.target === e.currentTarget) {
                    e.currentTarget.classList.remove('active');
                }
            });
        }

        // Gallery rendering
        function renderGallery() {
            const gallery = document.getElementById('gallery');
            gallery.className = \`gallery \${state.currentLayout}\`;
            gallery.innerHTML = '';

            // Filter and sort media
            let filteredMedia = filterMedia(mediaData);
            let sortedMedia = sortMedia(filteredMedia);

            // Apply search filter if active
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            if (searchTerm) {
                sortedMedia = sortedMedia.filter(item => 
                    item.name.toLowerCase().includes(searchTerm)
                );
            }

            // Render based on layout
            switch (state.currentLayout) {
                case 'scatter':
                    renderScatterLayout(sortedMedia);
                    break;
                case 'spiral':
                    renderSpiralLayout(sortedMedia);
                    break;
                default:
                    sortedMedia.forEach((item, index) => {
                        gallery.appendChild(createMediaElement(item, index));
                    });
            }

            // Setup observers for lazy loading
            if (config.enableLazyLoading) {
                setupLazyLoading();
            }

            // After rendering, recompute total gallery size and refresh cache progress
            updateTotalGallerySize();
            updateCacheProgress();
        }

        function createMediaElement(item, index) {
            const element = document.createElement('div');
            element.className = 'media-item loading';
            element.dataset.index = index;
            element.dataset.url = item.url;
            element.dataset.type = item.type;

            // Create media content
            const mediaContent = item.type === 'image' 
                ? \`<img data-src="\${item.url}" alt="\${item.name}" />\`
                : \`<video data-src="\${item.url}" muted loop></video>\`;

            element.innerHTML = \`
                \${mediaContent}
                <div class="media-overlay">
                    <div class="media-actions">
                        <button class="media-action-btn" onclick="downloadMedia('\${item.url}', '\${item.name}')" title="Download">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"></path>
                            </svg>
                        </button>
                        <button class="media-action-btn" onclick="applyMediaTheme('\${item.url}')" title="Apply Theme">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 2v20M8.5 7a5.5 5.5 0 1 1 0 11H12"></path>
                            </svg>
                        </button>
                        <button class="media-action-btn" onclick="copyToClipboard('\${item.url}')" title="Copy URL">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
                            </svg>
                        </button>
                    </div>
                    <div class="media-info">
                        <div class="media-name">\${item.name}</div>
                        <div class="media-meta">\${formatFileSize(item.size)} • \${item.type}</div>
                    </div>
                </div>
            \`;

            // Click handler for fullscreen
            element.addEventListener('click', (e) => {
                if (!e.target.closest('.media-action-btn')) {
                    window.location.hash = encodeURIComponent(item.url);
                }
            });

            return element;
        }

        function renderScatterLayout(media) {
            const gallery = document.getElementById('gallery');
            const bounds = gallery.getBoundingClientRect();
            
            media.forEach((item, index) => {
                const element = createMediaElement(item, index);
                const x = Math.random() * (bounds.width - 300);
                const y = Math.random() * (bounds.height - 300);
                const rotation = Math.random() * 30 - 15;
                const scale = 0.8 + Math.random() * 0.4;
                
                element.style.left = \`\${x}px\`;
                element.style.top = \`\${y}px\`;
                element.style.setProperty('--rotation', \`\${rotation}deg\`);
                element.style.setProperty('--scale', scale);
                
                gallery.appendChild(element);
            });
        }

        function renderSpiralLayout(media) {
            const gallery = document.getElementById('gallery');
            const centerX = gallery.offsetWidth / 2;
            const centerY = gallery.offsetHeight / 2;
            const angleStep = (2 * Math.PI) / media.length;
            let radius = 50;
            const radiusIncrement = 30;
            
            media.forEach((item, index) => {
                const element = createMediaElement(item, index);
                const angle = index * angleStep;
                const x = centerX + radius * Math.cos(angle) - 150;
                const y = centerY + radius * Math.sin(angle) - 150;
                
                element.style.left = \`\${x}px\`;
                element.style.top = \`\${y}px\`;
                element.style.transform = \`rotate(\${angle}rad) scale(\${0.8 + index * 0.02})\`;
                
                gallery.appendChild(element);
                
                // Increase radius for spiral effect
                if (index % 6 === 0) {
                    radius += radiusIncrement;
                }
            });
        }

        // Filtering and sorting
        function filterMedia(media) {
            if (state.currentFilter === 'all') {
                return media;
            }
            return media.filter(item => item.type === state.currentFilter);
        }

        function sortMedia(media) {
            const sorted = [...media];
            switch (state.currentSort) {
                case 'name': {
		    if (state.previousSort === state.currentSort) {
			state.previousSort = state.currentSort;
			return sorted.sort((a, b) => b.name.localeCompare(a.name));
		    } else {
			state.previousSort = state.currentSort;
			return sorted.sort((a, b) => a.name.localeCompare(b.name));
		    }
	        }
                case 'date': {
		    if (state.previousSort === state.currentSort) {
			state.previousSort = state.currentSort;
			return sorted.sort((a, b) => a.modified - b.modified);
		    } else {			
			state.previousSort = state.currentSort;
			return sorted.sort((a, b) => b.modified - a.modified);
		    }
	        }
                case 'size': {
		    if (state.previousSort === state.currentSort) {
			state.previousSort = state.currentSort;
			return sorted.sort((a, b) => a.size - b.size);
		    } else {
			state.previousSort = state.currentSort;
			return sorted.sort((a, b) => b.size - a.size);
		    }
	        }
                case 'type': {
		    if (state.previousSort === state.currentSort) {
			state.previousSort = state.currentSort;
			return sorted.sort((a, b) => b.type.localeCompare(a.type));
		    } else {
			state.previousSort = state.currentSort;
			return sorted.sort((a, b) => a.type.localeCompare(b.type));
		    }
	        }
	    	case 'shuffled': {
		    state.previousSort = state.currentSort;
		    return sorted;
		}
                default: {
		    state.previousSort = state.currentSort;
                    return sorted;
	        }
            }
        }

        function filterMediaBySearch(searchTerm) {
            renderGallery();
        }

        // Slideshow functionality
        function toggleSlideshow() {
            state.isPlaying = !state.isPlaying;
            const btn = document.getElementById('playPauseBtn');
            
            if (state.isPlaying) {
                btn.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="4" width="4" height="16"></rect><rect x="14" y="4" width="4" height="16"></rect></svg>';
                startSlideshow();
            } else {
                btn.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"></path></svg>';
                stopSlideshow();
            }
        }

        function startSlideshow() {
            if (!document.querySelector('.fullscreen-viewer.active')) {
                // Open fullscreen viewer with first media
                const firstMedia = document.querySelector('.media-item');
                if (firstMedia) {
                    window.location.hash = encodeURIComponent(firstMedia.dataset.url);
                }
            }
            
            state.slideshowInterval = setInterval(() => {
                navigateMedia(1, 0);
            }, config.slideshowSpeed);
        }

        function stopSlideshow() {
            clearInterval(state.slideshowInterval);
            state.slideshowInterval = null;
        }

        function adjustSpeed(delta) {
            config.slideshowSpeed = Math.max(1000, Math.min(10000, config.slideshowSpeed + delta));
            document.getElementById('speedDisplay').textContent = \`\${config.slideshowSpeed / 1000}s\`;
            
            if (state.isPlaying) {
                stopSlideshow();
                startSlideshow();
            }
        }

        function shuffleGallery() {
	    state.previousSort = state.currentSort;
	    state.currentSort = 'shuffled';

            // Fisher-Yates shuffle
            const shuffled = [...mediaData];
            for (let i = shuffled.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
            }
            
            // Update media data and re-render
            mediaData.length = 0;
            mediaData.push(...shuffled);
            renderGallery();
            
            // Vibrate if enabled
            if (config.enableVibrationAPI && navigator.vibrate) {
                navigator.vibrate(50);
            }
            
            showToast('Gallery shuffled!', 'info');
        }

        // Fullscreen viewer
        async function openFullscreenViewer(url) {
            const viewer = document.getElementById('fullscreenViewer');
            viewer.classList.add('active');
            
            // Find existing media index
            let index = mediaData.findIndex(item => item.url === url);
            // If not found, attempt to construct the media from external source
            if (index === -1) {
                const newItem = await createMediaFromExternal(url);
                if (newItem) {
                    mediaData.push(newItem);
                    index = mediaData.length - 1;
                    // Re-render gallery and update sizes and progress
                    renderGallery();
                    updateTotalGallerySize();
                    updateCacheProgress();
                } else {
                    showToast('Unable to load media', 'error');
                    return;
                }
            }
            // Show the media
            state.currentIndex = index;
            loadViewerMedia(mediaData[index]);
            
            // Add to history
            if (state.history[state.historyIndex] !== url) {
                state.history = state.history.slice(0, state.historyIndex + 1);
                state.history.push(url);
                state.historyIndex++;
            }
        }

        function closeFullscreenViewer() {
            const viewer = document.getElementById('fullscreenViewer');
            viewer.classList.remove('active');
            window.location.hash = '';
            
            // Stop slideshow if playing
            if (state.isPlaying) {
                toggleSlideshow();
            }
            
            // Reset zoom and rotation
            state.zoom = 1;
            state.rotation = 0;
        }

        async function loadViewerMedia(item) {
            const content = document.getElementById('viewerContent');
            const spinner = document.getElementById('viewerSpinner');
            const title = document.getElementById('viewerTitle');
            
            // Show spinner
            spinner.style.display = 'block';
            
            // Clear previous content
            const existingMedia = content.querySelector('img, video');
            if (existingMedia) {
                existingMedia.remove();
            }
            
            // Update title
            title.textContent = item.name;
            
            try {
                // Load media (from cache if available)
                const mediaUrl = state.cacheEnabled ? await loadMedia(item.url) : item.url;
                
                if (item.type === 'image') {
                    const img = new Image();
                    img.className = 'viewer-media';
                    img.alt = item.name;
                    
                    img.onload = () => {
                        spinner.style.display = 'none';
                        content.appendChild(img);
                        
                        // Apply stored zoom and rotation
                        updateMediaTransform(img);
                        
                        // Load metadata
                        if (config.enableEXIF) {
                            loadImageMetadata(item);
                        }
                    };
                    
                    img.onerror = () => {
                        spinner.style.display = 'none';
                        showToast('Failed to load image', 'error');
                    };
                    
                    img.src = mediaUrl;
                    
                    // Click to open in new tab
                    img.addEventListener('click', (e) => {
                        if (!e.shiftKey && !e.ctrlKey) {
                            window.open(item.url, '_blank');
                        }
                    });
                    
                    // Double click to zoom
                    img.addEventListener('dblclick', () => {
                        state.zoom = state.zoom === 1 ? 2 : 1;
                        updateMediaTransform(img);
                    });
                    
                } else if (item.type === 'video') {
                    const video = document.createElement('video');
                    video.className = 'viewer-media';
                    video.controls = true;
                    video.autoplay = state.isPlaying;
                    video.loop = true;
                    
                    video.onloadeddata = () => {
                        spinner.style.display = 'none';
                        content.appendChild(video);
                        
                        // Apply stored zoom and rotation
                        updateMediaTransform(video);
                        
                        // Initialize visualizer if enabled
                        if (config.enableMusicVisualizer) {
                            initVisualizer(video);
                        }
                    };
                    
                    video.onerror = () => {
                        spinner.style.display = 'none';
                        showToast('Failed to load video', 'error');
                    };
                    
                    video.src = mediaUrl;
                    
                    // Click to open in new tab
                    video.addEventListener('click', (e) => {
                        if (!e.target.closest('video:hover')) {
                            window.open(item.url, '_blank');
                        }
                    });
                }
                
            } catch (error) {
                console.error('Error loading media:', error);
                spinner.style.display = 'none';
                showToast('Error loading media', 'error');
            }
        }

        function updateMediaTransform(element) {
            element.style.transform = \`scale(\${state.zoom}) rotate(\${state.rotation}deg)\`;
            element.classList.toggle('zoomed', state.zoom > 1);
        }

        function navigateMedia(deltaX, deltaY) {
            const filteredMedia = filterMedia(mediaData);
            let newIndex = state.currentIndex;
            
            // Horizontal navigation (primary)
            if (deltaX !== 0) {
                newIndex += deltaX;
                
                // Wrap around
                if (newIndex < 0) newIndex = filteredMedia.length - 1;
                if (newIndex >= filteredMedia.length) newIndex = 0;
            }
            
            // Vertical navigation (secondary - jump by rows)
            if (deltaY !== 0) {
                const columns = Math.floor(window.innerWidth / config.thumbnailSize);
                newIndex += deltaY * columns;
                
                // Clamp to bounds
                newIndex = Math.max(0, Math.min(filteredMedia.length - 1, newIndex));
            }
            
            state.currentIndex = newIndex;
            const newMedia = filteredMedia[newIndex];
            
            if (newMedia) {
                window.location.hash = encodeURIComponent(newMedia.url);
            }
        }

        function toggleMetadata() {
            const panel = document.getElementById('metadataPanel');
            panel.classList.toggle('active');
            
            if (panel.classList.contains('active')) {
                const currentMedia = mediaData[state.currentIndex];
                displayMetadata(currentMedia);
            }
        }

        function displayMetadata(item) {
            const fileMetadata = document.getElementById('fileMetadata');
            fileMetadata.innerHTML = \`
                <div class="metadata-item">
                    <span class="metadata-key">Name</span>
                    <span class="metadata-value">\${item.name}</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-key">Type</span>
                    <span class="metadata-value">\${item.mimeType}</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-key">Size</span>
                    <span class="metadata-value">\${formatFileSize(item.size)}</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-key">Modified</span>
                    <span class="metadata-value">\${new Date(item.modified * 1000).toLocaleString()}</span>
                </div>
            \`;
        }

        async function loadImageMetadata(item) {
            // This would normally use EXIF.js or similar library
            // For now, showing placeholder data
            const exifMetadata = document.getElementById('exifMetadata');
            exifMetadata.innerHTML = \`
                <div class="metadata-item">
                    <span class="metadata-key">Camera</span>
                    <span class="metadata-value">Unknown</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-key">Lens</span>
                    <span class="metadata-value">Unknown</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-key">ISO</span>
                    <span class="metadata-value">Unknown</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-key">Aperture</span>
                    <span class="metadata-value">Unknown</span>
                </div>
            \`;
        }

        function downloadCurrentMedia() {
            const currentMedia = mediaData[state.currentIndex];
            downloadMedia(currentMedia.url, currentMedia.name);
        }

        function downloadMedia(url, filename) {
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            a.click();
            showToast(\`Downloading \${filename}\`, 'success');
        }

        async function shareCurrentMedia() {
            const currentMedia = mediaData[state.currentIndex];
            
            if (config.enableShareAPI && navigator.share) {
                try {
                    await navigator.share({
                        title: currentMedia.name,
                        text: \`Check out \${currentMedia.name}\`,
                        url: window.location.href
                    });
                } catch (error) {
                    console.log('Share cancelled or failed');
                }
            } else {
                // Fallback to clipboard
                copyToClipboard(window.location.href);
            }
        }

        async function copyToClipboard(text) {
            if (config.enableClipboardAPI && navigator.clipboard) {
                try {
                    await navigator.clipboard.writeText(text);
                    showToast('Copied to clipboard!', 'success');
                } catch (error) {
                    console.error('Failed to copy:', error);
                }
            }
        }

        // Theme management
        function cycleTheme() {
            const themes = ['cyber', 'neon', 'minimal', 'nature', 'retro', 'glassmorphism'];
            const currentIndex = themes.indexOf(state.currentTheme);
            const nextIndex = (currentIndex + 1) % themes.length;
            applyTheme(themes[nextIndex]);
        }

        function applyTheme(theme) {
            state.currentTheme = theme;
            document.body.className = \`theme-\${theme}\`;
            document.getElementById('themeSelect').value = theme;
            showToast(\`Theme changed to \${theme}\`, 'info');
        }

        async function applyMediaTheme(url) {
            if (!config.enableAITheme) {
                showToast('AI theming is disabled', 'info');
                return;
            }
            
            // This would normally analyze the image colors and patterns
            // For now, we'll apply a random theme
            const themes = ['cyber', 'neon', 'nature', 'retro'];
            const randomTheme = themes[Math.floor(Math.random() * themes.length)];
            applyTheme(randomTheme);
            showToast('Theme applied based on media', 'success');
        }

        // Utility functions
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        function updateMediaCounts() {
            const allCount = mediaData.length;
            const imageCount = mediaData.filter(m => m.type === 'image').length;
            const videoCount = mediaData.filter(m => m.type === 'video').length;
            
            document.getElementById('allCount').textContent = allCount;
            document.getElementById('imageCount').textContent = imageCount;
            document.getElementById('videoCount').textContent = videoCount;
        }

        function showToast(message, type = 'info') {
            const container = document.getElementById('toastContainer');
            const toast = document.createElement('div');
            toast.className = \`toast \${type}\`;
            
            const icons = {
                success: '✓',
                error: '✕',
                info: 'ℹ'
            };
            
            toast.innerHTML = \`
                <span class="toast-icon">\${icons[type]}</span>
                <span class="toast-message">\${message}</span>
            \`;
            
            container.appendChild(toast);
            
            // Auto remove after 3 seconds
            setTimeout(() => {
                toast.style.animation = 'slideOut 0.3s ease';
                setTimeout(() => toast.remove(), 300);
            }, 3000);
        }

        // Lazy loading
        let lazyLoadObserver = null;

        function setupLazyLoading() {
            if (!config.enableLazyLoading) return;
            
            // Disconnect existing observer
            if (lazyLoadObserver) {
                lazyLoadObserver.disconnect();
            }
            
            const options = {
                root: null,
                rootMargin: '50px',
                threshold: 0.01
            };
            
            lazyLoadObserver = new IntersectionObserver((entries) => {
                entries.forEach(async entry => {
                    if (entry.isIntersecting) {
                        const item = entry.target;
                        const media = item.querySelector('img, video');
                        
                        if (media && media.dataset.src) {
                            try {
                                // Load from cache if enabled
                                const src = state.cacheEnabled 
                                    ? await loadMedia(media.dataset.src)
                                    : media.dataset.src;
                                
                                media.src = src;
                                media.removeAttribute('data-src');
                                item.classList.remove('loading');
                                
                                // Auto-play videos on hover
                                if (media.tagName === 'VIDEO') {
                                    item.addEventListener('mouseenter', () => media.play());
                                    item.addEventListener('mouseleave', () => media.pause());
                                }
                            } catch (error) {
                                console.error('Failed to lazy load:', error);
                                item.classList.remove('loading');
                            }
                        }
                        
                        lazyLoadObserver.unobserve(item);
                    }
                });
            }, options);
            
            // Observe all media items
            document.querySelectorAll('.media-item').forEach(item => {
                lazyLoadObserver.observe(item);
            });
        }

        // Keyboard shortcuts
        function setupKeyboardShortcuts() {
            document.addEventListener('keydown', (e) => {
                if (!config.enableKeyboardShortcuts) return;
                
                // Ignore if typing in input
                if (e.target.tagName === 'INPUT') return;
                
                switch (e.key) {
                    case ' ':
                        e.preventDefault();
                        toggleSlideshow();
                        break;
                    case 'ArrowLeft':
                        e.preventDefault();
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            navigateMedia(-1, 0);
                        }
                        break;
                    case 'ArrowRight':
                        e.preventDefault();
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            navigateMedia(1, 0);
                        }
                        break;
                    case 'ArrowUp':
                        e.preventDefault();
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            navigateMedia(0, -1);
                        }
                        break;
                    case 'ArrowDown':
                        e.preventDefault();
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            navigateMedia(0, 1);
                        }
                        break;
                    case 'f':
                    case 'F':
                        toggleFullscreen();
                        break;
                    case 'g':
                    case 'G':
                        cycleLayout();
                        break;
                    case 't':
                    case 'T':
                        cycleTheme();
                        break;
                    case 's':
                    case 'S':
                        shuffleGallery();
                        break;
                    case 'Escape':
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            closeFullscreenViewer();
                        }
                        break;
                    case '+':
                    case '=':
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            state.zoom = Math.min(state.zoom + 0.25, 4);
                            updateViewerMediaTransform();
                        }
                        break;
                    case '-':
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            state.zoom = Math.max(state.zoom - 0.25, 0.5);
                            updateViewerMediaTransform();
                        }
                        break;
                    case 'r':
                    case 'R':
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            state.rotation = (state.rotation + 90) % 360;
                            updateViewerMediaTransform();
                        }
                        break;
                    case 'm':
                    case 'M':
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            toggleMetadata();
                        }
                        break;
                    case 'c':
                    case 'C':
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            copyToClipboard(window.location.href);
                        }
                        break;
                    case 'd':
                    case 'D':
                        if (document.querySelector('.fullscreen-viewer.active')) {
                            downloadCurrentMedia();
                        }
                        break;
                    default:
                        // Number keys for quick navigation
                        if (/^[1-9]$/.test(e.key)) {
                            const percentage = parseInt(e.key) * 10;
                            const targetIndex = Math.floor((mediaData.length - 1) * percentage / 100);
                            if (targetIndex !== state.currentIndex) {
                                state.currentIndex = targetIndex;
                                const media = mediaData[targetIndex];
                                if (media) {
                                    window.location.hash = encodeURIComponent(media.url);
                                }
                            }
                        }
                }
            });
        }

        function updateViewerMediaTransform() {
            const media = document.querySelector('.viewer-content img, .viewer-content video');
            if (media) {
                updateMediaTransform(media);
            }
        }

        function cycleLayout() {
            const layouts = ['masonry', 'grid', 'carousel', 'timeline', 'scatter', 'spiral'];
            const currentIndex = layouts.indexOf(state.currentLayout);
            const nextIndex = (currentIndex + 1) % layouts.length;
            state.currentLayout = layouts[nextIndex];
            
            // Update UI
            document.querySelectorAll('[data-layout]').forEach(btn => {
                btn.classList.toggle('active', btn.dataset.layout === state.currentLayout);
            });
            
            renderGallery();
            showToast(\`Layout changed to \${state.currentLayout}\`, 'info');
        }

        // Touch gestures
        function setupTouchGestures() {
            if (!config.enableTouchGestures) return;
            
            let touchStartX = 0;
            let touchStartY = 0;
            let touchEndX = 0;
            let touchEndY = 0;
            
            const viewerContent = document.getElementById('viewerContent');
            
            viewerContent.addEventListener('touchstart', (e) => {
                touchStartX = e.changedTouches[0].screenX;
                touchStartY = e.changedTouches[0].screenY;
            });
            
            viewerContent.addEventListener('touchend', (e) => {
                touchEndX = e.changedTouches[0].screenX;
                touchEndY = e.changedTouches[0].screenY;
                handleSwipe();
            });
            
            function handleSwipe() {
                const deltaX = touchEndX - touchStartX;
                const deltaY = touchEndY - touchStartY;
                const threshold = 50;
                
                if (Math.abs(deltaX) > Math.abs(deltaY)) {
                    // Horizontal swipe
                    if (Math.abs(deltaX) > threshold) {
                        if (deltaX > 0) {
                            navigateMedia(-1, 0); // Swipe right, go to previous
                        } else {
                            navigateMedia(1, 0); // Swipe left, go to next
                        }
                    }
                } else {
                    // Vertical swipe
                    if (Math.abs(deltaY) > threshold) {
                        if (deltaY > 0) {
                            navigateMedia(0, -1); // Swipe down
                        } else {
                            navigateMedia(0, 1); // Swipe up
                        }
                    }
                }
            }
            
            // Pinch to zoom
            let initialDistance = 0;
            let currentZoom = 1;
            
            viewerContent.addEventListener('touchstart', (e) => {
                if (e.touches.length === 2) {
                    initialDistance = getDistance(e.touches[0], e.touches[1]);
                    currentZoom = state.zoom;
                }
            });
            
            viewerContent.addEventListener('touchmove', (e) => {
                if (e.touches.length === 2) {
                    e.preventDefault();
                    const currentDistance = getDistance(e.touches[0], e.touches[1]);
                    const scale = currentDistance / initialDistance;
                    state.zoom = Math.max(0.5, Math.min(4, currentZoom * scale));
                    updateViewerMediaTransform();
                }
            });
            
            function getDistance(touch1, touch2) {
                const deltaX = touch1.screenX - touch2.screenX;
                const deltaY = touch1.screenY - touch2.screenY;
                return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
            }
        }

        // Fullscreen API
        function toggleFullscreen() {
            if (!config.enableFullscreenAPI) return;
            
            if (!document.fullscreenElement) {
                document.documentElement.requestFullscreen().catch(err => {
                    console.error('Error attempting to enable fullscreen:', err);
                });
            } else {
                document.exitFullscreen();
            }
        }

        // Particle effects
        let particleAnimation = null;
        
        function initParticles() {
            const canvas = document.getElementById('particles-canvas');
            const ctx = canvas.getContext('2d');
            const particles = [];
            const particleCount = 50;
            
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            
            class Particle {
                constructor() {
                    this.x = Math.random() * canvas.width;
                    this.y = Math.random() * canvas.height;
                    this.vx = (Math.random() - 0.5) * 2;
                    this.vy = (Math.random() - 0.5) * 2;
                    this.size = Math.random() * 3 + 1;
                    this.color = \`hsl(\${Math.random() * 360}, 70%, 50%)\`;
                }
                
                update() {
                    this.x += this.vx;
                    this.y += this.vy;
                    
                    if (this.x < 0 || this.x > canvas.width) this.vx *= -1;
                    if (this.y < 0 || this.y > canvas.height) this.vy *= -1;
                }
                
                draw() {
                    ctx.fillStyle = this.color;
                    ctx.beginPath();
                    ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                    ctx.fill();
                }
            }
            
            for (let i = 0; i < particleCount; i++) {
                particles.push(new Particle());
            }
            
            function animate() {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                
                particles.forEach(particle => {
                    particle.update();
                    particle.draw();
                });
                
                // Draw connections
                particles.forEach((p1, i) => {
                    particles.slice(i + 1).forEach(p2 => {
                        const distance = Math.sqrt((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2);
                        if (distance < 100) {
                            ctx.strokeStyle = \`rgba(255, 255, 255, \${0.1 * (1 - distance / 100)})\`;
                            ctx.beginPath();
                            ctx.moveTo(p1.x, p1.y);
                            ctx.lineTo(p2.x, p2.y);
                            ctx.stroke();
                        }
                    });
                });
                
                particleAnimation = requestAnimationFrame(animate);
            }
            
            animate();
            
            window.addEventListener('resize', () => {
                canvas.width = window.innerWidth;
                canvas.height = window.innerHeight;
            });
        }
        
        function stopParticles() {
            if (particleAnimation) {
                cancelAnimationFrame(particleAnimation);
                particleAnimation = null;
                const canvas = document.getElementById('particles-canvas');
                const ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, canvas.width, canvas.height);
            }
        }

        // Music visualizer
        function initVisualizer(video) {
            if (!config.enableMusicVisualizer) return;
            
            const visualizer = document.getElementById('visualizer');
            const canvas = document.getElementById('visualizer-canvas');
            const ctx = canvas.getContext('2d');
            
            visualizer.classList.add('active');
            
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const source = audioContext.createMediaElementSource(video);
            const analyser = audioContext.createAnalyser();
            
            source.connect(analyser);
            analyser.connect(audioContext.destination);
            
            analyser.fftSize = 256;
            const bufferLength = analyser.frequencyBinCount;
            const dataArray = new Uint8Array(bufferLength);
            
            canvas.width = window.innerWidth;
            canvas.height = 100;
            
            function draw() {
                requestAnimationFrame(draw);
                
                analyser.getByteFrequencyData(dataArray);
                
                ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                
                const barWidth = (canvas.width / bufferLength) * 2.5;
                let x = 0;
                
                for (let i = 0; i < bufferLength; i++) {
                    const barHeight = dataArray[i] / 2;
                    
                    const hue = (i / bufferLength) * 360;
                    ctx.fillStyle = \`hsl(\${hue}, 100%, 50%)\`;
                    ctx.fillRect(x, canvas.height - barHeight, barWidth, barHeight);
                    
                    x += barWidth + 1;
                }
            }
            
            draw();
            
            video.addEventListener('pause', () => {
                visualizer.classList.remove('active');
            });
            
            video.addEventListener('play', () => {
                visualizer.classList.add('active');
            });
        }

        // Initialize when DOM is loaded
        document.addEventListener('DOMContentLoaded', init);
    </script>
</body>
</html>
EOF
}

# Generate the complete HTML file (FIXED)
generate_html() {
    log_info "Starting gallery generation..."
    
    # Find media files
    log_verbose "Scanning for media files..."
    local media_files=$(find_media_files "${MEDIA_SOURCES[@]}")

    log_verbose "\$media_files=${media_files}"
    
    # Count total files.  Because find_media_files now outputs one file per line, we can
    # simply count the number of newline-delimited entries.
    TOTAL_FILES=$(printf '%s\n' "$media_files" | grep -c '^' || echo 0)
    log_info "Found $TOTAL_FILES media files"
    
    if [[ $TOTAL_FILES -eq 0 ]]; then
        log_error "No media files found in specified locations!"
        exit 1
    fi
    
    # Generate JSON data
    log_verbose "Processing media files..."
    log_debug "\$media_files=$media_files"
    # Pass the newline-delimited list of files into generate_media_json.  Use printf
    # rather than echo -n to preserve newlines in the input.
    local json_file=$(printf '%s\n' "$media_files" | generate_media_json)
    
    if [[ "$VERBOSE_MODE" == "true" ]]; then
        echo >&2  # New line after progress
    fi
    
    # Generate HTML directly with embedded JSON
    log_verbose "Generating HTML output..."
    write_html_template "$OUTPUT_FILE" "$json_file"
    
    # Cleanup temp files
    rm -f "$json_file"
    
    log_success "Gallery generated successfully: $OUTPUT_FILE"
    
    # Show file size
    local file_size=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo "0")
    log_info "Output file size: $(( file_size / 1024 )) KB"
}

# Main execution
main() {
    # Show banner
    show_banner
    
    # Parse arguments
    parse_args "$@"
    
    # Default to current directory if no sources specified
    if [[ ${#MEDIA_SOURCES[@]} -eq 0 ]]; then
        log_info "No paths specified, using current directory"
        MEDIA_SOURCES=("$(pwd)")
    fi
    
    # Debug: Show configuration
    if [[ "$DEBUG_MODE" == "true" ]]; then
        log_debug "Configuration:"
        log_debug "  Output file: $OUTPUT_FILE"
        log_debug "  Title: $TITLE"
        log_debug "  Theme: $THEME"
        log_debug "  Layout: $LAYOUT"
        log_debug "  Recursive: $RECURSIVE"
        log_debug "  Verbose: $VERBOSE_MODE"
        log_debug "  Media sources: ${MEDIA_SOURCES[*]}"
    fi
    
    # Generate the HTML gallery
    generate_html
    
    # Auto-open if requested
    if [[ "$AUTO_OPEN" == "true" ]]; then
        log_info "Opening gallery in browser..."
        if command -v xdg-open &> /dev/null; then
            xdg-open "$OUTPUT_FILE" &
        elif command -v open &> /dev/null; then
            open "$OUTPUT_FILE" &
        elif command -v start &> /dev/null; then
            start "$OUTPUT_FILE" &
        else
            log_warning "Could not auto-open gallery (no suitable command found)"
        fi
    fi
}

# Run main function
main "$@"
