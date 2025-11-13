#ifndef AST_H
#define AST_H

#include "symbol_table.h"

typedef enum {
    AST_PROGRAM, 
    AST_FUNCTION_DECLARATION,
    AST_BLOCK,
    AST_VARIABLE_DECLARATION,
    AST_PARAMETER,
    AST_ASSIGNMENT,
    AST_IF,
    AST_ELSE,
    AST_WHILE,
    AST_SWITCH,
    AST_CASE,
    AST_DEFAULT,
    AST_BREAK,
    AST_CONTINUE,
    AST_RETURN,
    AST_EXPR_BINARY,
    AST_EXPR_VAR,
    AST_EXPR_NUM,
    AST_EXPR_CALL
} ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;
    char *value; 
    char *data_type;
    int line;
    // Expressão fields
    float expr_value;
    char *expr_type;
    char *expr_name;
    // Links
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *next;
    struct ASTNode *children;
} ASTNode;

// Funções para criar nós
ASTNode *create_node(ASTNodeType type, char *value, char *data_type, int line);
void free_ast(ASTNode *node);

// Função para imprimir a AST (para depuração)
void print_ast(ASTNode *node, int level);

#endif