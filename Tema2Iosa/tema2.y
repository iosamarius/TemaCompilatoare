%{
     #include <stdio.h>
     #include <stdlib.h>
     #include <string.h>

        int yylex();
	int yyerror(const char *msg);

	int EsteCorecta = 0;
        char msg[500]; 

        class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
             void displayTable();                     
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

         void TVAR::displayTable()          
        {
         TVAR* tmp = TVAR::head;

           printf("Tabela simboluri\n");
	   while(tmp != NULL)
	   { 
           printf("%s %d \n",tmp->nume,tmp->valoare);
           tmp=tmp->next;
           }
        }

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}
	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}

%union { char* sir; int val; }

%token TOK_LEFT_PARENTHESIS TOK_RIGHT_PARENTHESIS TOK_SEMICOLON TOK_EQUAL TOK_COMMA
%token TOK_DEF TOK_COLON TOK_ID TOK_DO TOK_TO TOK_FOR TOK_END TOK_READ TOK_WRITE
%token TOK_BEGIN TOK_PROGRAM TOK_INTEGER TOK_ERRROR 
%token TOK_INT TOK_VARIABLE

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%type <sir> TOK_VARIABLE TOK_ID
%type <val> TOK_INT 
%type <val> term factor exp indexexp

%start S
 
%%
S : prog   
  ;
prog: TOK_PROGRAM progname TOK_VARIABLE declist TOK_BEGIN stmtlist TOK_END {EsteCorecta=1;}
    ;
progname : TOK_ID
{
ts=new TVAR();
ts->add($1);
}
	 ;
declist :declist TOK_SEMICOLON dec
	| dec
	;

dec : idlist TOK_COLON type
    ;
type : TOK_INTEGER
	;
idlist: idlist TOK_COMMA TOK_ID
        {
	if(ts->exists($3)==0)
        ts->add($3);
        }
	|TOK_ID
        {
	if(ts->exists($1)==0)
        ts->add($1);
        }
	;
stmtlist: stmtlist TOK_SEMICOLON stmt
	| stmt
        ;
stmt: assign
   | read
   | write
   | for
   ;
assign: TOK_ID TOK_DEF exp { 

 
 if(ts->exists($1)==0)
	{ sprintf(msg,"%d:%d Eroare semantica: Variabila nedeclarata!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      YYERROR;
	}
	else
	ts->setValue($1,$3);};

exp: term
   | exp TOK_PLUS term { $$ = $1 + $3; }
   | exp TOK_MINUS term { $$ = $1 - $3; }
   ;
term: factor
    | term TOK_MULTIPLY factor { $$ = $1 * $3; }
    | term TOK_DIVIDE factor
    {
	  if($3 == 0) 
	  { 
	      sprintf(msg,"%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      YYERROR;
	  } 
	  else { $$ = $1/$3; } 
    };
   
factor: TOK_ID
{
	if($1 == 0) 
	  { 
	      sprintf(msg,"%d:%d Variabila nedeclarata!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      YYERROR;
	  } 
	else
 	$$=ts->getValue($1);  // primeste 0 sau 1 ce returneaza get
}
      | TOK_INT
      | TOK_LEFT_PARENTHESIS exp TOK_RIGHT_PARENTHESIS { $$=$2; }
      ;
read: TOK_READ TOK_LEFT_PARENTHESIS idlist TOK_RIGHT_PARENTHESIS
    ;
write: TOK_WRITE TOK_LEFT_PARENTHESIS idlist TOK_RIGHT_PARENTHESIS
     ;
for: TOK_FOR indexexp TOK_DO body
   ;
indexexp: TOK_ID TOK_DEF exp TOK_TO exp { 
	if($1 == 0) 
	  { 
	      sprintf(msg,"%d:%d Variabila nedeclarata!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      YYERROR;
	  } 
	else
	ts->setValue($1,$3); }
        ;
body: stmt
    | TOK_BEGIN stmtlist TOK_END
    ;
%%

int main()
{  
	yyparse();

	if(EsteCorecta==1)
		printf("Corecta\n");
	else
		printf("Gresita\n");

        ts->displayTable();
        return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}
