---
name: setup-project
description: Full bootstrap for Elixir/Phoenix/Ash projects. Installs quality tools (credo, sobelow), Claude Code integration (hooks, skills, MCP), writes Ash/LiveView/Oban conventions to CLAUDE.md, fetches ash-vibez, and runs initial scan. One command to make any project AI-ready. Use on new or existing projects.
---

# Full Project Bootstrap for Elixir/Phoenix/Ash

You are a project bootstrapper. One command sets up EVERYTHING an AI agent needs to write quality code on this project: tools, hooks, conventions, patterns.

## What you install

1. **Quality tools** — credo (linter), sobelow (security scanner)
2. **Claude Code integration** — `claude` hex package, tidewave MCP, usage_rules
3. **Hooks** — credo per-file after edit (~0.04s), sobelow on stop (~1.3s), compile, format
4. **`.credo.exs`** — tuned for Ash/Phoenix/LiveView (no noise)
5. **Conventions in CLAUDE.md** — Ash patterns, LiveView component rules, Oban pitfalls, common traps
6. **Ash guidance** — fetch ash-vibez for up-to-date Ash documentation
7. **Initial scan** — baseline report + offer to auto-fix

## Step-by-step procedure

### Step 1: Detect project type

Read `mix.exs` to determine:
- Is this an Elixir project? (required)
- Is Phoenix present? (for sobelow + LiveView conventions)
- Is Ash Framework present? (for Ash conventions + ModuleDoc tuning)
- Is Oban present? (for Oban worker conventions)
- What's already installed? (skip what exists)

Report what you found and what you'll install.

### Step 2: Add dependencies to `mix.exs`

Add missing deps to the `deps` function:

```elixir
# Quality tools
{:credo, "~> 1.7", only: [:dev, :test], runtime: false},
{:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},  # only if Phoenix

# Claude Code integration
{:claude, "~> 0.5", only: [:dev], runtime: false},
{:tidewave, "~> 0.4", only: [:dev]},
{:usage_rules, "~> 0.1", only: [:dev]},
```

Skip any already present. Keep alphabetical order.

### Step 3: Create `.credo.exs`

Create `.credo.exs` in project root. Key tuning:
- **Only scan `lib/`** — tests don't need style enforcement
- **ModuleDoc disabled** if Ash project (Ash resources have own conventions), **enabled** otherwise
- **Cyclomatic complexity max: 13** — LiveView handle_event naturally has more branches
- **Function arity max: 8** — polling/recursive functions need more params
- **Nesting max: 3** — `with` + `case` in workers is normal
- **TODO exit_status: 0** — TODOs should not block the agent
- **AliasUsage threshold: called > 1** — alias required only from 2 uses

```elixir
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: true,
      checks: %{
        enabled: [
          {Credo.Check.Consistency.ExceptionNames, []},
          {Credo.Check.Consistency.LineEndings, []},
          {Credo.Check.Consistency.ParameterPatternMatching, []},
          {Credo.Check.Consistency.SpaceAroundOperators, []},
          {Credo.Check.Consistency.SpaceInParentheses, []},
          {Credo.Check.Consistency.TabsOrSpaces, []},
          {Credo.Check.Design.AliasUsage,
           [priority: :low, if_nested_deeper_than: 2, if_called_more_often_than: 1]},
          {Credo.Check.Design.TagFIXME, []},
          {Credo.Check.Design.TagTODO, [exit_status: 0]},
          {Credo.Check.Readability.AliasOrder, []},
          {Credo.Check.Readability.FunctionNames, []},
          {Credo.Check.Readability.LargeNumbers, []},
          {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
          {Credo.Check.Readability.ModuleAttributeNames, []},
          # If Ash: {Credo.Check.Readability.ModuleDoc, false},
          # If NOT Ash: {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Readability.ModuleNames, []},
          {Credo.Check.Readability.ParenthesesInCondition, []},
          {Credo.Check.Readability.ParenthesesOnZeroArityDefs, []},
          {Credo.Check.Readability.PredicateFunctionNames, []},
          {Credo.Check.Readability.PreferImplicitTry, []},
          {Credo.Check.Readability.RedundantBlankLines, []},
          {Credo.Check.Readability.Semicolons, []},
          {Credo.Check.Readability.SpaceAfterCommas, []},
          {Credo.Check.Readability.StringSigils, []},
          {Credo.Check.Readability.TrailingBlankLine, []},
          {Credo.Check.Readability.TrailingWhiteSpace, []},
          {Credo.Check.Readability.UnnecessaryAliasExpansion, []},
          {Credo.Check.Readability.VariableNames, []},
          {Credo.Check.Readability.WithSingleClause, []},
          {Credo.Check.Refactor.Apply, []},
          {Credo.Check.Refactor.CondStatements, []},
          {Credo.Check.Refactor.CyclomaticComplexity, [max_complexity: 13]},
          {Credo.Check.Refactor.FilterCount, []},
          {Credo.Check.Refactor.FilterFilter, []},
          {Credo.Check.Refactor.FunctionArity, [max_arity: 8]},
          {Credo.Check.Refactor.LongQuoteBlocks, []},
          {Credo.Check.Refactor.MapJoin, []},
          {Credo.Check.Refactor.MatchInCondition, []},
          {Credo.Check.Refactor.NegatedConditionsInUnless, []},
          {Credo.Check.Refactor.NegatedConditionsWithElse, []},
          {Credo.Check.Refactor.Nesting, [max_nesting: 3]},
          {Credo.Check.Refactor.RedundantWithClauseResult, []},
          {Credo.Check.Refactor.RejectReject, []},
          {Credo.Check.Refactor.UnlessWithElse, []},
          {Credo.Check.Refactor.WithClauses, []},
          {Credo.Check.Warning.ApplicationConfigInModuleAttribute, []},
          {Credo.Check.Warning.BoolOperationOnSameValues, []},
          {Credo.Check.Warning.Dbg, []},
          {Credo.Check.Warning.ExpensiveEmptyEnumCheck, []},
          {Credo.Check.Warning.IExPry, []},
          {Credo.Check.Warning.IoInspect, []},
          {Credo.Check.Warning.MissedMetadataKeyInLoggerConfig, []},
          {Credo.Check.Warning.OperationOnSameValues, []},
          {Credo.Check.Warning.OperationWithConstantResult, []},
          {Credo.Check.Warning.RaiseInsideRescue, []},
          {Credo.Check.Warning.SpecWithStruct, []},
          {Credo.Check.Warning.StructFieldAmount, []},
          {Credo.Check.Warning.UnsafeExec, []},
          {Credo.Check.Warning.UnusedEnumOperation, []},
          {Credo.Check.Warning.UnusedFileOperation, []},
          {Credo.Check.Warning.UnusedKeywordOperation, []},
          {Credo.Check.Warning.UnusedListOperation, []},
          {Credo.Check.Warning.UnusedMapOperation, []},
          {Credo.Check.Warning.UnusedPathOperation, []},
          {Credo.Check.Warning.UnusedRegexOperation, []},
          {Credo.Check.Warning.UnusedStringOperation, []},
          {Credo.Check.Warning.UnusedTupleOperation, []},
          {Credo.Check.Warning.WrongTestFilename, []}
        ],
        disabled: [
          {Credo.Check.Refactor.UtcNowTruncate, []},
          {Credo.Check.Consistency.MultiAliasImportRequireUse, []},
          {Credo.Check.Consistency.UnusedVariableNames, []},
          {Credo.Check.Design.DuplicatedCode, []},
          {Credo.Check.Design.SkipTestWithoutComment, []},
          {Credo.Check.Readability.AliasAs, []},
          {Credo.Check.Readability.BlockPipe, []},
          {Credo.Check.Readability.ImplTrue, []},
          {Credo.Check.Readability.MultiAlias, []},
          {Credo.Check.Readability.NestedFunctionCalls, []},
          {Credo.Check.Readability.OneArityFunctionInPipe, []},
          {Credo.Check.Readability.OnePipePerLine, []},
          {Credo.Check.Readability.PipeIntoAnonymousFunctions, []},
          {Credo.Check.Readability.SeparateAliasRequire, []},
          {Credo.Check.Readability.SingleFunctionToBlockPipe, []},
          {Credo.Check.Readability.SinglePipe, []},
          {Credo.Check.Readability.Specs, []},
          {Credo.Check.Readability.StrictModuleLayout, []},
          {Credo.Check.Readability.WithCustomTaggedTuple, []},
          {Credo.Check.Refactor.ABCSize, []},
          {Credo.Check.Refactor.AppendSingleItem, []},
          {Credo.Check.Refactor.CondInsteadOfIfElse, []},
          {Credo.Check.Refactor.DoubleBooleanNegation, []},
          {Credo.Check.Refactor.FilterReject, []},
          {Credo.Check.Refactor.IoPuts, []},
          {Credo.Check.Refactor.MapMap, []},
          {Credo.Check.Refactor.ModuleDependencies, []},
          {Credo.Check.Refactor.NegatedIsNil, []},
          {Credo.Check.Refactor.PassAsyncInTestCases, []},
          {Credo.Check.Refactor.PipeChainStart, []},
          {Credo.Check.Refactor.RejectFilter, []},
          {Credo.Check.Refactor.VariableRebinding, []},
          {Credo.Check.Warning.LazyLogging, []},
          {Credo.Check.Warning.LeakyEnvironment, []},
          {Credo.Check.Warning.MapGetUnsafePass, []},
          {Credo.Check.Warning.MixEnv, []},
          {Credo.Check.Warning.UnsafeToAtom, []}
        ]
      }
    }
  ]
}
```

### Step 4: Configure hooks in `.claude.exs`

Read existing `.claude.exs`. If missing, create one. **MERGE** (never replace) these hooks:

- `post_tool_use`: add `{"credo --strict {{tool_input.file_path}}", when: [:write, :edit, :multi_edit]}`
- `stop`: add `{"sobelow --skip -q", blocking?: false}` (only if Phoenix)
- `subagent_stop`: add `{"sobelow --skip -q", blocking?: false}` (only if Phoenix)

Keep ALL existing hooks. Only ADD new entries.

### Step 5: Write conventions to CLAUDE.md

**IMPORTANT**: Read existing `CLAUDE.md` first. If it has a `## Conventions` section, merge into it. If no CLAUDE.md exists, create one. Never overwrite existing content.

Adapt the `AppWeb` module name to match the actual project (find it in `lib/*_web.ex`).

Only include sections relevant to detected project type.

#### Ash Framework conventions (if Ash detected):

```markdown
## Conventions

### Ash Framework
- Every new Ash resource MUST have `authorizers: [Ash.Policy.Authorizer]` and a `policies` block — never commit without it
- Every new Ash resource MUST have proper RBAC policies from the start — never use `bypass authorize_if always()` as placeholder
- Internal workers/cron jobs use `authorize?: false` — never pass `nil` as actor to Ash actions with policies
- NEVER combine `authorize?: false` with `actor:` — if you pass an actor, REMOVE authorize?: false
- Split `[:create, :update]` policies when roles differ — create actions can't use `expr()` on the new record
- Custom Ash policy SimpleCheck for create actions MUST verify actor ownership — `actor_attribute_equals(:role, :client)` alone is IDOR
- Ash custom validations receive context as `%Ash.Resource.Validation.Context{}` — use `context.actor` (dot), NOT `context[:actor]`
- Ash `atomic_update` + `validate compare` don't work together — use DB CHECK constraint for post-update invariants
- Ash `validate compare(:attr, greater_than: ...)` doesn't support dynamic values — use custom validation
- `Ash.Changeset.force_change_attribute/3` needed for `allow_nil? false` attribute from another attribute in create actions
- Use `Ash.count!/2` for counting, never `Ash.read! |> length` — always aggregate at DB level
- Batch-load associations with `Ash.load!(list, :assoc)` before `Enum.map` — never N+1
- Every FK reference in a migration MUST have `create index(:table, [:fk_column])`
- `AshPhoenix.Form` — store raw form in assigns, call `to_form` only in render
```

#### LiveView conventions (if Phoenix detected):

```markdown
### LiveView Components
- **Two types of components:**
  - **Function components** (stateless) — in `AppComponents` module, auto-imported via `use AppWeb, :live_view`. For: badges, icons, stat cards, empty states, page headers
  - **LiveComponents** (stateful) — in `lib/app_web/live/components/`. For: items with own state, events, PubSub
- **Always check existing components** before writing new UI — search `AppComponents` for stateless, `live/components/` for stateful
- **When to use LiveComponent vs function component:** LiveComponent when the element has its own state, handles events independently, or needs isolated re-rendering. Function component for everything else.
- When a UI pattern repeats in 2+ LiveViews, extract it — don't duplicate private helper functions
- **Child LiveView** (`live_render/3`) — only when element must: (1) survive parent navigation, (2) subscribe to PubSub without re-rendering parent, (3) crash-isolate from parent. For everything else use LiveComponents.
- `allow_upload/3` MUST be in parent LiveView's mount, not in LiveComponent
- When a LiveComponent subscribes to PubSub, messages arrive at parent LiveView's `handle_info/2` — parent must handle the message
- Self-contained LiveComponents for complex forms: component manages own AshPhoenix.Form + validation + UI state, parent handles only `{:callback, result}` messages

### LiveView Patterns
- LiveView streams don't expose `.inserts` for emptiness checks — track count separately in assigns
- Workers (Oban) use `authorize?: false`, but LiveView `handle_event` ALWAYS uses `actor: socket.assigns.current_user`
- For PubSub subscriptions affected by URL params, subscribe in `handle_params/3` not `mount/3` — avoids double subscriptions
- When subscribing to PubSub, verify ALL message types have matching `handle_info` clauses
- Never use `String.to_integer` on LiveView form params — always `Integer.parse/1` with error handling
- `String.to_existing_atom` in handle_event crashes on unknown atoms — use explicit pattern match whitelist
- `embed_templates "layouts/*"` auto-generates functions from .heex files — do not define them manually
```

#### Oban conventions (if Oban detected):

```markdown
### Oban Workers
- Oban arg key names must EXACTLY match between `Worker.new(%{"key" => value})` and `args["key"]` in `perform/1`
- When Oban cron enqueues child jobs, wrap state transition + `Oban.insert!` in `Repo.transaction` + add `unique:` to prevent race conditions
- Workers that create + update multiple records MUST wrap in `Repo.transaction` + use `unique: [period: 300, keys: [:key]]`
```

#### Always include:

```markdown
### Config
- `runtime.exs` runs after `dev.exs` and overwrites same config keys — keep dev-specific config in `dev.exs` only
- Static files in `priv/static/` take priority over controller routes
```

### Step 6: Install official plugins

Install these plugins from the official Claude Code marketplace (`claude-plugins-official`). These provide high-quality, maintained skills:

1. **`frontend-design`** — distinctive, production-grade UI generation (LiveView, Tailwind)
2. **`skill-creator`** — create/modify/benchmark skills

To install, run in the Claude Code session:
```
/install-plugin frontend-design
/install-plugin skill-creator
```

If `/install-plugin` is not available, the user should install them manually via the Claude Code plugin manager.

### Step 7: Install implementation pipeline skills

Copy the implementation workflow skills to `.claude/skills/` in the project. These skills create the full AI-assisted development pipeline.

Create `.claude/skills/` directory if missing, then create each skill as a `SKILL.md` file. The source of truth is the adplatform project at `/home/bhf-ai-devel/Projects/adplatform/.claude/skills/`. Copy these:

**Implementation pipeline skills**:
- `prd-generator` — generates PRD from human project plan
- `implementation-plan` — breaks PRD into phased tasks
- `code-execute` — executes tasks from implementation plan
- `autopilot` — full autonomous execution: tasks + review + fix + commit
- `code-review` — parallel review (Security, Performance, Architecture, Logic)
- `code-fix` — auto-fix issues from code-review reports
- `code-complete` — mark tasks done in tasks.md
- `compound` — capture lessons learned after each phase

**Other skills**:
- `grill-me` — stress-test plans via relentless questioning
- `coolify-deploy` — deploy Phoenix to Coolify

Also create `.claude/agents/meta-agent.md` for the Meta Agent subagent (generates new subagents).

**How to copy**: Read each SKILL.md from the adplatform project and write it to the new project. If adplatform is not available at the expected path, ask the user where their reference project is.

### Step 8: Add workflow documentation to CLAUDE.md

Append the implementation workflow to CLAUDE.md so the agent knows the full pipeline:

```markdown
### Implementation Workflow

The project uses a structured AI-assisted development pipeline:

1. **`/prd-generator`** — write a human project plan, get a technical PRD
2. **`/grill-me`** — stress-test the PRD with relentless questions
3. **`/implementation-plan`** — break PRD into phased tasks (tasks.md)
4. **`/code-execute phase:N`** — execute tasks from a specific phase
5. **`/autopilot`** — full autonomous: execute + review + fix + commit per phase
6. **`/code-review`** — parallel review across 4 dimensions
7. **`/code-fix`** — auto-fix blocking/important issues from review
8. **`/compound`** — capture lessons learned after each phase (updates CLAUDE.md)
9. **`/code-complete`** — mark tasks done in tasks.md

Implementation artifacts live in `docs/implementation/`:
- `prd.md` — Product Requirements Document
- `tasks.md` — phased task list with checkboxes
- `context.md` — progress notes and context

Review reports live in `docs/reviews/`.

### Dependency Management
- Use Igniter when available: `mix igniter.install <package>` — handles config, migrations, code generation
- For manual deps: add to `mix.exs`, run `mix deps.get`
- Check outdated: `mix hex.outdated`
```

### Step 9: Install everything

Run in sequence:
1. `mix deps.get`
2. `mix claude.install --yes`
3. `mix compile`

### Step 10: Fetch Ash guidance (if Ash project)

Fetch the Ash Framework guidance index for up-to-date docs:
- URL: https://raw.githubusercontent.com/bradleygolden/ash_vibez/main/llms.txt

### Step 11: Run initial scan and report

Run `mix credo --strict` and (if Phoenix) `mix sobelow --skip -q`.

Report summary:
```
| Tool    | Issues | Breakdown                        |
|---------|--------|----------------------------------|
| Credo   | N      | X refactoring, Y readability,... |
| Sobelow | M      | X high, Y low confidence         |
```

Ask the user if they want to auto-fix credo issues now.

### Step 12: Final summary

Print a checklist of everything installed:

```
Setup complete:
  [x] credo + sobelow (quality tools)
  [x] .credo.exs (tuned config)
  [x] Claude Code hooks (credo per-file, sobelow on stop)
  [x] tidewave MCP + usage_rules
  [x] Conventions in CLAUDE.md (Ash/LiveView/Oban/Config)
  [x] Implementation workflow in CLAUDE.md
  [x] Skills installed (N skills)
  [x] ash-vibez fetched (if Ash)
  [x] Initial scan: N credo issues, M sobelow issues

Available commands:
  /prd-generator    — create PRD from project plan
  /implementation-plan — break PRD into tasks
  /autopilot        — autonomous execution
  /code-review      — parallel code review
  /code-fix         — auto-fix review issues
  /grill-me         — stress-test a design
  /compound         — capture lessons learned
```

## Important rules

- NEVER remove existing hooks, config, or CLAUDE.md content — only ADD/MERGE
- If `.claude.exs` doesn't exist and `claude` package is not available, skip hooks and just install credo+sobelow
- For non-Phoenix projects, skip sobelow and LiveView sections
- For non-Ash projects, keep ModuleDoc enabled and skip Ash section
- For non-Oban projects, skip Oban section
- Always `mix format` after creating config files
- Adapt AppWeb/AppComponents names to match the actual project module names
- When copying skills, read each SKILL.md fully before writing to ensure exact copy
- If Igniter is available (`{:igniter, ...}` in deps), prefer `mix igniter.install` for adding new packages
