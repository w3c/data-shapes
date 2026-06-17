# SHACL-AF to SHACL 1.2 Rules: Migration Patterns Cookbook

A pattern-by-pattern reference for rewriting SHACL-AF rules in SHACL 1.2.
Each pattern is self-contained with before/after examples.

---

## Pattern 1: Simple Property Inference (SPARQL Rule)

Infer a new property value from existing triples.

### Before (SHACL-AF)

```turtle
ex:PersonShape
    a sh:NodeShape ;
    sh:targetClass ex:Person ;
    sh:rule [
        a sh:SPARQLRule ;
        sh:prefixes ex: ;
        sh:construct """
            CONSTRUCT {
                $this ex:label ?label .
            }
            WHERE {
                $this ex:name ?label .
            }
            """ ;
    ] .
```

### After (SRL Text Syntax)

```
PREFIX ex: <http://example.com/ns#>

RULE { ?x ex:label ?label }
WHERE { ?x a ex:Person . ?x ex:name ?label }
```

### After (RDF Syntax)

```turtle
:labelRuleSet
    a srl:RuleSet ;
    srl:rules (
        [   a srl:Rule ;
            srl:body (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate rdf:type ;
                  srl:object ex:Person ]
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:name ;
                  srl:object [ srl:varName "label" ] ]
            ) ;
            srl:head (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:label ;
                  srl:object [ srl:varName "label" ] ]
            )
        ]
    ) .
```

### Notes

- `sh:targetClass ex:Person` becomes `?x a ex:Person` in body
- `$this` becomes `?x` (any variable name works)

---

## Pattern 2: Type Classification (Triple Rule + `sh:condition`)

Classify nodes based on property conditions.

### Before (SHACL-AF)

```turtle
ex:Rectangle
    a rdfs:Class, sh:NodeShape ;
    sh:property [
        sh:path ex:width ;
        sh:datatype xsd:integer ;
        sh:minCount 1 ; sh:maxCount 1 ;
    ] ;
    sh:property [
        sh:path ex:height ;
        sh:datatype xsd:integer ;
        sh:minCount 1 ; sh:maxCount 1 ;
    ] ;
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

### After (SRL Text Syntax)

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

### After (RDF Syntax)

```turtle
:squareRuleSet
    a srl:RuleSet ;
    srl:rules (
        [   a srl:Rule ;
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

### Notes

- `sh:condition ex:Rectangle` → class check and property existence in body
- `sh:equals ex:height` → FILTER equality test
- Datatype/cardinality constraints from sh:condition shape → implicit through
  pattern matching (binding `?w` and `?h` ensures at least one value exists)

---

## Pattern 3: Computed Values (SPARQL Rule + `BIND`)

Compute derived values using arithmetic or string operations.

### Before (SHACL-AF)

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
                SET (?area := ?width * ?height ) .
            }
            """ ;
        sh:condition ex:RectangleShape ;
    ] .
```

### After (SRL Text Syntax)

```
PREFIX ex: <http://example.com/ns#>

RULE { ?x ex:area ?area }
WHERE {
    ?x a ex:Rectangle .
    ?x ex:width ?width .
    ?x ex:height ?height .
    BIND(?width * ?height AS ?area)
}
```

### After (RDF Syntax)

```turtle
:areaRuleSet
    a srl:RuleSet ;
    srl:rules (
        [   a srl:Rule ;
            srl:body (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate rdf:type ;
                  srl:object ex:Rectangle ]
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:width ;
                  srl:object [ srl:varName "width" ] ]
                [ srl:subject [ srl:varName "x" ] ;
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
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:area ;
                  srl:object [ srl:varName "area" ] ]
            )
        ]
    ) .
```

### Notes

- BIND syntax identical between SPARQL and SRL
- `sh:condition ex:RectangleShape` → body patterns that enforce same constraints
- RDF syntax uses `srl:assign` + `srl:assignVar` + `srl:assignValue`

---

## Pattern 4: Conditional Inference (`sh:condition` shapes)

Apply rules only to nodes conforming to specific shapes.

### Before (SHACL-AF)

```turtle
ex:PersonRulesShape
    a sh:NodeShape ;
    sh:targetClass ex:Person ;
    sh:rule [
        a sh:SPARQLRule ;
        sh:prefixes ex: ;
        sh:construct """
            CONSTRUCT { $this ex:status "adult" }
            WHERE { $this ex:age ?age . FILTER(?age >= 18) }
            """ ;
        sh:condition [
            sh:property [
                sh:path ex:age ;
                sh:minCount 1 ;
                sh:datatype xsd:integer ;
            ] ;
        ] ;
    ] .
```

### After (SRL Text Syntax)

```
PREFIX ex: <http://example.com/ns#>

RULE { ?x ex:status "adult" }
WHERE {
    ?x a ex:Person .
    ?x ex:age ?age .
    FILTER(datatype(?age) = xsd:integer)
    FILTER(?age >= 18)
}
```

### After (RDF Syntax)

```turtle
:adultRuleSet
    a srl:RuleSet ;
    srl:rules (
        [   a srl:Rule ;
            srl:body (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate rdf:type ;
                  srl:object ex:Person ]
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:age ;
                  srl:object [ srl:varName "age" ] ]
                [ srl:filter [ sparql:equals (
                    [ sparql:datatype ( [ srl:varName "age" ] ) ]
                    xsd:integer
                ) ] ]
                [ srl:filter [ sparql:greaterThanOrEqual (
                    [ srl:varName "age" ]
                    18
                ) ] ]
            ) ;
            srl:head (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:status ;
                  srl:object "adult" ]
            )
        ]
    ) .
```

### Notes

- `sh:minCount 1` → body pattern match (binding ensures value exists)
- `sh:datatype xsd:integer` → `FILTER(datatype(?age) = xsd:integer)`
- Multiple conditions stack as multiple FILTER elements
- In practice, if your data is clean, the datatype filter may be unnecessary

---

## Pattern 5: Ordered/Chained Rules (`sh:order`)

Rules that must execute in sequence, where later rules depend on earlier results.

### Before (SHACL-AF)

```turtle
ex:PersonRulesShape
    a sh:NodeShape ;
    sh:targetClass ex:Person ;
    sh:rule [
        a sh:SPARQLRule ;
        sh:order 1 ;
        sh:prefixes ex: ;
        sh:construct """
            CONSTRUCT { $this ex:uncle ?uncle }
            WHERE {
                $this ex:parent ?parent .
                ?parent ex:sibling ?uncle .
                ?uncle ex:gender ex:male .
            }
            """ ;
    ] ;
    sh:rule [
        a sh:SPARQLRule ;
        sh:order 2 ;
        sh:prefixes ex: ;
        sh:construct """
            CONSTRUCT { $this ex:cousin ?cousin }
            WHERE {
                $this ex:uncle ?uncle .
                ?cousin ex:parent ?uncle .
            }
            """ ;
    ] .
```

### After (SRL Text Syntax)

```
PREFIX ex: <http://example.com/ns#>

RULE { ?x ex:uncle ?uncle }
WHERE {
    ?x a ex:Person .
    ?x ex:parent ?parent .
    ?parent ex:sibling ?uncle .
    ?uncle ex:gender ex:male
}

RULE { ?x ex:cousin ?cousin }
WHERE {
    ?x a ex:Person .
    ?x ex:uncle ?uncle .
    ?cousin ex:parent ?uncle
}
```

### Notes

- No `sh:order` needed. The cousin rule references `ex:uncle` in its body, and
  the uncle rule produces `ex:uncle` in its head. Stratification automatically
  places the uncle rule in a lower (earlier) stratum.
- Both rules run to fixed point within their respective strata.

---

## Pattern 6: Function-Based Computation (Node Expressions + SHACL Functions)

Using SHACL Functions within Triple Rules via node expressions.

### Before (SHACL-AF)

```turtle
ex:multiply
    a sh:SPARQLFunction ;
    sh:parameter [ sh:path ex:op1 ; sh:datatype xsd:integer ] ;
    sh:parameter [ sh:path ex:op2 ; sh:datatype xsd:integer ] ;
    sh:returnType xsd:integer ;
    sh:select "SELECT ($op1 * $op2 AS ?result) WHERE {}" .

ex:RectangleRulesShape
    a sh:NodeShape ;
    sh:targetClass ex:Rectangle ;
    sh:rule [
        a sh:TripleRule ;
        sh:subject sh:this ;
        sh:predicate ex:area ;
        sh:object [
            ex:multiply ( [ sh:path ex:width ] [ sh:path ex:height ] ) ;
        ] ;
        sh:condition ex:RectangleShape ;
    ] .
```

### After (SRL Text Syntax)

```
PREFIX ex: <http://example.com/ns#>

RULE { ?x ex:area ?area }
WHERE {
    ?x a ex:Rectangle .
    ?x ex:width ?w .
    ?x ex:height ?h .
    BIND(ex:multiply(?w, ?h) AS ?area)
}
```

### After (RDF Syntax)

```turtle
:areaRuleSet
    a srl:RuleSet ;
    srl:rules (
        [   a srl:Rule ;
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
                [ srl:assign [
                    srl:assignVar [ srl:varName "area" ] ;
                    srl:assignValue [ ex:multiply (
                        [ srl:varName "w" ]
                        [ srl:varName "h" ]
                    ) ]
                ] ]
            ) ;
            srl:head (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:area ;
                  srl:object [ srl:varName "area" ] ]
            )
        ]
    ) .
```

### Notes

- Node expression `[ ex:multiply ( [ sh:path ex:width ] [ sh:path ex:height ] ) ]`
  decomposes into: path expressions → body patterns, function call → `BIND` expression
- Function IRI (`ex:multiply`) used directly in `BIND` — same calling convention
- Function definition mechanism is in SHACL 1.2 Node Expressions specification, not rules specification

---

## Pattern 7: Path-Based Triple Derivation (Triple Rule + Path Expressions)

Using property paths in Triple Rules to navigate graph structure.

### Before (SHACL-AF)

```turtle
ex:OrgShape
    a sh:NodeShape ;
    sh:targetClass ex:Organization ;
    sh:rule [
        a sh:TripleRule ;
        sh:subject sh:this ;
        sh:predicate ex:memberName ;
        sh:object [
            sh:path ( ex:member ex:name ) ;
        ] ;
    ] .
```

### After (SRL Text Syntax)

```
PREFIX ex: <http://example.com/ns#>

RULE { ?org ex:memberName ?name }
WHERE {
    ?org a ex:Organization .
    ?org ex:member/ex:name ?name
}
```

### After (RDF Syntax)

```turtle
:memberNameRuleSet
    a srl:RuleSet ;
    srl:rules (
        [   a srl:Rule ;
            srl:body (
                [ srl:subject [ srl:varName "org" ] ;
                  srl:predicate rdf:type ;
                  srl:object ex:Organization ]
                [ srl:subject [ srl:varName "org" ] ;
                  srl:predicate ex:member ;
                  srl:object [ srl:varName "m" ] ]
                [ srl:subject [ srl:varName "m" ] ;
                  srl:predicate ex:name ;
                  srl:object [ srl:varName "name" ] ]
            ) ;
            srl:head (
                [ srl:subject [ srl:varName "org" ] ;
                  srl:predicate ex:memberName ;
                  srl:object [ srl:varName "name" ] ]
            )
        ]
    ) .
```

### Notes

- SHACL sequence paths `( ex:member ex:name )` → SRL path syntax `ex:member/ex:name`
  (SRL supports SPARQL property paths in body)
- In RDF syntax, multi-step paths decompose into separate triple patterns with
  intermediate variables

---

## Pattern 8: Multi-Triple Output (SPARQL `CONSTRUCT` with Multiple Patterns)

Rules that produce multiple triples per match.

### Before (SHACL-AF)

```turtle
ex:PersonShape
    a sh:NodeShape ;
    sh:targetClass ex:Person ;
    sh:rule [
        a sh:SPARQLRule ;
        sh:prefixes ex: ;
        sh:construct """
            CONSTRUCT {
                $this ex:fullName ?full .
                $this ex:initials ?init .
            }
            WHERE {
                $this ex:firstName ?f .
                $this ex:lastName ?l .
                BIND(CONCAT(?f, " ", ?l) AS ?full) .
                BIND(CONCAT(SUBSTR(?f, 1, 1), SUBSTR(?l, 1, 1)) AS ?init) .
            }
            """ ;
    ] .
```

### After (SRL Text Syntax)

```
PREFIX ex: <http://example.com/ns#>

RULE {
    ?x ex:fullName ?full .
    ?x ex:initials ?init
}
WHERE {
    ?x a ex:Person .
    ?x ex:firstName ?f .
    ?x ex:lastName ?l .
    BIND(concat(?f, " ", ?l) AS ?full)
    BIND(concat(substr(?f, 1, 1), substr(?l, 1, 1)) AS ?init)
}
```

### After (RDF Syntax)

```turtle
:nameRuleSet
    a srl:RuleSet ;
    srl:rules (
        [   a srl:Rule ;
            srl:body (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate rdf:type ;
                  srl:object ex:Person ]
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:firstName ;
                  srl:object [ srl:varName "f" ] ]
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:lastName ;
                  srl:object [ srl:varName "l" ] ]
                [ srl:assign [
                    srl:assignVar [ srl:varName "full" ] ;
                    srl:assignValue [ sparql:concat (
                        [ srl:varName "f" ]
                        " "
                        [ srl:varName "l" ]
                    ) ]
                ] ]
                [ srl:assign [
                    srl:assignVar [ srl:varName "init" ] ;
                    srl:assignValue [ sparql:concat (
                        [ sparql:substr ( [ srl:varName "f" ] 1 1 ) ]
                        [ sparql:substr ( [ srl:varName "l" ] 1 1 ) ]
                    ) ]
                ] ]
            ) ;
            srl:head (
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:fullName ;
                  srl:object [ srl:varName "full" ] ]
                [ srl:subject [ srl:varName "x" ] ;
                  srl:predicate ex:initials ;
                  srl:object [ srl:varName "init" ] ]
            )
        ]
    ) .
```

### Notes

- Multiple triple templates in the head → multiple inferred triples per match
- Each head triple template is a separate element in the `srl:head` list
- SPARQL built-in functions (CONCAT, SUBSTR) available via `sparql:` namespace

---

## Quick Reference: Migration Checklist

For each SHACL-AF rule, follow these steps:

1. **Identify target logic** — what `sh:targetClass`, `sh:targetNode`, or `sh:target`
   selects. Convert to body triple patterns.

2. **Extract conditions** — what `sh:condition` shapes enforce. Convert constraints
   to body patterns + filters.

3. **Map `$this`** — replace with explicit variable, ensure it's bound by body patterns.

4. **Convert construct/triple template** — `CONSTRUCT` body → SRL body; `CONSTRUCT` head
   → SRL head. Triple Rule properties → head triple template.

5. **Remove ordering** — delete `sh:order`. Verify dependency-based stratification
   preserves intended semantics.

6. **Decompose node expressions** — path expressions become body patterns; function
   expressions become `BIND`; filter shapes become body constraints.

7. **Group into rule set** — collect related rules into an `srl:RuleSet`.

8. **Leverage new features** — consider whether negation, recursion, or `TRANSITIVE`
   declarations simplify your rules.
