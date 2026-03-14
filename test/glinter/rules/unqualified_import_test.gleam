import glance
import gleam/list
import gleeunit/should
import glinter/rule.{type LintResult}
import glinter/rules/unqualified_import
import glinter/walker

fn lint_string(source: String) -> List(LintResult) {
  let assert Ok(module) = glance.module(source)
  walker.walk_module(
    module,
    [unqualified_import.rule()],
    source,
    "test.gleam",
  )
}

pub fn detects_unqualified_function_import_test() {
  let results = lint_string("import gleam/list.{map}")
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("unqualified_import")
  result.message
  |> should.equal(
    "Value 'map' is imported unqualified from 'gleam/list', use qualified access instead",
  )
}

pub fn detects_multiple_unqualified_imports_test() {
  let results = lint_string("import gleam/list.{map, filter, fold}")
  list.length(results) |> should.equal(3)
}

pub fn ignores_qualified_import_test() {
  let results = lint_string("import gleam/list")
  list.length(results) |> should.equal(0)
}

pub fn ignores_unqualified_type_import_test() {
  let results = lint_string("import gleam/option.{type Option}")
  list.length(results) |> should.equal(0)
}

pub fn flags_values_but_not_types_test() {
  let results =
    lint_string("import gleam/option.{type Option, None, Some}")
  // None and Some are values (constructors), type Option is fine
  list.length(results) |> should.equal(2)
}

pub fn ignores_aliased_import_test() {
  let results = lint_string("import gleam/list as l")
  list.length(results) |> should.equal(0)
}
