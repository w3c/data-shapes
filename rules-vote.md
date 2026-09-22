# Potential WG Vote on Relationship between the two Rules documents

In response to <https://lists.w3.org/Archives/Public/public-shacl/2026Sep/0062.html> this
page is here to formulate a vote (or votes) by the WG to resolve the remaining key question
related to the SHACL 1.2 Inference Rules and the SPARQL-RL specs.

## Background

In the beginning of the WG we decided to organize our work into Task Forces.
These Task Forces were supposed to be small, agile special interest groups that should prepare
a document for the wider group to consider.

### Original Requirements

The SHACL Rules TF is one of these Task Forces.
The input to the group were the requirements outlined in the [Charter](https://www.w3.org/2024/12/data-shapes.html):

> This specification will define a SHACL vocabulary to represent inferencing rules
that can be used to infer new RDF statements from existing statements.
A starting point may be the Node Expressions and SHACL Rules from the Advanced Features document.

Furthermore, the charter states

> The following features are out of scope, and will not be addressed by this Working group:
specifications not based on SHACL

### Current Status

SHACL 1.2 Inference Rules (SHACL Rules) is a direct evolution of SHACL-AF.
SPARQL-RL (SRL) is a datalog-based stand-alone language, unrelated to SHACL.
So we have two separate rule documents and there is no real bridge between them.

### Problem Statement

To achieve interoperability, implementations will need to transform the syntax before rules can be executed.
In other words, the situation between SHACL Rules and SRL is similar to SHACL Rules and SWRL, RIF or N3.
If the W3C mission is to produce standards (for interoperability) we have failed.

Example in CONSTRUCT (supported by sh:SPARQLRule right now)

```
    CONSTRUCT { ?r ex:area ?area }
    WHERE { ?r ex:width ?width . ?r ex:height ?height . BIND (?width * ?height AS ?area) }
```

Example in SRL syntax

```
    RULE { ?r ex:area ?area }
    WHERE { ?r ex:width ?width . ?r ex:height ?height . SET (?area := ?width * ?height) }
```

Furthermore, the current SPARQL-RL draft directly violates the charter and would need to be published
under a different charter.

## Proposal 1: Generalize SRL Syntax to also support CONSTRUCT (aka SPARQL-Full vs SPARQL-RL)

This was suggested by Holger across these tickets:
- [SPARQL-Full vs SPARQL-RL](https://github.com/w3c/data-shapes/issues/1073)
- [Add description of translation between SPARQL-RL syntax and SPARQL CONSTRUCT](https://github.com/w3c/data-shapes/issues/1196)

The core observation is that the expressiveness of SRL is a subset of SPARQL CONSTRUCTs.
SRL has introduced syntactic sugar (SET for BIND+FILTER bound and NOT for FILTER NOT EXISTS)
but there is nothing in SRL that could not also be expressed in SHACL Rules via CONSTRUCT
(except a detail with the execution of NOW() as [Simon pointed out](https://github.com/w3c/data-shapes/pull/1263#discussion_r4067169049)
and a [yet-to-be-implemented equivalent for WHERE DATA/NOT DATA](https://github.com/w3c/data-shapes/issues/1271)).

What SRL is adding is the ability to automatically compute the layers of rules (stratification).
This is a nice feature that would be beneficial also for users of SHACL rules that don't even know
that their rules fall into the SRL subset.

If we recognize that SRL is a subset of CONSTRUCT then it *should* be possible to express any SRL rule set
with SHACL Rules syntax.
This would allow SRL rules to be executed by a SHACL engine, assuming that the layers have been set
(either by hand or automatically through stratification).
A key benefit is that users can step outside of the SRL expressiveness for individual rules,
i.e. rule types can be mixed.

Furthermore, it is reasonable to assume that the future will produce different subsets of SPARQL
with different computational characteristics, and CONSTRUCT may allow this better than a custom SRL syntax.

Example of an SRL rule set in SHACL RDF syntax (see also [source](https://github.com/w3c/data-shapes/pull/1230#discussion_r3964203449)):

```
ex:MyRuleSet
    a sh:RuleSet ;
    sh:ruleProcessor "SRL" ;  # or "SPARQL-RL 1.2" or srl:SRL or whatever
    sh:hasRule [
        a sh:SPARQLRule ;
        sh:construct """
            CONSTRUCT { ?r ex:area ?area }
            WHERE { ?r ex:width ?width . ?r ex:height ?height . BIND (?width * ?height AS ?area) }
        """ ;
    ] ;
    sh:hasRule [
        a sh:SPARQLRule ;
        sh:construct """
            CONSTRUCT { ?r ex:large true }
            WHERE { ?r ex:area ?area . FILTER (?area > 100) }
        """ ;
    ] .
```

If the rule processor has already been executed, this becomes

```
ex:MyRuleSet
    a sh:RuleSet ;
    sh:hasRule [
        a sh:SPARQLRule ;
        sh:construct """
            CONSTRUCT { ?r ex:area ?area }
            WHERE { ?r ex:width ?width . ?r ex:height ?height . BIND (?width * ?height AS ?area) }
        """ ;
        sh:runOnce true ;
    ] ;
    sh:hasRule [
        a sh:SPARQLRule ;
        sh:construct """
            CONSTRUCT { ?r ex:large true }
            WHERE { ?r ex:area ?area . FILTER (?area > 100) }
        """ ;
    ] .
```

which means the stratification can be applied once and is no longer needed before each execution.
(In this case, only the sh:runOnce was computed, but there will certainly be more complex examples).

For SRL the cost is that the grammar requires a few additional lines so that either CONSTRUCT+BIND or RULE+SET
can be used. They would both map to the same runtime objects, so implementation overhead is likely small.

An alternative implementation strategy is to leave the SRL grammar unchanged but define a pre-processor
by making https://w3c.github.io/data-shapes/sparql12-rl/#srl-sparql-relationship normative.
Such SRL implementations would be able to convert CONSTRUCT to RULE on the fly and report a failure if they
receive a CONSTRUCT that cannot be converted.
Likely this would be a different vote "1b".

For SRL the benefit is that users that already know CONSTRUCT can get started immediately and even use
existing SPARQL-based tooling to develop and test the rules.

Another benefit for the SRL spec is that it doesn't need to worry about SHACL - the link becomes indirect through syntactical overlap.
This would mean that the SRL Rule Type from Proposal 2 would not really be required.

### Concerns re. proposal `#1` - David Habgood

1. for the use case where authors write rules with the intent of them being executed in a specific way, it is not clear without external context what the author's intent was. When text is copied / sent over chat/email etc. context can be lost
2. users may miss differences in semantics where the same tokens are used with different meanings. See https://dl.acm.org/doi/10.1145/3487051#sec-2-3-3

## Proposal 2: Add SRL Rule Type

### Proposal 2a: Add Rule Type for Rule Sets

This is proposed by Andy in [Add SPARQL-RL as a rule type in the SHACL Inf Rules framework](https://github.com/w3c/data-shapes/issues/1229).

```
ex:MyRuleSet
    a sh:RuleSet ;
    sh:hasRule [
        a sh:SRL ;
        sh:srlProgram """
            RULE { ?r ex:area ?area }
            WHERE { ?r ex:width ?width . ?r ex:height ?height . SET (?area := ?width * ?height) }

            RULE { ?r ex:large true }
            WHERE { ?r ex:area ?area . FILTER (?area > 100) }
        """ ;
    ] .
```

Concerns have been recorded in the PR: <https://github.com/w3c/data-shapes/pull/1230>,
for example that this definition should rather go into the SRL document
(in which case the syntax would slightly change to srl:SRL and srl:program).

### Proposal 2b: Add Rule Type for individual SRL rules

This is not covered by a PR yet but could make sense:

```
ex:MyRuleSet
    a sh:RuleSet ;
    sh:hasRule [
        a srl:Rule ;
        srl:text """
            RULE { ?r ex:area ?area }
            WHERE { ?r ex:width ?width . ?r ex:height ?height . SET (?area := ?width * ?height) }
        """ ;
    ] ;
    sh:hasRule [
        a srl:Rule ;
        srl:text """
            RULE { ?r ex:large true }
            WHERE { ?r ex:area ?area . FILTER (?area > 100) }
        """ ;
    ] .
```

In this design, the existing rule set infrastructure of SHACL RDF syntax is used
whereas 2a relied on nesting complete rule sets into (large) rule literals.
It would allow users to use the syntactic sugar of SRL.
And it would be a mechanism to enforce certain contracts as an engine that goes not fully recognize
the srl:Rule type would need to throw a failure.

A downside is that this cannot directly be executed with a vanilla SHACL engine.
Another downside is that people have to know the different syntax.
Switching between the syntaxes may be unclear, e.g. if someone edits a rule that uses a SPARQL-Full
feature then she also needs to switch from RULE to CONSTRUCT etc.

## Proposal 3: Support both

This combines Proposal 1 (CONSTRUCT) and Proposal 2 (dedicated SHACL rule types for SRL).

This acknowledges that none of us can fully predict the future so we could elect to give the choice to the users.

If there is a clear winner in the coming years, future versions could deprecate one or the other syntax.

There could be voted on:

### Proposal 3a (1 + 2a)

### Proposal 3b (1 + 2b)


## Proposal 4: Keep SHACL and SRL rather separate

This is again a spectrum of options. Please suggest others if they are not listed.

### Proposal 4a: Release them both with the current design at the end of the year

This is where we are heading right now.
The syntactic mapping between SRL and CONSTRUCT is explained in a non-normative section of SPARQL-RL.
Tools that wish to support both can use a transformation, as suggested by David Habgood this can be
done fairly easily e.g. https://kurrawong.github.io/codemirror-lang-rdf/?sample=sparql-conversion
(NB this is not an engine just a parser)

### Proposal 4b: Release the SHACL documents now and SPARQL-RL under a new charter next year

This could formally work if SRL is published next year and the WG charter is changed for 2027, to allow non-SHACL specs.
It would avoid the problem that SRL currently is not based on SHACL.
It would not solve the integration problem, i.e. there would still only be two unrelated/loosely coupled/competing standards.

Note that formal objections to such a charter change are possible, as well as other objections to the document.
So this path does not guarantee the outcome.


## Related Personal Statements (Optional)

This section is for general opinionated statements that don't fit easily into the individual votes.

### Holger: How did we get here

I was always under the assumption that the Task Force would end up with a proposal
that honors the original requirement which was to produce a SHACL-based language.
So concepts such as attaching rules to shapes/classes were expected.
I anticipated that the resulting language would have lesser expressiveness than general SPARQL,
so that optimizated algorithms such as incremental inferencing become possible.
This wasn't the problem.
But I did not anticipate that the language would completely sever any links to SHACL and instead
become just another language for flat rule lists.

So while I was observing the TF work from the outside (I don't have time to work on all documents myself)
I was assuming that sooner or later such a link between rules and shapes was added.
But the opposite happened, and gradually any remaining references to SHACL (even the namespace) were deleted.
Anything that made SHACL Rules different from other rule languages was removed.
SRL was not even properly able to match instances of a class, which is fundamental to linking rules to (SHACL) ontologies.

In June, even people from the outside noticed and asked [Why *SHACL* Rules?](https://github.com/w3c/data-shapes/issues/939).
And this caused a flurry of discussions. I raised quite a number of issues trying to bring SRL closer to SHACL:

- [Attaching rules to shapes](https://github.com/w3c/data-shapes/issues/765)
- [How to match all (SHACL) instances of a class in Rules?](https://github.com/w3c/data-shapes/issues/961)

Related to this, Simon proposed

- [FOR ?v IN <shape>](https://github.com/w3c/data-shapes/issues/1074)

I also made suggestions on how to improve the (now deleted) RDF syntax of SRL:

- [Do we even need head/body triples](https://github.com/w3c/data-shapes/issues/954)
- [Why the keyword "RULE"](https://github.com/w3c/data-shapes/issues/955)
- [Allow deactivation of individual rules](https://github.com/w3c/data-shapes/issues/962)

After all these attempts to influence SRL were rejected, the WG decided to the start a new document SHACL 1.2 Inference Rules
that is essentially a better version of what we started in SHACL-AF, in parallel to SRL.
I spent a significant portion of the last three months working on this document.
This was not planned given that I was already the main editor of three other documents.

I am disappointed that the Task Force did not implement the original plan and that any feedback that I have given so far
has been rejected.  The only thing I have achieved was the deletion of the SRL native RDF syntax and this change was
perhaps only made because I indicated that we would raise a formal objection otherwise.

Furthermore, I believe that the process of how we reached the current draft was unfair:
The Task Force made its key decisions (esp the introduction of the non-standard SPARQL keywords SET and NOT)
before it was obvious that SHACL support was off the menu.
As it is very difficult to change an existing draft (anyone can block commits and I am not even an editor of SRL),
and all my requests to reconsider these choices were rejected, there was no way for me to cast -1 votes or block commits myself.
So the current situation is the result of an asymmetric process in which I have no real power unless I cast formal objections
to block the whole document.

Meanwhile I have made numerous changes to SHACL Rules to make a closer integration with SRL possible:
sh:RuleSet, sh:layer, sh:runOnce, clarifications to sh:order, sh:ruleProcessor, extensible rule types,
and an alignment of the core rule execution algorithm to use layers and iteration.

While I acknowledge the desire of people in the SRL Task Force to produce a minimalistic and conceptually sound
rule language, I believe there is a simple compromise that the SRL group could accept so that both languages
can at least syntactically interoperate and so that we don't end up with two competing standards
that unnecessarily confuse and divide the user community.
