# SPARQL 1.2 RL Tests

## Manifests

Tests use the <http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#>
vocabulary.

```
PREFIX mf:   <http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#>
PREFIX srt:  <http://www.w3.org/ns/sparql-rl-tests#>
```

Each directory has a test manifest. A manifest file may contain `mf:include` to load
tests from another manifest files.

The top level manifest is `manifest-sparql-rl.ttl`.

## Tests

* [Syntax tests](syntax/)
* [Evaluation tests](eval/)
* [Evaluation examples](eval2/)
* [Stratification tests](stratification/)
* [Well-formedness tests](wellformed/)

### Syntax tests

Good and bad syntax tests, regardless of well-formedness and stratification.

### Well-formedness tests

These are test for well-formedness conditions. 

All the test are syntactically legal, i.e. conform to the SPARQL-RL Rules grammar and any
additional parsing rules.

To pass a test, the parser must accept or reject a rule set as stated by the test
type. A negative well-formedness is a ruleset that violates one or more well-formed
conditions of the SPARQL-RL abstract rule syntax.

### Stratification

These test rule sets to detect where the stratification condition is violated.

All the test are syntactically legal and well-formed.

## Evaluation tests

The result of an evaluation test is the inference graph. 

There are two directories of evaluation tests. [`eval/`](eval/) has feature
tests and [`eval2/`](eval2/)  has some larger tests.
