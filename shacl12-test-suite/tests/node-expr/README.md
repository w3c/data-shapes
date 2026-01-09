# SHACL 1.2 Node Expressions Test Suite

SHACL Node Expression test cases are instances of sht:EvalNodeExpr (not sht:Validate) where the mf:action has the properties below and mf:result defines an rdf:List of the expected results of the node expression:

- sht:nodeExpr: the node expression (usually blank node) to evaluate
- sht:focusNode: the (optional) focus node to start evaluation at
- sht:ignoreOrder: if true then the members of the actual output nodes do not have to have exactly the same order as the mf:result. They do need the same cardinalities though.
- sht:scope-XY: assigns the value of the property to the scope variable XY

Example:

```
<count-list-3>
  rdf:type sht:EvalNodeExpr ;
  rdfs:label "Test of a count expression on a list with three members" ;
  mf:action [
    sht:nodeExpr [
      shnex:count ( 4 3 3 ) ;
    ] ;
  ] ;
  mf:result ( 3 ) ;
  mf:status sht:approved ;
.
```

In the example above, the test harness needs to evaluate the node expression
which is the blank node value of sht:nodeExpr (a count expression) and then verify
that the output nodes are equal to the list mentioned in mf:result.
