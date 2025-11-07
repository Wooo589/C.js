#ifndef GERADOR_IR_H
#define GERADOR_IR_H

#include <stdio.h>
#include "ast.h"
#include "symbol_table.h"

void gerar_ir_main(ASTNode *ast_root, SymbolTable *global_table, FILE *saida);

#endif