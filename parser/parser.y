%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "src/ast.h"
#include "src/symbol_table.h"

int yylex(void);
void yyerror(const char *s);
void semantic_error(const char *s);
extern char* yytext;
extern int contaLinhas;

SymbolTable *global_table = NULL;
SymbolTable *current_table = NULL;
ASTNode *ast_root = NULL;
%}

%union {
    int ival;
    float fval;
    double dval;
    char *sval;
    ASTNode *ast;
}

%token <ival> NUM
%token <fval> FLOAT_NUM
%token <sval> VAR CHAR
%token <ival> INT FLOAT DOUBLE VOID
%token CONST SHORT LONG SIGNED UNSIGNED ASSIGN
%token PLUS MINUS TIMES DIVIDE MOD POWER SEMICOLON LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET COMMA
%token EQ NEQ LT GT LEQ GEQ AND OR NOT
%token PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIVIDE_ASSIGN MOD_ASSIGN INCREMENT DECREMENT ARROW
%token IF ELSE WHILE FOR DO SWITCH CASE DEFAULT BREAK CONTINUE RETURN
%token AUTO ENUM EXTERN REGISTER SIZEOF STATIC STRUCT TYPEDEF UNION VOLATILE

%type <ast> programa programa_corpo declaracao_funcao bloco comandos comando declaracao atribuicao expressao
%type <ast> parametros lista_parametros condicao loop switch_statement comando_break comando_continue comando_return
%type <ast> argumentos lista_argumentos case_list case_statement default_statement
%type <ast> declaracoes_struct lista_enumeradores
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
        global_table = create_symbol_table(NULL);
        current_table = global_table;
        ast_root = create_node(AST_PROGRAM, NULL, NULL, contaLinhas);
    }
    programa_corpo { 
        ast_root->children = $2; 
        $$ = ast_root;
    }
    ;

programa_corpo:
    declaracao_funcao { $$ = $1; }
    | comando { $$ = $1; }
    | programa_corpo declaracao_funcao { $1->next = $2; $$ = $1; }
    | programa_corpo comando { $1->next = $2; $$ = $1; }
    ;

declaracao_funcao:
    tipo VAR LPAREN parametros RPAREN bloco 
    {
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Função '%s' já foi declarada neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        SymbolTable *func_table = create_symbol_table(current_table);
        insert_symbol(func_table, $2, $1, SYMBOL_FUNCTION, contaLinhas, 1);
        current_table = func_table;
        
        $$ = create_node(AST_FUNCTION_DECLARATION, $2, $1, contaLinhas);
        if ($4) {
            $$->children = $4;
            ASTNode *last_param = $4;
            while (last_param->next) last_param = last_param->next;
            last_param->next = $6;
        } else {
            $$->children = $6;
        }
        
        print_symbol_table(current_table);
        SymbolTable *temp = current_table;
        current_table = current_table->parent;
        free_symbol_table(temp);
        free($1); free($2);
    }
    ;

parametros:
    /* vazio */ { $$ = NULL; }
    | lista_parametros { $$ = $1; }
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
        $$ = create_node(AST_PARAMETER, $2, $1, contaLinhas);
        free($1); free($2);
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
        $$ = $1;
        ASTNode *new_param = create_node(AST_PARAMETER, $4, $3, contaLinhas);
        new_param->next = $1->next;
        $1->next = new_param;
        free($3); free($4);
    }
    ;

comandos:
    comando { $$ = $1; }
    | comandos comando { $1->next = $2; $$ = $1; }
    ;

declaracao:
    tipo VAR {
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' já foi declarada neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        insert_symbol(current_table, $2, $1, SYMBOL_VARIABLE, contaLinhas, 0);
        $$ = create_node(AST_VARIABLE_DECLARATION, $2, $1, contaLinhas);
        free($1); free($2);
    }
    | tipo VAR ASSIGN expressao {
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' já foi declarada neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        insert_symbol(current_table, $2, $1, SYMBOL_VARIABLE, contaLinhas, 1);
        $$ = create_node(AST_VARIABLE_DECLARATION, $2, $1, contaLinhas);
        $$->children = $4;
        free($1); free($2);
    }
    | tipo VAR LBRACKET expressao RBRACKET {
        if (lookup_symbol_current_scope(current_table, $2) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' já foi declarada neste escopo", 
                    contaLinhas, $2);
            yyerror(error_msg);
            YYERROR;
        }
        char *array_type = malloc(strlen($1) + 4);
        sprintf(array_type, "%s[]", $1);
        insert_symbol(current_table, $2, array_type, SYMBOL_VARIABLE, contaLinhas, 1);
        $$ = create_node(AST_VARIABLE_DECLARATION, $2, array_type, contaLinhas);
        $$->children = $4;
        free($1); free($2); free(array_type);
    }
    | TYPEDEF tipo VAR {
        if (lookup_symbol_current_scope(current_table, $3) != NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Typedef '%s' já foi declarado neste escopo", 
                    contaLinhas, $3);
            yyerror(error_msg);
            YYERROR;
        }
        insert_symbol(current_table, $3, $2, SYMBOL_TYPEDEF, contaLinhas, 1);
        $$ = create_node(AST_VARIABLE_DECLARATION, $3, $2, contaLinhas);
        free($2); free($3);
    }
    ;

comando:
    declaracao SEMICOLON { $$ = $1; }
    | atribuicao SEMICOLON { $$ = $1; }
    | expressao SEMICOLON { $$ = $1; }
    | condicao { $$ = $1; }
    | loop { $$ = $1; }
    | switch_statement { $$ = $1; }
    | comando_break { $$ = $1; }
    | comando_continue { $$ = $1; }
    | comando_return { $$ = $1; }
    | bloco { $$ = $1; }
    ;

atribuicao:
    VAR ASSIGN expressao {
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
        $$ = create_node(AST_ASSIGNMENT, $1, NULL, contaLinhas);
        $$->children = $3;
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
        $$ = create_node(AST_ASSIGNMENT, $1, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "+=", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $1, symbol->type, contaLinhas);
        binop->right = $3;
        $$->children = binop;
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
        update_symbol_initialization(current_table, $1);
        $$ = create_node(AST_ASSIGNMENT, $1, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "-=", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $1, symbol->type, contaLinhas);
        binop->right = $3;
        $$->children = binop;
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
        update_symbol_initialization(current_table, $1);
        $$ = create_node(AST_ASSIGNMENT, $1, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "*=", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $1, symbol->type, contaLinhas);
        binop->right = $3;
        $$->children = binop;
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
        update_symbol_initialization(current_table, $1);
        $$ = create_node(AST_ASSIGNMENT, $1, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "/=", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $1, symbol->type, contaLinhas);
        binop->right = $3;
        $$->children = binop;
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
        update_symbol_initialization(current_table, $1);
        $$ = create_node(AST_ASSIGNMENT, $1, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "%=", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $1, symbol->type, contaLinhas);
        binop->right = $3;
        $$->children = binop;
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
        update_symbol_initialization(current_table, $1);
        $$ = create_node(AST_ASSIGNMENT, $1, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "++", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $1, symbol->type, contaLinhas);
        $$->children = binop;
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
        update_symbol_initialization(current_table, $1);
        $$ = create_node(AST_ASSIGNMENT, $1, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "--", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $1, symbol->type, contaLinhas);
        $$->children = binop;
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
        update_symbol_initialization(current_table, $2);
        $$ = create_node(AST_ASSIGNMENT, $2, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "++", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $2, symbol->type, contaLinhas);
        $$->children = binop;
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
        update_symbol_initialization(current_table, $2);
        $$ = create_node(AST_ASSIGNMENT, $2, NULL, contaLinhas);
        ASTNode *binop = create_node(AST_EXPR_BINARY, "--", symbol->type, contaLinhas);
        binop->left = create_node(AST_EXPR_VAR, $2, symbol->type, contaLinhas);
        $$->children = binop;
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
    /* vazio */ { $$ = NULL; }
    | declaracoes_struct declaracao SEMICOLON { $1->next = $2; $$ = $1; }
    ;

lista_enumeradores:
    VAR { $$ = create_node(AST_EXPR_VAR, $1, NULL, contaLinhas); free($1); }
    | lista_enumeradores COMMA VAR { $1->next = create_node(AST_EXPR_VAR, $3, NULL, contaLinhas); $$ = $1; free($3); }
    ;

expressao:
    expressao PLUS expressao {
        if ($1->expr_type && $3->expr_type && strcmp($1->expr_type, $3->expr_type) != 0) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Tipos incompatíveis na soma (%s e %s)", 
                    contaLinhas, $1->expr_type, $3->expr_type);
            yyerror(error_msg);
            YYERROR;
        }
        $$ = create_node(AST_EXPR_BINARY, "+", $1->expr_type ? $1->expr_type : "float", contaLinhas);
        $$->left = $1;
        $$->right = $3;
        $$->expr_value = $1->expr_value + $3->expr_value;
        free($1->expr_type); free($3->expr_type);
    }
    | expressao MINUS expressao {
        $$ = create_node(AST_EXPR_BINARY, "-", $1->expr_type ? $1->expr_type : "float", contaLinhas);
        $$->left = $1;
        $$->right = $3;
        $$->expr_value = $1->expr_value - $3->expr_value;
        free($1->expr_type); free($3->expr_type);
    }
    | expressao TIMES expressao {
        $$ = create_node(AST_EXPR_BINARY, "*", $1->expr_type ? $1->expr_type : "float", contaLinhas);
        $$->left = $1;
        $$->right = $3;
        $$->expr_value = $1->expr_value * $3->expr_value;
        free($1->expr_type); free($3->expr_type);
    }
    | expressao DIVIDE expressao {
        if ($3->expr_value == 0) {
            semantic_error("Divisão por zero");
            YYERROR;
        }
        $$ = create_node(AST_EXPR_BINARY, "/", $1->expr_type ? $1->expr_type : "float", contaLinhas);
        $$->left = $1;
        $$->right = $3;
        $$->expr_value = $1->expr_value / $3->expr_value;
        free($1->expr_type); free($3->expr_type);
    }
    | NUM { 
        $$ = create_node(AST_EXPR_NUM, NULL, "int", contaLinhas);
        $$->expr_value = $1;
        $$->expr_type = strdup("int");
    }
    | FLOAT_NUM { 
        $$ = create_node(AST_EXPR_NUM, NULL, "float", contaLinhas);
        $$->expr_value = $1;
        $$->expr_type = strdup("float");
    }
    | VAR { 
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Erro semântico na linha %d: Variável '%s' não foi declarada", 
                    contaLinhas, $1);
            yyerror(error_msg);
            YYERROR;
        }
        $$ = create_node(AST_EXPR_VAR, $1, symbol->type, contaLinhas);
        $$->expr_type = strdup(symbol->type);
        $$->expr_name = strdup($1);
        free($1);
    }
    | VAR LPAREN argumentos RPAREN { 
        Symbol *symbol = lookup_symbol(current_table, $1);
        if (symbol == NULL) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Aviso na linha %d: Função '%s' não foi declarada", 
                    contaLinhas, $1);
            fprintf(stderr, "%s\n", error_msg);
        }
        $$ = create_node(AST_EXPR_CALL, $1, symbol ? symbol->type : "unknown", contaLinhas);
        $$->children = $3;
        free($1);
    }
    | LPAREN expressao RPAREN { $$ = $2; }
    ;

argumentos:
    /* vazio */ { $$ = NULL; }
    | lista_argumentos { $$ = $1; }
    ;

lista_argumentos:
    expressao { $$ = $1; }
    | lista_argumentos COMMA expressao { $1->next = $3; $$ = $1; }
    ;

condicao:
    IF LPAREN expressao RPAREN bloco %prec IFX {
        $$ = create_node(AST_IF, NULL, NULL, contaLinhas);
        $$->children = $3;
        ASTNode *if_block = create_node(AST_BLOCK, NULL, NULL, contaLinhas);
        if_block->children = $5;
        $$->next = if_block;
    }
    | IF LPAREN expressao RPAREN bloco ELSE bloco {
        $$ = create_node(AST_IF, NULL, NULL, contaLinhas);
        $$->children = $3;
        ASTNode *if_block = create_node(AST_BLOCK, NULL, NULL, contaLinhas);
        if_block->children = $5;
        $$->next = if_block;
        ASTNode *else_block = create_node(AST_ELSE, NULL, NULL, contaLinhas);
        else_block->children = $7;
        if_block->next = else_block;
    }
    ;

bloco:
    LBRACE comandos RBRACE 
    {
        current_table = create_symbol_table(current_table);
        $$ = create_node(AST_BLOCK, NULL, NULL, contaLinhas);
        $$->children = $2;
        print_symbol_table(current_table);
        SymbolTable *temp = current_table;
        current_table = current_table->parent;
        free_symbol_table(temp);
    }
    | LBRACE RBRACE 
    { 
        current_table = create_symbol_table(current_table);
        $$ = create_node(AST_BLOCK, NULL, NULL, contaLinhas);
        SymbolTable *temp = current_table;
        current_table = current_table->parent;
        free_symbol_table(temp);
    }
    ;

switch_statement:
    SWITCH LPAREN expressao RPAREN LBRACE case_list RBRACE {
        $$ = create_node(AST_SWITCH, NULL, NULL, contaLinhas);
        $$->children = $3;
        $$->next = $6;
    }
    ;

case_list:
    /* vazio */ { $$ = NULL; }
    | case_list case_statement { if ($1) $1->next = $2; else $$ = $2; }
    | case_list default_statement { if ($1) $1->next = $2; else $$ = $2; }
    ;

case_statement:
    CASE expressao SEMICOLON comandos {
        $$ = create_node(AST_CASE, NULL, NULL, contaLinhas);
        $$->children = $2;
        $$->next = $4;
    }
    ;

default_statement:
    DEFAULT SEMICOLON comandos {
        $$ = create_node(AST_DEFAULT, NULL, NULL, contaLinhas);
        $$->next = $3;
    }
    ;

comando_break:
    BREAK SEMICOLON { $$ = create_node(AST_BREAK, NULL, NULL, contaLinhas); }
    ;

comando_continue:
    CONTINUE SEMICOLON { $$ = create_node(AST_CONTINUE, NULL, NULL, contaLinhas); }
    ;

comando_return:
    RETURN SEMICOLON { $$ = create_node(AST_RETURN, NULL, "void", contaLinhas); }
    | RETURN expressao SEMICOLON {
        $$ = create_node(AST_RETURN, NULL, $2->expr_type, contaLinhas);
        $$->children = $2;
    }
    ;

loop:
    WHILE LPAREN expressao RPAREN bloco {
        $$ = create_node(AST_WHILE, NULL, NULL, contaLinhas);
        $$->children = $3;
        ASTNode *while_block = create_node(AST_BLOCK, NULL, NULL, contaLinhas);
        while_block->children = $5;
        $$->next = while_block;
    }
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
        if (file) yyin = file;
    }
    
    int result = yyparse();
    
    if (result == 0 && global_table != NULL) {
        printf("=== TABELA DE SÍMBOLOS ===\n");
        print_symbol_table(global_table);
        printf("\n=== ÁRVORE SINTÁTICA ===\n");
        print_ast(ast_root, 0);
    }
    
    if (global_table != NULL) free_symbol_table(global_table);
    if (ast_root != NULL) free_ast(ast_root);
    
    return result;
}