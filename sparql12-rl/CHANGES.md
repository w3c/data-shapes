# SPARQL-RL - CHANGES

This document records major changes and new material that would be of interest to
implementers.

It is not a comprehensive list of changes to the specification.

This file is temporary while the specification is in-development — it is not
intended for publication.

## 2026-08-24
GH-1191: Grammar: `FOR ?var IN <iri>` (`ForClause`) removed; the 2026-08-12
entry below recorded this removal before it had happened.
GH-1191: Grammar: the body-first `IF ... THEN ...` form (`Rule2`) removed;
`Rule1` folded into `Rule`. Productions renumbered accordingly
(156 productions to 153).
A `WHERE DATA` rule body and a `NOT DATA` negation element no longer give rise
to rule dependencies.
Blank nodes in a rule head are freshened per solution.
Test namespace prefix is `srlt:` in every manifest.

## 2026-08-19
Move from "SHACL 1.2 Rules" to "SPARQL 12 RL" / SPARQL-RL.
Move tests to `shacl12-test-suite/tests/sparql-rl/`
Change test namespace to `PREFIX srlt: <http://www.w3.org/ns/sparql-rl-tests#>`
Change root test manifest to `manifest-sparql-rl.ttl`

## 2026-08-12
IMPORTS is now optional, and if provided it may be only partial
Remove RDF syntax.
Media type is "application/sparql-rl"
Evaluation for NOT DATA and WHERE DATA
"FOR ?var IN <shape>" agreed to be removed (removed from the grammar on
2026-08-24)

## 2026-07-18
GH-1074
Syntax for FOR ?var IN <shape> (grammar change)

## 2026-07-16
Removed sections of at-risk abbreviation (grammar change) and at-risk tuples.

## 2026-07-07
Grammar: add NOT DATA and WHERE DATA in preparation for grounded patterns
(GH-960 Default triples)

## 2026-07-07
Rewrite of the SRL grammar so that the three areas (data, head templates and
body patterns) each have specific syntax productions.

  Data blocks do not have variables, and do not have paths.
  Head templates have variables, but do not have paths.
  Body patterns have variables and paths.

## 2026-07-01 Start change log
