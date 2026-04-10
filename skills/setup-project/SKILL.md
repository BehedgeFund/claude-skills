---
name: setup-project
description: Full bootstrap for Elixir/Phoenix/Ash projects. Installs Elixir marketplace plugin (auto format/compile/credo/sobelow/ash.codegen hooks), quality tools, Claude Code integration, writes conventions to CLAUDE.md, copies implementation pipeline skills. One command to make any project AI-ready.
---

# Full Project Bootstrap for Elixir/Phoenix/Ash

One command sets up EVERYTHING: plugins, tools, hooks, conventions, skills, workflow.

## What you install

1. **Elixir marketplace plugin** — `bradleygolden/claude-marketplace-elixir` with `elixir` + `ash` plugins (auto format, compile, credo, sobelow, ash.codegen hooks per edit)
2. **Quality tools** — credo, sobelow as mix deps + tuned `.credo.exs`
3. **Claude Code integration** — `claude` hex package, tidewave MCP, usage_rules
4. **Official plugins** — `frontend-design`, `skill-creator` from Anthropic marketplace
5. **Conventions in CLAUDE.md** — Ash, LiveView, LiveComponent, Oban patterns
6. **Implementation pipeline skills** — prd-generator, autopilot, code-review, compound, etc.
7. **Initial scan** — baseline report + offer to auto-fix

## Procedure

### Step 1: Detect project type

Read `mix.exs`. Determine:
- Is Phoenix present? (sobelow + LiveView conventions)
- Is Ash Framework present? (Ash conventions + Ash plugin + ModuleDoc tuning)
- Is Oban present? (Oban conventions)
- What's already installed?

Report findings.

### Step 2: Add Elixir marketplace plugin

This is the core — provides automatic hooks for format, compile, credo, sobelow, ash.codegen on every file edit.

```
/plugin marketplace add bradleygolden/claude-marketplace-elixir
```

Then install plugins based on detected stack:

```
/plugin install elixir@elixir
```

If Ash detected:
```
/plugin install elixir@ash
```

These plugins provide PostToolUse hooks that automatically run on every `.ex`/`.exs` edit:
- `mix format` (file)
- `mix compile --warnings-as-errors`
- `mix credo suggest` (if credo dep present)
- `mix sobelow` (if sobelow dep present)
- `mix ash.codegen --check` (if ash dep present)
- `mix hex.audit` (on mix.exs edits)

And PreToolUse hooks for pre-commit checks.

### Step 3: Add dependencies to `mix.exs`

Add missing deps (the plugins need these to run their checks):

```elixir
# Quality tools (needed by elixir plugin hooks)
{:credo, "~> 1.7", only: [:dev, :test], runtime: false},
{:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},  # only if Phoenix

# Claude Code integration
{:claude, "~> 0.5", only: [:dev], runtime: false},
{:tidewave, "~> 0.4", only: [:dev]},
{:usage_rules, "~> 0.1", only: [:dev]},
```

Skip already present. Use `mix igniter.install` when Igniter is available.

### Step 4: Create `.credo.exs`

Create tuned `.credo.exs` in project root:
- **Only scan `lib/`** — tests don't need style enforcement
- **ModuleDoc disabled** if Ash (resources have own conventions), **enabled** otherwise
- **Cyclomatic complexity max: 13** — LiveView handle_event has more branches
- **Function arity max: 8** — polling/recursive functions
- **Nesting max: 3** — `with` + `case` in workers is normal
- **TODO exit_status: 0** — don't block the agent
- **AliasUsage threshold: > 1** — alias from 2 uses

Full `.credo.exs` config:

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

### Step 5: Install and configure Claude Code integration

Run in sequence:
1. `mix deps.get`
2. `mix claude.install --yes` — creates `.claude.exs` with compile/format hooks, installs commands (mix:*, claude:*, elixir:*, memory:*), tidewave MCP, usage_rules sync, meta-agent subagent
3. `mix compile`

### Step 6: Install official Anthropic plugins

```
/install-plugin frontend-design
/install-plugin skill-creator
```

### Step 7: Write conventions to CLAUDE.md

Read existing `CLAUDE.md`. MERGE (never overwrite) a `## Conventions` section. Adapt module names to match the project (find in `lib/*_web.ex`). Only include sections for detected deps.

#### If Ash detected, add:

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

#### If Phoenix detected, add:

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
- For PubSub subscriptions affected by URL params, subscribe in `handle_params/3` not `mount/3`
- When subscribing to PubSub, verify ALL message types have matching `handle_info` clauses
- Never use `String.to_integer` on LiveView form params — always `Integer.parse/1`
- `String.to_existing_atom` in handle_event crashes — use explicit pattern match whitelist
- `embed_templates "layouts/*"` auto-generates functions — do not define them manually
```

#### If Oban detected, add:

```markdown
### Oban Workers
- Oban arg key names must EXACTLY match between `Worker.new(%{"key" => value})` and `args["key"]` in `perform/1`
- When Oban cron enqueues child jobs, wrap state transition + `Oban.insert!` in `Repo.transaction` + add `unique:` to prevent race conditions
- Workers that create + update multiple records MUST wrap in `Repo.transaction` + use `unique: [period: 300, keys: [:key]]`
```

#### Always add:

```markdown
### Config
- `runtime.exs` runs after `dev.exs` and overwrites same config keys — keep dev-specific config in `dev.exs` only
- Static files in `priv/static/` take priority over controller routes

### Dependency Management
- Use Igniter when available: `mix igniter.install <package>`
- For manual deps: add to `mix.exs`, run `mix deps.get`

### Implementation Workflow
1. **`/prd-generator`** — write a human project plan, get a technical PRD
2. **`/grill-me`** — stress-test the PRD
3. **`/implementation-plan`** — break PRD into phased tasks (tasks.md)
4. **`/code-execute phase:N`** — execute tasks from a phase
5. **`/autopilot`** — full autonomous: execute + review + fix + commit
6. **`/code-review`** — parallel review across 4 dimensions
7. **`/code-fix`** — auto-fix blocking/important issues
8. **`/compound`** — capture lessons learned (updates CLAUDE.md)
9. **`/code-complete`** — mark tasks done in tasks.md

Implementation artifacts: `docs/implementation/` (prd.md, tasks.md, context.md).
Review reports: `docs/reviews/`.
```

### Step 8: Copy implementation pipeline skills

Copy skills to `.claude/skills/` from the reference project (`/home/bhf-ai-devel/Projects/adplatform/.claude/skills/`). If not available, ask the user for the path.

Skills to copy:
- `prd-generator`, `implementation-plan`, `code-execute`, `autopilot`
- `code-review`, `code-fix`, `code-complete`, `compound`
- `grill-me`, `coolify-deploy`

Also create `.claude/agents/meta-agent.md`.

### Step 9: Fetch Ash guidance (if Ash)

Fetch: https://raw.githubusercontent.com/bradleygolden/ash_vibez/main/llms.txt

### Step 10: Run initial scan

Run `mix credo --strict` and `mix sobelow --skip -q`.

Report:
```
| Tool    | Issues | Breakdown                        |
|---------|--------|----------------------------------|
| Credo   | N      | X refactoring, Y readability,... |
| Sobelow | M      | X high, Y low confidence         |
```

Ask if user wants to auto-fix.

### Step 11: Suggest dependency monitoring (optional)

Ask the user if they want to set up automatic weekly dependency monitoring via `/schedule`. Explain:

- Runs every Monday morning as a **remote agent** (cloud, works even when computer is off)
- Only **reports** outdated deps — never installs or updates anything
- Requires GitHub repo connected to Claude Code (`/web-setup`)
- Results appear in claude.ai/code session list

If they want it, guide them:
1. Run `/web-setup` to connect GitHub (if not already done)
2. Then use `/schedule` to create the trigger with this prompt:

```
Run `mix hex.outdated` in this project. Report a table with columns:
dep name | current version | latest version | bump type (major/minor/patch).
Flag any major version bumps as BREAKING.
Do NOT run `mix deps.update` — only report, never install.
If everything is up to date, say so.
```

If they decline, skip — this is informational, not mandatory.

### Step 12: Summary

```
Setup complete:
  [x] Elixir marketplace plugin (format/compile/credo/sobelow/ash.codegen hooks)
  [x] Ash plugin (ash.codegen --check hook)          # if Ash
  [x] credo + sobelow deps + .credo.exs
  [x] Claude Code (tidewave, usage_rules, commands)
  [x] Official plugins (frontend-design, skill-creator)
  [x] Conventions in CLAUDE.md
  [x] Implementation pipeline skills (N skills)
  [x] ash-vibez guidance                              # if Ash
  [x] Initial scan: N credo, M sobelow issues
  [ ] Deps monitoring (optional, needs GitHub connection)

Available commands:
  /prd-generator    — create PRD from project plan
  /implementation-plan — break PRD into tasks
  /autopilot        — autonomous execution
  /code-review      — parallel code review
  /code-fix         — auto-fix review issues
  /grill-me         — stress-test a design
  /compound         — capture lessons learned
  /frontend-design  — high-quality UI generation
```

## Rules

- NEVER remove existing config or CLAUDE.md content — only ADD/MERGE
- For non-Phoenix projects: skip sobelow, LiveView sections
- For non-Ash projects: keep ModuleDoc enabled, skip Ash sections, skip Ash plugin
- For non-Oban projects: skip Oban section
- Adapt AppWeb/AppComponents names to match actual project
- If Igniter available, prefer `mix igniter.install` for deps
