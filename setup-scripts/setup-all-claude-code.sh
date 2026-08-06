#!/bin/bash
# setup-all-claude-code.sh - Install the agent-memory-coding-skill OVERLAY procedures as ~/.claude/commands/.
#
# Installs the coding/repo overlay procedures (wizards, doc-gen, QA, fleet, map-orientation,
# localize-context, wait-options, push/pull, project-wrap-up, awaken-coder). This overlay composes
# ON TOP OF the memory core (agent-memory-system) — install the core too (run its own installer).
# Uses its OWN manifest so it cleans up independently of the core.
#
# Usage:        bash setup-scripts/setup-all-claude-code.sh
# Env override: AGENT_MEMORY_TARGET_DIR (default: ~/.claude/commands)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROC_DIR="$(dirname "$SCRIPT_DIR")/procedures"
TARGET_DIR="${AGENT_MEMORY_TARGET_DIR:-$HOME/.claude/commands}"
MANIFEST_FILE="$TARGET_DIR/.agent-memory-coding-skill-manifest"

echo "=== Setup agent-memory-coding-skill OVERLAY Slash Commands ==="
echo ""
echo "Source (overlay): $PROC_DIR"
echo "Target:           $TARGET_DIR"
echo ""

if [ ! -d "$PROC_DIR" ]; then echo "Error: overlay procedures directory not found: $PROC_DIR"; exit 1; fi

mkdir -p "$TARGET_DIR"

# Clean up previously installed OVERLAY files using the overlay manifest (leaves core commands untouched).
if [ -f "$MANIFEST_FILE" ]; then
    echo "Cleaning up previously installed overlay commands..."
    CLEANED=0
    while IFS= read -r filename; do
        if [ -n "$filename" ] && [ -f "$TARGET_DIR/$filename" ]; then
            rm "$TARGET_DIR/$filename"
            CLEANED=$((CLEANED + 1))
        fi
    done < "$MANIFEST_FILE"
    echo "  Removed $CLEANED stale overlay commands"
    echo ""
fi

# Copy overlay procedures/*.md; record each in the overlay manifest.
: > "$MANIFEST_FILE"
TOTAL_COUNT=0
for file in "$PROC_DIR"/*.md; do
    [ -f "$file" ] || continue
    cp "$file" "$TARGET_DIR/"
    basename "$file" >> "$MANIFEST_FILE"
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
done

if [ "$TOTAL_COUNT" -eq 0 ]; then
    echo "Error: No .md files found in $PROC_DIR"
    exit 1
fi

echo "Successfully installed $TOTAL_COUNT overlay procedures!"
echo ""
echo "Installed overlay commands:"
while IFS= read -r fname; do echo "  /$(basename "$fname" .md)"; done < "$MANIFEST_FILE"
