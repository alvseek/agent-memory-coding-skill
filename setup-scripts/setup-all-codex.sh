#!/bin/bash
# setup-all-codex.sh - Install the agent-memory-coding-skill OVERLAY procedures as Codex user skills.
#
# Installs the coding/repo overlay procedures. Composes ON TOP OF the memory core
# (agent-memory-system) — install the core too. Own manifest so it cleans up independently.
#
# Usage:        bash setup-scripts/setup-all-codex.sh
# Env override: AGENT_MEMORY_TARGET_DIR (default: ~/.agents/skills)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROC_DIR="$(dirname "$SCRIPT_DIR")/procedures"
TARGET_DIR="${AGENT_MEMORY_TARGET_DIR:-$HOME/.agents/skills}"
MANIFEST_FILE="$TARGET_DIR/.agent-memory-coding-skill-codex-manifest"

echo "=== Setup agent-memory-coding-skill OVERLAY Codex Skills ==="
echo ""
echo "Source (overlay): $PROC_DIR"
echo "Target:           $TARGET_DIR"
echo ""

if [ ! -d "$PROC_DIR" ]; then echo "Error: overlay procedures directory not found: $PROC_DIR"; exit 1; fi

mkdir -p "$TARGET_DIR"

# Clean up previously installed OVERLAY skills using the overlay manifest (leaves core skills untouched).
if [ -f "$MANIFEST_FILE" ]; then
    echo "Cleaning up previously installed overlay skills..."
    CLEANED=0
    while IFS= read -r skill_dir; do
        if [ -n "$skill_dir" ] && [ -d "$TARGET_DIR/$skill_dir" ]; then
            rm -rf "$TARGET_DIR/$skill_dir"
            CLEANED=$((CLEANED + 1))
        fi
    done < "$MANIFEST_FILE"
    echo "  Removed $CLEANED previously installed overlay skills"
    echo ""
fi

create_skill_from_markdown() {
    local source_file="$1"
    local base_name skill_dir_name skill_dir title description

    base_name="$(basename "$source_file" .md)"
    skill_dir_name="agent-memory-$base_name"
    skill_dir="$TARGET_DIR/$skill_dir_name"

    mkdir -p "$skill_dir"

    title="$(sed -n 's/^# //p' "$source_file" | head -n 1)"
    if [ -z "$title" ]; then
        title="$base_name"
    fi

    description="Use when the user wants the \"$title\" procedure or explicitly mentions $base_name."

    {
        echo "---"
        echo "name: $base_name"
        echo "description: $description"
        echo "---"
        echo ""
        echo "Follow this procedure exactly. Treat the content below as the canonical workflow."
        echo ""
        cat "$source_file"
    } > "$skill_dir/SKILL.md"

    echo "$skill_dir_name" >> "$MANIFEST_FILE"
}

: > "$MANIFEST_FILE"
TOTAL_COUNT=0
for file in "$PROC_DIR"/*.md; do
    [ -f "$file" ] || continue
    create_skill_from_markdown "$file"
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
done

if [ "$TOTAL_COUNT" -eq 0 ]; then
    echo "Error: No .md files found in $PROC_DIR"
    exit 1
fi

echo ""
echo "Successfully installed $TOTAL_COUNT overlay Codex skills!"
echo ""
echo "Installed overlay skills:"
while IFS= read -r skill_dir; do
    if [ -f "$TARGET_DIR/$skill_dir/SKILL.md" ]; then
        skill_name="$(sed -n 's/^name: //p' "$TARGET_DIR/$skill_dir/SKILL.md" | head -n 1)"
        echo "  \$$skill_name"
    fi
done < "$MANIFEST_FILE"
