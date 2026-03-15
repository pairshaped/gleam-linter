import gleam/list
import gleeunit/should
import glinter/rule
import glinter/rules/avoid_panic
import glinter/test_helpers

pub fn detects_panic_test() {
  let results =
    test_helpers.lint_string("pub fn bad() { panic }", avoid_panic.rule())
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("avoid_panic")
  result.severity |> should.equal(rule.Error)
}

pub fn detects_panic_with_message_test() {
  let results =
    test_helpers.lint_string(
      "pub fn bad() { panic as \"oh no\" }",
      avoid_panic.rule(),
    )
  list.length(results) |> should.equal(1)
}

pub fn ignores_clean_code_test() {
  let results =
    test_helpers.lint_string("pub fn good() { Ok(1) }", avoid_panic.rule())
  list.length(results) |> should.equal(0)
}

pub fn detects_nested_panic_test() {
  let results =
    test_helpers.lint_string("pub fn bad() { { panic } }", avoid_panic.rule())
  list.length(results) |> should.equal(1)
}
