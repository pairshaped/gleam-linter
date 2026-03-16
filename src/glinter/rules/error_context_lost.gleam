import glance
import gleam/list
import glinter/rule.{type Rule, Rule, RuleResult, Warning}

pub fn rule() -> Rule {
  Rule(
    name: "error_context_lost",
    default_severity: Warning,
    needs_collect: True,
    check: check,
  )
}

fn check(data: rule.ModuleData, _source: String) -> List(rule.RuleResult) {
  data.expressions |> list.flat_map(check_expression)
}

fn check_expression(expr: glance.Expression) -> List(rule.RuleResult) {
  case expr {
    // result.map_error(x, fn(_) { ... }) or result.replace_error(...)
    glance.Call(
      location,
      glance.FieldAccess(_, glance.Variable(_, "result"), label),
      args,
    )
      if label == "map_error" || label == "replace_error"
    -> check_discards_error(location, label, args)
    // x |> result.map_error(fn(_) { ... }) — pipe form has one fewer arg
    // but the walker collects the Call node after pipe desugaring won't happen,
    // so we also check for a single-arg call (the piped version)
    _ -> []
  }
}

fn check_discards_error(
  location: glance.Span,
  label: String,
  args: List(glance.Field(glance.Expression)),
) -> List(rule.RuleResult) {
  let has_discard =
    args
    |> list.any(fn(field) {
      case field {
        glance.UnlabelledField(glance.Fn(_, [param], _, _))
        | glance.LabelledField(_, _, glance.Fn(_, [param], _, _))
        ->
          case param.name {
            glance.Discarded(_) -> True
            _ -> False
          }
        _ -> False
      }
    })
  case has_discard {
    True -> [
      RuleResult(
        rule: "error_context_lost",
        location: location,
        message: "result."
          <> label
          <> " discards the original error — consider wrapping it instead",
      ),
    ]
    False -> []
  }
}
