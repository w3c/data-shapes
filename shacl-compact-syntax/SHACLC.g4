grammar SHACLC;

shaclDoc            : directive* (nodeShape|shapeClass)* EOF;

directive           : baseDecl | importsDecl | prefixDecl ;
baseDecl            : KW_BASE  IRIREF ;
importsDecl         : KW_IMPORTS IRIREF ;
prefixDecl          : KW_PREFIX PNAME_NS IRIREF ;

shapeClass          : KW_SHAPE_CLASS iri nodeShapeBody ;
nodeShape           : KW_SHAPE iri targetClass? nodeShapeBody ;
nodeShapeBody       : '{' constraint* '}';
targetClass         : '->' iri+ ;

constraint          : ( nodeOr+ | propertyShape ) '.' ;
nodeOr              : nodeNot ( '|' nodeNot) * ;
nodeNot             : negation? nodeValue ;
nodeValue           : nodeParam '=' iriOrLiteralOrArray ;

propertyShape       : path ( propertyCount | propertyOr )* ;
propertyOr          : propertyNot ( '|' propertyNot) * ;
propertyNot         : negation? propertyAtom ;
propertyAtom        : propertyType | nodeKind | shapeRef | propertyValue | nodeShapeBody ;
propertyCount       : '[' propertyMinCount '..' propertyMaxCount ']' ;
propertyMinCount    : INTEGER ;
propertyMaxCount    : (INTEGER | '*') ;
propertyType        : iri ;
nodeKind            : 'BlankNode' | 'IRI' | 'Literal' | 'BlankNodeOrIRI' | 'BlankNodeOrLiteral' | 'IRIOrLiteral' ;
shapeRef            : ATPNAME_LN | ATPNAME_NS | '@' IRIREF ;
propertyValue       : propertyParam '=' iriOrLiteralOrArray ;
negation            : '!' ;

path                : pathAlternative ;
pathAlternative     : pathSequence ( '|' pathSequence )* ;
pathSequence        : pathEltOrInverse ( '/' pathEltOrInverse )* ;
pathElt             : pathPrimary pathMod? ;
pathEltOrInverse    : pathElt | pathInverse pathElt ;
pathInverse         : '^' ;
pathMod             : '?' | '*' | '+' ;
pathPrimary         : iri | '(' path ')' ;

iriOrLiteralOrArray : iriOrLiteral | array ;
iriOrLiteral        : iri | literal ;

iri                 : IRIREF | prefixedName ;
prefixedName        : PNAME_LN | PNAME_NS ;

literal             : rdfLiteral | numericLiteral | booleanLiteral ;
booleanLiteral      : KW_TRUE | KW_FALSE ;
numericLiteral      : INTEGER | DECIMAL | DOUBLE ;
rdfLiteral          : string (LANGTAG | '^^' datatype)? ;
datatype            : iri ;
string              : STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2 | STRING_LITERAL1 | STRING_LITERAL2 ;

array               : '[' iriOrLiteral* ']' ;

nodeParam           : 'targetNode' | 'targetObjectsOf' | 'targetSubjectsOf' |
                      'deactivated' | 'severity' | 'message' |
                      'class' | 'datatype' | 'nodeKind' |
                      'minExclusive' | 'minInclusive' | 'maxExclusive' | 'maxInclusive' |
                      'minLength' | 'maxLength' | 'pattern' | 'flags' | 'languageIn' |
                      'equals' | 'disjoint' |
                      'closed' | 'ignoredProperties' | 'hasValue' | 'in' ;

propertyParam       : 'deactivated' | 'severity' | 'message' |
                      'class' | 'datatype' | 'nodeKind' |
                      'minExclusive' | 'minInclusive' | 'maxExclusive' | 'maxInclusive' |
                      'minLength' | 'maxLength' | 'pattern' | 'flags' | 'languageIn' | 'uniqueLang' |
                      'equals' | 'disjoint' | 'lessThan' | 'lessThanOrEquals' |
                      'qualifiedValueShape' | 'qualifiedMinCount' | 'qualifiedMaxCount' | 'qualifiedValueShapesDisjoint' |
                      'closed' | 'ignoredProperties' | 'hasValue' | 'in' ;

// Keywords
KW_BASE             : 'BASE' ;
KW_IMPORTS          : 'IMPORTS' ;
KW_PREFIX           : 'PREFIX' ;

KW_SHAPE_CLASS      : 'shapeClass' ;
KW_SHAPE            : 'shape' ;

KW_TRUE             : 'true' ;
KW_FALSE            : 'false' ;

// Terminals
PASS                : [ \t\r\n]+ -> skip;
COMMENT             : '#' ~[\r\n]* -> skip;

IRIREF              : '<' (~[\u0000-\u0020=<>\"{}|^`\\] | UCHAR)* '>' ;
PNAME_NS            : PN_PREFIX? ':' ;
PNAME_LN            : PNAME_NS PN_LOCAL ;
ATPNAME_NS          : '@' PN_PREFIX? ':' ;
ATPNAME_LN          : '@' PNAME_NS PN_LOCAL ;
LANGTAG             : '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)* ;
INTEGER             : [+-]? [0-9]+ ;
DECIMAL             : [+-]? [0-9]* '.' [0-9]+ ;
DOUBLE              : [+-]? ([0-9]+ '.' [0-9]* EXPONENT | '.'? [0-9]+ EXPONENT) ;
fragment EXPONENT   : [eE] [+-]? [0-9]+ ;
STRING_LITERAL1     : '\'' (~[\u0027\u005C\u000A\u000D] | ECHAR | UCHAR)* '\'' ;
STRING_LITERAL2     : '"' (~[\u0022\u005C\u000A\u000D] | ECHAR | UCHAR)* '"' ;
STRING_LITERAL_LONG1: '\'\'\'' (('\'' | '\'\'')? (~[\'\\] | ECHAR | UCHAR))* '\'\'\'' ;
STRING_LITERAL_LONG2: '"""' (('"' | '""')? (~[\"\\] | ECHAR | UCHAR))* '"""' ;
fragment UCHAR      : '\\u' HEX HEX HEX HEX | '\\U' HEX HEX HEX HEX HEX HEX HEX HEX ;
fragment ECHAR      : '\\' [tbnrf\\\"\'] ;
fragment WS         : [\u0020\u0009\u000D\u000A] ;
fragment PN_CHARS_BASE: [A-Z] | [a-z] | [\u00C0-\u00D6] | [\u00D8-\u00F6] | [\u00F8-\u02FF] | [\u0370-\u037D]
                       | [\u037F-\u1FFF] | [\u200C-\u200D] | [\u2070-\u218F] | [\u2C00-\u2FEF] | [\u3001-\uD7FF]
                       | [\uF900-\uFDCF] | [\uFDF0-\uFFFD]
					   		   ;
fragment PN_CHARS_U : PN_CHARS_BASE | '_' ;
fragment PN_CHARS   : PN_CHARS_U | '-' | [0-9] | [\u00B7] | [\u0300-\u036F] | [\u203F-\u2040] ;
fragment PN_PREFIX  : PN_CHARS_BASE ((PN_CHARS | '.')* PN_CHARS)? ;
fragment PN_LOCAL   : (PN_CHARS_U | ':' | [0-9] | PLX) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX))? ;
fragment PLX        : PERCENT | PN_LOCAL_ESC ;
fragment PERCENT    : '%' HEX HEX ;
fragment HEX        : [0-9] | [A-F] | [a-f] ;
fragment PN_LOCAL_ESC: '\\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | '\'' | '(' | ')' | '*' | '+' | ','
                       | ';' | '=' | '/' | '?' | '#' | '@' | '%') ;
