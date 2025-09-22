%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int yylex(void);
void yyerror(const char *s);
%}

%token INT FLOAT DOUBLE CHAR CONST VOID SHORT LONG SIGNED UNSIGNED VAR ASSIGN NUM FLOAT_NUM
%token PLUS MINUS TIMES DIVIDE MOD POWER SEMICOLON LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET COMMA
%token EQ NEQ LT GT LEQ GEQ AND OR NOT
%token PLUS_ASSIGN MINUS_ASSIGN INCREMENT DECREMENT ARROW
%token IF ELSE ELSEIF WHILE FOR DO SWITCH CASE DEFAULT BREAK RETURN
%token AUTO CONTINUE ENUM EXTERN REGISTER SIZEOF STATIC STRUCT TYPEDEF UNION VOLATILE

%right ASSIGN PLUS_ASSIGN MINUS_ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT
%left POWER
%left INCREMENT DECREMENT

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
    | loop
    | comando_break
    | comando_return
    | bloco
    ;

comando_break:
      BREAK SEMICOLON
    ;

comando_return:
      RETURN SEMICOLON
    | RETURN expressao SEMICOLON
    ;

loop:
      WHILE LPAREN expressao RPAREN bloco
    | FOR LPAREN atribuicao_ou_expressao SEMICOLON expressao SEMICOLON atribuicao_ou_expressao RPAREN bloco
    | DO bloco WHILE LPAREN expressao RPAREN SEMICOLON
    ;

atribuicao_ou_expressao:
      /* vazio */
    | atribuicao
    | expressao
    ;

atribuicao:
      tipo VAR ASSIGN expressao
    | VAR ASSIGN expressao
    | VAR PLUS_ASSIGN expressao
    | VAR MINUS_ASSIGN expressao
    | VAR INCREMENT
    | VAR DECREMENT
    | INCREMENT VAR
    | DECREMENT VAR
    ;

tipo:
      tipo_base
    | modificador tipo_base
    | tipo_base modificador
    | modificador modificador tipo_base
    ;

tipo_base:
      INT
    | FLOAT
    | DOUBLE
    | CHAR
    | VOID
    ;

modificador:
      CONST 
    | SHORT
    | LONG 
    | SIGNED
    | UNSIGNED
    | STATIC
    | EXTERN
    | AUTO
    | REGISTER
    | VOLATILE
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
    | expressao MOD expressao {$$ = $1 % $3;}
    | expressao POWER expressao {$$ = pow($1, $3);}
    | expressao EQ expressao {$$ = ($1 == $3);}
    | expressao NEQ expressao {$$ = ($1 != $3);}
    | expressao LT expressao {$$ = ($1 < $3);}
    | expressao GT expressao {$$ = ($1 > $3);}
    | expressao LEQ expressao {$$ = ($1 <= $3);}
    | expressao GEQ expressao {$$ = ($1 >= $3);}
    | expressao AND expressao {$$ = ($1 && $3);}
    | expressao OR expressao {$$ = ($1 || $3);}
    | NOT expressao {$$ = !$2;}
    | MINUS expressao {$$ = -$2;}
    | PLUS expressao {$$ = $2;}
    | LPAREN expressao RPAREN {$$ = $2;} 
    | NUM {$$ = $1;} 
    | FLOAT_NUM {$$ = $1;}
    | VAR {$$ = 0;} /* Variável - por enquanto retorna 0 */
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
