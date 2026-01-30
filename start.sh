#!/usr/bin/env bash
set -e

echo "Starting OpenClaw wrapper…"

exec node src/server.js
