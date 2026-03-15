import gleam/list
import gleeunit/should
import glinter/rules/missing_type_annotation
import glinter/test_helpers

pub fn detects_missing_return_type_test() {
  let results =
    test_helpers.lint_string(
      "pub fn greet() { \"hello\" }",
      missing_type_annotation.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("missing_type_annotation")
  result.message
  |> should.equal("Function 'greet' is missing a return type annotation")
}

pub fn ignores_annotated_return_type_test() {
  let results =
    test_helpers.lint_string(
      "pub fn greet() -> String { \"hello\" }",
      missing_type_annotation.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn detects_missing_param_type_test() {
  let results =
    test_helpers.lint_string(
      "pub fn greet(name) -> String { name }",
      missing_type_annotation.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.message
  |> should.equal("Function 'greet' has untyped parameter 'name'")
}

pub fn ignores_annotated_param_type_test() {
  let results =
    test_helpers.lint_string(
      "pub fn greet(name: String) -> String { name }",
      missing_type_annotation.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn detects_multiple_missing_annotations_test() {
  let results =
    test_helpers.lint_string(
      "pub fn add(a, b) { a }",
      missing_type_annotation.rule(),
    )
  // Missing return type + 2 untyped params
  list.length(results) |> should.equal(3)
}

pub fn detects_on_private_functions_test() {
  let results =
    test_helpers.lint_string(
      "fn helper(x) { x }",
      missing_type_annotation.rule(),
    )
  // Missing return type + untyped param
  list.length(results) |> should.equal(2)
}

pub fn fully_annotated_private_function_test() {
  let results =
    test_helpers.lint_string(
      "fn helper(x: Int) -> Int { x }",
      missing_type_annotation.rule(),
    )
  list.length(results) |> should.equal(0)
}
