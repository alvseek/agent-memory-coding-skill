#!/bin/bash
# setup-all-antigravity.sh - Install the agent-memory-coding-skill OVERLAY procedures as ~/.gemini/workflows/.
#
# Installs the coding/repo overlay procedures. Composes ON TOP OF the memory core
# (agent-memory-system) — install the core too. Own manifest so it cleans up independently.
#
# Usage:        bash setup-scripts/setup-all-antigravity.sh
# Env override: AGENT_MEMORY_TARGET_DIR (default: ~/.gemini/workflows)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROC_DIR="$(dirname "$SCRIPT_DIR")/procedures"
TARGET_DIR="${AGENT_MEMORY_TARGET_DIR:-$HOME/.gemini/workflows}"
MANIFEST_FILE="$TARGET_DIR/.agent-memory-coding-skill-manifest"

echo "=== Install agent-memory-coding-skill OVERLAY Workflows ==="
echo ""
echo "Source (overlay): $PROC_DIR"
echo "Target:           $TARGET_DIR"
echo ""

if [ ! -d "$PROC_DIR" ]; then echo "Error: overlay procedures directory not found: $PROC_DIR"; exit 1; fi

mkdir -p "$TARGET_DIR"

# Clean up previously installed OVERLAY files using the overlay manifest (leaves core workflows untouched).
if [ -f "$MANIFEST_FILE" ]; then
    echo "Cleaning up previously installed overlay workflows..."
    CLEANED=0
    while IFS= read -r filename; do
        if [ -n "$filename" ] && [ -f "$TARGET_DIR/$filename" ]; then
            rm "$TARGET_DIR/$filename"
            CLEANED=$((CLEANED + 1))
        fi
    done < "$MANIFEST_FILE"
    echo "  Removed $CLEANED stale overlay workflows"
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

echo "Successfully installed $TOTAL_COUNT overlay procedures as workflows!"
echo ""
echo "Installed overlay workflows:"
while IFS= read -r fname; do echo "  /$(basename "$fname" .md)"; done < "$MANIFEST_FILE"
