# Claude Code Skills for Elixir/Phoenix/Ash

Global skills for AI-assisted Elixir development with Claude Code.

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
# Linux/macOS:
./install.sh
# Windows:
.\install.ps1
```

## What you get

### `/setup-project`
Full project bootstrap. Run once on any Elixir/Phoenix/Ash project:
- Installs credo + sobelow with Claude Code hooks
- Creates tuned `.credo.exs` for Ash/Phoenix/LiveView
- Writes conventions to CLAUDE.md (Ash, LiveView, LiveComponent, Oban patterns)
- Copies implementation pipeline skills to the project
- Fetches ash-vibez guidance
- Runs initial scan

### `/ash-vibez`
Fetches up-to-date Ash Framework patterns and documentation.

## Usage

```bash
cd ~/Projects/my-elixir-project
claude
> /setup-project
```

This installs per-project skills including:
- `/prd-generator` - create PRD from project plan
- `/implementation-plan` - break PRD into phased tasks  
- `/autopilot` - autonomous execution + review + fix + commit
- `/code-review` - parallel review (Security, Performance, Architecture, Logic)
- `/code-fix` - auto-fix review issues
- `/compound` - capture lessons learned
- `/grill-me` - stress-test designs

## Updating

Re-run the install command to update all skills to latest version.
