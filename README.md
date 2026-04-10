# Claude Code Skills for Elixir/Phoenix/Ash

Global skills for AI-assisted Elixir development with Claude Code.
One install, one command — full project setup on any machine.

## Quick Install

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/BehedgeFund/claude-skills/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/BehedgeFund/claude-skills/main/install.ps1 | iex
```

**Manual (any OS):**
```bash
git clone https://github.com/BehedgeFund/claude-skills.git
cd claude-skills
./install.sh        # Linux/macOS
.\install.ps1       # Windows
```

This installs global skills to `~/.claude/skills/`. They become available in every Claude Code session.

---

## Usage: Existing Project

```bash
cd ~/Projects/my-existing-project
claude
> /setup-project
```

The skill detects your stack (Phoenix? Ash? Oban?) and installs only what's missing.

## Usage: New Project

```bash
mix phx.new my_app
cd my_app
claude
> /setup-project
```

---

## What `/setup-project` Does

| Step | What | Details |
|------|------|---------|
| 1 | **Detect stack** | Reads mix.exs for Phoenix, Ash, Oban |
| 2 | **Elixir marketplace plugin** | `bradleygolden/claude-marketplace-elixir` — auto hooks for format, compile, credo, sobelow, ash.codegen on every edit |
| 3 | **Add deps** | credo, sobelow, claude, tidewave, usage_rules |
| 4 | **Create `.credo.exs`** | Tuned for Ash/Phoenix/LiveView (no noise) |
| 5 | **`mix claude.install`** | Hooks, commands (mix:*, claude:*, elixir:*, memory:*), tidewave MCP, meta-agent |
| 6 | **Official plugins** | `frontend-design` + `skill-creator` from Anthropic marketplace |
| 7 | **Conventions to CLAUDE.md** | Ash policies, LiveComponent rules, Oban patterns, config traps |
| 8 | **Implementation pipeline skills** | prd-generator, autopilot, code-review, compound, etc. |
| 9 | **Ash guidance** | Fetches ash-vibez docs (if Ash) |
| 10 | **Initial scan** | Credo + sobelow baseline + offer to auto-fix |

## Available Commands After Setup

### Implementation Pipeline
```
/prd-generator          — write project plan, get technical PRD
/grill-me               — stress-test a plan with relentless questions
/implementation-plan    — break PRD into phased tasks
/code-execute phase:N   — execute tasks from a phase
/autopilot              — full autonomous: execute + review + fix + commit
/code-review            — parallel review (Security, Performance, Architecture, Logic)
/code-fix               — auto-fix blocking/important issues
/compound               — capture lessons learned after each phase
/code-complete          — mark tasks done
```

### Design & Tools
```
/frontend-design        — high-quality LiveView UI
/ash-vibez              — Ash Framework guidance
/coolify-deploy         — deploy Phoenix to Coolify
```

### Project Management
```
/mix:deps               — dependency management
/mix:deps-check         — check outdated deps
/elixir:upgrade         — Elixir/OTP upgrade assistant
/claude:status          — check Claude Code config
```

## Updating

Re-run the install command to update global skills:
```bash
curl -fsSL https://raw.githubusercontent.com/BehedgeFund/claude-skills/main/install.sh | bash
```

Then in each project run `/setup-project` again to update per-project skills.
