%{
    //für Bison Hack
     #include <iostream>
     #include <string>
     using namespace std;
     
     
     
     int yyerror(string s);
     int yylex();
     int yylex_2();
%}

//Generalisierter Parser, kann Alternativen parallel verfolgen, unterstützt aber nicht Visualisierung mit Bisonhack (ein- oder auskommentieren)
//%glr-parser

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



/* verwendete Tokens */

%token<cval> T_STRING_LITERAL           //siehe RFC-9535 S.17
%token<cval> T_MEMBER_NAME_SHORTHAND    //siehe RFC-9535 S.41
%token<cval> T_FUNCTION_NAME            //siehe RFC-9535 S.35

//siehe RFC-9535 S.27
%token T_TRUE
%token T_FALSE
%token T_NULL

//siehe RFC-9535 S.26
%token T_LOGICAL_OR
%token T_LOGICAL_AND

//siehe RFC-9535 S.27
%token T_CMP_EQ
%token T_CMP_NEQ
%token T_CMP_LTE
%token T_CMP_GTE
%token T_CMP_LT
%token T_CMP_GT

//siehe RFC-9535 S.41
%token T_CHILD_OP

//siehe RFC-9535 S.43
%token T_DESC_OP

//siehe RFC-9535 S.21
%token<ival> T_INT

//siehe RFC-9535 S.27
%token T_MINUS_ZERO
%token<cval> T_FRAC
%token<cval> T_EXP

//siehe RFC-9535 S.47
%token<cval> T_NORMAL_NAME_SELECTOR
%token<ival> T_NORMAL_INDEX_SELECTOR



%token T_ERR                            //undefined input



//Bisonhack
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





/* leere Ableitung (für optionale Regeln) */

epsilon:
    /* leer */
;
    




/* siehe RFC-9535 Abschnitt 2.1.1 */

jsonpath_query: 
	root_identifier segments
;

segments: 
    epsilon
	| segments segment
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
	T_INT
;





/* siehe RFC-9535 Abschnitt 2.3.4.1 */

slice_selector: 
	opt_start ':' opt_end opt_step
;

opt_start:
    epsilon
	| start
;

opt_end:
    epsilon
	| end
;

opt_step:
    epsilon
	| ':' step
	| ':'
;

start: 
	T_INT
;

end: 
	T_INT
;

step: 
	T_INT
;





/* siehe RFC-9535 Abschnitt 2.3.5.1 */

filter_selector: 
	'?' logical_expr
;



logical_expr: 
	logical_or_expr
;

logical_or_expr: 
	logical_and_expr rep_logical_and_expr
;

rep_logical_and_expr: 
    epsilon
	| rep_logical_and_expr T_LOGICAL_OR logical_and_expr
;

logical_and_expr: 
	basic_expr rep_basic_expr
;

rep_basic_expr:
    epsilon
	| rep_basic_expr T_LOGICAL_AND basic_expr
;

basic_expr: 
	paren_expr
	| comparison_expr
	| test_expr
;

paren_expr: 
	opt_logical_not_op '(' logical_expr ')'
;

opt_logical_not_op:
    epsilon
	| logical_not_op
;

logical_not_op:
	'!'
;



test_expr:
	opt_logical_not_op filter_query
	| opt_logical_not_op function_expr
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
	comparable comparison_op comparable
;

literal: 
	number
	| T_STRING_LITERAL
	| T_TRUE
	| T_FALSE
	| T_NULL
;

comparable: 
	literal
	| singular_query
	| function_expr
;

comparison_op: 
	T_CMP_EQ
	| T_CMP_NEQ
	| T_CMP_LTE
	| T_CMP_GTE
	| T_CMP_LT
	| T_CMP_GT
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
    epsilon
	| rep_singular_query_segment singular_query_segment
;

singular_query_segment:
	name_segment
	| index_segment
;

name_segment:
	'[' name_selector ']'
	| T_CHILD_OP T_MEMBER_NAME_SHORTHAND
;

index_segment:
	'[' index_selector ']'
;



number:
	T_INT opt_frac opt_exp
	| T_MINUS_ZERO opt_frac opt_exp
;

opt_frac:
    epsilon
	| T_FRAC
;

opt_exp:
    epsilon
	| T_EXP
;





/* siehe RFC-9535 Abschnitt 2.4 */

function_expr:
	T_FUNCTION_NAME '(' opt_func_args ')'
;

opt_func_args:
    epsilon
	| function_argument rep_function_argument
;

rep_function_argument:
    epsilon
	| rep_function_argument ',' function_argument
;

function_argument:
	literal
    | logical_expr
	| filter_query        //-> TODO: RFC-konform?
	| function_expr       //-> TODO: RFC-Konform?
;





/* siehe RFC-9535 Abschnitt 2.5 */

segment: 
	child_segment
	| descendant_segment
;





/* siehe RFC-9535 Abschnitt 2.5.1.1 */

child_segment: 
	bracketed_selection
	| T_CHILD_OP wildcard_selector
	| T_CHILD_OP T_MEMBER_NAME_SHORTHAND
;

bracketed_selection: 
	'[' selector rep_selector ']'
;

rep_selector: 
    epsilon
	| rep_selector ',' selector
;





/* siehe RFC-9535 Abschnitt 2.5.2.1 */

descendant_segment: 
	T_DESC_OP bracketed_selection
	| T_DESC_OP wildcard_selector
	| T_DESC_OP T_MEMBER_NAME_SHORTHAND
;





/* siehe RFC-9535 Abschnitt 2.5.2.1 */

normalized_path:
    root_identifier rep_normal_index_segment
;

rep_normal_index_segment:
    epsilon
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

