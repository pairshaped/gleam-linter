import gleam/list
import gleeunit/should
import glinter/rule
import glinter/rules/unwrap_used
import glinter/test_helpers

pub fn detects_result_unwrap_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/result
pub fn bad() { result.unwrap(Ok(1), 0) }",
      unwrap_used.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("unwrap_used")
  result.severity |> should.equal(rule.Warning)
}

pub fn detects_option_unwrap_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/option
pub fn bad() { option.unwrap(option.Some(1), 0) }",
      unwrap_used.rule(),
    )
  list.length(results) |> should.equal(1)
}

pub fn detects_lazy_unwrap_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/result
pub fn bad() { result.lazy_unwrap(Ok(1), fn() { 0 }) }",
      unwrap_used.rule(),
    )
  list.length(results) |> should.equal(1)
}

pub fn ignores_other_module_unwrap_test() {
  let results =
    test_helpers.lint_string(
      "import my/utils
pub fn ok() { utils.unwrap(thing) }",
      unwrap_used.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_result_map_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/result
pub fn ok() { result.map(Ok(1), fn(x) { x + 1 }) }",
      unwrap_used.rule(),
    )
  list.length(results) |> should.equal(0)
}
