import gleam/list
import gleeunit/should
import glinter/rules/todo_without_message
import glinter/test_helpers

pub fn detects_todo_without_message_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { todo }",
      todo_without_message.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("todo_without_message")
}

pub fn ignores_todo_with_message_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { todo as \"implement auth\" }",
      todo_without_message.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_non_todo_test() {
  let results =
    test_helpers.lint_string(
      "pub fn main() { Nil }",
      todo_without_message.rule(),
    )
  list.length(results) |> should.equal(0)
}
