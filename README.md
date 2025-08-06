# MediaVault Generator
**by Claude Opus 4, ChatGPT GPT-4o (Agent Mode), and Jeremy Carter <jeremy@jeremycarter.ca>**

A bash script which generates IndexedDB-caching frontend-only media gallery web apps as self-contained single .html files, which can run as a server-hosted web page, or loaded directly from the filesystem as a file:// url (albeit with slightly degraded features, but mostly works just fine without needing to be served by a webserver).

## Usage

```bash
$ ./mediavault-generator.sh --help

    __  __         _ _     __     __          _ _
   |  \/  |       | (_)    \ \   / /         | | |
   | \  / | ___  __| |_  __ _\ \ / /_ _ _   _| | |_
   | |\/| |/ _ \/ _` | |/ _` |\ V / _` | | | | | __|
   | |  | |  __/ (_| | | (_| | | | (_| | |_| | | |_
   |_|  |_|\___|\__,_|_|\__,_| |_|\__,_|\__,_|_|\__|

    MediaVault Generator - Media Gallery Generator


USAGE:
    /home/defcronyke/bin/mediavault-generator.sh [OPTIONS] [MEDIA_PATHS...]

DESCRIPTION:
    Generates a self-contained HTML5 media gallery with advanced features including
    IndexedDB caching, dynamic theming, multiple layouts, and touch support.

OPTIONS:
    -h, --help              Show this help message
    -o, --output FILE       Output HTML file (default: mediavault-gallery.html)
    -t, --title TITLE       Gallery title (default: MediaVault Gallery)
    -v, --verbose           Enable verbose output showing progress
    --theme THEME           Initial theme: cyber, neon, minimal, nature, retro, glassmorphism
    --layout LAYOUT         Initial layout: masonry, grid, carousel, timeline, scatter, spiral (default: masonry)
    --speed MS              Slideshow speed in milliseconds (default: 4000)
    --columns N             Grid columns (default: auto)
    --thumb-size SIZE       Thumbnail size in pixels (default: 400)
    --max-cache MB          Max cache size in MB (default: 4000000)
    --no-cache              Disable IndexedDB caching
    --no-ai-theme           Disable AI-based theming
    --no-exif               Disable EXIF data display
    --face-detection        Enable face detection features
    --no-lazy               Disable lazy loading
    --no-keyboard           Disable keyboard shortcuts
    --no-touch              Disable touch gestures
    --no-fullscreen         Disable fullscreen API
    --no-share              Disable share API
    --no-clipboard          Disable clipboard API
    --no-vibration          Disable vibration feedback
    --no-3d                 Disable 3D transforms
    --music-viz             Enable music visualizer for videos
    --particles             Enable particle effects
    --debug                 Enable debug mode with detailed output
    --auto-open             Auto-open gallery in browser
    -r, --recursive         Recursively scan directories
    --include-pattern PAT   Include files matching pattern
    --exclude-pattern PAT   Exclude files matching pattern

EXAMPLES:
    # Basic usage with images directory
    /home/defcronyke/bin/mediavault-generator.sh ~/Pictures

    # Multiple sources with custom output
    /home/defcronyke/bin/mediavault-generator.sh -o my-gallery.html ~/Photos ~/Videos

    # Verbose mode with recursive scan
    /home/defcronyke/bin/mediavault-generator.sh -v -r ~/Pictures

    # Advanced configuration
    /home/defcronyke/bin/mediavault-generator.sh --theme neon --layout masonry --face-detection \
       --particles --music-viz -r ~/Media

SUPPORTED FORMATS:
    Images: jpg, jpeg, png, gif, webp, avif, svg, bmp, ico
    Videos: mp4, webm, ogg, mov, avi, mkv, m4v

KEYBOARD SHORTCUTS:
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

```

## License

[MIT License](./LICENSE)

