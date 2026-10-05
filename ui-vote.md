# Votes on the SHACL UI conformance model (#1083)

Issue [#1083](https://github.com/w3c/data-shapes/issues/1083) asks how tightly the SHACL UI specification should constrain implementations.
I propose the WG decides the following:

1. **Features as building blocks:** An implementation conforms by implementing the features it claims correctly, not by implementing all of them.
2. **Profiles instead of a core set:** Guarantees across features are defined by profiles, not by a single required core set.

Below I explain my position on each vote, based on the use cases in [#1174](https://github.com/w3c/data-shapes/issues/1174), [#1170](https://github.com/w3c/data-shapes/issues/1170), and [#1142](https://github.com/w3c/data-shapes/issues/1142).

## Vote 1: Features as building blocks

### Proposed resolution

- The spec defines SHACL UI as a set of features.
- Each feature is a building block that covers one functional concern, such as language and label resolution, ordering, grouping, or widget scoring.
- An implementation doesn't have to implement all features to be spec conformant.
- It conforms if it correctly implements the features it claims.
- Features can build on other features, for example ordering uses label resolution.

### The use cases

- **Lightweight renderer (#1174):**
  Renderers that must not depend on SPARQL or Node Expressions, because of resource constraints or security requirements, need bounded computation and few dependencies.
  Widget scoring would require a full SHACL engine, including SPARQL and Node Expressions for custom widgets.
  A renderer that only implements declared widgets (`shui:editor`/`shui:viewer`) fits these needs, but only if scoring is a feature it can leave out.
- **Closed-world systems (#1142):**
  SHACL is used for data modeling as a semantic layer, and widgets are assigned directly as part of the model.
  The widgets come from a defined set that is checked at build time: a subset of the built-in widgets, custom widgets, or both.
  No scoring layer is wanted.
  Conformance is a selling point in that enterprise market, so these implementations need to be conformant for the features they do implement.
- **Smart order (#1170):**
  Usage-based ordering, or grouping related properties based on the ontology or on AI, for properties without `sh:order`.
  This needs the fallback order to be a separate feature from "respect `sh:order`".

### Example: Alphabetical sorting of property shapes

The current specification says: "SHACL Renderers MUST determine the presentation order of property shapes and property groups using the value of `sh:order`."
A renderer that lets the user switch to alphabetical sorting, for example with a "Sort A–Z" toggle, violates that MUST whenever `sh:order` is given.
With ordering as a feature, the definition for `sh:order` could be treated as optional.

## Vote 2: Profiles instead of a core set of features

### Proposed resolution

- A profile is a named set of features, which can add constraints using MUST.
- A conformance claim names the profiles and features it meets.
- The spec can define several profiles.
  - One of the profiles can reflect the requested minimal core.
- Other profiles can be defined later, inside or outside the WG.

### Why profiles are better than a core set

The use cases need different sets of features, and some of those sets conflict:

| Use case | Needs | Conflicts |
|---|---|---|
| Application profile portability | widget scoring, built-in widgets, fallback order, tie-breaking | optional widget scoring, optional built-in widgets, optional fallback order, optional tie-breaking |
| Lightweight renderer | declared widgets only, bounded complexity | mandatory widget scoring |
| Closed-world systems | own widget set, declared widgets only | mandatory widget scoring, mandatory built-in widgets |
| Smart order | custom fallback order | mandatory fallback order, strict tie-breaking |

A single core set has to be either:

- the **union** of everything one group needs, which excludes the others, or
- the **intersection** of all use cases, which is too small to give the portability guarantees its supporters want.

Profiles solve this conflict.
Nobody is pushed out of conformance by another group's requirements.
Profiles are also more flexible over time: a new use case can get a new profile without changing what existing implementations conform to.

## Summary

- **Vote 1:** Yes to features as functional building blocks that can be implemented individually.
- **Vote 2:** Yes to profiles as the way to define sets of features with guarantees, instead of one required core set.

Together, these two votes give the guarantees to those who need them, and keep valid use cases like #1174, #1170, and #1142 conformant.

## Vote 3: Publish SHACL UI as a Note

### Proposed resolution

- SHACL UI is published as a W3C Working Group Note instead of a Recommendation.

### Why

The specification has quality issues, and it's unrealistic that the task force can solve them in the remaining time.
Some examples:

- **Example: Deterministic tie-breaking:**
  Adding "deterministic" to the tie-breaking algorithm has been discussed for months.
  Comments pointing out that the context in which the behavior must be deterministic isn't defined have been ignored.
  So has the comment that such a definition would be hard to write in a way that covers all use cases.
- **Example: Entry point of the renderer:**
  "SHACL UI Application" was proposed as the entry point.
  Comments about use cases with multiple renderers in a single application have been ignored.
- **Example: Ordering:**
  The ordering part of the specification was added without PR review and has serious quality issues.
- **Example: Widget scoring:**
  Changes to widget scoring were also added without PR review.
  Cleaning them up takes much more time than reviewing them would have.
  The same will apply to ordering, and it's unrealistic that the task force will manage this in time.

A Note still documents the work done so far and lets implementations build on it, without claiming a level of quality and consensus the specification hasn't reached.
