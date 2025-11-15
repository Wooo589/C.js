#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

ASTNode *create_node(ASTNodeType type, char *value, char *data_type, int line) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Erro: Falha na alocação de memória para ASTNode\n");
        exit(1);
    }
    node->type = type;
    node->value = value ? strdup(value) : NULL;
    node->data_type = data_type ? strdup(data_type) : NULL;
    node->line = line;
    
    node->expr_value = 0.0;
    node->expr_type = NULL;
    node->expr_name = NULL;
    node->left = NULL;
    node->right = NULL;
    node->next = NULL;
    node->children = NULL;
    return node;
}

void free_ast(ASTNode *node) {
    if (!node) return;
    if (node->value) free(node->value);
    if (node->data_type) free(node->data_type);
    if (node->expr_type) free(node->expr_type);
    if (node->expr_name) free(node->expr_name);
    free_ast(node->left);
    free_ast(node->right);
    free_ast(node->next);
    free_ast(node->children);
    free(node);
}

void print_ast(ASTNode *node, int level) {
    if (!node) return;
    for (int i = 0; i < level; i++) printf("  ");
    const char *type_str;
    switch(node->type) {
        case AST_PROGRAM: type_str = "PROGRAM"; break;
        case AST_FUNCTION_DECLARATION: type_str = "FUNCTION_DECL"; break;
        case AST_BLOCK: type_str = "BLOCK"; break;
        case AST_VARIABLE_DECLARATION: type_str = "VAR_DECL"; break;
        case AST_PARAMETER: type_str = "PARAMETER"; break;
        case AST_ASSIGNMENT: type_str = "ASSIGNMENT"; break;
        case AST_IF: type_str = "IF"; break;
        case AST_ELSE: type_str = "ELSE"; break;
        case AST_WHILE: type_str = "WHILE"; break;
        case AST_FOR: type_str = "FOR"; break;
        case AST_SWITCH: type_str = "SWITCH"; break;
        case AST_CASE: type_str = "CASE"; break;
        case AST_DEFAULT: type_str = "DEFAULT"; break;
        case AST_BREAK: type_str = "BREAK"; break;
        case AST_CONTINUE: type_str = "CONTINUE"; break;
        case AST_RETURN: type_str = "RETURN"; break;
        case AST_EXPR_BINARY: type_str = "BINARY_OP"; break;
        case AST_EXPR_VAR: type_str = "VAR"; break;
        case AST_EXPR_NUM: type_str = "NUM"; break;
        case AST_EXPR_CALL: type_str = "CALL"; break;
        default: type_str = "UNKNOWN"; break;
    }
    printf("Node(%s, value=%s, type=%s, line=%d, expr_value=%.2f, expr_type=%s, expr_name=%s)\n",
           type_str, node->value ? node->value : "null",
           node->data_type ? node->data_type : "null", node->line,
           node->expr_value,
           node->expr_type ? node->expr_type : "null",
           node->expr_name ? node->expr_name : "null");
    print_ast(node->left, level + 1);
    print_ast(node->right, level + 1);
    print_ast(node->children, level + 1);
    print_ast(node->next, level);
}