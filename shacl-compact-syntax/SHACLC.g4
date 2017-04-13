grammar SHACLC;

@header {
	package org.topbraid.shacl.compact.parser;
}

shaclDoc 			: directive* nodeShape* EOF;

directive       	: baseDecl | importsDecl | prefixDecl ;
baseDecl 			: KW_BASE  IRIREF ;
importsDecl			: KW_IMPORTS IRIREF ;
prefixDecl			: KW_PREFIX PNAME_NS IRIREF ;

nodeShape			: iri targetClass? nodeShapeBody ;
nodeShapeBody   	: '{' constraint* '}';
targetClass			: '->' iri+ ;

constraint			: ( nodeValue+ | propertyShape ) ';' ;
nodeValue			: nodeParam '=' iriOrLiteralOrArray ;

propertyShape		: iri ( propertyCount | propertyOr )* ;
propertyOr			: propertyNot ( '|' propertyNot) * ;
propertyNot			: negation? propertyAtom ;
propertyAtom		: propertyType | nodeKind | shapeRef | propertyValue | nodeShapeBody ;
propertyCount		: '[' propertyMinCount '..' propertyMaxCount ']' ;
propertyMinCount	: INTEGER ;
propertyMaxCount	: (INTEGER | '*') ;
propertyType    	: iri ;
nodeKind			: 'BlankNode' | 'IRI' | 'Literal' | 'BlankNodeOrIRI' | 'BlankNodeOrLiteral' | 'IRIOrLiteral' ;
shapeRef			: ATPNAME_LN | ATPNAME_NS | '@' IRIREF ;
propertyValue		: propertyParam '=' iriOrLiteralOrArray ;
negation			: '!' ;

iriOrLiteralOrArray	: iriOrLiteral | array ;
iriOrLiteral		: iri | literal ;

iri					: IRIREF | prefixedName ;
prefixedName		: PNAME_LN | PNAME_NS ;

literal         	: rdfLiteral | numericLiteral | booleanLiteral ;
booleanLiteral  	: KW_TRUE | KW_FALSE ;
numericLiteral  	: INTEGER | DECIMAL | DOUBLE ;
rdfLiteral      	: string (LANGTAG | '^^' datatype)? ;
datatype        	: iri ;
string          	: STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2 | STRING_LITERAL1 | STRING_LITERAL2 ;

array				: '[' iriOrLiteral* ']' ;

nodeParam			: 'targetNode' | 'targetObjectsOf' | 'targetSubjectsOf' |
					  'deactivated' | 'severity' | 'message' |
					  'class' | 'datatype' | 'nodeKind' |
					  'minExclusive' | 'minInclusive' | 'maxExclusive' | 'maxInclusive' |
					  'minLength' | 'maxLength' | 'pattern' | 'flags' | 'languageIn' |
					  'equals' | 'disjoint' |
					  'closed' | 'ignoredProperties' | 'hasValue' | 'in' ;

propertyParam		: 'deactivated' | 'severity' | 'message' |
					  'class' | 'datatype' | 'nodeKind' |
					  'minExclusive' | 'minInclusive' | 'maxExclusive' | 'maxInclusive' |
					  'minLength' | 'maxLength' | 'pattern' | 'flags' | 'languageIn' | 'uniqueLang' |
					  'equals' | 'disjoint' | 'lessThan' | 'lessThanOrEquals' |
					  'qualifiedValueShape' | 'qualifiedMinCount' | 'qualifiedMaxCount' | 'qualifiedValueShapesDisjoint' |
					  'closed' | 'ignoredProperties' | 'hasValue' | 'in' ;


// Keywords
KW_BASE 			: B A S E ;
KW_IMPORTS			: I M P O R T S ;
KW_PREFIX			: P R E F I X ;

KW_TRUE         	: 'true' ;
KW_FALSE        	: 'false' ;

// terminals
PASS				  : [ \t\r\n]+ -> skip;
COMMENT				  : '#' ~[\r\n]* -> skip;

CODE                  : '{' (~[%\\] | '\\' [%\\] | UCHAR)* '%' '}' ;
RDF_TYPE              : 'a' ;
IRIREF                : '<' (~[\u0000-\u0020=<>\"{}|^`\\] | UCHAR)* '>' ; /* #x00=NULL #01-#x1F=control codes #x20=space */
PNAME_NS              : PN_PREFIX? ':' ;
PNAME_LN              : PNAME_NS PN_LOCAL ;
ATPNAME_NS			  : '@' PN_PREFIX? ':' ;
ATPNAME_LN			  : '@' PNAME_NS PN_LOCAL ;
REGEXP                : '~/' ([^\u002f\u005C\u000A\u000D] | '\\' [tbnrf\\/] | UCHAR)* '/' [smix]* ;
BLANK_NODE_LABEL      : '_:' (PN_CHARS_U | [0-9]) ((PN_CHARS | '.')* PN_CHARS)? ;
LANGTAG               : '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)* ;
INTEGER               : [+-]? [0-9]+ ;
DECIMAL               : [+-]? [0-9]* '.' [0-9]+ ;
DOUBLE                : [+-]? ([0-9]+ '.' [0-9]* EXPONENT | '.'? [0-9]+ EXPONENT) ;
fragment EXPONENT     : [eE] [+-]? [0-9]+ ;
STRING_LITERAL1       : '\'' (~[\u0027\u005C\u000A\u000D] | ECHAR | UCHAR)* '\'' ; /* #x27=' #x5C=\ #xA=new line #xD=carriage return */
STRING_LITERAL2       : '"' (~[\u0022\u005C\u000A\u000D] | ECHAR | UCHAR)* '"' ;   /* #x22=" #x5C=\ #xA=new line #xD=carriage return */
STRING_LITERAL_LONG1  : '\'\'\'' (('\'' | '\'\'')? (~[\'\\] | ECHAR | UCHAR))* '\'\'\'' ;
STRING_LITERAL_LONG2  : '"""' (('"' | '""')? (~[\"\\] | ECHAR | UCHAR))* '"""' ;
fragment UCHAR                 : '\\u' HEX HEX HEX HEX | '\\U' HEX HEX HEX HEX HEX HEX HEX HEX ;
fragment ECHAR                 : '\\' [tbnrf\\\"\'] ;
fragment WS                    : [\u0020\u0009\u000D\u000A] ; /* #x20=space #x9=character tabulation #xD=carriage return #xA=new line */
fragment PN_CHARS_BASE 		   : [A-Z] | [a-z] | [\u00C0-\u00D6] | [\u00D8-\u00F6] | [\u00F8-\u02FF] | [\u0370-\u037D]
					   		   | [\u037F-\u1FFF] | [\u200C-\u200D] | [\u2070-\u218F] | [\u2C00-\u2FEF] | [\u3001-\uD7FF]
					           | [\uF900-\uFDCF] | [\uFDF0-\uFFFD]
					   		   ;
fragment PN_CHARS_U            : PN_CHARS_BASE | '_' ;
fragment PN_CHARS              : PN_CHARS_U | '-' | [0-9] | [\u00B7] | [\u0300-\u036F] | [\u203F-\u2040] ;
fragment PN_PREFIX             : PN_CHARS_BASE ((PN_CHARS | '.')* PN_CHARS)? ;
fragment PN_LOCAL              : (PN_CHARS_U | ':' | [0-9] | PLX) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX))? ;
fragment PLX                   : PERCENT | PN_LOCAL_ESC ;
fragment PERCENT               : '%' HEX HEX ;
fragment HEX                   : [0-9] | [A-F] | [a-f] ;
fragment PN_LOCAL_ESC          : '\\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | '\'' | '(' | ')' | '*' | '+' | ','
					  		   | ';' | '=' | '/' | '?' | '#' | '@' | '%') ;

fragment A:('a'|'A');
fragment B:('b'|'B');
fragment C:('c'|'C');
fragment D:('d'|'D');
fragment E:('e'|'E');
fragment F:('f'|'F');
fragment G:('g'|'G');
fragment H:('h'|'H');
fragment I:('i'|'I');
fragment J:('j'|'J');
fragment K:('k'|'K');
fragment L:('l'|'L');
fragment M:('m'|'M');
fragment N:('n'|'N');
fragment O:('o'|'O');
fragment P:('p'|'P');
fragment Q:('q'|'Q');
fragment R:('r'|'R');
fragment S:('s'|'S');
fragment T:('t'|'T');
fragment U:('u'|'U');
fragment V:('v'|'V');
fragment W:('w'|'W');
fragment X:('x'|'X');
fragment Y:('y'|'Y');
fragment Z:('z'|'Z');