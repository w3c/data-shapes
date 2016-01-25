# Tests requested

## **name of test**
Short description

    `code (backtick)`

    `code`
    
> blockquote text for longer
> descriptions

## **Test of test**
Here's a first test

    `If
    
		then
		
			that`

> Here's where you give a bunch of detail os 
> why or how you think this test needs to be 
> done, and anything else you want to say about it

## **Validating schema.org data**
UC41 Validating schema.org instances against model and metamodel

> schema.org domainIncludes and rangeIncludes, which are the union of these types rather than
> the intersection; datatypes and plain literals (the latter are always plain string literals); 
> very loose conformance levels

## **Inherit Shapes of superclasses**
UC9 Contract time intervals
    
> An ontology may state that instances of a class have a value for a property. Subclasses may be associated with a constraint that requires that there is a provided value for the property. For example, in the OMG time ontology adopted by FIBO every contract has to have an end date. A shape (set of constraints) may require that bonds (a subclass of contracts) have specified end dates without requiring that all contracts have specified end dates.
> descriptions

## **Bad templates**
Test templates that do not meet the template model

## **SameAs QA**
UC14 Quality Assurance for object reconciliation

>In data integration activities, tools such as Silk or Limes may be used to discover entity co-references. Entity co-references are pairs of different identifiers, often in different datasets, that refer to the same entity. Detected co-references are often recorded as owl:sameAs triples. This may be a step in an object reconciliation pipeline.

>E.g. If source1.movie.title is highly similar (by some widely adopted string similarity function, perhaps plugged in through an extension interface) to source2.film.title and source1.movie.release-date.year is identical to source2.film.initial-release, then a owl:sameAs triple should be present
