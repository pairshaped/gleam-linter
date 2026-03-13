import glance
import gleam/list
import gleeunit/should
import glinter/rule.{type LintResult}
import glinter/rules/echo_rule
import glinter/walker

fn lint_string(source: String) -> List(LintResult) {
  let assert Ok(module) = glance.module(source)
  walker.walk_module(module, [echo_rule.rule()], source, "test.gleam")
}

pub fn detects_echo_test() {
  let results = lint_string("pub fn debug() { echo 42 }")
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("echo")
  result.severity |> should.equal(rule.Warning)
}

pub fn ignores_clean_code_test() {
  let results = lint_string("pub fn good() { 42 }")
  list.length(results) |> should.equal(0)
}
