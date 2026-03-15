import gleam/list
import gleeunit/should
import glinter/rules/string_inspect
import glinter/test_helpers

pub fn detects_string_inspect_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { string.inspect(42) }",
      string_inspect.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("string_inspect")
}

pub fn ignores_other_string_functions_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { string.length(\"hi\") }",
      string_inspect.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_other_module_inspect_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { other.inspect(42) }",
      string_inspect.rule(),
    )
  list.length(results) |> should.equal(0)
}
