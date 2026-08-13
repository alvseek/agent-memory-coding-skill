#!/bin/bash
# compile-procedures.sh - Compile procedures/*.md into self-contained output/*.md.
#
# Produces install-ready commands with NO references to the overlay's own component/template files:
#   - Components ([...](.../components/X.md)) are INLINED at the reference point (link -> plain text,
#     component body inserted right after — caller params in the sentence are preserved).
#   - Templates ([...](.../plan-templates|templates/X.md[#anchor]) OR `.../templates/X.md`) are inlined
#     ONCE as a bottom "## Templates" appendix (collected TRANSITIVELY, so a template that references
#     another template pulls it in too); every reference is rewritten to an in-doc anchor.
#   - Runtime refs are LEFT ALONE: [AGENT-MEMORY-PATH]/... (where memory lives) and
#     [path-to-agent-memory-coding-skill]/scripts/*.sh (executables the agent runs).
#
# Output name == source name, so /wait-options stays /wait-options.
#
# Usage: bash setup-scripts/compile-procedures.sh

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
PROC_DIR="$ROOT/procedures"
COMP_DIR="$ROOT/components"
TPL_DIRS=("$ROOT/plan-templates" "$ROOT/templates")
OUT_DIR="$ROOT/output"

if [ ! -d "$PROC_DIR" ]; then echo "Error: procedures/ not found at $PROC_DIR"; exit 1; fi
rm -rf "$OUT_DIR"; mkdir -p "$OUT_DIR"

# Locate a template file by bare name across the template dirs.
find_tpl() {
    local name="$1" d
    for d in "${TPL_DIRS[@]}"; do
        if [ -f "$d/$name.md" ]; then echo "$d/$name.md"; return 0; fi
    done
    return 1
}

# high-wizard-plan-template -> "High Wizard Plan Template" (heading anchor == the bare name).
titlecase() { echo "$1" | sed -E 's/-/ /g' | awk '{for(i=1;i<=NF;i++)$i=toupper(substr($i,1,1)) substr($i,2)}1'; }

# Bare template names referenced in a file (link OR backtick code-path form), unique, in order.
tpl_names_in() { grep -oE '/(plan-templates|templates)/[a-z-]+\.md' "$1" | sed -E 's#.*/##; s#\.md##' | awk '!s[$0]++'; }

NPROC=$(ls -1 "$PROC_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Compiling $NPROC procedures (inlining components + templates) -> $OUT_DIR ..."
total=0
for f in "$PROC_DIR"/*.md; do
    [ -f "$f" ] || continue
    echo "  [$((total + 1))/$NPROC] $(basename "$f")"
    out="$OUT_DIR/$(basename "$f")"
    tmp="$(mktemp)"

    # --- Pass 1: inline components at the reference point (single awk pass) ---
    awk -v compdir="$COMP_DIR" '
        function inline_comp(name,   file, line, started) {
            file = compdir "/" name ".md"; started = 0
            while ((getline line < file) > 0) { if (started) print line; if (line ~ /^---[ \t]*$/) started = 1 }
            close(file)
        }
        {
            if ($0 ~ /\/components\/[a-z-]+\.md\)/) {
                match($0, /\/components\/[a-z-]+\.md/); name = substr($0, RSTART, RLENGTH)
                gsub(/\/components\/|\.md/, "", name)
                print gensub(/\[([^]]*)\]\([^)]*\)/, "\\1", "g", $0)   # de-link, keep label + caller params
                print ""
                inline_comp(name)
            } else print $0
        }
    ' "$f" > "$tmp"

    # --- Pass 2: collect referenced templates TRANSITIVELY ---
    unset seen; declare -A seen; order=(); queue=()
    while read -r nm; do
        [ -n "$nm" ] && [ -z "${seen[$nm]:-}" ] && { seen[$nm]=1; order+=("$nm"); queue+=("$nm"); }
    done < <(tpl_names_in "$tmp")
    qi=0
    while [ "$qi" -lt "${#queue[@]}" ]; do
        nm="${queue[$qi]}"; qi=$((qi + 1))
        tf="$(find_tpl "$nm")" || continue
        while read -r n2; do
            [ -n "$n2" ] && [ -z "${seen[$n2]:-}" ] && { seen[$n2]=1; order+=("$n2"); queue+=("$n2"); }
        done < <(tpl_names_in "$tf")
    done

    # --- Append the Templates appendix (at the very bottom) ---
    if [ "${#order[@]}" -gt 0 ]; then
        {
            echo ""; echo "---"; echo ""; echo "## Templates"; echo ""
            echo "*Inlined at compile time — the procedure above references these by anchor.*"
            for tn in "${order[@]}"; do
                echo ""; echo "### $(titlecase "$tn")"; echo ""
                if tf="$(find_tpl "$tn")"; then awk 'NR==1 && /^# / {next} {print}' "$tf"
                else echo "> [compile: template $tn.md not found]"; fi
            done
        } >> "$tmp"
    fi

    # --- Final rewrite: template refs -> in-doc anchors (link + code-path forms) ---
    sed -E \
        -e 's@\]\([^)]*/(plan-templates|templates)/[a-z-]+\.md#([a-z0-9-]+)\)@](#\2)@g' \
        -e 's@\]\([^)]*/(plan-templates|templates)/([a-z-]+)\.md\)@](#\2)@g' \
        -e 's@`\[path-to-agent-memory-coding-skill\]/(plan-templates|templates)/([a-z-]+)\.md`@[\2](#\2)@g' \
        "$tmp" > "$out"

    rm -f "$tmp"
    total=$((total + 1))
done

echo "Compiled $total procedures -> $OUT_DIR"
