%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%token NUM PLUS MINUS TIMES DIVIDE LPAREN RPAREN

%%

expressao:
    expressao PLUS expressao {$$ = $1 + $3;}
  | expressao MINUS expressao {$$ = $1 - $3;}
  | expressao TIMES expressao {$$ = $1 * $3;}
  | expressao DIVIDE expressao {
    if ($3 == 0){
        fprintf(stderr, "[ERRO SEMANTICO] Divisao por zero\n");
        $$ = 0;
    }  else {
        $$ = $1 / $3;
    }
  }
  | LPAREN expressao RPAREN {$$ = $2;}
  | NUM {$$ = $1;}
  ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
