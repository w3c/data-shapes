# Migrating from SHACL-AF Rules to SHACL 1.2 Rules

## 1. Introduction

This document describes how to migrate existing SHACL Advanced Features (SHACL-AF) rules
to SHACL 1.2 Rules. It covers both SPARQL Rules (`sh:SPARQLRule`) and Triple Rules
(`sh:TripleRule`) as defined in the SHACL-AF specification, as well as related features
such as Node Expressions and SHACL Functions that are used within rules.

### Audience

- **Data modelers/users**: People who have existing SHACL-AF rules in their shapes graphs
  and need to rewrite them for SHACL 1.2 implementations.
- **Implementors**: Engine developers migrating their SHACL-AF rule engines to support
  SHACL 1.2 Rules.

### Scope

This guide covers:
- SPARQL Rules (`sh:SPARQLRule`)
- Triple Rules (`sh:TripleRule`)
- Node Expressions used within rules
- SHACL Functions used within rule expressions

It does not cover Annotation Properties or Expression Constraints, which are
separate features in SHACL-AF with their own migration paths. Custom Targets are
covered only insofar as they drive rule focus nodes (see
[§6.4](#64-custom-targets--rules--body-patterns)); their use outside rules is out
of scope.

---

## 2. Architectural Differences

### 2.1 Shape-Attached Rules vs. Standalone Rule Sets

**SHACL-AF**: Rules are attached to shapes via `sh:rule`. The shape's targets determine
which focus nodes the rules apply to.

```turtle
ex:PersonShape
    a sh:NodeShape ;
    sh:targetClass ex:Person ;
    sh:rule [
        a sh:SPARQLRule ;
        sh:construct "..." ;
    ] .
```

**SHACL 1.2**: Rules are standalone, grouped in a `srl:RuleSet`. They operate over all
data matching their body patterns. There is no inherent shape attachment.

```
PREFIX ex: <http://example.com/>
RULE { ?x ex:fullName ?name }
WHERE { ?x a ex:Person ; ex:firstName ?f ; ex:lastName ?l .
        SET (?name := CONCAT(?f, " ", ?l)) }
```

**Migration impact**: You must move targeting logic (class membership, property patterns)
into the rule body as explicit triple patterns.

### 2.2 Execution Model: Manual Ordering vs. Stratification

**SHACL-AF**: Rule execution order is controlled manually via `sh:order` on rules and
shapes. Rules with lower values execute first. Visibility of inferred triples between
rules at the same order level is undefined (race conditions are possible).

**SHACL 1.2**: Ordering is determined automatically via stratification. A
**dependency graph** is built where an edge from `R1` to `R2` means `R1` depends
on `R2` (the head of `R2` could produce triples that `R1`'s body matches). Each
edge is labeled **open** or **closed**:

- An **open dependency** is an ordinary positive one: the matching triple pattern
  in `R1` is a plain triple pattern element. Open dependencies do *not* force a
  stratum boundary — the two rules may share a stratum and iterate together.
- A **closed dependency** arises when the matching pattern is inside a `NOT`
  block, or when `R1` has an assignment, or when `R1`'s head creates a blank
  node. A closed dependency forces `R2` into a strictly earlier stratum so that
  `R2` has produced *all* its output before `R1` runs.

Rules within the same stratum execute to a fixed point (iteratively until no new
triples are produced). The **stratification condition** requires that no
dependency cycle contains a closed dependency; if it does, the spec leaves the
outcome undefined. This guarantees a single well-defined, finite outcome.

**Migration impact**: Remove `sh:order` annotations. If your rules relied on
explicit ordering for correctness, verify that the stratification produces the
same sequencing. Ordinary positive chains converge in a shared stratum; a `NOT`,
an assignment, or a blank-node-producing head is what introduces a hard stratum
boundary.

### 2.3 Data Graph Modification vs. Inference Graph Separation

**SHACL-AF**: The rules engine adds inferred triples to the data graph (logically).
The spec notes implementations may internally use a separate inference graph.

**SHACL 1.2**: The specification clearly separates the base graph (input) from the
inference graph (output). Combining them is optional and left to users. Rules
evaluate against the "evaluation graph" (base + inferences so far), but output
only contains triples not in the base graph.

**Migration impact**: If your workflow assumes that inferred triples are automatically
merged back into the data graph, you may need to add an explicit merge step after rule
evaluation.

### 2.4 Pre-bound `$this` vs. Explicit Variables

**SHACL-AF**: The variable `$this` is pre-bound to the current focus node determined
by the shape's targets.

**SHACL 1.2**: No pre-binding. All variables are bound through triple pattern matching
in the rule body. What was `$this` becomes an explicit variable (e.g., `?x`) matched
via triple patterns.

**Migration impact**: Replace `$this` references with explicit variables and add
corresponding triple patterns to the body.

---

## 3. Vocabulary Mapping

### 3.1 Classes

| SHACL-AF | SHACL 1.2 | Notes |
|----------|-----------|-------|
| `sh:SPARQLRule` | `srl:Rule` | Single rule class covers both cases |
| `sh:TripleRule` | `srl:Rule` | Same; triple template structure in head |
| — | `srl:RuleSet` | New; container for rules + data |
| — | `srl:RuleElement` | New; abstract class for body elements |
| — | `srl:TriplePattern` | New; subclass of RuleElement |
| — | `srl:ConditionElement` | New; subclass of RuleElement (FILTER) |
| — | `srl:AssignmentElement` | New; subclass of RuleElement (`SET`) |
| — | `srl:NegationElement` | New; subclass of RuleElement (`NOT`) |

### 3.2 Properties

| SHACL-AF | SHACL 1.2 | Notes |
|----------|-----------|-------|
| `sh:rule` (on shape) | `srl:rules` (on RuleSet) | List of rules, not per-shape |
| `sh:construct` | `srl:head` + `srl:body` | `CONSTRUCT` split into head/body |
| `sh:subject` (TripleRule) | `srl:subject` (triple template) | Similar semantics |
| `sh:predicate` (TripleRule) | `srl:predicate` (triple template) | Similar semantics |
| `sh:object` (TripleRule) | `srl:object` (triple template) | Similar semantics |
| `sh:condition` | Body triple patterns + `srl:filter` | Conditions become part of rule body |
| `sh:order` | — | Removed; stratification is automatic |
| `sh:deactivated` | — | Remove rule from set instead |
| `sh:prefixes` | `PREFIX` declarations | SRL has its own prefix mechanism |
| `sh:this` (node expr) | Variable in triple pattern | Explicit binding |
| — | `srl:varName` | New; names variables in RDF syntax |
| — | `srl:not` | New; negation as failure (`NOT`) |
| — | `srl:data` | New; data block triples |
| — | `srl:assign` | New; assignment element (`SET`) |
| — | `srl:assignVar` | New; the variable assigned by an `srl:assign` |
| — | `srl:assignValue` | New; the value/expression of an `srl:assign` |
| — | `srl:filter` | New; `FILTER` equivalent |
| — | `IMPORTS` (SRL text keyword) | New; rule set imports. The RDF-syntax property is not yet defined in the current vocabulary draft |

The triple-component properties `srl:subject`, `srl:predicate`, and `srl:object`
are used both in `srl:head` (triple templates) and in `srl:body`/`srl:data`
(triple patterns and data triples), not only for the SHACL-AF `sh:subject`/etc.
mapping shown above.

### 3.3 Namespace Change

| Spec | Prefix | Namespace |
|------|--------|-----------|
| SHACL-AF | `sh:` | `http://www.w3.org/ns/shacl#` |
| SHACL 1.2 Rules | `srl:` | `http://www.w3.org/ns/shacl-rules#` |
| SHACL 1.2 (expressions) | `sparql:` | `http://www.w3.org/ns/sparql#` |

---

## 4. Syntax Migration

### 4.1 SPARQL Rules to SRL Text Syntax

**SHACL-AF SPARQL Rule:**
```turtle
ex:RectangleRulesShape
    a sh:NodeShape ;
    sh:targetClass ex:Rectangle ;
    sh:rule [
        a sh:SPARQLRule ;
        sh:prefixes ex: ;
        sh:construct """
            CONSTRUCT {
                $this ex:area ?area .
            }
            WHERE {
                $this ex:width ?width .
                $this ex:height ?height .
                BIND (?width * ?height AS ?area) .
            }
            """ ;
        sh:condition ex:RectangleShape ;
    ] .
```

**SHACL 1.2 SRL:**
```
PREFIX ex: <http://example.com/ns#>

RULE { ?this ex:area ?area }
WHERE {
    ?this a ex:Rectangle .
    ?this ex:width ?width .
    ?this ex:height ?height .
    SET (?area := ?width * ?height )
}
```

Key changes:
- `$this` → `?this` (or any variable name); must be bound by body patterns
- `sh:targetClass ex:Rectangle` → `?this a ex:Rectangle .` in body
- `sh:condition ex:RectangleShape` → equivalent constraints as body patterns
- `CONSTRUCT { } WHERE { }` → `RULE { } WHERE { }`
- SPARQL `BIND(expr AS ?v)` → SRL `SET (?v := expr)`; SRL text has no `BIND`
- The assignment makes this rule a **run-once rule** (it has an `srl:assign`)
- Declare prefixes via `PREFIX` keyword, not `sh:prefixes` indirection

### 4.2 SPARQL Rules to RDF Syntax

The same rule in `srl:` RDF vocabulary:

```turtle
PREFIX srl:    <http://www.w3.org/ns/shacl-rules#>
PREFIX sparql: <http://www.w3.org/ns/sparql#>
PREFIX ex:     <http://example.com/ns#>

:areaRuleSet
    a srl:RuleSet ;
    srl:rules (
        [
            a srl:Rule ;
            srl:body (
                [ srl:subject [ srl:varName "this" ] ;
                  srl:predicate rdf:type ;
                  srl:object ex:Rectangle ]
                [ srl:subject [ srl:varName "this" ] ;
                  srl:predicate ex:width ;
                  srl:object [ srl:varName "width" ] ]
                [ srl:subject [ srl:varName "this" ] ;
                  srl:predicate ex:height ;
                  srl:object [ srl:varName "height" ] ]
                [ srl:assign [
                    srl:assignVar [ srl:varName "area" ] ;
                    srl:assignValue [ sparql:multiply (
                        [ srl:varName "width" ]
                        [ srl:varName "height" ]
                    ) ]
                ] ]
            ) ;
            srl:head (
                [ srl:subject [ srl:varName "this" ] ;
                  srl:predicate ex:area ;
                  srl:object [ srl:varName "area" ] ]
            )
        ]
    ) .
```

### 4.3 Triple Rules to SRL Text Syntax

**SHACL-AF Triple Rule:**
```turtle
ex:Rectangle
    a rdfs:Class, sh:NodeShape ;
    sh:rule [
        a sh:TripleRule ;
        sh:subject sh:this ;
        sh:predicate rdf:type ;
        sh:object ex:Square ;
        sh:condition ex:Rectangle ;
        sh:condition [
            sh:property [
                sh:path ex:width ;
                sh:equals ex:height ;
            ] ;
        ] ;
    ] .
```

**SHACL 1.2 SRL:**
```
PREFIX ex: <http://example.com/ns#>

RULE { ?x a ex:Square }
WHERE {
    ?x a ex:Rectangle .
    ?x ex:width ?w .
    ?x ex:height ?h .
    FILTER(?w = ?h)
}
```

Key changes:
- `sh:this` → explicit variable `?x`
- `sh:subject`/`sh:predicate`/`sh:object` node expressions → head triple template
- `sh:condition` shapes → body patterns that enforce the same constraints
- `sh:equals` constraint → `FILTER` with equality test

### 4.4 Triple Rules to RDF Syntax

```turtle
:squareRuleSet
    a srl:RuleSet ;
    srl:rules (
        [
            a srl:Rule ;
            srl:body (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate rdf:type ;
                  srl:object ex:Rectangle ]
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:width ;
                  srl:object [ srl:varName "w" ] ]
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:height ;
                  srl:object [ srl:varName "h" ] ]
                [ srl:filter [ sparql:equals (
                    [ srl:varName "w" ]
                    [ srl:varName "h" ]
                ) ] ]
            ) ;
            srl:head (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate rdf:type ;
                  srl:object ex:Square ]
            )
        ]
    ) .
```

---

## 5. New Capabilities in SHACL 1.2

These features have no SHACL-AF equivalent. Migrated rules can leverage them
for improved expressiveness.

### 5.1 Negation as Failure (`NOT`)

```
RULE { ?x ex:name ?fullName }
WHERE {
    ?x a ex:Person .
    NOT { ?x ex:name ?existingName }
    ?x ex:givenName ?g ; ex:familyName ?f .
    SET (?fullName := CONCAT(?g, " ", ?f))
}
```

Infer a computed name only when no name exists. Previously required workarounds
with SPARQL `NOT EXISTS` inside `sh:construct` strings. Note this rule has both
a negation element and an assignment, so it is a **run-once rule** with closed
dependencies on any rule that could produce `ex:name`.

### 5.2 Recursion

```
RULE { ?x ex:ancestorOf ?y } WHERE { ?x ex:parentOf ?y }
RULE { ?x ex:ancestorOf ?y } WHERE { ?x ex:ancestorOf ?z . ?z ex:ancestorOf ?y }
```

SHACL 1.2 Rules can reference their own output. Here the recursion is through an
**open** dependency (a plain triple pattern), so the recursive rule stays in its
stratum and evaluation iterates to a fixed point. SHACL-AF had no defined
behavior for recursive rules. (Recursion through a closed dependency — `NOT`,
assignment, or blank-node head — is disallowed by the stratification condition.)

### 5.3 Imports (`IMPORTS`)

```
PREFIX ex: <http://example.com/rules/>
IMPORTS <http://example.com/rules/base-rules.srl>

RULE { ?x ex:derived ?y } WHERE { ... }
```

SHACL 1.2 Rule sets can import other rule sets. Imported rules merge into a single
combined rule set before stratification.

### 5.4 Data Blocks (`DATA`)

```
DATA { ex:defaultThreshold ex:value 10 }

RULE { ?x ex:exceeds true }
WHERE { ?x ex:score ?s . ex:defaultThreshold ex:value ?t . FILTER(?s > ?t) }
```

Declare facts inline with the rule set. Useful for configuration constants.

### 5.5 Shorthand Declarations

```
TRANSITIVE(ex:partOf)
SYMMETRIC(ex:relatedTo)
INVERSE(ex:parentOf, ex:childOf)
```

Common rule patterns expressed as single declarations.

---

## 6. Features Requiring Different Approaches

### 6.1 `sh:condition` → Body Patterns

SHACL-AF `sh:condition` points to a shape that the focus node must conform to.
In SHACL 1.2, replicate the shape's constraints as triple patterns and filters
in the rule body.

| sh:condition constraint | SRL body equivalent |
|------------------------|---------------------|
| `sh:minCount 1` on path P | `?x P ?val .` (pattern match ensures existence) |
| `sh:maxCount 1` on path P | — (single-valuedness implicit if you bind one var) |
| `sh:datatype xsd:integer` | `FILTER(datatype(?val) = xsd:integer)` |
| `sh:class ex:Foo` | `?val a ex:Foo .` |
| `sh:equals ex:other` | `?x ex:other ?o . FILTER(?val = ?o)` |
| `sh:hasValue ex:v` | `?x P ex:v .` |

### 6.2 `sh:deactivated` → Remove from Rule Set

SHACL-AF allows `sh:deactivated true` to disable a rule without deleting it.
In SHACL 1.2, simply remove the rule from the `srl:rules` list or comment it out
in SRL syntax.

### 6.3 `sh:order` → Automatic Stratification

SHACL-AF `sh:order` explicitly sequences rules. In SHACL 1.2, stratification
determines order based on dependencies. If rule A's body references predicates
that rule B's head produces, A **depends on** B.

Whether that dependency creates a stratum boundary depends on its kind:

- If A matches B's output with a plain triple pattern (an **open dependency**),
  A and B may share a stratum and iterate together to a fixed point. There is
  **no** guarantee that A lands in a strictly higher stratum than B — and it
  does not need one, because the fixed-point iteration lets A re-evaluate as B
  produces more triples.
- If A matches B's output inside a `NOT` block, or A has an assignment, or A's
  head creates a blank node (a **closed dependency**), then B is placed in a
  strictly earlier stratum so it is fully evaluated before A runs.

If you had rules at the same `sh:order` level that intentionally did NOT see
each other's output, note that SHACL 1.2 rules within the same stratum DO
converge to a fixed point (they iterate). This is a semantic difference.

### 6.4 Custom Targets + Rules → Body Patterns

SHACL-AF rules inherit focus nodes from shape targets (including custom
SPARQL-based targets). In SHACL 1.2, move the target's `SELECT` logic into
the rule body as triple patterns.

**Before (target-driven):**
```turtle
ex:Shape
    sh:target [ a sh:SPARQLTarget ;
        sh:select "SELECT ?this WHERE { ?this a ex:Person . ?this ex:bornIn ex:USA }" ] ;
    sh:rule [ ... ] .
```

**After (body pattern):**
```
RULE { ?x ex:citizenship ex:US }
WHERE { ?x a ex:Person . ?x ex:bornIn ex:USA }
```

### 6.5 `$this` Pre-binding → Explicit Variables

Every occurrence of `$this` in SHACL-AF CONSTRUCT queries becomes a regular
variable matched by the body.

**Before:** `$this ex:prop ?val` (pre-bound by target)
**After:** `?x ex:prop ?val` where `?x` is bound by other body patterns

### 6.6 Node Expressions → SRL Expressions

SHACL-AF node expressions (path expressions, function expressions, filter shape
expressions) used in Triple Rule `sh:object`, etc., map to SRL body patterns plus
a `SET` assignment:

| Node Expression | SRL Equivalent |
|----------------|----------------|
| `[ sh:path ex:name ]` | Body pattern: `?x ex:name ?result` |
| `[ ex:multiply ( [ sh:path ex:w ] [ sh:path ex:h ] ) ]` | Body patterns + `SET (?result := ex:multiply(?w, ?h))` |
| `[ sh:filterShape ex:S ; sh:nodes [ sh:path ex:p ] ]` | Body patterns with shape constraints as filters |
| `sh:this` | Variable bound elsewhere in body |
| Constant term (e.g., `ex:Square`) | Direct use in head triple template |

### 6.7 SHACL Functions → Expression Function Calls

SHACL-AF `sh:SPARQLFunction` declarations define reusable functions callable from
SPARQL or node expressions. In SHACL 1.2, functions are called within SRL expressions
using the same IRI-based function call syntax compatible with SPARQL extensible value
testing.

**Before (declaration + use in SPARQL Rule):**
```turtle
ex:multiply a sh:SPARQLFunction ;
    sh:parameter [ sh:path ex:op1 ] ;
    sh:parameter [ sh:path ex:op2 ] ;
    sh:select "SELECT ($op1 * $op2 AS ?result) WHERE {}" .
```
Used as: `BIND(ex:multiply(?w, ?h) AS ?area)` inside `sh:construct`.

**After (in SRL text syntax):**
```
SET (?area := ex:multiply(?w, ?h))
```

The function call syntax within expressions is preserved — the change is only
from SPARQL `BIND(expr AS ?v)` to SRL `SET (?v := expr)`. The function
definition mechanism is defined in SHACL 1.2 Node Expressions (separate spec),
not in the rules spec itself.

---

## 7. Implementor Considerations

### 7.1 Evaluation Model

SHACL-AF defines a single-pass ordered iteration over shapes and rules.
SHACL 1.2 defines stratified fixed-point evaluation:

- Build the dependency graph from rule head/body relationships, labeling each
  edge **open** or **closed**
- Partition rules into strata (no dependency cycle may contain a closed edge)
- Within a stratum, evaluate **run-once rules** (those with assignments or
  blank-node-producing heads) exactly once, then iterate the **general rules**
  to a fixed point
- Evaluate each stratum completely and in order before proceeding to the next

Implementations must detect the **stratification condition** — that no recursive
(cyclic) dependency involves a closed dependency — and report an error if it is
violated.

### 7.2 Handling Recursive Rules

SHACL-AF has no defined behavior for recursive rules. SHACL 1.2 explicitly supports
recursion through **open** dependencies within a stratum — rules iterate until no
new triples are produced. Recursion through a **closed** dependency (negation,
assignment, or blank-node-producing head) violates the stratification condition
and is undefined. Implementations need semi-naive evaluation or equivalent to
avoid redundant computation.

### 7.3 Inference Graph Separation

The output of SHACL 1.2 rule evaluation is strictly the inference graph — triples
NOT present in the base graph. Implementations must track which triples are new.
This differs from SHACL-AF where the data graph is conceptually modified in place.

### 7.4 Expression Compatibility

SHACL 1.2 Rule expressions are compatible with both SPARQL expressions and SHACL
Node Expression list-parameter functions. Implementations supporting SHACL-AF
functions should be able to reuse their expression evaluation logic.

### 7.5 Two Concrete Syntaxes

Implementations must handle either or both:
- **SRL text syntax**: `RULE`/`WHERE` grammar (SPARQL-like)
- **RDF syntax**: `srl:` vocabulary in Turtle/other RDF serializations

Both map to the same abstract syntax. Implementations may choose to support one
and provide translation tooling for the other.
