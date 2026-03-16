/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Skeleton interface for Bison GLR parsers in C

   Copyright (C) 2002-2015, 2018-2021 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_JSONPATH_TAB_H_INCLUDED
# define YY_YY_JSONPATH_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    T_TAB = 258,                   /* T_TAB  */
    T_NEW_LINE = 259,              /* T_NEW_LINE  */
    T_CARRIAGE_RETURN = 260,       /* T_CARRIAGE_RETURN  */
    T_SPACE = 261,                 /* T_SPACE  */
    T_EXCLAMATION = 262,           /* T_EXCLAMATION  */
    T_DOUBLE_QUOTE = 263,          /* T_DOUBLE_QUOTE  */
    T_HASHTAG = 264,               /* T_HASHTAG  */
    T_DOLLAR = 265,                /* T_DOLLAR  */
    T_PERCENT = 266,               /* T_PERCENT  */
    T_AMPERSAND = 267,             /* T_AMPERSAND  */
    T_SINGLE_QUOTE = 268,          /* T_SINGLE_QUOTE  */
    T_PAREN_OPEN = 269,            /* T_PAREN_OPEN  */
    T_PAREN_CLOSE = 270,           /* T_PAREN_CLOSE  */
    T_ASTERISK = 271,              /* T_ASTERISK  */
    T_PLUS = 272,                  /* T_PLUS  */
    T_COMMA = 273,                 /* T_COMMA  */
    T_HYPHEN = 274,                /* T_HYPHEN  */
    T_PERIOD = 275,                /* T_PERIOD  */
    T_FORWARD_SLASH = 276,         /* T_FORWARD_SLASH  */
    T_ZERO = 277,                  /* T_ZERO  */
    T_ONE = 278,                   /* T_ONE  */
    T_TWO = 279,                   /* T_TWO  */
    T_THREE = 280,                 /* T_THREE  */
    T_FOUR = 281,                  /* T_FOUR  */
    T_FIVE = 282,                  /* T_FIVE  */
    T_SIX = 283,                   /* T_SIX  */
    T_SEVEN = 284,                 /* T_SEVEN  */
    T_EIGHT = 285,                 /* T_EIGHT  */
    T_NINE = 286,                  /* T_NINE  */
    T_COLON = 287,                 /* T_COLON  */
    T_SEMICOLON = 288,             /* T_SEMICOLON  */
    T_LT = 289,                    /* T_LT  */
    T_EQUALS = 290,                /* T_EQUALS  */
    T_GT = 291,                    /* T_GT  */
    T_QUESTION = 292,              /* T_QUESTION  */
    T_AT = 293,                    /* T_AT  */
    T_UC_A = 294,                  /* T_UC_A  */
    T_UC_B = 295,                  /* T_UC_B  */
    T_UC_C = 296,                  /* T_UC_C  */
    T_UC_D = 297,                  /* T_UC_D  */
    T_UC_E = 298,                  /* T_UC_E  */
    T_UC_F = 299,                  /* T_UC_F  */
    T_UC_G = 300,                  /* T_UC_G  */
    T_UC_H = 301,                  /* T_UC_H  */
    T_UC_I = 302,                  /* T_UC_I  */
    T_UC_J = 303,                  /* T_UC_J  */
    T_UC_K = 304,                  /* T_UC_K  */
    T_UC_L = 305,                  /* T_UC_L  */
    T_UC_M = 306,                  /* T_UC_M  */
    T_UC_N = 307,                  /* T_UC_N  */
    T_UC_O = 308,                  /* T_UC_O  */
    T_UC_P = 309,                  /* T_UC_P  */
    T_UC_Q = 310,                  /* T_UC_Q  */
    T_UC_R = 311,                  /* T_UC_R  */
    T_UC_S = 312,                  /* T_UC_S  */
    T_UC_T = 313,                  /* T_UC_T  */
    T_UC_U = 314,                  /* T_UC_U  */
    T_UC_V = 315,                  /* T_UC_V  */
    T_UC_W = 316,                  /* T_UC_W  */
    T_UC_X = 317,                  /* T_UC_X  */
    T_UC_Y = 318,                  /* T_UC_Y  */
    T_UC_Z = 319,                  /* T_UC_Z  */
    T_SQUARE_BRACKET_OPEN = 320,   /* T_SQUARE_BRACKET_OPEN  */
    T_BACKSLASH = 321,             /* T_BACKSLASH  */
    T_SQUARE_BRACKET_CLOSE = 322,  /* T_SQUARE_BRACKET_CLOSE  */
    T_CIRCUMFLEX = 323,            /* T_CIRCUMFLEX  */
    T_UNDERSCORE = 324,            /* T_UNDERSCORE  */
    T_GRAVE = 325,                 /* T_GRAVE  */
    T_LC_A = 326,                  /* T_LC_A  */
    T_LC_B = 327,                  /* T_LC_B  */
    T_LC_C = 328,                  /* T_LC_C  */
    T_LC_D = 329,                  /* T_LC_D  */
    T_LC_E = 330,                  /* T_LC_E  */
    T_LC_F = 331,                  /* T_LC_F  */
    T_LC_G = 332,                  /* T_LC_G  */
    T_LC_H = 333,                  /* T_LC_H  */
    T_LC_I = 334,                  /* T_LC_I  */
    T_LC_J = 335,                  /* T_LC_J  */
    T_LC_K = 336,                  /* T_LC_K  */
    T_LC_L = 337,                  /* T_LC_L  */
    T_LC_M = 338,                  /* T_LC_M  */
    T_LC_N = 339,                  /* T_LC_N  */
    T_LC_O = 340,                  /* T_LC_O  */
    T_LC_P = 341,                  /* T_LC_P  */
    T_LC_Q = 342,                  /* T_LC_Q  */
    T_LC_R = 343,                  /* T_LC_R  */
    T_LC_S = 344,                  /* T_LC_S  */
    T_LC_T = 345,                  /* T_LC_T  */
    T_LC_U = 346,                  /* T_LC_U  */
    T_LC_V = 347,                  /* T_LC_V  */
    T_LC_W = 348,                  /* T_LC_W  */
    T_LC_X = 349,                  /* T_LC_X  */
    T_LC_Y = 350,                  /* T_LC_Y  */
    T_LC_Z = 351,                  /* T_LC_Z  */
    T_CURLY_BRACE_OPEN = 352,      /* T_CURLY_BRACE_OPEN  */
    T_VERTICAL_BAR = 353,          /* T_VERTICAL_BAR  */
    T_CURLY_BRACE_CLOSE = 354,     /* T_CURLY_BRACE_CLOSE  */
    T_TILDE = 355,                 /* T_TILDE  */
    T_DEL = 356                    /* T_DEL  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_JSONPATH_TAB_H_INCLUDED  */
