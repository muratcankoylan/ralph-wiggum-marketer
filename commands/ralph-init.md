---
description: Initialize a new Ralph Marketer project in the current directory
allowed-tools: [Bash, Write, Read, Glob]
model: sonnet
---

# Initialize Ralph the Marketer

Set up a new Ralph Marketer copywriting project in the current directory.

## What This Does

1. Creates the directory structure for Ralph
2. Copies template files (prd.json, progress.txt, prompt.md)
3. Sets up the content database with sample data
4. Creates content directories (drafts/, published/)

## Setup Steps

```bash
# Create directories
mkdir -p scripts/ralph content/{drafts,published} data scripts/src/{db,content}

# Copy database scripts from plugin
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
cp "$PLUGIN_ROOT/scripts/src/db/init.js" scripts/src/db/
cp "$PLUGIN_ROOT/scripts/src/db/seed.js" scripts/src/db/
cp "$PLUGIN_ROOT/scripts/src/db/status.js" scripts/src/db/
cp "$PLUGIN_ROOT/scripts/src/db/query.js" scripts/src/db/
cp "$PLUGIN_ROOT/scripts/src/content/list.js" scripts/src/content/
cp "$PLUGIN_ROOT/scripts/src/test.js" scripts/src/

# Copy Ralph templates
cp "$PLUGIN_ROOT/templates/prd.json" scripts/ralph/
cp "$PLUGIN_ROOT/templates/progress.txt" scripts/ralph/
cp "$PLUGIN_ROOT/templates/prompt.md" scripts/ralph/

# Copy package.json if it doesn't exist
if [ ! -f package.json ]; then
  cp "$PLUGIN_ROOT/templates/package.json" .
fi

# Create .gitkeep files
touch content/drafts/.gitkeep content/published/.gitkeep data/.gitkeep

# Initialize git if needed
if [ ! -d .git ]; then
  git init
fi

# Install dependencies
npm install

# Initialize and seed database
npm run db:reset

echo "✅ Ralph Marketer initialized!"
echo ""
echo "Next steps:"
echo "  1. Edit scripts/ralph/prd.json with your content tasks"
echo "  2. Run /ralph-marketer to start the loop"
```

## After Initialization

The user should:
1. Customize `scripts/ralph/prd.json` with their specific content tasks
2. Optionally modify the seed data in `src/db/seed.js` with their own trends/research/communications
3. Run `/ralph-marketer` to start the autonomous content creation loop
