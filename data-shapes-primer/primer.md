#SHACL Primer
##What is SHACL?

SHACL (Shapes Constraint Language) is a language for describing and constraining the contents of RDF graphs. It has two primary functions:
*Selection of the appropriate set of triples in the data to be validated, called the **scope**
*Description of the rules or constraints against which that graph will be compared, called the **constraint**

##SHACL in the RDF stack
Based on SPARQL
Written in RDF/RDFS

##Inputs

A SHACL implementation takes two inputs:
*The graph of SHACL triples that define the scopes and constraints
*The graph of triples that is to be validated 

These two inputs are static as far as SHACL is concerned -- no changes are made to either during the validation process.

##Functions

The main functions of SHACL are the definition of scopes, and the definition of constraints. A scope determines the set of triples in the data graph that will be compared to the defined constraints. The scoped triples are called the **focus node**. The constraints themselves are the rules that will be applied to the triples in the data graph. 

There is another scoping function called **filters**. Filters further refine scopes.

The results of the comparison between the constraints in SHACL and the focus node is an "error" report. Levels of error are supported: errors, warnings, and information. 

###scopes

The scope that determines the area of the data graph that will be compared to the constraints can be defined in these ways:

1. By **node** - a node scope defines a particular RDF node in the data graph by its IRI or literal. [Note: unclear what a match on literal would look like]
2. By **property** - a property scope defines the subjects in the data graph with the designated property as in scope. 
3. By **class membership** - a class scope defines all subjects in the data graph that are instances of the designated class and any subclasses of that class as "in scope." Class membership in the data graph is defined as the subjects with a predicate of **rdf:type** and an object with the class named in the shapes graph. 

###Constraints

A summary of constraint types (probably in order by their presumed use: 
*valid properties
*cardinality
*valid values
...

###validation

##SHACL How-To


###Defining shapes
The basic components of a shape are...

###Defining Scopes
Here's how you define a scope,

###Filtering
Further refining of scopes'

###Defining Constraints
(includes filtering)

##Advanced SHACL

###All subclasses of...

###Scopes within scopes

###

##SHACL extensions
If the SHACL core doesn't meet your needs, you can use the extensions. Those are defined in DocX

##Terminology'
