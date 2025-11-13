#include "intermediate_generator.h"
#include <stdlib.h>
#include <string.h>

static int temp_count = 0;
static int label_count = 0;


static char *novaTemp() {
    char *temp = (char *)malloc(16);
    if (!temp) {
        fprintf(stderr, "Erro fatal: falha ao alocar memória para temporário.\n");
        exit(1);
    }
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

static char *novoLabel() {
    char *label = (char *)malloc(16);
    if (!label) {
        fprintf(stderr, "Erro fatal: falha ao alocar memória para rótulo.\n");
        exit(1);
    }
    sprintf(label, "L%d", label_count++);
    return label;
}


static char* gerarIR_no(ASTNode *no, FILE *saida, SymbolTable *escopo, 
                        const char *breakLabel, const char *continueLabel) {
    
    if (no == NULL) return NULL;

    char *result = NULL;
    ASTNode *proximo_no_lista = no->next;

    switch (no->type) {
        
        case AST_EXPR_NUM: {
            result = novaTemp();
            fprintf(saida, "  %s = %f\n", result, no->expr_value);
            break;
        }

        case AST_EXPR_VAR: {
            if (no->value) result = strdup(no->value);
            else result = NULL;
            break;
        }

        case AST_EXPR_BINARY: {
            char *left = gerarIR_no(no->left, saida, escopo, breakLabel, continueLabel);
            char *right = gerarIR_no(no->right, saida, escopo, breakLabel, continueLabel);
            result = novaTemp();
            fprintf(saida, "  %s = %s %s %s\n", result, left, no->value, right);
            free(left);
            free(right);
            break;
        }

        case AST_EXPR_CALL: {
            result = novaTemp();
            int arg_count = 0;
            ASTNode *arg = no->children;
            
            char *arg_temps[100];
            while(arg) {
                arg_temps[arg_count] = gerarIR_no(arg, saida, escopo, breakLabel, continueLabel);
                arg_count++;
                arg = arg->next;
            }
            
            for (int i = 0; i < arg_count; i++) {
                fprintf(saida, "  param %s\n", arg_temps[i]);
                free(arg_temps[i]);
            }
            
            fprintf(saida, "  %s = call %s, %d\n", result, no->value, arg_count);
            break;
        }

        case AST_PROGRAM: {
            gerarIR_no(no->children, saida, escopo, NULL, NULL);
            break;
        }

        case AST_FUNCTION_DECLARATION: {
            fprintf(saida, "\nfunc %s\n", no->value);
            SymbolTable *func_table = create_symbol_table(escopo);
            ASTNode *child = no->children;
            ASTNode *block = NULL;

            while (child) {
                if (child->type == AST_PARAMETER) {
                    fprintf(saida, "  recv_param %s\n", child->value);
                    if (child->next && child->next->type == AST_BLOCK) {
                        block = child->next;
                        break;
                    }
                    child = child->next;
                } else if (child->type == AST_BLOCK) {
                    block = child;
                    break;
                } else {
                    child = child->next; 
                }
            }
            
            if (block) {
                gerarIR_no(block, saida, func_table, NULL, NULL);
            }
            
            fprintf(saida, "end func %s\n", no->value);
            free_symbol_table(func_table);
            
            break;
        }
        
        case AST_BLOCK: {
            SymbolTable *novo_escopo = create_symbol_table(escopo);
            gerarIR_no(no->children, saida, novo_escopo, breakLabel, continueLabel);
            free_symbol_table(novo_escopo);
            break;
        }

        case AST_VARIABLE_DECLARATION: {
            if (no->children) {
                char *val = gerarIR_no(no->children, saida, escopo, breakLabel, continueLabel);
                fprintf(saida, "  %s = %s\n", no->value, val);
                free(val);
            } else {
                fprintf(saida, "  %s = 0\n", no->value);
            }
            break;
        }

        case AST_ASSIGNMENT: {
            char *val = gerarIR_no(no->children, saida, escopo, breakLabel, continueLabel);
            fprintf(saida, "  %s = %s\n", no->value, val);
            free(val);
            break;
        }

        case AST_RETURN: {
            if (no->children) {
                char *val = gerarIR_no(no->children, saida, escopo, breakLabel, continueLabel);
                fprintf(saida, "  return %s\n", val);
                free(val);
            } else {
                fprintf(saida, "  return\n");
            }
            break;
        }

        case AST_BREAK: {
            if (breakLabel) {
                fprintf(saida, "  goto %s\n", breakLabel);
            } else {
                fprintf(stderr, "Erro linha %d: 'break' fora de loop ou switch.\n", no->line);
            }
            break;
        }

        case AST_CONTINUE: {
            if (continueLabel) {
                fprintf(saida, "  goto %s\n", continueLabel);
            } else {
                fprintf(stderr, "Erro linha %d: 'continue' fora de loop.\n", no->line);
            }
            break;
        }

        case AST_IF: {
            ASTNode *then_block = no->next;
            ASTNode *else_node = (then_block && then_block->next) ? then_block->next : NULL;
            
            char *label_else = novoLabel();
            char *label_end = (else_node && else_node->type == AST_ELSE) ? novoLabel() : NULL;

            char *cond = gerarIR_no(no->children, saida, escopo, breakLabel, continueLabel);
            fprintf(saida, "  ifFalse %s goto %s\n", cond, label_else);
            free(cond);

            gerarIR_no(then_block, saida, escopo, breakLabel, continueLabel);

            if (label_end) {
                fprintf(saida, "  goto %s\n", label_end);
                fprintf(saida, "%s:\n", label_else);

                gerarIR_no(else_node->children, saida, escopo, breakLabel, continueLabel);
                fprintf(saida, "%s:\n", label_end);
                free(label_end);
            } else {
                fprintf(saida, "%s:\n", label_else);
            }
            free(label_else);
            
            proximo_no_lista = no->next;
            if (proximo_no_lista) proximo_no_lista = proximo_no_lista->next;
            if (proximo_no_lista && proximo_no_lista->type == AST_ELSE) {
                proximo_no_lista = proximo_no_lista->next;
            }
            break;
        }

        case AST_WHILE: {
            char *label_inicio = novoLabel();
            char *label_fim = novoLabel();
            
            fprintf(saida, "%s:\n", label_inicio);
            
            char *cond = gerarIR_no(no->children, saida, escopo, breakLabel, continueLabel);
            fprintf(saida, "  ifFalse %s goto %s\n", cond, label_fim);
            free(cond);

            gerarIR_no(no->next, saida, escopo, label_fim, label_inicio);
            
            fprintf(saida, "  goto %s\n", label_inicio);
            fprintf(saida, "%s:\n", label_fim);
            
            free(label_inicio);
            free(label_fim);

            proximo_no_lista = no->next ? no->next->next : NULL;
            break;
        }

        case AST_SWITCH: {
            char *label_end_switch = novoLabel();
            char *label_default = NULL;
            
            char *switch_val = gerarIR_no(no->children, saida, escopo, breakLabel, continueLabel);

            typedef struct { char *label; ASTNode *node; } CaseEntry;
            CaseEntry jump_table[100];
            int case_count = 0;
            
            ASTNode *item = no->next;
            while (item) {
                if (item->type == AST_CASE) {
                    char *case_label = novoLabel();
                    jump_table[case_count].label = case_label;
                    jump_table[case_count].node = item;
                    case_count++;

                    char *case_val = gerarIR_no(item->children, saida, escopo, breakLabel, continueLabel);
                    char *temp_cmp = novaTemp();
                    fprintf(saida, "  %s = %s == %s\n", temp_cmp, switch_val, case_val);
                    fprintf(saida, "  ifTrue %s goto %s\n", temp_cmp, case_label);
                    free(case_val);
                    free(temp_cmp);
                    
                    item = item->next ? item->next->next : NULL;
                
                } else if (item->type == AST_DEFAULT) {
                    label_default = novoLabel();
                    jump_table[case_count].label = label_default;
                    jump_table[case_count].node = item;
                    case_count++;
                    
                    item = item->next ? item->next->next : NULL;

                } else {
                    break;
                }
            }

            if (label_default) {
                fprintf(saida, "  goto %s\n", label_default);
            } else {
                fprintf(saida, "  goto %s\n", label_end_switch);
            }

            for (int i = 0; i < case_count; i++) {
                fprintf(saida, "%s:\n", jump_table[i].label);
                ASTNode *comandos = jump_table[i].node->next;
                
                gerarIR_no(comandos, saida, escopo, label_end_switch, continueLabel); 
                
                free(jump_table[i].label);
            }

            fprintf(saida, "%s:\n", label_end_switch);
            free(switch_val);
            free(label_end_switch);
            if (label_default) free(label_default);

            proximo_no_lista = no->next;
            while (proximo_no_lista) {
                if (proximo_no_lista->type == AST_CASE || proximo_no_lista->type == AST_DEFAULT) {
                    proximo_no_lista = proximo_no_lista->next ? proximo_no_lista->next->next : NULL;
                } else {
                    break;
                }
            }
            break;
        }

        case AST_PARAMETER:
        case AST_ELSE:
        case AST_CASE:
        case AST_DEFAULT:
            break;
        
        default:
            fprintf(stderr, "Aviso: Tipo de nó AST não suportado para IR: %d\n", no->type);
            break;
    }

    if (proximo_no_lista) {
        gerarIR_no(proximo_no_lista, saida, escopo, breakLabel, continueLabel);
    }
    
    return result;
}

void gerar_ir_main(ASTNode *ast_root, SymbolTable *global_table, FILE *saida) {
    if (!ast_root || !saida) return;
    
    fprintf(saida, "; --- Início do Código Intermediário ---\n");
    
    gerarIR_no(ast_root, saida, global_table, NULL, NULL);
    
    fprintf(saida, "; --- Fim do Código Intermediário ---\n");
}