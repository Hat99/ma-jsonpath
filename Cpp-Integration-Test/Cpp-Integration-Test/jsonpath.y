%{
     #include <iostream>
     #include <string>
     using namespace std;
     
     
     
     int yyerror(string s);
     int yylex();
     int yylex_2();
%}

//Generalisierter Parser, kann Alternativen parallel verfolgen
%glr-parser

//Debugging trace
%define parse.trace

//Bison Hack
%code requires{
#include "tree.hpp"
typedef tree<string> syntaxTree;
inline syntaxTree * syntaxTree_epsilon_node () {
    return new syntaxTree("$\\epsilon$");
}
}
%union {
    syntaxTree * tree;
    char * cval;
    int ival;
}

%token<cval> T_STRING_LITERAL   //siehe RFC-9535 S.17

%token<cval> T_NORMAL_NAME_SELECTOR    //siehe RFC-9535 S.47
%token<ival> T_NORMAL_INDEX_SELECTOR    //siehe RFC_9535 S.47

%token T_ERR                //undefined input

%{
    syntaxTree * root;
%}
%initial-action {
#include "syntaxtree-initial-action-bison-3.8.2.h"

} // %initial-action

%start jsonpath

%%

    

/* Einstieg entweder in normalized_path (n/N) oder jsonpath_query (j/J) */

jsonpath:
    'J' jsonpath_query
    | 'j' jsonpath_query
    | 'N' normalized_path
    | 'n' normalized_path
;
    




/* siehe RFC-9535 Abschnitt 2.1.1 */

jsonpath_query: 
	root_identifier segments
;

segments: 

	| segments S segment
;

B:
	'\x20'
	| '\x09'
	| '\x0A'
	| '\x0D'
;

S:

	| S B
;





/* siehe RFC-9535 Abschnitt 2.2.1 */

root_identifier:
	'$'
;





/* siehe RFC-9535 Abschnitt 2.3 */

selector: 
	name_selector
	| wildcard_selector
	| slice_selector
	| index_selector
	| filter_selector
;





/* siehe RFC-9535 Abschnitt 2.3.1.1 */

name_selector: 
    T_STRING_LITERAL
;






/* siehe RFC-9535 Abschnitt 2.3.2.1 */

wildcard_selector:
	'*'
;





/* siehe RFC-9535 Abschnitt 2.3.3.1 */

index_selector: 
	int
;

int: 
	'0'
	| opt_hyphen DIGIT1 rep_DIGIT
;

opt_hyphen:

	| '-'
;

DIGIT1:
	'1'
	| '2'
	| '3'
	| '4'
	| '5'
	| '6'
	| '7'
	| '8'
	| '9'
;

rep_DIGIT: 

	| rep_DIGIT DIGIT
;





/* siehe RFC-9535 Abschnitt 2.3.4.1 */

slice_selector: 
	opt_start ':' S opt_end opt_step
;

opt_start:

	| start S
;

opt_end:

	| end S
;

opt_step:

	| ':' S step
	| ':'
;

start: 
	int
;

end: 
	int
;

step: 
	int
;





/* siehe RFC-9535 Abschnitt 2.3.5.1 */

filter_selector: 
	'?' S logical_expr
;



logical_expr: 
	logical_or_expr
;

logical_or_expr: 
	logical_and_expr rep_logical_and_expr
;

rep_logical_and_expr: 

	| rep_logical_and_expr S '|' '|' S logical_and_expr
;

logical_and_expr: 
	basic_expr rep_basic_expr
;

rep_basic_expr:

	| rep_basic_expr S '&' '&' S basic_expr
;

basic_expr: 
	paren_expr
	| comparison_expr
	| test_expr
;

paren_expr: 
	opt_not_op '(' S logical_expr S ')'
;

opt_not_op:
	
	| logical_not_op S
;

logical_not_op:
	'!'
;



test_expr:
	opt_not_op filter_query
	| opt_not_op function_expr
;

filter_query:
	rel_query
	| jsonpath_query
;

rel_query:
	current_node_identifier segments
;

current_node_identifier:
	'@'
;



comparison_expr:
	comparable S comparison_op S comparable
;

literal: 
	number
	| T_STRING_LITERAL
	| true
	| false
	| null
;

comparable: 
	literal
	| singular_query
	| function_expr
;

comparison_op: 
	'=''='
	| '!' '='
	| '<' '='
	| '>' '='
	| '<'
	| '>'
;

singular_query: 
	rel_singular_query
	| abs_singular_query
;

rel_singular_query: 
	current_node_identifier singular_query_segments
;

abs_singular_query: 
	root_identifier singular_query_segments
;

singular_query_segments:
	rep_singular_query_segment
;

rep_singular_query_segment:
	
	| rep_singular_query_segment singular_query_segment
;

singular_query_segment:
	S name_segment
	| S index_segment
;

name_segment:
	'[' name_selector ']'
	| '.' member_name_shorthand
;

index_segment:
	'[' index_selector ']'
;



number:
	int opt_frac opt_exp
	| '-' '0' opt_frac opt_exp
;

opt_frac:

	| frac
;

frac:
	'.' DIGIT rep_DIGIT
;

opt_exp:

	| exp
;

exp:
	'e' opt_signed DIGIT rep_DIGIT
;

opt_signed:

	| '-'
	| '+'
;

true:
	't''r''u''e'
;

false:
	'f''a''l''s''e'
;

null:
	'n''u''l''l'
;





/* siehe RFC-9535 Abschnitt 2.4 */

function_name:
	function_name_first rep_function_name_char
;

rep_function_name_char:

	| rep_function_name_char function_name_char
;

function_name_first:
	LCALPHA
;

function_name_char:
	function_name_first
	| '_'
	| DIGIT
;

LCALPHA:
	'a'
	| 'b'
    | 'c'
    | 'd'
    | 'e'
    | 'f'
    | 'g'
    | 'h'
    | 'i'
    | 'j'
    | 'k'
    | 'l'
    | 'm'
    | 'n'
    | 'o'
    | 'p'
    | 'q'
    | 'r'
    | 's'
    | 't'
    | 'u'
    | 'v'
    | 'w'
    | 'x'
    | 'y'
    | 'z'
;



function_expr:
	function_name '(' S opt_func_args S ')'
;

opt_func_args:
	
	| function_argument rep_function_argument
;

rep_function_argument:
	
	| rep_function_argument S ',' S function_argument
;

function_argument:
	literal
	//| filter_query        -> TODO: RFC-konform?
	| logical_expr
	//| function_expr       -> TODO: RFC-Konform?
;





/* siehe RFC-9535 Abschnitt 2.5 */

segment: 
	child_segment
	| descendant_segment
;





/* siehe RFC-9535 Abschnitt 2.5.1.1 */

child_segment: 
	bracketed_selection
	| '.' wildcard_selector
	| '.' member_name_shorthand
;

bracketed_selection: 
	'[' S selector rep_selector S ']'
;

rep_selector: 
	
	| rep_selector S ',' S selector
;



member_name_shorthand: 
	name_first rep_name_char
;

name_first: 
	ALPHA
	| '_'
;

rep_name_char:

	| rep_name_char name_char
;

name_char: 
	name_first
	| DIGIT
;

DIGIT: 
	'0'
	| DIGIT1
;

ALPHA: 
	UCALPHA
	| LCALPHA
;

UCALPHA:
	'A'
    | 'B'
    | 'C'
    | 'D'
    | 'E'
    | 'F'
    | 'G'
    | 'H'
    | 'I'
    | 'J'
    | 'K'
    | 'L'
    | 'M'
    | 'N'
    | 'O'
    | 'P'
    | 'Q'
    | 'R'
    | 'S'
    | 'T'
    | 'U'
    | 'V'
    | 'W'
    | 'X'
    | 'Y'
    | 'Z'
;





/* siehe RFC-9535 Abschnitt 2.5.2.1 */

descendant_segment: 
	'.' '.' bracketed_selection
	| '.' '.' wildcard_selector
	| '.' '.' member_name_shorthand
;





/* siehe RFC-9535 Abschnitt 2.5.2.1 */

normalized_path:
    root_identifier rep_normal_index_segment
;

rep_normal_index_segment:

    | rep_normal_index_segment normal_index_segment
;

normal_index_segment:
    '[' normal_selector ']'
;

normal_selector:
    T_NORMAL_NAME_SELECTOR
    | T_NORMAL_INDEX_SELECTOR
;

%%

