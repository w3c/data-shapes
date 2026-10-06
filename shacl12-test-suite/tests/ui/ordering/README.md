# SHACL 1.2 UI Ordering Tests

SHACL UI ordering test cases are instances of `sht:EvalOrder` (not `sht:Validate`).
They cover [Grouping, Ordering, and Layout Hints](../../../../shacl12-ui/index.html#grouping-and-ordering),
[Property Roles](../../../../shacl12-ui/index.html#property-roles) and
[ValueTableViewer](../../../../shacl12-ui/index.html#ValueTableViewer).

The `mf:action` has the following properties:

- `sht:shapesGraph`: the shapes graph (the test document itself)
- `sht:orderingContext`: the ordering to evaluate, one of:
  - `sht:PresentationOrder`: presentation order of the property shapes and property groups of `sht:nodeShape`
  - `sht:RolePrecedence`: precedence of the property shapes of `sht:nodeShape` that have the role `sht:propertyRole`
  - `sht:TableColumnOrder`: column order of the `shui:ValueTableViewer` property shape `sht:propertyShape`, taken from its `sh:node` shape
- `sht:nodeShape`, `sht:propertyShape`, `sht:propertyRole`: the selectors that the context requires

`mf:result` is an RDF list of the expected property shapes, in order. In a
presentation order, each property group appears as a *group entry*: a blank node
with `sht:group` (the group) and `sht:members` (an RDF list of its property
shapes, in order).

Property shapes and property groups in these tests are always IRIs, so that
`mf:result` refers to the same resources as the shapes graph. The only blank
nodes in `mf:result` are list nodes and group entries. This is a convention for
these test files; SHACL itself allows shapes and groups to be blank nodes.

Example:

```turtle
<property-groups-001>
  rdf:type sht:EvalOrder ;
  mf:action [
    sht:shapesGraph <> ;
    sht:orderingContext sht:PresentationOrder ;
    sht:nodeShape ex:PersonShape
  ] ;
  mf:result (
    ex:NameShape
    [ sht:group ex:ContactGroup ; sht:members ( ex:PhoneShape ex:EmailShape ) ]
    ex:NotesShape
  ) ;
  mf:status sht:proposed ;
.
```

The test harness evaluates the requested ordering and checks that the output
matches `mf:result`: the same property shapes and groups, in the same order,
with each property shape in the same group, and nothing missing, extra or
duplicated. Blank node labels and serialization order do not matter, so
comparing both as RDF graphs, for example by graph isomorphism, is one way to
check this.

All cases use distinct `sh:order` values, so they do not depend on default orders
or tie-breaking.
