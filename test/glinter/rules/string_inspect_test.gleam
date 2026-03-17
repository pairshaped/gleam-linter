import gleam/list
import glinter/rules/string_inspect
import glinter/test_helpers

pub fn detects_string_inspect_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn main() { string.inspect(42) }",
      string_inspect.rule(),
    )
  let assert True = list.length(results) == 1
  let assert [result] = results
  let assert True = result.rule == "string_inspect"
}

pub fn ignores_other_string_functions_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn main() { string.length(\"hi\") }",
      string_inspect.rule(),
    )
  let assert True = results == []
}

pub fn ignores_other_module_inspect_test() {
  let results =
    test_helpers.lint_string_rule(
      "pub fn main() { other.inspect(42) }",
      string_inspect.rule(),
    )
  let assert True = results == []
}

pub fn allows_inspect_on_generic_parameter_test() {
  let results =
    test_helpers.lint_string_rule(
      "import gleam/string
pub fn log_with(message: String, error: a) -> Nil {
  string.inspect(error)
}",
      string_inspect.rule(),
    )
  let assert True = results == []
}

pub fn still_flags_inspect_on_concrete_type_test() {
  let results =
    test_helpers.lint_string_rule(
      "import gleam/string
pub fn show_user(user: User) -> String {
  string.inspect(user)
}",
      string_inspect.rule(),
    )
  let assert True = list.length(results) == 1
}

pub fn allows_inspect_on_error_bound_variable_test() {
  let results =
    test_helpers.lint_string_rule(
      "import gleam/string
pub fn send(msg: String) -> Nil {
  case do_send(msg) {
    Ok(Nil) -> Nil
    Error(err) -> string.inspect(err)
  }
}",
      string_inspect.rule(),
    )
  let assert True = results == []
}

pub fn still_flags_inspect_on_ok_bound_variable_test() {
  let results =
    test_helpers.lint_string_rule(
      "import gleam/string
pub fn bad() -> String {
  case get_user() {
    Ok(user) -> string.inspect(user)
    Error(_) -> \"unknown\"
  }
}",
      string_inspect.rule(),
    )
  let assert True = list.length(results) == 1
}
