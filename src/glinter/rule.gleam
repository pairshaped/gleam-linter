import glance.{type Expression, type Module, type Span, type Statement}

pub type Severity {
  Error
  Warning
  Off
}

/// Result returned by individual rules. Does not include file or severity —
/// those are set by the orchestrator from the Rule and file context.
pub type RuleResult {
  RuleResult(rule: String, location: Span, message: String)
}

/// Full lint result with file path and severity, produced by the orchestrator.
pub type LintResult {
  LintResult(
    rule: String,
    severity: Severity,
    file: String,
    location: Span,
    message: String,
  )
}

/// Pre-computed data from a single AST traversal.
/// Rules receive this instead of walking the AST themselves.
pub type ModuleData {
  ModuleData(
    module: Module,
    expressions: List(Expression),
    statements: List(Statement),
  )
}

pub type Rule {
  Rule(
    name: String,
    default_severity: Severity,
    /// Whether this rule uses the pre-collected expression/statement lists.
    /// When False, walker.collect() can be skipped if no other active rule
    /// needs it.
    needs_collect: Bool,
    /// The source parameter provides the raw file content for rules that need
    /// string-level analysis beyond what the parsed AST offers.
    check: fn(ModuleData, String) -> List(RuleResult),
  )
}
