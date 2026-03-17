import gleam/list
import glinter/rule
import glinter/rules/stringly_typed_error
import glinter/test_helpers

pub fn detects_string_error_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn bad() -> Result(Int, String) { Ok(1) }",
      stringly_typed_error.rule(),
    )
  let assert True = list.length(results) == 1
  let assert [result] = results
  let assert True = result.rule == "stringly_typed_error"
  let assert True = result.severity == rule.Warning
}

pub fn ignores_custom_error_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn ok() -> Result(Int, MyError) { Ok(1) }",
      stringly_typed_error.rule(),
    )
  let assert True = results == []
}

pub fn ignores_nil_error_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn ok() -> Result(Int, Nil) { Ok(1) }",
      stringly_typed_error.rule(),
    )
  let assert True = results == []
}

pub fn ignores_no_return_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn ok() { Ok(1) }",
      stringly_typed_error.rule(),
    )
  let assert True = results == []
}

pub fn ignores_non_result_return_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn ok() -> String { \"hello\" }",
      stringly_typed_error.rule(),
    )
  let assert True = results == []
}
