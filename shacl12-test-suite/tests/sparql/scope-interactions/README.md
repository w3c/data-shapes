# Prebinding and result identity tests

These 55 cases target the [18 September 2026 SHACL 1.2 Working Draft](https://www.w3.org/TR/2026/WD-shacl12-sparql-20260918/) under `shacl-1.2-2026-09-18`.
Expected results use the draft's values-insertion definition.
Every entry has `mf:status sht:approved`, as requested in the [Working Group review](https://github.com/w3c/data-shapes/pull/1296#pullrequestreview-5580815916). Implementation observations do not define the expectations.

Start with the [family review guide](REVIEW.md): it derives one representative, explains the four controls per pattern, and summarizes the distinct obligations.
The per-case index below links directly to the manifest and validator.

## Files, identity and requirements

Each case has `manifest.ttl` and `shapes.ttl`. The manifest is also its data graph (`sht:dataGraph <>`) and contains the complete expected report.
A case identifier is relative to its own manifest, so each deployed case has its own test IRI. Do not reuse the old `example.org/community` identifiers in new reports.
Record anchors preserve shared blank focus/value identity. Nested syntax is used only where it does not split a shared node.
The query-based cases declare `mf:requires sht:SPARQLValidation`; the standalone sequence/inverse-path case declares `sht:Core`.
Both documents are contributed under the W3C Software and Document License and carry no separate copyright or license notice.

## Inventory and review order

Review the ten absence-pattern families first: each has IRI/blank-focus and conforming/violating controls (40 cases). Parameterized ASK/SELECT add four cases; predicate position adds two; failure, message and Core path add three.
The five draft admission cases and the triple-term focus case complete the 55.

The UNION controls use `FILTER(1 = 2)` for the dead branch. This is semantically equivalent to the original `FILTER(false)` but separates prebinding from literal-filter translation. The expected reports are unchanged.
A standalone `FILTER(false)` reproducer is kept outside these manifests.

## Case index

| Case | Requirement | Expected outcome | Validator |
| --- | --- | --- | --- |
| [admission-hidden-prebound-subquery-draft](admission-hidden-prebound-subquery-draft/manifest.ttl) | SPARQLValidation | complete report | [shapes](admission-hidden-prebound-subquery-draft/shapes.ttl) |
| [admission-local-values-draft](admission-local-values-draft/manifest.ttl) | SPARQLValidation | complete report | [shapes](admission-local-values-draft/shapes.ttl) |
| [admission-minus-draft](admission-minus-draft/manifest.ttl) | SPARQLValidation | failure | [shapes](admission-minus-draft/shapes.ttl) |
| [admission-prebound-as-draft](admission-prebound-as-draft/manifest.ttl) | SPARQLValidation | failure | [shapes](admission-prebound-as-draft/shapes.ttl) |
| [admission-prebound-values-draft](admission-prebound-values-draft/manifest.ttl) | SPARQLValidation | failure | [shapes](admission-prebound-values-draft/shapes.ttl) |
| [aggregate-subquery-blank-conforming](aggregate-subquery-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](aggregate-subquery-blank-conforming/shapes.ttl) |
| [aggregate-subquery-blank-violating](aggregate-subquery-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](aggregate-subquery-blank-violating/shapes.ttl) |
| [aggregate-subquery-iri-conforming](aggregate-subquery-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](aggregate-subquery-iri-conforming/shapes.ttl) |
| [aggregate-subquery-iri-violating](aggregate-subquery-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](aggregate-subquery-iri-violating/shapes.ttl) |
| [anchored-optional-blank-conforming](anchored-optional-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](anchored-optional-blank-conforming/shapes.ttl) |
| [anchored-optional-blank-violating](anchored-optional-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](anchored-optional-blank-violating/shapes.ttl) |
| [anchored-optional-iri-conforming](anchored-optional-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](anchored-optional-iri-conforming/shapes.ttl) |
| [anchored-optional-iri-violating](anchored-optional-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](anchored-optional-iri-violating/shapes.ttl) |
| [ask-validator-parameter-conforming](ask-validator-parameter-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](ask-validator-parameter-conforming/shapes.ttl) |
| [ask-validator-parameter-violating](ask-validator-parameter-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](ask-validator-parameter-violating/shapes.ttl) |
| [complex-sequence-inverse-path](complex-sequence-inverse-path/manifest.ttl) | Core | complete report | [shapes](complex-sequence-inverse-path/shapes.ttl) |
| [empty-left-optional-blank-conforming](empty-left-optional-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](empty-left-optional-blank-conforming/shapes.ttl) |
| [empty-left-optional-blank-violating](empty-left-optional-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](empty-left-optional-blank-violating/shapes.ttl) |
| [empty-left-optional-iri-conforming](empty-left-optional-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](empty-left-optional-iri-conforming/shapes.ttl) |
| [empty-left-optional-iri-violating](empty-left-optional-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](empty-left-optional-iri-violating/shapes.ttl) |
| [exists-absence-blank-conforming](exists-absence-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](exists-absence-blank-conforming/shapes.ttl) |
| [exists-absence-blank-violating](exists-absence-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](exists-absence-blank-violating/shapes.ttl) |
| [exists-absence-iri-conforming](exists-absence-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](exists-absence-iri-conforming/shapes.ttl) |
| [exists-absence-iri-violating](exists-absence-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](exists-absence-iri-violating/shapes.ttl) |
| [nested-not-exists-blank-conforming](nested-not-exists-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](nested-not-exists-blank-conforming/shapes.ttl) |
| [nested-not-exists-blank-violating](nested-not-exists-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](nested-not-exists-blank-violating/shapes.ttl) |
| [nested-not-exists-iri-conforming](nested-not-exists-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](nested-not-exists-iri-conforming/shapes.ttl) |
| [nested-not-exists-iri-violating](nested-not-exists-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](nested-not-exists-iri-violating/shapes.ttl) |
| [nested-optional-blank-conforming](nested-optional-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](nested-optional-blank-conforming/shapes.ttl) |
| [nested-optional-blank-violating](nested-optional-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](nested-optional-blank-violating/shapes.ttl) |
| [nested-optional-iri-conforming](nested-optional-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](nested-optional-iri-conforming/shapes.ttl) |
| [nested-optional-iri-violating](nested-optional-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](nested-optional-iri-violating/shapes.ttl) |
| [not-exists-blank-conforming](not-exists-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](not-exists-blank-conforming/shapes.ttl) |
| [not-exists-blank-violating](not-exists-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](not-exists-blank-violating/shapes.ttl) |
| [not-exists-iri-conforming](not-exists-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](not-exists-iri-conforming/shapes.ttl) |
| [not-exists-iri-violating](not-exists-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](not-exists-iri-violating/shapes.ttl) |
| [path-absence-blank-conforming](path-absence-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](path-absence-blank-conforming/shapes.ttl) |
| [path-absence-blank-violating](path-absence-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](path-absence-blank-violating/shapes.ttl) |
| [path-absence-iri-conforming](path-absence-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](path-absence-iri-conforming/shapes.ttl) |
| [path-absence-iri-violating](path-absence-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](path-absence-iri-violating/shapes.ttl) |
| [predicate-focus-blank](predicate-focus-blank/manifest.ttl) | SPARQLValidation | complete report | [shapes](predicate-focus-blank/shapes.ttl) |
| [predicate-focus-iri](predicate-focus-iri/manifest.ttl) | SPARQLValidation | complete report | [shapes](predicate-focus-iri/shapes.ttl) |
| [projected-subquery-blank-conforming](projected-subquery-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](projected-subquery-blank-conforming/shapes.ttl) |
| [projected-subquery-blank-violating](projected-subquery-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](projected-subquery-blank-violating/shapes.ttl) |
| [projected-subquery-iri-conforming](projected-subquery-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](projected-subquery-iri-conforming/shapes.ttl) |
| [projected-subquery-iri-violating](projected-subquery-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](projected-subquery-iri-violating/shapes.ttl) |
| [quoted-focus-optional](quoted-focus-optional/manifest.ttl) | SPARQLValidation | complete report | [shapes](quoted-focus-optional/shapes.ttl) |
| [select-validator-parameter-conforming](select-validator-parameter-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](select-validator-parameter-conforming/shapes.ttl) |
| [select-validator-parameter-violating](select-validator-parameter-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](select-validator-parameter-violating/shapes.ttl) |
| [solution-declared-failure](solution-declared-failure/manifest.ttl) | SPARQLValidation | failure | [shapes](solution-declared-failure/shapes.ttl) |
| [solution-message-priority](solution-message-priority/manifest.ttl) | SPARQLValidation | complete report | [shapes](solution-message-priority/shapes.ttl) |
| [union-absence-blank-conforming](union-absence-blank-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](union-absence-blank-conforming/shapes.ttl) |
| [union-absence-blank-violating](union-absence-blank-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](union-absence-blank-violating/shapes.ttl) |
| [union-absence-iri-conforming](union-absence-iri-conforming/manifest.ttl) | SPARQLValidation | conforms; no results | [shapes](union-absence-iri-conforming/shapes.ttl) |
| [union-absence-iri-violating](union-absence-iri-violating/manifest.ttl) | SPARQLValidation | complete report | [shapes](union-absence-iri-violating/shapes.ttl) |

## Reproduction and disposition

Run the cases under profile `shacl-1.2-2026-09-18` and compare complete reports under the suite's normalization rules, with shared source blank nodes kept fixed as the review guide explains.
Engine execution records observations, including disagreements and unsupported syntax. Record the engine version, artifact identity and how the engine was configured for the requested profile before comparing results.
The [review guide](REVIEW.md) contains the clause links, hand derivations, admission decisions and family reference.
