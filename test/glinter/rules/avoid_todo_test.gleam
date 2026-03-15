import gleam/list
import gleeunit/should
import glinter/rule
import glinter/rules/avoid_todo
import glinter/test_helpers

pub fn detects_todo_test() {
  let results =
    test_helpers.lint_string("pub fn stub() { todo }", avoid_todo.rule())
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("avoid_todo")
  result.severity |> should.equal(rule.Error)
}

pub fn detects_todo_with_message_test() {
  let results =
    test_helpers.lint_string(
      "pub fn stub() { todo as \"implement later\" }",
      avoid_todo.rule(),
    )
  list.length(results) |> should.equal(1)
}

pub fn ignores_clean_code_test() {
  let results =
    test_helpers.lint_string("pub fn good() { Ok(1) }", avoid_todo.rule())
  list.length(results) |> should.equal(0)
}
