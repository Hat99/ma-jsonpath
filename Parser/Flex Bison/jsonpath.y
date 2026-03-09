%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}





%token T_TAB				//"\x09", "\t"
%token T_NEW_LINE			//"\x0A", "\n"
%token T_CARRIAGE_RETURN		//"\x0D", "\r"

%token T_SPACE				//"\x20", " "
%token T_EXCLAMATION		//"\x21", "!"
%token T_DOUBLE_QUOTE		//"\x22", '"'
%token T_HASHTAG			//"\x23", "#"
%token T_DOLLAR			//"\x24", "$"
%token T_PERCENT			//"\x25", "%"
%token T_AMPERSAND			//"\x26", "&"
%token T_SINGLE_QUOTE		//"\x27", "'"

%token T_PAREN_OPEN			//"\x28", "("
%token T_PAREN_CLOSE		//"\x29", ")"
%token T_ASTERISK			//"\x2A", "*"
%token T_PLUS				//"\x2B", "+"
%token T_COMMA				//"\x2C", ","
%token T_HYPHEN			//"\x2D", "-"
%token T_PERIOD			//"\x2E", "."
%token T_FORWARD_SLASH		//"\x2F", "/"

/* \x30-\x39 "0-9" */
%token T_ZERO		
%token T_ONE	
%token T_TWO		
%token T_THREE	
%token T_FOUR		
%token T_FIVE		
%token T_SIX	
%token T_SEVEN
%token T_EIGHT
%token T_NINE

%token T_COLON		//"\x3A", ":"
%token T_SEMICOLON		//"\x3B", ";"
%token T_LT			//"\x3C", "<"
%token T_EQUALS		//"\x3D", "="
%token T_GT			//"\x3E", ">"
%token T_QUESTION		//"\x3F", "?"
%token T_AT			//"\x40", "@"

/* \x41-\x5A "A-Z" */
%token T_UC_A
%token T_UC_B
%token T_UC_C
%token T_UC_D
%token T_UC_E
%token T_UC_F
%token T_UC_G
%token T_UC_H
%token T_UC_I
%token T_UC_J
%token T_UC_K
%token T_UC_L
%token T_UC_M
%token T_UC_N
%token T_UC_O
%token T_UC_P
%token T_UC_Q
%token T_UC_R
%token T_UC_S
%token T_UC_T
%token T_UC_U
%token T_UC_V
%token T_UC_W
%token T_UC_X
%token T_UC_Y
%token T_UC_Z

%token T_SQUARE_BRACKET_OPEN		//"\x5B", "["
%token T_BACKSLASH				//"\x5C", "\"
%token T_SQUARE_BRACKET_CLOSE		//"\x5D", "]"
%token T_CIRCUMFLEX				//"\x5E", "^"
%token T_UNDERSCORE				//"\x5F", "_"
%token T_GRAVE					//"\x60", "`"

/* \x61-\x7A "a-z" */
%token T_LC_A
%token T_LC_B
%token T_LC_C
%token T_LC_D
%token T_LC_E
%token T_LC_F
%token T_LC_G
%token T_LC_H
%token T_LC_I
%token T_LC_J
%token T_LC_K
%token T_LC_L
%token T_LC_M
%token T_LC_N
%token T_LC_O
%token T_LC_P
%token T_LC_Q
%token T_LC_R
%token T_LC_S
%token T_LC_T
%token T_LC_U
%token T_LC_V
%token T_LC_W
%token T_LC_X
%token T_LC_Y
%token T_LC_Z

%token T_CURLY_BRACE_OPEN	//"\x7B", "{"
%token T_VERTICAL_BAR		//"\x7C", "|"
%token T_CURLY_BRACE_CLOSE	//"\x7D", "}"
%token T_TILDE				//"\x7E", "~"
%token T_DEL				//"\x7F"





%start jsonpath_query

%%





/* siehe RFC-9535 Abschnitt 2.1.1 */

jsonpath_query: 
	root_identifier segments
;

segments: 

	| segments S segment
;

B:
	T_SPACE
	| T_TAB
	| T_NEW_LINE
	| T_CARRIAGE_RETURN
;

S:

	| S B
;





/* siehe RFC-9535 Abschnitt 2.2.1 */

root_identifier:
	T_DOLLAR
;





/* siehe RFC-9535 Abschnitt 2.3 */

selector: 
	name_selector
	| wildcard_selector
	| slice_seletor
	| index_selector
	| filter_selector
;





/* siehe RFC-9535 Abschnitt 2.3.1.1 */

name_selector: 
	string_literal
;

string_literal: 
	T_DOUBLE_QUOTE rep_double_quoted T_DOUBLE_QUOTE
	| T_SINGLE_QUOTE rep_single_quoted T_SINGLE_QUOTE
;

rep_double_quoted:

	| rep_double_quoted double_quoted
;

double_quoted: 
	unescaped
	| T_SINGLE_QUOTE
	| ESC T_DOUBLE_QUOTE
	| ESC escapable
;

rep_single_quoted:

	| rep_single_quoted single_quoted
;

single_quoted: 
	unescaped
	| T_DOUBLE_QUOTE
	| ESC T_SINGLE_QUOTE
	| ESC escapable	
;

ESC:
	T_BACKSLASH
;

unescaped: 
	T_SPACE
	| T_EXCLAMATION
	| T_HASHTAG
	| T_DOLLAR
	| T_PERCENT
	| T_AMPERSAND
	| T_PAREN_OPEN
	| T_PAREN_CLOSE
	| T_ASTERISK
	| T_PLUS
	| T_COMMA
	| T_HYPHEN
	| T_PERIOD
	| T_FORWARD_SLASH
	| DIGIT
	| T_COLON
	| T_SEMICOLON
	| T_LT
	| T_EQUALS
	| T_GT
	| T_QUESTION 
	| T_AT
	| UCALPHA
	| T_SQUARE_BRACKET_OPEN
	| T_SQUARE_BRACKET_CLOSE
	| T_CICRUMFLEX
	| T_UNDERSCORE
	| T_GRAVE
	| LCALPHA
	| T_CURLY_BRACE_OPEN
	| T_VERTICAL_BAR
	| T_CURLY_BRACE_CLOSE
	| T_TILDE
	| T_DEL
;

escapable: 
	T_LC_B
	| T_LC_F
	| T_LC_N
	| T_LC_R
	| T_LC_T
	| T_FORWARD_SLASH
	| T_BACKSLASH
	| T_LC_U hexchar
;

hexchar: 
	non_surrogate
	| high_surrogate T_BACKSLASH T_LC_U low_surrogate
;

non_surrogate:
	DIGIT HEXDIG HEXDIG HEXDIG
	| T_UC_A HEXDIG HEXDIG HEXDIG
	| T_UC_B HEXDIG HEXDIG HEXDIG
	| T_UC_C HEXDIG HEXDIG HEXDIG
	| T_UC_E HEXDIG HEXDIG HEXDIG
	| T_UC_F HEXDIG HEXDIG HEXDIG
	| T_UC_D T_ZERO HEXDIG HEXDIG
	| T_UC_D T_ONE HEXDIG HEXDIG
	| T_UC_D T_TWO HEXDIG HEXDIG
	| T_UC_D T_THREE HEXDIG HEXDIG
	| T_UC_D T_FOUR HEXDIG HEXDIG
	| T_UC_D T_FIVE HEXDIG HEXDIG
	| T_UC_D T_SIX HEXDIG HEXDIG
	| T_UC_D T_SEVEN HEXDIG HEXDIG
;

high_surrogate:
	T_UC_D T_EIGHT HEXDIG HEXDIG
	| T_UC_D T_NINE HEXDIG HEXDIG
	| T_UC_D T_UC_A HEXDIG HEXDIG
	| T_UC_D T_UC_B HEXDIG HEXDIG
;

low_surrogate:
	T_UC_D T_UC_C HEXDIG HEXDIG
	| T_UC_D T_UC_D HEXDIG HEXDIG
	| T_UC_D T_UC_E HEXDIG HEXDIG
	| T_UC_D T_UC_F HEXDIG HEXDIG
;

HEXDIG:
	DIGIT
	| T_UC_A
	| T_UC_B
	| T_UC_C
	| T_UC_D
	| T_UC_E
	| T_UC_F
;





/* siehe RFC-9535 Abschnitt 2.3.2.1 */

wildcard_selector:
	T_ASTERISK
;





/* siehe RFC-9535 Abschnitt 2.3.3.1 */

index_selector: 
	int
;

int: 
	T_ZERO
	| opt_hyphen DIGIT1 rep_DIGIT
;

opt_hyphen:

	| T_HYPHEN
;

DIGIT1:
	T_ONE
	| T_TWO
	| T_THREE
	| T_FOUR
	| T_FIVE
	| T_SIX
	| T_SEVEN
	| T_EIGHT
	| T_NINE
;

rep_DIGIT: 

	| rep_DIGIT DIGIT
;





/* siehe RFC-9535 Abschnitt 2.3.4.1 */

slice_selector: 
	opt_start T_COLON S opt_end opt_step
;

opt_start:

	| start S
;

opt_end:

	| end S
;

opt_step:

	| T_COLON S step
	| T_COLON
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
	T_QUESTION S logical_expr
;



logical_expr: 
	logical_or_expr
;

logical_or_expr: 
	logical_and_expr rep_logical_and_expr
;

rep_logical_and_expr: 

	| rep_logical_and_expr S T_VERTICAL_BAR T_VERTICAL_BAR S logical_and_expr
;

logical_and_expr: 
	basic_expr rep_basic_expr
;

rep_basic_expr:

	| rep_basic_expr S T_AMPERSAND T_AMPERSAND S basic_expr
;

basic_expr: 
	paren_expr
	| comparison_expr
	| test_expr
;

paren_expr: 
	opt_not_op T_PAREN_OPEN S logical_expr S T_PAREN_CLOSE
;

opt_not_op:
	
	| logical_not_op S
;

logical_not_op:
	T_EXCLAMATION
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
	T_AT
;



comparison_expr = 
	comparable S comparison_op S comparable
;

literal = 
	number
	| string_literal
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
	T_EQUALS T_EQUALS
	| T_EXCLAMATION T_EQUALS
	| T_LT T_EQUALS
	| T_GT T_EQUALS
	| T_LT
	| T_GT
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
	T_SQUARE_BRACKET_OPEN name_selector T_SQUARE_BRACKET_CLOSE
	| T_PERIOD member_name_shorthand
;

index_segment:
	T_SQUARE_BRACKET_OPEN index_selector T_SQUARE_BRACKET_CLOSE
;



number:
	int opt_frac opt_exp
	| T_HYPHEN T_ZERO opt_frac opt_exp
;

opt_frac:

	| frac
;

frac:
	T_PERIOD DIGIT rep_DIGIT
;

opt_exp:

	| exp
;

exp:
	T_LC_E opt_signed DIGIT rep_DIGIT
;

rep_DIGIT:
	
	| rep_DIGIT DIGIT
;

opt_signed:

	| T_HYPHEN
	| T_PLUS
;

true:
	T_LC_T T_LC_R T_LC_U T_LC_E
;

false:
	T_LC_F T_LC_A T_LC_L T_LC_S T_LC_E
;

null:
	T_LC_N T_LC_U T_LC_L T_LC_L
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
	| T_UNDERSCORE
	| DIGIT
;

LCALPHA:
	T_LC_A
	| T_LC_B
	| T_LC_C
	| T_LC_D
	| T_LC_E
	| T_LC_F
	| T_LC_G
	| T_LC_H
	| T_LC_I
	| T_LC_J
	| T_LC_K
	| T_LC_L
	| T_LC_M
	| T_LC_N
	| T_LC_O
	| T_LC_P
	| T_LC_Q
	| T_LC_R
	| T_LC_S
	| T_LC_T
	| T_LC_U
	| T_LC_V
	| T_LC_W
	| T_LC_X
	| T_LC_Y
	| T_LC_Z
;



function_expr:
	function_name T_PAREN_OPEN S opt_func_args S T_PAREN_CLOSE
;

opt_func_args:
	
	| function-argument rep_function_argument
;

rep_function_argument:
	
	| rep_function_argument S T_COMMA S function_argument
;

function_argument:
	literal
	| filter_query
	| logical_expr
	| function_expr
;





/* siehe RFC-9535 Abschnitt 2.5 */

segment: 
	child_segment
	| descendant_segment
;





/* siehe RFC-9535 Abschnitt 2.5.1.1 */

child_segment: 
	bracketed_selection
	| T_PERIOD wildcard_selector
	| T_PERIOD member_name_shorthand
;

bracketed_selection: 
	T_SQUARE_BRACKET_OPEN S selector rep_selector S T_SQUARE_BRACKET_CLOSE
;

rep_selector: 
	
	| rep_selector S T_COMMA S selector
;



member_name_shorthand: 
	name_first rep_name_char
;

name_first: 
	ALPHA
	| T_UNDERSCORE
;

rep_name_char:

	| rep_name_char name_char
;

name_char: 
	name_first
	| DIGIT
;

DIGIT: 
	T_ZERO
	| DIGIT1
;

ALPHA: 
	UCALPHA
	| LCALPHA
;

UCALPHA:
	T_UC_A
	| T_UC_B
	| T_UC_C
	| T_UC_D
	| T_UC_E
	| T_UC_F
	| T_UC_G
	| T_UC_H
	| T_UC_I
	| T_UC_J
	| T_UC_K
	| T_UC_L
	| T_UC_M
	| T_UC_N
	| T_UC_O
	| T_UC_P
	| T_UC_Q
	| T_UC_R
	| T_UC_S
	| T_UC_T
	| T_UC_U
	| T_UC_V
	| T_UC_W
	| T_UC_X
	| T_UC_Y
	| T_UC_Z
;




/* siehe RFC-9535 Abschnitt 2.5.2.1 */

descendant_segment: 
	T_PERIOD T_PERIOD bracketed_selection
	| T_PERIOD T_PERIOD wildcard_selector
	| T_PERIOD T_PERIOD member_name_shorthand
;





%%

int main() {
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}