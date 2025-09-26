%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>


int yylex(void);
void yyerror(const char *s);
void semantic_error(const char *s);
extern char* yytext;
extern int contaLinhas;
%}

%union {
    int ival;
    float fval;
    double dval;
    char *sval;
}

%token <ival> NUM
%token <fval> FLOAT_NUM
%token <sval> VAR CHAR
%token <ival> INT
%token <fval> FLOAT
%token <dval> DOUBLE
%token CONST VOID SHORT LONG SIGNED UNSIGNED ASSIGN
%token PLUS MINUS TIMES DIVIDE MOD POWER SEMICOLON LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET COMMA
%token EQ NEQ LT GT LEQ GEQ AND OR NOT
%token PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIVIDE_ASSIGN MOD_ASSIGN INCREMENT DECREMENT ARROW
%token IF ELSE ELSEIF WHILE FOR DO SWITCH CASE DEFAULT BREAK CONTINUE RETURN
%token AUTO ENUM EXTERN REGISTER SIZEOF STATIC STRUCT TYPEDEF UNION VOLATILE

%type <fval> expressao
%type <sval> tipo tipo_base modificador modificadores

%right ASSIGN PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIVIDE_ASSIGN MOD_ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right UNARY
%right NOT
%left POWER
%precedence IFX
%precedence ELSE

%%

programa:
    declaracao_funcao
    | comando
    | programa declaracao_funcao
    | programa comando
    ;

declaracao_funcao:
    tipo VAR LPAREN parametros RPAREN bloco
    ;

parametros:
    /* vazio */
    | lista_parametros
    ;

lista_parametros:
    tipo VAR
    | lista_parametros COMMA tipo VAR
    ;

comandos:
    comando
    | comandos comando
    ;

declaracao:
    tipo VAR
    | tipo VAR ASSIGN expressao
    | tipo VAR LBRACKET expressao RBRACKET
    | TYPEDEF tipo VAR
    ;

comando:
    declaracao SEMICOLON
    | atribuicao SEMICOLON
    | expressao SEMICOLON
    | condicao
    | loop
    | switch_statement
    | comando_break
    | comando_continue
    | comando_return
    | bloco
    ;

atribuicao:
    VAR ASSIGN expressao
    | VAR PLUS_ASSIGN expressao
    | VAR MINUS_ASSIGN expressao
    | VAR TIMES_ASSIGN expressao
    | VAR DIVIDE_ASSIGN expressao
    | VAR MOD_ASSIGN expressao
    | VAR INCREMENT
    | VAR DECREMENT
    | INCREMENT VAR
    | DECREMENT VAR
    ;

tipo:
    tipo_base { $$ = $1; }
    | modificadores tipo_base { asprintf(&$$, "%s %s", $1, $2); free($1); free($2); }
    | STRUCT VAR LBRACE declaracoes_struct RBRACE { asprintf(&$$, "struct %s", $2); free($2); }
    | UNION VAR LBRACE declaracoes_struct RBRACE { asprintf(&$$, "union %s", $2); free($2); }
    | ENUM VAR LBRACE lista_enumeradores RBRACE { asprintf(&$$, "enum %s", $2); free($2); }
    ;

tipo_base:
    INT { $$ = strdup("int"); }
    | FLOAT { $$ = strdup("float"); }
    | DOUBLE { $$ = strdup("double"); }
    | CHAR { $$ = strdup("char"); }
    | VOID { $$ = strdup("void"); }
    ;

modificadores:
    modificador { $$ = $1; }
    | modificadores modificador { asprintf(&$$, "%s %s", $1, $2); free($1); free($2); }
    ;

modificador:
    CONST { $$ = strdup("const"); }
    | SHORT { $$ = strdup("short"); }
    | LONG { $$ = strdup("long"); }
    | SIGNED { $$ = strdup("signed"); }
    | UNSIGNED { $$ = strdup("unsigned"); }
    | STATIC { $$ = strdup("static"); }
    | EXTERN { $$ = strdup("extern"); }
    | AUTO { $$ = strdup("auto"); }
    | REGISTER { $$ = strdup("register"); }
    | VOLATILE { $$ = strdup("volatile"); }
    ;

declaracoes_struct:
    /* vazio */
    | declaracoes_struct declaracao SEMICOLON
    ;

lista_enumeradores:
    VAR
    | lista_enumeradores COMMA VAR
    ;

expressao:
    expressao PLUS expressao { $$ = $1 + $3; }
    | expressao MINUS expressao { $$ = $1 - $3; }
    | expressao TIMES expressao { $$ = $1 * $3; }
    | expressao DIVIDE expressao {
        if ($3 == 0) {
            semantic_error("Divisao por zero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | expressao MOD expressao { $$ = fmod($1, $3); }
    | expressao POWER expressao { $$ = pow($1, $3); }
    | expressao EQ expressao { $$ = ($1 == $3); }
    | expressao NEQ expressao { $$ = ($1 != $3); }
    | expressao LT expressao { $$ = ($1 < $3); }
    | expressao GT expressao { $$ = ($1 > $3); }
    | expressao LEQ expressao { $$ = ($1 <= $3); }
    | expressao GEQ expressao { $$ = ($1 >= $3); }
    | expressao AND expressao { $$ = ($1 && $3); }
    | expressao OR expressao { $$ = ($1 || $3); }
    | NOT expressao { $$ = !$2; }
    | MINUS expressao %prec UNARY { $$ = -$2; }
    | PLUS expressao %prec UNARY { $$ = $2; }
    | LPAREN expressao RPAREN { $$ = $2; }
    | NUM { $$ = $1; }
    | FLOAT_NUM { $$ = $1; }
    | VAR { $$ = 0; } /* Variável - por enquanto retorna 0 */
    | VAR LPAREN argumentos RPAREN { $$ = 0; }
    | VAR LBRACKET expressao RBRACKET { $$ = 0; }
    | VAR ARROW VAR { $$ = 0; }
    | SIZEOF LPAREN tipo RPAREN { $$ = 0; }
    | SIZEOF LPAREN VAR RPAREN { $$ = 0; }
    ;

argumentos:
    /* vazio */
    | lista_argumentos
    ;

lista_argumentos:
    expressao
    | lista_argumentos COMMA expressao
    ;

condicao:
    IF LPAREN expressao RPAREN bloco %prec IFX
    | IF LPAREN expressao RPAREN bloco ELSE bloco
    | IF LPAREN expressao RPAREN bloco ELSEIF LPAREN expressao RPAREN bloco condicao_encadeada
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

switch_statement:
    SWITCH LPAREN expressao RPAREN LBRACE case_list RBRACE
    ;

case_list:
    /* vazio */
    | case_list case_statement
    | case_list default_statement
    ;

case_statement:
    CASE expressao SEMICOLON comandos
    ;

default_statement:
    DEFAULT SEMICOLON comandos
    ;

comando_break:
    BREAK SEMICOLON
    ;

comando_continue:
    CONTINUE SEMICOLON
    ;

comando_return:
    RETURN SEMICOLON
    | RETURN expressao SEMICOLON
    ;

loop:
    WHILE LPAREN expressao RPAREN bloco
    | FOR LPAREN atribuicao SEMICOLON expressao SEMICOLON atribuicao RPAREN bloco
    | DO bloco WHILE LPAREN expressao RPAREN SEMICOLON
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático perto da linha %d. Token inesperado: '%s'\n", contaLinhas, yytext);
}

void semantic_error(const char *s) {
    fprintf(stderr, "Erro semântico: %s\n", s);
}