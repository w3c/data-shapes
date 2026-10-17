# Reviewing the prebinding and result-identity proposals

The [2017 cases](README.md) and
[dated SHACL 1.2 cases](../../../../shacl12-test-suite/tests/sparql/scope-interactions/README.md)
are separate proposals. Every entry remains `sht:proposed`. An implementation
observation is evidence to investigate, not a derivation or Working Group approval.
Reviewers can accept or dispute a family without deciding all 110 cases together.

## Start with one absence control

Read [the IRI violating case](empty-left-optional-iri-violating/manifest.ttl) and
[its shapes](empty-left-optional-iri-violating/shapes.ttl), then the
[conforming control](empty-left-optional-iri-conforming/manifest.ttl).
The validator query is:

```sparql
SELECT $this WHERE {
  OPTIONAL { $this <http://example.org/p> ?present }
  FILTER(!BOUND(?present))
}
```

The target is every instance of `ex:C`. The violating input has three such
nodes, `a`, `b`, and `c`, with `p` only at `a`. Evaluate separately for each focus:

| Focus | OPTIONAL match for that focus | Filter | Expected result |
| --- | --- | --- | --- |
| a | binds present | false | none |
| b | no match; the left solution survives | true | b as focus and value |
| c | no match; the left solution survives | true | c as focus and value |

The control gives all three nodes `p`, so it must have no result and conform.
Restricting only after evaluating the OPTIONAL can hide the missing-node
rows. The expected report checks both the boolean and the complete two-result
structure, including the named constraint and source shape.

For the Recommendation, use
[Appendix A's values-insertion definition](https://www.w3.org/TR/2017/REC-shacl-20170720/#pre-binding)
and [the result mapping](https://www.w3.org/TR/2017/REC-shacl-20170720/#sparql-constraints-variables).
For the dated draft, use
[its values-insertion definition](https://www.w3.org/TR/2026/WD-shacl12-sparql-20260918/#pre-binding)
and [its result mapping](https://www.w3.org/TR/2026/WD-shacl12-sparql-20260918/#sparql-constraints-variables).
Both texts define values insertion; their admission restrictions and referenced
SPARQL versions differ. Neither suite asks a processor to implement the other revision. In particular, abstract prebinding of a blank node is not a
request to interpolate its label into SPARQL text.

Under the Recommendation's SPARQL 1.1 translation, the empty left BGP is
also subject to values insertion, so the surviving solution retains `this`.
In the draft's referenced SPARQL algebra, the empty left group is a
`ContextSolution`. Values insertion restricts the right-hand BGP but need not bind
`this` in the surviving missing-property solution. Projection can therefore leave
`this` unbound. The result still identifies the current focus: [Core's focus-node
requirement](https://www.w3.org/TR/2026/WD-shacl12-core-20260918/#results-focusNode)
requires that exact node, and [node-shape value nodes](https://www.w3.org/TR/2026/WD-shacl12-core-20260918/#value-nodes)
provide the value fallback. Do not infer a query binding from the report's focus.
The same distinction applies to nested OPTIONAL, EXISTS, UNION, path/subquery
absence, SELECT parameters, predicate and triple-term cases, and the two accepted
draft admission cases below. An editorial clarification of the result-mapping
table would help make this interaction explicit; these tests do not implement a
new rule that silently binds projected query variables.

## What the four variants establish

Each of the ten absence-pattern families has IRI and blank-focus versions, with
one conforming and one violating control in each version: 40 cases per suite.
The IRI case establishes the pattern result. The blank case establishes that
the same behavior preserves source-node identity. The conforming case detects
spurious violations; the violating case detects missing or wrong results.

In a blank-focus case, `ex:recordA`, `ex:recordB`, and `ex:recordC` anchor the data
nodes. Compare the complete report with those source identities fixed. A report
for arbitrary fresh blank nodes, or for recordA in place of recordB, is wrong
even if the report alone is isomorphic. Remaining labels such as `_:b` and `_:c`
connect multiple references; replacing each occurrence by `[]` changes the data.

## Family review checklist

All rows below await WG disposition; the checkboxes record a review task, not
an assertion that the family is already approved. Links use the 2017 representative;
the dated suite's index supplies its equivalent and profile-specific cases.

| Review | Family and representative | Distinct obligation |
| --- | --- | --- |
| [ ] | [Empty-left OPTIONAL](empty-left-optional-iri-violating/manifest.ttl) | Focus binding reaches the OPTIONAL without an earlier anchor. |
| [ ] | [Anchored OPTIONAL](anchored-optional-iri-violating/manifest.ttl) | An earlier class match does not change missing-property detection. |
| [ ] | [Nested OPTIONAL](nested-optional-iri-violating/manifest.ttl) | Both OPTIONAL levels preserve the missing-property solution. |
| [ ] | [NOT EXISTS](not-exists-iri-violating/manifest.ttl) | The absence test is correlated with the current focus. |
| [ ] | [Nested NOT EXISTS](nested-not-exists-iri-violating/manifest.ttl) | OPTIONAL plus an inner bound filter gives the correct existence result. |
| [ ] | [EXISTS absence](exists-absence-iri-violating/manifest.ttl) | An inner absent-value solution makes EXISTS true. |
| [ ] | [UNION](union-absence-iri-violating/manifest.ttl) | Only the absence branch contributes solutions. |
| [ ] | [Alternative path](path-absence-iri-violating/manifest.ttl) | The current focus restricts both alternatives. |
| [ ] | [Projected subquery](projected-subquery-iri-violating/manifest.ttl) | Restriction applies inside the subquery before LIMIT. |
| [ ] | [Aggregate subquery](aggregate-subquery-iri-violating/manifest.ttl) | Restriction applies before grouping, SAMPLE, HAVING, ordering and LIMIT. |
| [ ] | [ASK parameter](ask-validator-parameter-violating/manifest.ttl) | The component parameter and value node are prebound; ASK false produces a result. |
| [ ] | [SELECT parameter](select-validator-parameter-violating/manifest.ttl) | The component parameter and this are prebound; each selected row produces a result. |
| [ ] | [Predicate position](predicate-focus-blank/manifest.ttl) | A blank focus cannot match an RDF predicate and keeps its identity in the result. |
| [ ] | [Admission](admission-local-values-rec/manifest.ttl) | Apply the exact revision's restrictions, summarized below. |
| [ ] | [Failure solution](solution-declared-failure/manifest.ttl) | A true failure binding reports a semantic failure, not ordinary nonconformance. |
| [ ] | [Message precedence](solution-message-priority/manifest.ttl) | The bound message wins over the declared message. |
| [ ] | [Complex result path](complex-sequence-inverse-path/manifest.ttl) | The report describes p then inverse q, not an arbitrary path blank node. |
| [ ] | [Triple-term focus](../../../../shacl12-test-suite/tests/sparql/scope-interactions/quoted-focus-optional/manifest.ttl) | The complete bad triple term is the sole focus/value; dated draft only. |

For every absence family, the violating input has `p` only at a and the expected
validation invocations producing results are exactly b and c; the conforming input has `p` at all three
and produces none. For NOT EXISTS, the inner p-pattern therefore has a match only
for a. In nested NOT EXISTS its `BOUND` filter removes the missing-property
solution; in EXISTS absence, `!BOUND` retains it. In the subquery cases, a
missing focus contributes no group or projected row, so OPTIONAL retains the
outer solution with present unbound. The UNION dead branch uses `FILTER(1 = 2)`:
it has false effective boolean value without depending on literal-filter
translation. A standalone `FILTER(false)` reproducer is kept outside these
manifests.

## Version-specific admission decisions

Read each rule in its own [Recommendation](https://www.w3.org/TR/2017/REC-shacl-20170720/#pre-binding)
or [dated draft](https://www.w3.org/TR/2026/WD-shacl12-sparql-20260918/#pre-binding).

| Query feature | REC 2017 | Draft 2026-09-18 |
| --- | --- | --- |
| Local VALUES not mentioning a prebound variable | failure | accepted; one result in this input |
| Nested SELECT hiding this from projection | failure | accepted; one result in this input |
| VALUES mentioning this | failure | failure |
| AS assigning this | failure | failure |
| MINUS | failure | failure |
| SERVICE | failure | no universal draft-policy test proposed |

Do not count an unreadable file, unsupported parser syntax, timeout, or arbitrary
runtime exception as the expected failure. A processor may use an
implementation-specific channel, but it must be attributable to the intended
admission rule or the true failure solution.

## Full-report cases beyond absence

For parameterized validators, `required` is p. In the violating input, b and c
lack that property and produce two results; in the control all three have it.
The source component is `ex:Component`, not `sh:SPARQLConstraintComponent`.

For message precedence, the query binds `message` to `row message`; the mapping
table chooses that before the constraint's `declared message`. For failure, the
query projects `true AS ?failure`; both dated texts require the failure channel.
These are result-mapping tests and can be decided separately from OPTIONAL.

For the Core path, a has p to m, and z has q to m, so p followed by inverse q
reaches z from a. It reaches no node from b. Exactly b violates minCount 1; the
report needs the equivalent sequence/inverse path and no value. This is a Core
test, even though it is grouped here with other result-identity proposals.

For the draft triple-term case, the two target objects are distinct complete
triple terms. Only recordGood has p, so the bad term is the sole focus/value.
An RDF 1.1-only parser cannot execute that case; report unsupported syntax rather
than a semantic failure.

## Relationship to the proposed prebinding rewrite

The [VALUES-based rewrite](https://github.com/w3c/data-shapes/pull/1251) is a
separate proposal, not the normative authority for either dated suite. These
cases provide concrete questions for reviewing it: does binding reach nested
OPTIONAL and EXISTS, is it applied before subquery modifiers, are blank and
triple-term identities preserved, and which admission rules change? Failure,
message and Core-path expectations do not follow from the rewrite mechanism.
Do not label results as a run of that candidate unless the candidate algorithm
was actually executed. A divergence should be reviewed against the candidate
text before changing a dated expectation.

## Evidence and acceptance

Record separate per-engine observations. Report exact versions, source/artifact
identity, the requested profile and how the engine was configured for it,
complete-report agreement, semantic failures, unsupported syntax and operational
errors. Successfully writing an observation report does not mean the engine
agrees with all proposals.

The WG may decide families independently under the suite's existing approval
process. Keep entries proposed until that decision. Once accepted, retain stable
case identifiers; a changed semantic expectation needs an explicit explanation
and renewed review rather than silent replacement of an established test.
