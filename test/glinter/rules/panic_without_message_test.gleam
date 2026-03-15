import gleam/list
import gleeunit/should
import glinter/rules/panic_without_message
import glinter/test_helpers

pub fn detects_panic_without_message_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { panic }",
      panic_without_message.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("panic_without_message")
}

pub fn ignores_panic_with_message_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { panic as \"should never happen\" }",
      panic_without_message.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_non_panic_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { Nil }",
      panic_without_message.rule(),
    )
  list.length(results) |> should.equal(0)
}
