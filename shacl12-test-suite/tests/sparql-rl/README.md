# SPARQL 1.2 RL Tests

## Implementation reports

SPARQL-RL implementation reports use the [W3C EARL vocabulary](https://www.w3.org/WAI/standards-guidelines/earl/).

Please submit a pull request to put your report in [/shacl12-test-suite/reports/sparql-rl/](https://github.com/w3c/data-shapes/tree/gh-pages/shacl12-test-suite/reports/sparql-rl/).

Alternatively, email the working group mailing list
`public-shacl@w3.org` with your EARL file as an attachment.

## Manifests

Tests use the <http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#>
vocabulary.

Each directory has a test manifest. A manifest file may contain
`mf:include` to load tests from another manifest file.

The top level manifest is `manifest-sparql-rl.ttl`.

Tests are named as `:testLocalName` where the `PREFIX` in each test
folder is of the pattern:

```
PREFIX :       <https://w3c.github.io/rdf-tests/sparql-rl/FOLDER/>
```

## Tests

* [Syntax tests](syntax/)
* [Well-formedness tests](wellformed/)
* [Stratification tests](stratification/)
* [Evaluation tests](eval/)
* [Evaluation tests (illustrative uses)](eval2/)
* [Examples from the specification](examples/)

### Syntax tests

These are good and bad syntax tests, regardless of well-formedness and
stratification.

Each test has a single `mf:action` property whose object is a SPARQL-RL
rule set file. An implementation must parse the file and decide whether
the file is valid syntax or not.

To pass a test, the parser must accept or reject a rule set as stated by
the test type. A positive syntax test is a rule set that conforms to the
SPARQL-RL grammar. A negative syntax test is a rule set that does not
conform to the SPARQL-RL grammar.

| Test type | Criterion |
| --------- | --------- |
| `srlt:RulesPositiveSyntaxTest` | Conforms to the SPARQL-RL grammar. |
| `srlt:RulesNegativeSyntaxTest` | Does not conform to the SPARQL-RL grammar. |

### Well-formedness tests

These are tests for well-formedness conditions.

All the tests are syntactically legal, i.e. conform to the SPARQL-RL
grammar and any additional parsing rules. Each test has a single
`mf:action` property whose object is a SPARQL-RL rule set file.

To pass a test, the parser must accept or reject a rule set as stated by
the test type. A negative well-formedness test has a rule set that
violates one or more well-formed conditions of the SPARQL-RL abstract
rule syntax. A positive well-formedness test has a rule set that passes
all the well-formed conditions.

| Test type | Criterion |
| --------- | --------- |
| `srlt:RulesPositiveWellFormednessTest` | Passes the well-formedness conditions. |
| `srlt:RulesNegativeWellFormednessTest` | Does not pass the well-formedness conditions. |

### Stratification tests

These tests detect rulesets that violate the stratification condition.

All the stratification tests are syntactically legal and well-formed.
Each test has a single `mf:action` property whose object is a SPARQL-RL
rule set file.

| Test type | Criterion |
| --------- | --------- |
| `srlt:RulesPositiveStratificationTest` | The rule set has a stratification. |
| `srlt:RulesNegativeStratificationTest` | The rule set cannot be stratified. |

### Evaluation tests

The result of an evaluation test is the inference graph.

There are three directories of evaluation tests. [`eval/`](eval/) has
feature tests, [`eval2/`](eval2/) has some feature tests, and
[`examples/`](examples/) contains some of the examples from the
specification.

| Test type |
| --------- |
| `srlt:RulesEvalTest` |

An evaluation test has a triple with property `mf:action` and a triple
with property `mf:result`.

The triple with property `mf:action` has an object (usually a blank
node) that in turn is the subject of two triples. One triple has
property `srlt:ruleset` with the object being a URL for a SPARQL-RL
rule set. The other triple has property `srlt:data` whose object is a URL
for a file containing an RDF graph (the file extension indicates the
syntax).

The triple with property `mf:result` has an object which is a URL for a
file containing an RDF graph.

To pass the test, an implementation must parse the SPARQL-RL rule set, load
the data graph, then execute to produce the inference graph of rule set
evaluation (i.e. inferred triples not present in the input graph).

An implementation passes an evaluation test if the inference graph is
blank node isomorphic to the graph given by `mf:result`.
