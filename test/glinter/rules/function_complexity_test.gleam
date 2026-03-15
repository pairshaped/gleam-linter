import gleam/list
import gleam/string
import glinter/rule
import glinter/rules/function_complexity
import glinter/test_helpers

fn make_cases(count: Int) -> String {
  list.repeat("case x { _ -> 1 }", count)
  |> string.join("\n")
}

pub fn ignores_function_at_threshold_test() {
  let body = make_cases(10)
  let source = "pub fn f(x) {\n" <> body <> "\n}"
  let results = test_helpers.lint_string(source, function_complexity.rule())
  let assert True = results == []
}

pub fn detects_function_over_threshold_test() {
  let body = make_cases(11)
  let source = "pub fn f(x) {\n" <> body <> "\n}"
  let results = test_helpers.lint_string(source, function_complexity.rule())
  let assert True = list.length(results) == 1
  let assert [result] = results
  let assert True = result.rule == "function_complexity"
  let assert True = result.severity == rule.Off
}

pub fn counts_anonymous_fns_test() {
  // 9 cases + 2 anonymous fns = 11
  let cases = make_cases(9)
  let source = "pub fn f(x) {\n" <> cases <> "\nfn() { 1 }\nfn() { 2 }\n}"
  let results = test_helpers.lint_string(source, function_complexity.rule())
  let assert True = list.length(results) == 1
}

pub fn ignores_simple_function_test() {
  let results =
    test_helpers.lint_string("pub fn f() { 1 }", function_complexity.rule())
  let assert True = results == []
}
