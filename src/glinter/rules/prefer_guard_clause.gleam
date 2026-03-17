import glance
import gleam/option.{None}
import glinter/rule

pub fn rule() -> rule.Rule {
  rule.new(name: "prefer_guard_clause")
  |> rule.with_simple_function_visitor(visitor: check_function)
  |> rule.to_module_rule()
}

fn check_function(
  function: glance.Function,
  _span: glance.Span,
) -> List(rule.RuleError) {
  case function.body {
    [glance.Expression(glance.Case(location, _, [clause_a, clause_b]))] ->
      case
        clause_a.guard == None
        && clause_b.guard == None
        && is_bool_pair(clause_a, clause_b)
        && has_simple_branch(clause_a, clause_b)
      {
        True -> [
          rule.error(
            message: "Consider using 'use <- bool.guard' instead of case True/False",
            details: "Guard clauses reduce nesting and improve readability for boolean branches.",
            location: location,
          ),
        ]
        False -> []
      }
    _ -> []
  }
}

fn is_bool_pair(clause_a: glance.Clause, clause_b: glance.Clause) -> Bool {
  case clause_a.patterns, clause_b.patterns {
    [[glance.PatternVariant(_, None, "True", [], _)]],
      [[glance.PatternVariant(_, None, "False", [], _)]]
    -> True
    [[glance.PatternVariant(_, None, "False", [], _)]],
      [[glance.PatternVariant(_, None, "True", [], _)]]
    -> True
    _, _ -> False
  }
}

fn has_simple_branch(clause_a: glance.Clause, clause_b: glance.Clause) -> Bool {
  is_simple(clause_a.body) || is_simple(clause_b.body)
}

fn is_simple(expr: glance.Expression) -> Bool {
  case expr {
    glance.Block(_, _) -> False
    _ -> True
  }
}
