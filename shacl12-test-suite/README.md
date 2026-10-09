# SHACL 1.2 test-suite

This repository contains the SHACL test-suite for SHACL 1.2.

The format follows the previously published
http://w3c.github.io/data-shapes/data-shapes-test-suite/

The content from the data-shapes-test-suite folder remains unaffected, for SHACL 1.0.

## Implementation Reports

Submitted implementations so far: [Implementation reports](reports.html)

## Conformance Criteria

The 1.2 specs that are covered by test cases define these conformance criteria:

| ID | Description | Default for
| --- | --- | ---
| `Core` | "SHACL Core processors" | all tests under tests/core |
| `InferenceRules` | "SHACL rules engines" | all tests under tests/inference-rules |
| `NodeExpr` | "SHACL Node Expressions processors" | all tests under tests/node-expr |
| `SPARQLValidation` | "SHACL-SPARQL validation processors" |
| `SPARQLNodeExpr` | "SPARQL node expression processors" |
| `SPARQLCustomFunctions` | "SPARQL custom function processors" |
| `SRLEvaluation` | "SPARQL-RL Rule Set evaluation" |
| `SRLSyntax` | "SPARQL-RL syntax" |

Tests SHOULD list the conformance criteria that are covered using the property `mf:requires`
with values such as `sht:Core`, `sht:InferenceRules` etc as listed above.
