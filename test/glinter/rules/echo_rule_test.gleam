import gleam/list
import gleeunit/should
import glinter/rule
import glinter/rules/echo_rule
import glinter/test_helpers

pub fn detects_echo_test() {
  let results =
    test_helpers.lint_string("pub fn debug() { echo 42 }", echo_rule.rule())
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("echo")
  result.severity |> should.equal(rule.Warning)
}

pub fn ignores_clean_code_test() {
  let results =
    test_helpers.lint_string("pub fn good() { 42 }", echo_rule.rule())
  list.length(results) |> should.equal(0)
}
