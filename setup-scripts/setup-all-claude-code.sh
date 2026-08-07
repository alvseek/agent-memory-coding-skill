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

# Compile procedures (inline components + templates) into output/, then install FROM output/
# so the installed commands are self-contained (no refs to components/ or templates/).
bash "$SCRIPT_DIR/compile-procedures.sh" || { echo "Error: compile-procedures.sh failed"; exit 1; }

PROC_DIR="$(dirname "$SCRIPT_DIR")/output"
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

# --- Register this overlay's repo path so [path-to-agent-memory-coding-skill] resolves ---
# The overlay's procedures reference their templates via [path-to-agent-memory-coding-skill]/...;
# that placeholder needs a definition in the global CLAUDE.md every agent loads. Since the overlay
# is a standalone repo at an arbitrary location, only its own installer knows the path — so we
# register it here (idempotent, UUID-guarded so re-runs don't duplicate).
OVERLAY_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
PATH_DEF_UUID="9f3c2a1e-7b4d-4e6a-8c1f-2d5e9a3b6c7f"   # marks the overlay-path definition line
if [ ! -f "$CLAUDE_MD" ]; then
    echo "  NOTE: $CLAUDE_MD not found — could not register [path-to-agent-memory-coding-skill]."
    echo "        Run the memory-core setup first (it creates CLAUDE.md), then re-run this installer."
elif grep -q "$PATH_DEF_UUID" "$CLAUDE_MD"; then
    echo "  [path-to-agent-memory-coding-skill] already registered in CLAUDE.md — skipped."
else
    printf '\n- **[path-to-agent-memory-coding-skill]** = `%s`  <!-- overlay-path-def %s -->\n' \
        "$OVERLAY_ROOT" "$PATH_DEF_UUID" >> "$CLAUDE_MD"
    echo "  Registered [path-to-agent-memory-coding-skill] = $OVERLAY_ROOT"
fi
echo ""

echo "Installed overlay commands:"
while IFS= read -r fname; do echo "  /$(basename "$fname" .md)"; done < "$MANIFEST_FILE"
