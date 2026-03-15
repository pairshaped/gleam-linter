import gleam/list
import gleeunit/should
import glinter/rules/unqualified_import
import glinter/test_helpers

pub fn detects_unqualified_function_import_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/list.{map}",
      unqualified_import.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("unqualified_import")
  result.message
  |> should.equal(
    "Function 'map' is imported unqualified from 'gleam/list', use qualified access instead",
  )
}

pub fn detects_multiple_unqualified_function_imports_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/list.{map, filter, fold}",
      unqualified_import.rule(),
    )
  list.length(results) |> should.equal(3)
}

pub fn ignores_qualified_import_test() {
  let results =
    test_helpers.lint_string("import gleam/list", unqualified_import.rule())
  list.length(results) |> should.equal(0)
}

pub fn ignores_unqualified_type_import_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/option.{type Option}",
      unqualified_import.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn ignores_constructor_imports_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/option.{type Option, None, Some}",
      unqualified_import.rule(),
    )
  // Constructors (PascalCase) are fine, only functions/constants flagged
  list.length(results) |> should.equal(0)
}

pub fn ignores_aliased_import_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/list as l",
      unqualified_import.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn mixed_constructors_and_functions_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/option.{type Option, None, Some, unwrap}",
      unqualified_import.rule(),
    )
  // Only unwrap (lowercase) is flagged
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.message
  |> should.equal(
    "Function 'unwrap' is imported unqualified from 'gleam/option', use qualified access instead",
  )
}
