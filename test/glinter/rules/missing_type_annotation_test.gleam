import gleam/list
import glinter/rules/missing_type_annotation
import glinter/test_helpers

pub fn detects_missing_return_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn greet() { \"hello\" }",
      missing_type_annotation.rule(),
    )
  let assert True = list.length(results) == 1
  let assert [result] = results
  let assert True = result.rule == "missing_type_annotation"
  let assert True =
    result.message == "Function 'greet' is missing a return type annotation"
}

pub fn ignores_annotated_return_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn greet() -> String { \"hello\" }",
      missing_type_annotation.rule(),
    )
  let assert True = results == []
}

pub fn detects_missing_param_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn greet(name) -> String { name }",
      missing_type_annotation.rule(),
    )
  let assert True = list.length(results) == 1
  let assert [result] = results
  let assert True =
    result.message == "Function 'greet' has untyped parameter 'name'"
}

pub fn ignores_annotated_param_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn greet(name: String) -> String { name }",
      missing_type_annotation.rule(),
    )
  let assert True = results == []
}

pub fn detects_multiple_missing_annotations_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn add(a, b) { a }",
      missing_type_annotation.rule(),
    )
  // Missing return type + 2 untyped params
  let assert True = list.length(results) == 3
}

pub fn detects_on_private_functions_test() {
  let results =
    test_helpers.lint_string_rule(
      "fn helper(x) { x }",
      missing_type_annotation.rule(),
    )
  // Missing return type + untyped param
  let assert True = list.length(results) == 2
}

pub fn fully_annotated_private_function_test() {
  let results =
    test_helpers.lint_string_rule(
      "fn helper(x: Int) -> Int { x }",
      missing_type_annotation.rule(),
    )
  let assert True = results == []
}
