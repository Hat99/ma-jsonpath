%option noyywrap

%option header-file="lex.yy.h"


%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "jsonpath.tab.h"

%}

%%



"\x09"	{return T_TAB;}
"\x0A"	{return T_NEW_LINE;}
"\x0D"	{return T_CARRIAGE_RETURN;}

"\x20"	{return T_SPACE;}
"\x21"	{return T_EXCLAMATION;}
"\x22"	{return T_DOUBLE_QUOTE;}
"\x23"	{return T_HASHTAG;}
"\x24"	{return T_DOLLAR;}
"\x25"	{return T_PERCENT;}
"\x26"	{return T_AMPERSAND;}
"\x27"	{return T_SINGLE_QUOTE;}

"\x28"	{return T_PAREN_OPEN;}
"\x29"	{return T_PAREN_CLOSE;}
"\x2A"	{return T_ASTERISK;}
"\x2B"	{return T_PLUS;}
"\x2C"	{return T_COMMA;}
"\x2D"	{return T_HYPHEN;}
"\x2E"	{return T_PERIOD;}
"\x2F"	{return T_FORWARD_SLASH;}

"\x30"	{return T_ZERO;}
"\x31"	{return T_ONE;}
"\x32"	{return T_TWO;}
"\x33"	{return T_THREE;}
"\x34"	{return T_FOUR;}
"\x35"	{return T_FIVE;}
"\x36"	{return T_SIX;}
"\x37"	{return T_SEVEN;}
"\x38"	{return T_EIGHT;}
"\x39"	{return T_NINE;}

"\x3A"	{return T_COLON;}
"\x3B"	{return T_SEMICOLON;}
"\x3C"	{return T_LT;}
"\x3D"	{return T_EQUALS;}
"\x3E"	{return T_GT;}
"\x3F"	{return T_QUESTION;}
"\x40"	{return T_AT;}


"\x41"	{return T_UC_A;}
"\x42"	{return T_UC_B;}
"\x43"	{return T_UC_C;}
"\x44"	{return T_UC_D;}
"\x45"	{return T_UC_E;}
"\x46"	{return T_UC_F;}
"\x47"	{return T_UC_G;}
"\x48"	{return T_UC_H;}
"\x49"	{return T_UC_I;}
"\x4A"	{return T_UC_J;}
"\x4B"	{return T_UC_K;}
"\x4C"	{return T_UC_L;}
"\x4D"	{return T_UC_M;}
"\x4E"	{return T_UC_N;}
"\x4F"	{return T_UC_O;}
"\x50"	{return T_UC_P;}
"\x51"	{return T_UC_Q;}
"\x52"	{return T_UC_R;}
"\x53"	{return T_UC_S;}
"\x54"	{return T_UC_T;}
"\x55"	{return T_UC_U;}
"\x56"	{return T_UC_V;}
"\x57"	{return T_UC_W;}
"\x58"	{return T_UC_X;}
"\x59"	{return T_UC_Y;}
"\x5A"	{return T_UC_Z;}

"\x5B"	{return T_SQUARE_BRACKET_OPEN;}
"\x5C"	{return T_BACKSLASH;}
"\x5D"	{return T_SQUARE_BRACKET_CLOSE;}
"\x5E"	{return T_CIRCUMFLEX;}
"\x5F"	{return T_UNDERSCORE;}
"\x60"	{return T_GRAVE;}

"\x61"	{return T_LC_A;}
"\x62"	{return T_LC_B;}
"\x63"	{return T_LC_C;}
"\x64"	{return T_LC_D;}
"\x65"	{return T_LC_E;}
"\x66"	{return T_LC_F;}
"\x67"	{return T_LC_G;}
"\x68"	{return T_LC_H;}
"\x69"	{return T_LC_I;}
"\x6A"	{return T_LC_J;}
"\x6B"	{return T_LC_K;}
"\x6C"	{return T_LC_L;}
"\x6D"	{return T_LC_M;}
"\x6E"	{return T_LC_N;}
"\x6F"	{return T_LC_O;}
"\x70"	{return T_LC_P;}
"\x71"	{return T_LC_Q;}
"\x72"	{return T_LC_R;}
"\x73"	{return T_LC_S;}
"\x74"	{return T_LC_T;}
"\x75"	{return T_LC_U;}
"\x76"	{return T_LC_V;}
"\x77"	{return T_LC_W;}
"\x78"	{return T_LC_X;}
"\x79"	{return T_LC_Y;}
"\x7A"	{return T_LC_Z;}

"\x7B"	{return T_CURLY_BRACE_OPEN;}
"\x7C"	{return T_VERTICAL_BAR;}
"\x7D"	{return T_CURLY_BRACE_CLOSE;}
"\x7E"	{return T_TILDE;}
"\x7F"	{return T_DEL;}



.		//Default-Fall?

%%