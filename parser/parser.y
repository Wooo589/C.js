%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%token INT FLOAT DOUBLE CHAR CONST VOID SHORT LONG SIGNED UNSIGNED VAR ASSIGN NUM PLUS MINUS TIMES DIVIDE SEMICOLON LPAREN RPAREN IF LBRACE RBRACE ELSE ELSEIF

%%

tipo:
      INT;
    | FLOAT;
    | DOUBLE
    | CHAR
    | CONST 
    | VOID 
    | SHORT
    | LONG 
    | SIGNED
    | UNSIGNED
    ;

atribuicao:
    tipo VAR ASSIGN expressao
    | VAR ASSIGN expressao
    ;

expressao:
    expressao PLUS expressao SEMICOLON {$$ = $1 + $3;}
  | expressao MINUS expressao SEMICOLON {$$ = $1 - $3;}
  | expressao TIMES expressao SEMICOLON {$$ = $1 * $3;}
  | expressao DIVIDE expressao SEMICOLON {
    if ($3 == 0){
        fprintf(stderr, "[ERRO SEMANTICO] Divisao por zero\n");
        $$ = 0;
    }  else {
        $$ = $1 / $3;
    }
  }
  | LPAREN expressao RPAREN SEMICOLON {$$ = $2;} 
  | NUM SEMICOLON {$$ = $1;} 
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

comando:
    expressao
    | condicao
    ;

comandos:
      comando
    | comandos comando
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
