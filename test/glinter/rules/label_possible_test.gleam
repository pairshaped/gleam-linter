import gleam/list
import gleeunit/should
import glinter/rule
import glinter/rules/label_possible
import glinter/test_helpers

pub fn detects_unlabeled_param_test() {
  let results =
    test_helpers.lint_string(
      "pub fn greet(name: String, greeting: String) { greeting <> name }",
      label_possible.rule(),
    )
  list.length(results) |> should.equal(2)
  let assert [result, ..] = results
  result.rule |> should.equal("label_possible")
  result.severity |> should.equal(rule.Warning)
}

pub fn ignores_single_param_test() {
  let results =
    test_helpers.lint_string(
      "pub fn greet(name: String) { name }",
      label_possible.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_all_labeled_test() {
  let results =
    test_helpers.lint_string(
      "pub fn greet(name name: String, greeting greeting: String) { greeting <> name }",
      label_possible.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn detects_partial_labels_test() {
  let results =
    test_helpers.lint_string(
      "pub fn greet(name name: String, greeting: String) { greeting <> name }",
      label_possible.rule(),
    )
  list.length(results) |> should.equal(1)
}

pub fn ignores_one_param_no_label_test() {
  let results =
    test_helpers.lint_string("pub fn f(x) { x }", label_possible.rule())
  list.length(results) |> should.equal(0)
}

pub fn detects_three_unlabeled_params_test() {
  let results =
    test_helpers.lint_string(
      "pub fn f(a: Int, b: Int, c: Int) { a + b + c }",
      label_possible.rule(),
    )
  list.length(results) |> should.equal(3)
}
