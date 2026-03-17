import gleam/list
import glinter/rules/division_by_zero
import glinter/test_helpers

pub fn detects_int_division_by_zero_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn bad(x) { x / 0 }",
      division_by_zero.rule(),
    )
  let assert True = list.length(results) == 1
  let assert [result] = results
  let assert True = result.rule == "division_by_zero"
}

pub fn detects_float_division_by_zero_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn bad(x) { x /. 0.0 }",
      division_by_zero.rule(),
    )
  let assert True = list.length(results) == 1
}

pub fn detects_remainder_by_zero_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn bad(x) { x % 0 }",
      division_by_zero.rule(),
    )
  let assert True = list.length(results) == 1
}

pub fn ignores_nonzero_divisor_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn ok(x) { x / 2 }",
      division_by_zero.rule(),
    )
  let assert True = results == []
}

pub fn ignores_variable_divisor_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn ok(x, y) { x / y }",
      division_by_zero.rule(),
    )
  let assert True = results == []
}
