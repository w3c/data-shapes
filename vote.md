# SHACL UI 

Proposal for votes for the working group

_5 Oct 2026_

# Vote: define a normative core

An implementation that supports every feature in a normative core conforms to SHACL UI. 

_An implementation that does not support the full core does not conform, though it can state which features it supports._

## Topic: normative core

The following features are an example of what could be considered a normative core. We will explore these, to establish the point that the working group should create a normative core.

1. Node UI Component and Property UI Component
2. Label and language resolution
3. Scoring system
4. Ordering
5. A small set of required widgets
6. Global configuration

## About Node UI Component and Property UI Component

SHACL shapes define validation constraints. It is perfectly fine to have multiple node shapes for one class. It is perfectly fine to have multiple property shape for one sh:path.

SHACL introduces Node UI Component and Property UI Component, these concepts describe how to merge nodes and properties.

_A core problem of translating N validation constraints to 1 UI component._

## About label and language resolution

Two algorithms that determine the most appropriate label for a given context.

A normative core must only require implementation of features that have clear intent.

For example: The meaning of language of xsd:strings are ambiguous. Is it English or just the system's native language? 

## About the scoring system

- Determines which widgets can be used for a given property shape and optional data
- Defines core characteristics of the SHACL UI, such as:
    - Resilience in case of data invalid for a specific shape
    - Allows for standardized extensions, like community widgets
    - Needed to render any existing SHACL shapes already written for validation without the addition of UI hints

## About ordering

- Order is a core aspect of every form
- Authors sequence fields deliberately: 
    dependent fields follow the fields they depend on
- sh:order has been used in practice for years without defined semantics, so every implementation invented its own and will keep doing so if the specification leaves order undefined

## About a small set of required widgets

Every value in RDF is an IRI, a literal or a blank node

A conforming implementation should be able to render all three, so that no value in the data is left without a widget

## About global configuration

We defined a configuration object for SHACL UI. It has the following properties:

- shui:defaultNamespace
- shui:languagePreference
- shui:timeZone
- shui:labelPreference
- shui:readOnlyGraph

It would be helpful is this configuration is part of a normative core. Shapes that contain such a configuration then would be interpreted in an interoperable way.

## Summary

We went through a couple of components which could be considered part of a potential normative core. However, we will only vote on having a normative core.

# Vote: sh:order semantics

- Where sh:order is given, properties and groups MUST be ordered respectively, from low to high.
- Where it is absent, the specification describes the fallback behaviour, which implementations SHOULD follow
- Ties SHOULD be broken deterministically. The specification describes a tie breaking algorithm, the implementer SHOULD use [but they MAY use an alternative one]

## Topic: sh:order semantics

- Order is a core aspect of every form
- Authors sequence fields deliberately: 
	dependent fields follow the fields they depend on
- sh:order has been used in practice for years without defined semantics, so every implementation invented its own

## Smart ordering works within the proposal

Usage based ordering does not need the specification to loosen sh:order. 
It can be built on top of it:

1. Gather usage statistics from the end user
2. Derive an adjusted copy of the shapes graph, giving frequently used properties a low sh:order value
3. Render the form from that copy

The renderer stays fully conformant: it respects sh:order exactly as specified, and the smart behaviour lives in the step before it.

A reactive renderer could go further and update the form whenever the derived shapes graph changes.

## Preprocessing shapes has precedence

Deriving shapes before rendering is already how the specification supports behaviour beyond the core:

- Rendering a form when only data is given and no shapes exist
- Selecting the most applicable node shapes for a given focus node

Smart ordering follows the same pattern. The renderer stays simple and predictable; innovation happens in the step before it, where it does not affect what other implementations guarantee.

# Vote: Create a test suite

Create a test suite, organised by feature, so an implementation can show which features it supports and check correctness of their implementation

Scope: which fields appear, their order, labels and selected widgets

## Topic: Test suite

SHACL UI defines how an implementation determines, from shapes and data:

- The most applicable widget for each value
- The most applicable label, in the most applicable language
- The order of fields and groups

Each of these is an outcome that follows from the inputs. Given the same shapes and data, two conforming implementations should arrive at the same result.
Without a test suite, it is very hard to tell if multiple renderers are interoperable.

## Many W3C specifications have test suites

A shared test suite lets implementers check their implementation against the specification, and compare that outcome with each other.

- It covers ordering, labels and widget IRIs
- It only checks outcomes the shapes actually determine. Where the specification leaves room, tests do not assert on that outcome:
    - The choice between plain xsd:string and rdf:langString labels is not checked when no language preference settles it
    - The order of fields without sh:order is not checked, though the same shapes can still be used to test everything else

## Interoperability suite does not involve any visual aspects

The proposal for a test suite involves:

Input files that leads to an outcome:
- data graph
- shapes graph
- focus node

Output JSON files with expected:
- labels
- ordering
- widget IRIs
