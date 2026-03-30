%{
#include "jsonpath.tab.hpp"
#define YY_DECL int yylex_2()
%}

/*Start Conditions*/

%s  NORMALIZED





/* Regex-Bausteine nach RFC-9535 Abschnitt 2.3.3.1 (S.17) */

HEXDIG  [0-9A-F]

LOW_SURROGATE   (D[C-F]{HEXDIG}{HEXDIG})
HIGH_SURROGATE  (D[89AB]{HEXDIG}{HEXDIG})
NON_SURROGATE   ([0-9ABCEF]{HEXDIG}{HEXDIG}{HEXDIG})|(D[0-7]{HEXDIG}{HEXDIG})
HEXCHAR         ({NON_SURROGATE}|({HIGH_SURROGATE}\\u{LOW_SURROGATE}))

ESCAPABLE   ([bfnrt/\\]|(u{HEXCHAR}))
UNESCAPED   [\x20-\x21\x23-\x26\x28-\x5B\x5D-\x7F]

ESC         \\

SINGLE_QUOTED   ({UNESCAPED}|\"|({ESC}')|({ESC}{ESCAPABLE}))
DOUBLE_QUOTED   ({UNESCAPED}|'|({ESC}\")|({ESC}{ESCAPABLE}))



/* Regex-Bausteine nach RFC-9535 Abschnitt 2.7 (S.47) */

NORMAL_INDEX_SELECTOR   (0|([1-9][0-9]*))

NORMAL_HEXDIG   [0-9a-f]

NORMAL_HEXCHAR  (00((0[0-7])|(0b)|(0[ef])|(1{NORMAL_HEXDIG})))

NORMAL_ESCAPABLE    ([bfnrt'\\]|(u{NORMAL_HEXCHAR}))
NORMAL_UNESCAPED    [\x20-\x26\x28-\x5B\x5D-\x7F]

NORMAL_SINGLE_QUOTED    ({NORMAL_UNESCAPED}|({ESC}{NORMAL_ESCAPABLE}))



%%
    
<NORMALIZED>'{NORMAL_SINGLE_QUOTED}*'  {
    yylval.cval = yytext;
    return T_NORMAL_NAME_SELECTOR;
}

<NORMALIZED>{NORMAL_INDEX_SELECTOR} {
    yylval.ival = atoi(yytext);
    return T_NORMAL_INDEX_SELECTOR;
}
    
(\"{DOUBLE_QUOTED}*\")|('{SINGLE_QUOTED}*')   {
    yylval.cval = yytext;
    return T_STRING_LITERAL;
}


[\x09\x0A\x0D\x20-\x7F]     {return yytext[0];}

.		{return T_ERR;}

%%
    
int yywrap(void){
    return 1;
}
    
void setStateInitial(void){
    BEGIN(INITIAL);
}

void setStateNormalized(void){
    BEGIN(NORMALIZED);
}
