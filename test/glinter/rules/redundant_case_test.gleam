import gleam/list
import gleeunit/should
import glinter/rule
import glinter/rules/redundant_case
import glinter/test_helpers

pub fn detects_single_branch_case_test() {
  let results =
    test_helpers.lint_string(
      "pub fn bad(x) { case x { Ok(v) -> v } }",
      redundant_case.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("redundant_case")
  result.severity |> should.equal(rule.Warning)
}

pub fn ignores_multi_branch_case_test() {
  let results =
    test_helpers.lint_string(
      "pub fn ok(x) { case x { Ok(v) -> v \n Error(_) -> 0 } }",
      redundant_case.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_single_branch_with_guard_test() {
  let results =
    test_helpers.lint_string(
      "pub fn ok(x) { case x { v if v > 0 -> v \n _ -> 0 } }",
      redundant_case.rule(),
    )
  list.length(results) |> should.equal(0)
}
