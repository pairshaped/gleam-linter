import glance
import gleam/dict
import gleam/list
import glinter/config
import glinter/rule
import glinter/rules/avoid_panic
import glinter/runner

fn make_config() -> config.Config {
  config.Config(
    rules: dict.new(),
    ignore: dict.new(),
    include: ["src/"],
    exclude: [],
    stats: False,
    warnings_as_errors: False,
  )
}

fn run_with_source(
  source: String,
  rules: List(rule.Rule),
) -> List(rule.LintResult) {
  let assert Ok(module) = glance.module(source)
  let files = [#("test.gleam", source, module)]
  runner.run(rules: rules, files: files, config: make_config())
}

pub fn line_level_suppression_test() {
  let source =
    "pub fn bad() {\n  // nolint: avoid_panic\n  panic as \"ok\"\n}"
  let results = run_with_source(source, [avoid_panic.rule()])
  let panic_errors =
    results |> list.filter(fn(r) { r.rule == "avoid_panic" })
  let assert True = panic_errors == []
}

pub fn function_level_suppression_test() {
  let source =
    "// nolint: avoid_panic\npub fn fallback() {\n  panic as \"unreachable\"\n}"
  let results = run_with_source(source, [avoid_panic.rule()])
  let panic_errors =
    results |> list.filter(fn(r) { r.rule == "avoid_panic" })
  let assert True = panic_errors == []
}

pub fn unrelated_rule_not_suppressed_test() {
  let source =
    "// nolint: deep_nesting\npub fn bad() {\n  panic as \"oh no\"\n}"
  let results = run_with_source(source, [avoid_panic.rule()])
  let panic_errors =
    results |> list.filter(fn(r) { r.rule == "avoid_panic" })
  let assert True = list.length(panic_errors) == 1
}

pub fn stale_annotation_produces_warning_test() {
  let source = "// nolint: avoid_panic\n\npub fn good() { 1 }"
  let results = run_with_source(source, [avoid_panic.rule()])
  let nolint_warnings =
    results |> list.filter(fn(r) { r.rule == "nolint_unused" })
  let assert True = list.length(nolint_warnings) == 1
}

pub fn unused_annotation_produces_warning_test() {
  let source = "// nolint: avoid_panic\npub fn good() { 1 }"
  let results = run_with_source(source, [avoid_panic.rule()])
  let nolint_warnings =
    results |> list.filter(fn(r) { r.rule == "nolint_unused" })
  let assert True = list.length(nolint_warnings) == 1
}
