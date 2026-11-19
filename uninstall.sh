#!/usr/bin/env bash
# Flutter Agent Toolkit — Uninstaller (Linux & macOS)

set -euo pipefail

echo "Uninstalling Flutter Agent Toolkit MCP servers and tools..."

# Remove global binaries
rm -f "$HOME/.local/bin/evolvemem-mcp"
if command -v dart &>/dev/null; then
  dart pub global deactivate marionette_mcp 2>/dev/null || true
fi
if command -v uv &>/dev/null; then
  uv tool uninstall graphifyy 2>/dev/null || true
fi

echo "To remove the EvolveMem SQLite database and virtual environment, run:"
echo "  rm -rf ~/.evolvemem"

echo "Uninstall complete."
