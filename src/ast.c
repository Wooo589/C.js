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
    free_ast(node->left);
    free_ast(node->right);
    free_ast(node->next);
    free_ast(node->children);
    free(node);
}

void print_ast(ASTNode *node, int level) {
    if (!node) return;
    for (int i = 0; i < level; i++) printf("  ");
    printf("Node(type=%d, value=%s, data_type=%s, line=%d)\n",
           node->type, node->value ? node->value : "null",
           node->data_type ? node->data_type : "null", node->line);
    print_ast(node->left, level + 1);
    print_ast(node->right, level + 1);
    print_ast(node->children, level + 1);
    print_ast(node->next, level);
}