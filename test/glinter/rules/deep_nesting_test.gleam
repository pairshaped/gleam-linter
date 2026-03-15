import gleam/list
import gleeunit/should
import glinter/rule
import glinter/rules/deep_nesting
import glinter/test_helpers

pub fn ignores_shallow_nesting_test() {
  // 5 levels: fn body -> block -> block -> block -> block -> block
  let results =
    test_helpers.lint_string(
      "pub fn f() { { { { { 1 } } } } }",
      deep_nesting.rule(),
    )
  list.length(results) |> should.equal(0)
}

pub fn detects_deep_nesting_test() {
  // 6 levels: fn body -> block -> block -> block -> block -> block -> block
  let results =
    test_helpers.lint_string(
      "pub fn f() { { { { { { 1 } } } } } }",
      deep_nesting.rule(),
    )
  list.length(results) |> should.equal(1)
  let assert [result] = results
  result.rule |> should.equal("deep_nesting")
  result.severity |> should.equal(rule.Warning)
}

pub fn detects_deep_case_nesting_test() {
  let results =
    test_helpers.lint_string(
      "pub fn f(a, b, c, d, e, g) {
        case a {
          _ -> case b {
            _ -> case c {
              _ -> case d {
                _ -> case e {
                  _ -> case g {
                    _ -> 1
                  }
                }
              }
            }
          }
        }
      }",
      deep_nesting.rule(),
    )
  list.length(results) |> should.equal(1)
}

pub fn detects_deep_fn_nesting_test() {
  let results =
    test_helpers.lint_string(
      "pub fn f() {
        fn() { fn() { fn() { fn() { fn() { 1 } } } } }
      }",
      deep_nesting.rule(),
    )
  list.length(results) |> should.equal(1)
}

pub fn reports_only_first_crossing_test() {
  // 7 levels deep — should still only report once
  let results =
    test_helpers.lint_string(
      "pub fn f() { { { { { { { 1 } } } } } } }",
      deep_nesting.rule(),
    )
  list.length(results) |> should.equal(1)
}
