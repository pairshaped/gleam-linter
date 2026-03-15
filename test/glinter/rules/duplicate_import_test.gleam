import gleam/list
import glinter/rules/duplicate_import
import glinter/test_helpers

pub fn detects_duplicate_import_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/list
       import gleam/list",
      duplicate_import.rule(),
    )
  let assert True = list.length(results) == 1
  let assert [result] = results
  let assert True = result.rule == "duplicate_import"
  let assert True =
    result.message == "Module 'gleam/list' is imported more than once"
}

pub fn ignores_unique_imports_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/list
       import gleam/string",
      duplicate_import.rule(),
    )
  let assert True = results == []
}

pub fn ignores_single_import_test() {
  let results =
    test_helpers.lint_string("import gleam/list", duplicate_import.rule())
  let assert True = results == []
}

pub fn detects_triple_import_test() {
  let results =
    test_helpers.lint_string(
      "import gleam/list
       import gleam/string
       import gleam/list
       import gleam/list",
      duplicate_import.rule(),
    )
  let assert True = list.length(results) == 2
}
