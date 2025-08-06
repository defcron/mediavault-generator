#!/bin/bash
FILENAME="${1:-"gallery.example.1.html"}"
shift 1
TARGETS="${@:-.}"

HOST_PORT=${HOST_PORT:-8000} mediavault-generator.sh -v --face-detection -o "${FILENAME}" "${TARGETS}"
ln -sf "${FILENAME}" index.html

which python >/dev/null 2>&1 && [ -z "$PYTHON_CMD" ] && \
PYTHON_CMD="python"

which python3 >/dev/null 2>&1 && [ -z "$PYTHON_CMD" ] && \
PYTHON_CMD="python3"

${PYTHON_CMD} -m http.server -b localhost $HOST_PORT
