# SHACL 1.2 Rules Tests



## Manifests

Tests use the <http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#>
vocabulary.

```
PREFIX mf:   <http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#>
PREFIX srt:  <http://www.w3.org/ns/shacl-rules-test#>
```

Each directory has a test manifest. A manifest file may contain `mf:include` to load
tests from another manifest files.

## Test types

### Syntax tests

Good and bad syntax tests, regardless of well-formedness and stratification.

### Translation tests

Translate between SRL and RDF syntax forms.

### Well-formedness tests

These are test for well-formedness conditions. 
All the test are syntactically legal, i.e. conform to the SHACL Rules grammar and any
addition parsing rules.

To pass a test, the parser must accept or reject a rule set as stated by the test
stype. A negative well-formedness is a ruleset that violates the well-formed
conditions of the SHACL abstract rule syntax.

### Illegal stratification

These test rule sets to detect where the stratification condition is violated.

All the test are syntactically legal and well-formed.

## Evaluation tests
