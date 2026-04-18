import gleam/list
import glinter/annotation.{FunctionScope, LineScope, Stale}

pub fn parses_standalone_nolint_test() {
  let results = annotation.parse("// nolint: avoid_panic\npanic as \"x\"")
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.rules == ["avoid_panic"]
  let assert True = a.target_line == 2
  let assert True = a.scope == LineScope
}

pub fn parses_inline_nolint_test() {
  let results = annotation.parse("let _ = x // nolint: discarded_result")
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.rules == ["discarded_result"]
  let assert True = a.target_line == 1
  let assert True = a.scope == LineScope
}

pub fn parses_multiple_rules_test() {
  let results =
    annotation.parse(
      "// nolint: deep_nesting, function_complexity\nfn walk() { 1 }",
    )
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.rules == ["deep_nesting", "function_complexity"]
}

pub fn ignores_reason_after_dashes_test() {
  let results =
    annotation.parse(
      "// nolint: avoid_panic -- unreachable fallback\npanic as \"x\"",
    )
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.rules == ["avoid_panic"]
}

pub fn detects_function_scope_fn_test() {
  let results =
    annotation.parse(
      "// nolint: deep_nesting\nfn walk(x) { x }",
    )
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.scope == FunctionScope
  let assert True = a.target_line == 2
}

pub fn detects_function_scope_pub_fn_test() {
  let results =
    annotation.parse(
      "// nolint: deep_nesting\npub fn walk(x) { x }",
    )
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.scope == FunctionScope
  let assert True = a.target_line == 2
}

pub fn detects_line_scope_for_non_fn_test() {
  let results =
    annotation.parse(
      "// nolint: thrown_away_error\nError(_) -> Ok([])",
    )
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.scope == LineScope
  let assert True = a.target_line == 2
}

pub fn detects_stale_annotation_blank_line_test() {
  let results = annotation.parse("// nolint: avoid_panic\n\npanic")
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.scope == Stale
}

pub fn detects_stale_annotation_eof_test() {
  let results = annotation.parse("// nolint: avoid_panic")
  let assert True = list.length(results) == 1
  let assert [a] = results
  let assert True = a.scope == Stale
}

pub fn no_annotations_returns_empty_test() {
  let results = annotation.parse("pub fn ok() { 1 }")
  let assert True = results == []
}
