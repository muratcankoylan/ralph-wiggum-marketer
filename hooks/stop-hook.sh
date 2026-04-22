#!/bin/bash
#
# Ralph the Marketer - Stop Hook
#
# This hook intercepts Claude's exit attempts during an active Ralph loop.
# It re-feeds the prompt to continue iterative content creation.
#
# Loop state is stored in: .claude/ralph-marketer-loop.local.md
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOOP_STATE_FILE=".claude/ralph-marketer-loop.local.md"

# Read the stop hook input from stdin
INPUT=$(cat)

# Check if we have an active loop
if [ ! -f "$LOOP_STATE_FILE" ]; then
  # No active loop, allow normal exit
  exit 0
fi

# Parse the loop state file (YAML frontmatter)
ITERATION=$(grep -E "^iteration:" "$LOOP_STATE_FILE" 2>/dev/null | sed 's/iteration: *//' | tr -d ' ')
MAX_ITERATIONS=$(grep -E "^max_iterations:" "$LOOP_STATE_FILE" 2>/dev/null | sed 's/max_iterations: *//' | tr -d ' ')
COMPLETION_PROMISE=$(grep -E "^completion_promise:" "$LOOP_STATE_FILE" 2>/dev/null | sed 's/completion_promise: *//')

# Validate numeric fields
if ! [[ "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Warning: Invalid iteration count in loop state. Removing corrupted state file." >&2
  rm -f "$LOOP_STATE_FILE"
  exit 0
fi

if ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  MAX_ITERATIONS=999999
fi

# Extract the last assistant message to check for completion
LAST_OUTPUT=$(echo "$INPUT" | jq -r '.transcript[-1].content // ""' 2>/dev/null || echo "")

# Check for completion promise
if [ -n "$COMPLETION_PROMISE" ]; then
  if echo "$LAST_OUTPUT" | grep -qF "<promise>${COMPLETION_PROMISE}</promise>"; then
    # Completion detected! Clean up and exit
    rm -f "$LOOP_STATE_FILE"
    echo '{"decision": "allow", "message": "Ralph loop completed successfully!"}'
    exit 0
  fi
fi

# Check iteration limit
NEXT_ITERATION=$((ITERATION + 1))
if [ "$NEXT_ITERATION" -gt "$MAX_ITERATIONS" ]; then
  rm -f "$LOOP_STATE_FILE"
  echo '{"decision": "allow", "message": "Max iterations reached. Loop terminated."}'
  exit 0
fi

# Update iteration count in state file
sed -i '' "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$LOOP_STATE_FILE" 2>/dev/null || \
sed -i "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$LOOP_STATE_FILE"

# Read the original prompt from state file (everything after the frontmatter)
PROMPT=$(sed -n '/^---$/,/^---$/!p' "$LOOP_STATE_FILE" | tail -n +1)

# If no stored prompt, use the default from templates
if [ -z "$PROMPT" ] || [ "$PROMPT" = "" ]; then
  if [ -f "scripts/ralph/prompt.md" ]; then
    PROMPT=$(cat "scripts/ralph/prompt.md")
  else
    PROMPT="Continue working on the content tasks. Check prd.json for remaining stories."
  fi
fi

# Build the system message for this iteration
SYSTEM_MSG="[Ralph Marketer Loop - Iteration $NEXT_ITERATION of $MAX_ITERATIONS]

You are in an active Ralph loop. The same task is being fed to you again.
Your previous work is visible in the files and git history.

Continue where you left off. Check:
- scripts/ralph/prd.json for remaining tasks
- scripts/ralph/progress.txt for learnings

When ALL tasks are complete, output: <promise>${COMPLETION_PROMISE:-COMPLETE}</promise>

---

$PROMPT"

# Return the block decision with the new prompt
jq -n --arg decision "block" --arg message "$SYSTEM_MSG" \
  '{decision: $decision, message: $message}'
