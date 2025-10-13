#ifndef AST_H
#define AST_H

#include "symbol_table.h"

typedef enum {
    AST_PROGRAM, 
    AST_FUNCTION, 
    AST_BLOCK,
    AST_DECL,
    AST_ASSIGN,
    AST_EXPR_BINARY,
    AST_EXPR_VAR,
    AST_EXPR_NUM,
    AST_EXPR_CALL,
    AST_RETURN
} ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;
    char *value; 
    char *data_type;
    int line;
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