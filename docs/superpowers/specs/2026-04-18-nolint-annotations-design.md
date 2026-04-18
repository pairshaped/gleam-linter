# nolint Comment Annotations

## Problem

File-level ignores in `gleam.toml` are a blunt instrument — they suppress a rule across the entire file, letting new violations slip in silently. Most real suppression needs are scoped to a single line or function.

## Syntax

```gleam
// nolint: rule1, rule2 -- optional reason
```

- `// nolint:` is the directive prefix
- Rule names are comma-separated, trimmed of whitespace
- Everything after `--` is a human-readable reason (ignored by the parser)
- Can appear as a standalone comment line or inline after code

## Scope Rules

**Line-level:** The annotation suppresses errors on the next line below it (when standalone) or on the same line (when inline).

```gleam
// nolint: thrown_away_error -- key absent means use default
Error(_) -> Ok([])

let _ = setup() // nolint: discarded_result -- fire and forget
```

**Function-level:** When the next line starts with `fn` or `pub fn`, the annotation suppresses matching errors for the entire function body.

```gleam
// nolint: deep_nesting, function_complexity -- recursive AST walker
fn walk_expression(expr, context) {
  // ... all errors in this function suppressed for those two rules
}
```

**Strict placement:** The annotation must be immediately above the target line or function — no blank lines or other comments between them. This keeps the association unambiguous.

**Stale annotations:** If a `// nolint:` comment isn't followed by code on the next line (blank line, another comment, or EOF), or if an annotation doesn't suppress any actual error, glinter emits a warning with rule name `nolint_unused`.

## Architecture

### New module: `src/glinter/annotation.gleam`

Parses raw source text and produces a list of annotation directives.

**Input:** Source string.

**Process:**
1. Split source into lines
2. For each line containing `// nolint:`, extract rule names and line number
3. Determine scope by inspecting the next line:
   - If inline (code before `// nolint:`): scope is the current line
   - If next line starts with `fn` or `pub fn`: function scope (target is the function)
   - If next line is code: line scope (target is the next line)
   - If next line is blank/comment/EOF: stale annotation

**Output:** `List(Annotation)` where each annotation contains:
- `rules: List(String)` — rule names to suppress
- `target_line: Int` — the line number being annotated (1-indexed)
- `scope: Scope` — `LineSuppression` or `FunctionSuppression` or `Stale`

Function scope resolution (mapping target line to the function's full span) happens in the runner, which has access to the parsed AST.

### Runner integration: `src/glinter/runner.gleam`

After running rules on a file and collecting errors:

1. Call `annotation.parse(source)` to get annotations
2. For function-scope annotations, resolve the function's end line using `module.functions` spans and `byte_offset_to_line`
3. Filter errors: remove any error where the rule name matches an annotation and the error's line falls within scope
4. Track which annotations suppressed at least one error — emit `nolint_unused` warnings for any that didn't

### Shared utility: `byte_offset_to_line`

Currently lives in `reporter.gleam` (private). Needs to be made public or moved to a shared module so the runner can also convert Span byte offsets to line numbers for function scope resolution.

## When to Use Each Level

**Line-level `// nolint:`** — For specific intentional violations. One-off error handling patterns, known-safe discards, single expressions that don't fit a rule's assumptions.

**Function-level `// nolint:`** — For functions that are inherently complex or where a rule doesn't apply to the function's purpose. Deep AST walkers, recursive codegen helpers, FFI shim functions.

**File-level `[tools.glinter.ignore]`** — When a rule is fundamentally wrong for the entire file's purpose. CLI modules where every function returns `Result(Nil, String)`, codegen files that are entirely string template building.

**Guidance: use the narrowest scope that covers your case.** Line > function > file.

## Testing

### Unit tests: `test/glinter/annotation_test.gleam`

1. Parses standalone nolint comment
2. Parses inline nolint comment (code before `// nolint:`)
3. Parses multiple comma-separated rules
4. Ignores reason text after `--`
5. Detects function scope (next line is `fn` or `pub fn`)
6. Detects line scope (next line is non-fn code)
7. Detects stale annotation (next line is blank/comment/EOF)

### Integration tests

1. Line-level suppression filters the annotated error
2. Function-level suppression filters errors within the function body
3. Errors on unannotated lines pass through unchanged
4. Stale annotation produces `nolint_unused` warning
5. Annotation with wrong rule name doesn't suppress other rules

## Documentation

Update `README.md` with a "Suppressing warnings" section covering all three levels with examples and the "narrowest scope" guidance. Clarify that line-level annotations suppress the line **below** the comment (or the same line when inline), not the line above.

## Version

This is a purely additive feature. Minor version bump: `2.13.0`.
