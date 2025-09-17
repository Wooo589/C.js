%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%token INT FLOAT DOUBLE CHAR CONST VOID SHORT LONG SIGNED UNSIGNED VAR ASSIGN NUM PLUS MINUS TIMES DIVIDE SEMICOLON LPAREN RPAREN IF LBRACE RBRACE ELSE ELSEIF

%left PLUS MINUS
%left TIMES DIVIDE

%%

programa:
      comandos
    ;

comandos:
      comando
    | comandos comando
    ;

comando:
      atribuicao SEMICOLON
    | expressao SEMICOLON
    | condicao
    ;

atribuicao:
      tipo VAR ASSIGN expressao
    | VAR ASSIGN expressao
    ;

tipo:
      INT
    | FLOAT
    | DOUBLE
    | CHAR
    | CONST 
    | VOID 
    | SHORT
    | LONG 
    | SIGNED
    | UNSIGNED
    ;

expressao:
      expressao PLUS expressao {$$ = $1 + $3;}
    | expressao MINUS expressao {$$ = $1 - $3;}
    | expressao TIMES expressao {$$ = $1 * $3;}
    | expressao DIVIDE expressao {
          if ($3 == 0){
              fprintf(stderr, "[ERRO SEMANTICO] Divisao por zero\n");
              $$ = 0;
          } else {
              $$ = $1 / $3;
          }
      }
    | LPAREN expressao RPAREN {$$ = $2;} 
    | NUM {$$ = $1;} 
    ;

condicao:
      IF LPAREN expressao RPAREN bloco condicao_encadeada
    ;

condicao_encadeada:
      /* vazio */
    | ELSEIF LPAREN expressao RPAREN bloco condicao_encadeada
    | ELSE bloco
    ;

bloco:
      LBRACE comandos RBRACE
    | LBRACE RBRACE
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}
