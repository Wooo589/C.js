%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "symbol_table.h"

int yylex(void);
void yyerror(const char *s);
void semantic_error(const char *s);
extern char* yytext;
extern int contaLinhas;

// Tabela de símbolos global
SymbolTable *global_table = NULL;
SymbolTable *current_table = NULL;
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
%token AUTO ENUM EXTERN REGISTER SIZEOF STATIC STRUCT TYPEDEF UNION VOLATILE STRING_LITERAL

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
    { 
        // Inicializar tabela de símbolos global
        global_table = create_symbol_table(NULL);
        current_table = global_table;
    }
    programa_corpo
    ;

programa_corpo:
    declaracao_funcao
    | comando
    | programa_corpo declaracao_funcao
    | programa_corpo comando
    ;

declaracao_funcao:
    tipo VAR LPAREN {
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Função '%s' já foi declarada neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        insert_symbol(current_table, $2, $1, SYMBOL_FUNCTION, contaLinhas, 1);
        current_table = create_symbol_table(current_table); // Novo escopo para parâmetros e corpo
    } 
    parametros RPAREN bloco {
        SymbolTable *temp = current_table;
        current_table = current_table->parent;
        free_symbol_table(temp);
        free($1);
        free($2);
    }
    ;

parametros:
    /* vazio */
    | lista_parametros
    ;

lista_parametros:
    tipo VAR {
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Parâmetro '%s' já foi declarado neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        insert_symbol(current_table, $2, $1, SYMBOL_PARAMETER, contaLinhas, 1);
        free($1);
        free($2);
    }
    | lista_parametros COMMA tipo VAR {
        if (lookup_symbol_current_scope(current_table, $4) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Parâmetro '%s' já foi declarado neste escopo", 
                    contaLinhas, $4);
            yyerror(error_msg);
            YYERROR;
        }
        insert_symbol(current_table, $4, $3, SYMBOL_PARAMETER, contaLinhas, 1);
        free($3);
        free($4);
    }
    ;

comandos:
    comando
    | comandos comando
    ;

declaracao:
    tipo VAR {
        // Verificar se já foi declarada
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' já foi declarada neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        // Inserir na tabela de símbolos (não inicializada)
        insert_symbol(current_table, $2, $1, SYMBOL_VARIABLE, contaLinhas, 0);
        free($1);
        free($2);
    }
    | tipo VAR ASSIGN expressao {
        // Verificar se já foi declarada
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' já foi declarada neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        // Inserir na tabela de símbolos (inicializada)
        insert_symbol(current_table, $2, $1, SYMBOL_VARIABLE, contaLinhas, 1);
        free($1);
        free($2);
    }
    | tipo VAR LBRACKET expressao RBRACKET {
        // Verificar se já foi declarada
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' já foi declarada neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        // Array - inserir na tabela
        char *array_type = malloc(strlen($1) + 10);
        sprintf(array_type, "%s[]", $1);
        insert_symbol(current_table, $2, array_type, SYMBOL_VARIABLE, contaLinhas, 1);
        free($1);
        free($2);
        free(array_type);
    }
    | TYPEDEF tipo VAR {
        // Verificar se já foi declarada
        if (lookup_symbol_current_scope(current_table, $3) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Typedef '%s' já foi declarado neste escopo", 
                    contaLinhas, $3);
            yyerror(error_msg);
            YYERROR;
        }
        // Inserir typedef na tabela
        insert_symbol(current_table, $3, $2, SYMBOL_TYPEDEF, contaLinhas, 1);
        free($2);
        free($3);
    }
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
    VAR ASSIGN expressao {
        // Verificar se a variável foi declarada
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        // Marcar como inicializada
        update_symbol_initialization(current_table, $1);
        free($1);
    }
    | VAR PLUS_ASSIGN expressao {
    Symbol *symbol = lookup_symbol(current_table, $1);
    if (symbol == NULL) {
        char error_msg[256];
        snprintf(error_msg, sizeof(error_msg), 
                "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                contaLinhas, $1);
        yyerror(error_msg);
        YYERROR;
    }
    update_symbol_initialization(current_table, $1);
    free($1);
    }
    | VAR MINUS_ASSIGN expressao {
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        free($1);
    }
    | VAR TIMES_ASSIGN expressao {
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        free($1);
    }
    | VAR DIVIDE_ASSIGN expressao {
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        free($1);
    }
    | VAR MOD_ASSIGN expressao {
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        free($1);
    }
    | VAR INCREMENT {
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        free($1);
    }
    | VAR DECREMENT {
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        free($1);
    }
    | INCREMENT VAR {
        Symbol *symbol = lookup_symbol(current_table, $2);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        free($2);
    }
    | DECREMENT VAR {
        Symbol *symbol = lookup_symbol(current_table, $2);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        free($2);
    }
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
    | VAR { 
        // Verificar se a variável foi declarada
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        $$ = 0;
        free($1);
    }
    | VAR LPAREN argumentos RPAREN { 
        // Verificar se a função foi declarada
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Aviso na linha %d: Função '%s' não foi declarada", 
                    contaLinhas, $1);
            fprintf(stderr, "%s\n", error_msg);
        }
        $$ = 0; 
        free($1);
    }
    | VAR LBRACKET expressao RBRACKET { 
        // Verificar se a variável foi declarada
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Array '%s' não foi declarado", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        $$ = 0; 
        free($1);
    }
    | VAR ARROW VAR { 
        $$ = 0; 
        free($1);
        free($3);
    }
    | SIZEOF LPAREN tipo RPAREN { $$ = 0; }
    | SIZEOF LPAREN VAR RPAREN { $$ = 0; }
    | STRING_LITERAL { }
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
    LBRACE {
        current_table = create_symbol_table(current_table);
    }
    comandos RBRACE {
        SymbolTable *temp = current_table;
        current_table = current_table->parent;
        free_symbol_table(temp);
    }
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
    fprintf(stderr, "%s\n", s);
}

void semantic_error(const char *s) {
    fprintf(stderr, "Erro semântico: %s\n", s);
}

int main(int argc, char **argv) {
    extern FILE *yyin;
    
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (file) {
            yyin = file;
        }
    }
    
    int result = yyparse();
    if (global_table != NULL) {
        free_symbol_table(global_table);
    }
    
    return result;
}