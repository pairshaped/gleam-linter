import gleam/list
import gleeunit/should
import glinter/rule
import glinter/rules/discarded_result
import glinter/test_helpers

pub fn detects_discarded_result_test() {
  let results =
    test_helpers.lint_string(
      "pub fn bad() { let _ = get() \n 1 }",
      discarded_result.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("discarded_result")
  result.severity |> should.equal(rule.Warning)
}

pub fn ignores_named_discard_test() {
  let results =
    test_helpers.lint_string(
      "pub fn ok() { let _result = get() \n 1 }",
      discarded_result.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_regular_assignment_test() {
  let results =
    test_helpers.lint_string(
      "pub fn ok() { let x = 1 \n x }",
      discarded_result.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_let_assert_test() {
  let results =
    test_helpers.lint_string(
      "pub fn ok() { let assert Ok(x) = get() \n x }",
      discarded_result.rule(),
    )
  list.length(results) |> should.equal(0)
}
