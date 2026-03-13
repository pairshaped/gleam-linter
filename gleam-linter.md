# Gleam Linter — Project Handoff

## Goal

Build a standalone Gleam linter using [glance](https://hexdocs.pm/glance/) (a Gleam parser written in Gleam) to enforce code quality rules via AST analysis. Runs as a CLI tool against Gleam source files.

This replaces our current `bin/lint` (grep-based stopgap) with proper AST-aware analysis.

## Why

- LLMs take shortcuts (ignored Results, panics, unwraps) when not constrained
- Gleam has no official linter and the compiler team has no plans to expose internals for one
- grep can only catch surface patterns; AST walking catches structural issues
- A Gleam-native linter dogfoods the language

## Technology

- **Language:** Gleam (Erlang target)
- **Parser:** [glance](https://hex.pm/packages/glance) v6.0.0
- **Entry point:** `glance.module(src: String) -> Result(Module, Error)`
- **Distribution:** CLI tool, runs via `gleam run -m gleam_lint -- src/`

## Glance AST — Key Types for Rules

```
Module
  └─ functions: List(Definition(Function))
       └─ Function(name, parameters, body: List(Statement), ...)
            └─ Statement
                 ├─ Assignment(kind: Let | LetAssert, pattern, value)
                 ├─ Assert(expression, message)
                 ├─ Use(patterns, function)
                 └─ Expression(Expression)
                      ├─ Panic(message)
                      ├─ Todo(message)
                      ├─ Echo(expression)
                      ├─ Case(subjects, clauses: List(Clause))
                      ├─ Call(function, arguments: List(Field))
                      ├─ Block(statements)
                      ├─ Variable(name)
                      ├─ Fn(arguments, body)
                      └─ ... (Int, Float, String, List, Tuple, etc.)

Field(t) = LabelledField(label, item) | UnlabelledField(item) | ShorthandField(label)
Pattern  = PatternDiscard(name) | PatternVariable(name) | PatternVariant(constructor, arguments) | ...
AssignmentName = Named(String) | Discarded(String)
```

Every node has a `location: Span` (byte offsets) for error reporting.

## Rules to Implement

### Phase 1 — Direct pattern matches (simplest)

These are single-node checks, no tree context needed:

| # | Rule | AST Match | Description |
|---|------|-----------|-------------|
| 1 | `avoid_panic` | `Expression.Panic` | Flags `panic` expressions |
| 2 | `avoid_todo` | `Expression.Todo` | Flags `todo` expressions |
| 3 | `echo` | `Expression.Echo` | Flags leftover `echo` debug statements |
| 4 | `assert_ok_pattern` | `Statement.Assignment(kind: LetAssert, ...)` | Flags `let assert` patterns |

### Phase 2 — Simple structural checks

These need minimal context from parent/child nodes:

| # | Rule | How | Description |
|---|------|-----|-------------|
| 5 | `discarded_result` | `Assignment(pattern: PatternDiscard("_"), ...)` | Flags `let _ = expr` (ignored Result) |
| 6 | `short_variable_name` | `PatternVariable(name)` where `string.length(name) == 1` | Flags single-letter variable names |
| 7 | `unnecessary_variable` | Last two statements: `Assignment(pattern: PatternVariable(x), value: v)` then `Expression(Variable(x))` | Flags immediately-returned variables |
| 8 | `redundant_case` | `Case(clauses: [single_clause])` | Flags single-branch case expressions |
| 9 | `unwrap_used` | `Call(function: FieldAccess(label: "unwrap"), ...)` on `result` or `option` | Flags `result.unwrap` / `option.unwrap` / lazy variants |

### Phase 3 — Tree-walking checks

These need recursive traversal with depth/size tracking:

| # | Rule | How | Description |
|---|------|-----|-------------|
| 10 | `deep_nesting` | Track depth during walk, flag when > threshold | Flags deeply nested blocks |
| 11 | `function_complexity` | Count AST nodes in function body | Flags functions exceeding complexity threshold |
| 12 | `module_complexity` | Count AST nodes across all functions | Flags overly complex modules |
| 13 | `prefer_guard_clause` | Function body ends with `Case` that has an early-return pattern | Suggests `use <- bool.guard` instead |

### Phase 4 — Cross-reference checks

These need function definition context to check call sites:

| # | Rule | How | Description |
|---|------|-----|-------------|
| 14 | `missing_labels` | Compare `Call` arguments against known function parameter labels | Flags calls missing required labels |
| 15 | `label_possible` | Function with 2+ params defined without labels | Suggests adding labels to definitions |

### Out of scope (need type info)

These require compiler type inference, which glance doesn't provide:

- `stringly_typed_error` — needs `Result(x, String)` type knowledge
- `nil_result` — needs `Result(Nil, Nil)` type knowledge
- `thrown_away_error` / `thrown_away_ok` — needs to know what type is being matched
- `thrown_away_fn_param` — needs parameter type info
- `thrown_away_nil` — needs type info
- `error_context_lost` — needs to know what `map_error` receives

## Architecture

```
src/
  gleam_lint.gleam          — CLI entry point: parse args, discover files, run, report
  gleam_lint/
    rule.gleam              — Rule type, severity enum, lint result type
    walker.gleam            — Recursive AST walker that dispatches to rules
    rules/
      avoid_panic.gleam     — One file per rule
      avoid_todo.gleam
      echo.gleam
      assert_ok_pattern.gleam
      discarded_result.gleam
      short_variable_name.gleam
      unnecessary_variable.gleam
      redundant_case.gleam
      unwrap_used.gleam
      deep_nesting.gleam
      function_complexity.gleam
      module_complexity.gleam
      prefer_guard_clause.gleam
      missing_labels.gleam
      label_possible.gleam
    reporter.gleam          — Format lint results (text, JSON, etc.)
    config.gleam            — Rule enable/disable, thresholds, suppressions
```

### Core types

```gleam
pub type Severity {
  Error
  Warning
}

pub type LintResult {
  LintResult(
    rule: String,
    severity: Severity,
    file: String,
    location: Span,
    message: String,
  )
}

pub type Rule {
  Rule(
    name: String,
    severity: Severity,
    check_statement: Option(fn(Statement) -> List(LintResult)),
    check_expression: Option(fn(Expression) -> List(LintResult)),
    check_function: Option(fn(Function) -> List(LintResult)),
    check_module: Option(fn(Module) -> List(LintResult)),
  )
}
```

### Suppression

Support `// lint:allow <rule>` comments. Glance doesn't preserve comments in the AST, so scan the raw source for suppression comments and map them to line numbers. When reporting, skip results on suppressed lines.

### Walker

Single recursive walk of the AST. For each node, run all applicable rules. Collect results.

```gleam
pub fn walk_module(module: Module, rules: List(Rule), source: String, file: String) -> List(LintResult) {
  // Run module-level rules
  // Walk each function definition
  // For each function, walk statements and expressions recursively
  // Filter out suppressed results
}
```

## CLI Interface

```bash
# Lint src/ (default)
gleam run -m gleam_lint

# Lint specific directory
gleam run -m gleam_lint -- src/ test/

# Eventually, as a standalone binary
gleam_lint src/
```

### Output format

```
src/gleam_mcp_todo/oauth.gleam:221: [error] avoid_panic: Use Result types instead of panic
src/gleam_mcp_todo.gleam:51: [warning] assert_ok_pattern: let assert crashes on mismatch — handle the error

Found 2 issues (1 error, 1 warning)
```

## Implementation Order

1. **Scaffold project** — `gleam new gleam_lint`, add glance dependency
2. **File discovery** — recursively find `.gleam` files in target dirs
3. **Parse + walk** — parse each file with glance, walk AST
4. **Phase 1 rules** — avoid_panic, avoid_todo, echo, assert_ok_pattern (4 rules)
5. **Suppression** — `// lint:allow` comment scanning
6. **Reporter** — formatted output with file:line references
7. **Phase 2 rules** — discarded_result, short_variable_name, unnecessary_variable, redundant_case, unwrap_used (5 rules)
8. **Phase 3 rules** — deep_nesting, function_complexity, module_complexity, prefer_guard_clause (4 rules)
9. **Phase 4 rules** — missing_labels, label_possible (2 rules)
10. **Config** — rule enable/disable, severity overrides, thresholds

## Testing strategy

- Unit test each rule with small Gleam source snippets parsed through glance
- Test suppression with `// lint:allow` comments
- Integration test against this project's `src/` as a real-world corpus

## Open questions

- **Project name:** `gleam_lint`? `glint`? `gleamlint`?
- **Distribution:** hex package? standalone binary? both?
- **Config format:** gleam.toml section? separate `.gleam-lint.toml`?
- **Comment preservation:** glance doesn't include comments in AST — need to parse them separately for suppression. Should we use a simple line-based regex scan of the raw source?
