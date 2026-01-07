# Ralph Wiggum Marketer

A **Claude Code Plugin** that provides an autonomous AI copywriter for SaaS content marketing.

Uses the [Ralph Wiggum pattern](https://ghuntley.com/ralph/) - an iterative AI loop that ships content while you sleep.

## Installation

### Option 1: Add as Marketplace (Recommended)

```bash
# In Claude Code, add the repo as a marketplace:
/plugin marketplace add muratcankoylan/ralph-wiggum-marketer

# Then install the plugin:
/plugin install ralph-wiggum-marketer@muratcankoylan-ralph-wiggum-marketer
```

### Option 2: Test Locally (For Development)

```bash
# Clone the repo
git clone https://github.com/muratcankoylan/ralph-wiggum-marketer.git

# Run Claude Code with the plugin directory
claude --plugin-dir ./ralph-wiggum-marketer
```

### Option 3: Interactive Plugin Manager

```bash
# Open the plugin manager:
/plugin

# Browse, search, and install from the interactive UI
```

## Quick Start

```bash
# 1. Initialize a new content project
/ralph-init

# 2. Start the autonomous copywriter loop
/ralph-marketer --max-iterations 25

# 3. Check progress anytime
/ralph-status

# 4. Cancel if needed
/ralph-cancel
```

## Commands

| Command | Description |
|---------|-------------|
| `/ralph-init` | Initialize a new content project in current directory |
| `/ralph-marketer` | Start the autonomous copywriter loop |
| `/ralph-status` | Check content pipeline and progress |
| `/ralph-cancel` | Cancel the active loop |

## How It Works

```
┌──────────────────────────────────────────────────────────────────┐
│                     MULTI-AGENT ECOSYSTEM                        │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐            │
│  │ TrendScout  │   │  Research   │   │  Product/   │            │
│  │   Agent     │   │   Agent     │   │  Marketing  │            │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘            │
│         │                 │                 │                    │
│         ▼                 ▼                 ▼                    │
│  ┌────────────────────────────────────────────────────┐         │
│  │              SQLite Content Database               │         │
│  │  • trends     • research     • communications      │         │
│  └────────────────────────┬───────────────────────────┘         │
│                           │                                      │
│                           ▼                                      │
│  ┌────────────────────────────────────────────────────┐         │
│  │           RALPH THE COPYWRITER                     │         │
│  │                                                     │         │
│  │   Reads inputs → Plans content → Writes drafts     │         │
│  │   → Reviews & iterates → Publishes                 │         │
│  │                                                     │         │
│  │   Memory: git commits + progress.txt + prd.json    │         │
│  └────────────────────────────────────────────────────┘         │
│                           │                                      │
│                           ▼                                      │
│                    Published Content                             │
│              (blogs, case studies, social, newsletters)          │
└──────────────────────────────────────────────────────────────────┘
```

### The Ralph Loop

1. **Read PRD**: Check `scripts/ralph/prd.json` for tasks
2. **Check Progress**: Read `scripts/ralph/progress.txt` for learnings
3. **Pick Task**: Find highest priority story where `passes: false`
4. **Execute**: Complete the task following acceptance criteria
5. **Verify**: Run tests to ensure quality
6. **Commit**: Save progress to git
7. **Update**: Mark task done, log learnings
8. **Repeat**: Loop until all tasks complete

Each iteration is a fresh context window. Memory persists through files.

## Plugin Structure

```
ralph-wiggum-marketer/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── ralph-marketer.md    # Main loop command
│   ├── ralph-init.md        # Project initialization
│   ├── ralph-status.md      # Status check
│   └── ralph-cancel.md      # Cancel loop
├── skills/
│   └── copywriter/
│       └── SKILL.md         # Copywriter skill
├── hooks/
│   ├── hooks.json           # Hook configuration
│   └── stop-hook.sh         # Loop continuation hook
├── scripts/
│   └── src/                 # Database & utility scripts
├── templates/
│   ├── prd.json             # Task template
│   ├── progress.txt         # Progress log template
│   ├── prompt.md            # Agent instructions template
│   └── package.json         # Project package.json template
└── README.md
```

## Content Types

Ralph can create:

| Type | Word Count | Structure |
|------|------------|-----------|
| Blog Post | 800-2000 | Hook → Problem → Solution → Proof → CTA |
| Case Study | 1000-1500 | Challenge → Solution → Results → Quote |
| Social Post | <280 chars | Hook + Value + CTA + Hashtags |
| Newsletter | 500-800 | Intro → Summaries → Trend → CTA |

## Database Schema

### Input Tables (from other agents)

```sql
-- Trends from TrendScout
trends (topic, description, source, relevance_score, status)

-- Research from Research Agent
research (title, summary, key_findings, data_points, category, status)

-- Communications from Product/Marketing
communications (type, title, details, key_messages, target_audience, priority, status)
```

### Ralph's Workspace

```sql
-- Content planning
content_plan (content_type, title, brief, target_keywords, status)

-- Work in progress
drafts (plan_id, version, content, word_count, feedback)

-- Final content
published (plan_id, final_content, meta_description)

-- Activity tracking
agent_log (action, details, created_at)
```

## Customizing

### Add Your Own Content Sources

Edit `src/db/seed.js`:

```javascript
// Add a trend
insertTrend.run(
  'Your Trend Topic',
  'Description of the trend',
  'Source',
  85  // relevance score
);

// Add a communication
insertComm.run(
  'product_update',
  'Your Product Launch',
  'Details about what it does',
  JSON.stringify(['Key message 1', 'Key message 2']),
  'Target audience',
  1  // priority
);
```

### Add Your Own Tasks

Edit `scripts/ralph/prd.json`:

```json
{
  "id": "WRITE-004",
  "title": "Write your custom blog",
  "acceptanceCriteria": [
    "At least 1000 words",
    "Includes 3 data points",
    "Has compelling CTA"
  ],
  "priority": 5,
  "passes": false
}
```

## Sample Tasks

The default PRD includes 12 stories:

1. **SETUP-001**: Initialize database
2. **PLAN-001**: Plan product launch blog
3. **WRITE-001**: Write launch blog draft
4. **PLAN-002**: Plan thought leadership blog
5. **WRITE-002**: Write data-driven blog
6. **REVIEW-001**: Review and improve draft
7. **PUBLISH-001**: Publish launch blog
8. **PLAN-003**: Plan case study
9. **WRITE-003**: Write case study
10. **SOCIAL-001**: Create social posts
11. **NEWSLETTER-001**: Draft newsletter
12. **METRICS-001**: Log final metrics

## The Ralph Philosophy

> "Ralph is a Bash loop. Memory persists only through git history and text files. Each iteration is a fresh context window."

Key principles:
- **Small stories** - Must complete in one iteration
- **Explicit criteria** - No ambiguity
- **Fast feedback** - Tests every iteration
- **Compound learnings** - Patterns accumulate
- **Persistence wins** - Keep iterating

## Credits

- Original Ralph concept: [@GeoffreyHuntley](https://ghuntley.com/ralph/)
- Official Ralph plugin: [claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-wiggum)
- Video walkthrough: [@mattpocockuk](https://twitter.com/mattpocockuk)

## License

MIT
