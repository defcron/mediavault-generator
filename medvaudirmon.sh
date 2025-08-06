#!/bin/bash
# media-monitor.sh - Monitor media directories for changes
#
# Written by Claude Opus 4 2025-08-05
#
# WARNING!!: NOT TESTED! Use at your own risk
#
# Licensed by the standard MIT License

watch_dir="${1:-.}"
echo "Monitoring $watch_dir for media files..."

while true; do
    img_count=$(find "$watch_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.gif" \) 2>/dev/null | wc -l)
    vid_count=$(find "$watch_dir" -type f \( -iname "*.mp4" -o -iname "*.webm" -o -iname "*.mkv" \) 2>/dev/null | wc -l)
    
    printf "\r📷 Images: %d | 🎬 Videos: %d | Total: %d " "$img_count" "$vid_count" $((img_count + vid_count))
    sleep 2
done
