%{
	#include "y.tab.h"  //generat de yacc -d

	int lineNo = 1;
	int colNo = 1;
%}

%%
"+"				{ colNo++; return TOK_PLUS; }
"-"				{ colNo++; return TOK_MINUS; }
"*"				{ colNo++; return TOK_MULTIPLY; }
"("				{ colNo++; return TOK_LEFT_PARENTHESIS; }
")"				{ colNo++; return TOK_RIGHT_PARENTHESIS; }

";"				{ colNo++; return TOK_SEMICOLON; }
"="				{ colNo++; return TOK_EQUAL; }
"."				{ colNo++; return '.';}
","				{ colNo++; return TOK_COMMA; }
":="				{ colNo+=2; return TOK_DEF; }
":"				{ colNo++; return TOK_COLON; }

"DO"			        { colNo+=2; return TOK_DO; }
"TO"			        { colNo+=2; return TOK_TO; }
"VAR" 				{ colNo+=3; return TOK_VARIABLE; }
"DIV"				{ colNo+=3; return TOK_DIVIDE; }
"FOR"			        { colNo+=3; return TOK_FOR; }
"END"			        { colNo+=3; return TOK_END; }
"READ"			        { colNo+=4; return TOK_READ; }
"WRITE"			        { colNo+=5; return TOK_WRITE; }
"BEGIN"			        { colNo+=5; return TOK_BEGIN; }

"PROGRAM"                       { colNo+=7; return TOK_PROGRAM; }
"INTEGER"                       { colNo+=7; return TOK_INTEGER; }

0|[1-9][0-9]*	          { yylloc.first_line = lineNo;
                            yylloc.first_column = colNo;
                            yylval.val = atoi(yytext);
                            colNo+=strlen(yytext);
                            return TOK_INT; }

[a-zA-Z][_a-zA-Z0-9]*     { yylloc.first_line = lineNo;
                            yylloc.first_column = colNo;
                            yylval.sir = strdup(yytext); 
                            colNo+=strlen(yytext);
                            return TOK_ID; }

\n			{lineNo++;colNo=1;}		
[ \t\f\v]    	        { ; }     // ignora spatiile
.                       { colNo++; return TOK_ERRROR; } // printf("linia %d, coloana:%d",lineNo,colNo)
%%
