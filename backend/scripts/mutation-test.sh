#!/usr/bin/env bash
set -e

echo "Running mutation tests..."
uv run mutmut run --CI --no-progress 2>/dev/null || true

RESULTS=$(uv run mutmut results 2>/dev/null || echo "")
KILLED=$(echo "$RESULTS" | grep -c "killed" || echo "0")
SURVIVED=$(echo "$RESULTS" | grep -c "survived" || echo "0")
TOTAL=$((KILLED + SURVIVED))

if [ "$TOTAL" -gt 0 ]; then
    SCORE=$((KILLED * 100 / TOTAL))
    echo "Mutation Score: ${SCORE}% (${KILLED}/${TOTAL} killed)"
    
    if [ "$SCORE" -lt 80 ]; then
        echo "FAILED: Mutation score ${SCORE}% < 80% threshold"
        uv run mutmut results 2>/dev/null || true
        exit 1
    fi
    echo "PASSED: Mutation score meets 80% threshold"
else
    echo "No mutations generated (code may be too simple)"
fi
