# SRL to SPARQL CONSTRUCT: translation examples

Examples for the rule-to-query translation designed in
[`../translate-rule-to-construct.md`](../translate-rule-to-construct.md)
(issue [#1303](https://github.com/w3c/data-shapes/issues/1303), appendix
`#translate-srl-sparql`).

Each example is a pair of files with the same base name:

* `exNN-name.srl` — a rule set containing one SPARQL-RL rule;
* `exNN-name.rq`  — the SPARQL 1.2 `CONSTRUCT` query it translates to.

`manifest.ttl` lists the pairs as `srlt:RulesPositiveTranslationTest`
entries: `mf:action` is the rule file, `mf:result` the query file.

Executing the query computes `evalRule(R, G, GD)` for that rule
(`index.html#eval-rule`): one application of the rule, as performed
repeatedly by rule set evaluation. A header comment in each `.rq` file
states the dataset to execute the query over:

* the default graph is the graph the rule body matches — the evaluation
  graph `GE` for an ordinary rule, the base graph `G0` for a `WHERE DATA`
  rule;
* for `NOT DATA` in an ordinary rule, the named graph
  `<urn:srl:base-graph>` holds the base graph `G0`.

The queries show the simplified output of the algorithm: the outermost
scope-closing group is elided when nothing follows it (design note, § 8).

| Example           | Demonstrates                                                |
|-------------------|-------------------------------------------------------------|
| ex01-patterns     | triple patterns: token-for-token                            |
| ex02-filter       | `FILTER` in place                                           |
| ex03-not          | `NOT` → `FILTER NOT EXISTS`                                 |
| ex04-not-scope    | nested group freezing the scope of a negation               |
| ex05-not-data     | `NOT DATA` → `GRAPH` over the base graph; with `SET`        |
| ex06-where-data   | `WHERE DATA` → query executed over the base graph           |
| ex07-set          | `SET` → `BIND` + `FILTER(BOUND(..))`                        |
| ex08-group        | `GROUP BY` → sub-`SELECT`; aggregation-error guard          |
| ex09-group-nokeys | keyless `GROUP`: row-count guard against the empty group    |
| ex10-group-distinct | the `[]` form → `SELECT DISTINCT` over the keys           |
| ex11-bnode-head   | head blank node: fresh blank node per solution              |
| ex12-bnode-body   | body blank nodes → fresh variables                          |
| ex13-path-seq     | a sequence path, `/`                                        |
| ex14-path-inverse | an inverse path, `^`                                        |
| ex15-path         | a sequence and an inverse together                          |
| ex16-path-inverse-seq | an inverse of a sequence, `^(:p1/:p2)`                  |
