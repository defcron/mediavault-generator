#!/bin/bash
HOST_PORT=${HOST_PORT:-8000}

which python >/dev/null 2>&1 && [ -z "$PYTHON_CMD" ] && \
PYTHON_CMD="python"

which python3 >/dev/null 2>&1 && [ -z "$PYTHON_CMD" ] && \
PYTHON_CMD="python3"

${PYTHON_CMD} -m http.server -b localhost $HOST_PORT
