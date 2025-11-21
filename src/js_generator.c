#include "js_generator.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// Redeclaração das estruturas IR necessárias (mesmo que em intermediate_generator.c)
typedef enum {
    INST_ASSIGN,
    INST_BINARY,
    INST_PARAM,
    INST_CALL,
    INST_IFFALSE,
    INST_IFTRUE,
    INST_GOTO,
    INST_LABEL,
    INST_FUNC_BEGIN,
    INST_FUNC_END,
    INST_RECV_PARAM,
    INST_RETURN
} InstKind;

typedef struct Instr {
    InstKind kind;
    char *dest;
    char *arg1;
    char *arg2;
    char *op;
    int aux;
    struct Instr *next;
} Instr;

// Utilitário: verifica se uma string é um número
static int is_number(const char *s) {
    if (!s || *s == '\0') return 0;
    
    // Ignora espaços iniciais
    while (*s && isspace(*s)) s++;
    if (*s == '\0') return 0;
    
    // Verifica sinal
    if (*s == '+' || *s == '-') s++;
    if (*s == '\0') return 0;
    
    // Deve ter pelo menos um dígito
    int has_digit = 0;
    int has_dot = 0;
    
    while (*s) {
        if (isdigit(*s)) {
            has_digit = 1;
        } else if (*s == '.' && !has_dot) {
            has_dot = 1;
        } else if (isspace(*s)) {
            break;
        } else {
            return 0;
        }
        s++;
    }
    
    // Verifica resto da string
    while (*s) {
        if (!isspace(*s)) return 0;
        s++;
    }
    
    return has_digit;
}

// Utilitário: mapeia operadores do IR para JavaScript
static const char* map_operator(const char *op) {
    if (!op) return "?";
    
    // Operadores compostos precisam ser traduzidos
    if (strcmp(op, "++") == 0) return "+= 1";
    if (strcmp(op, "--") == 0) return "-= 1";
    if (strcmp(op, "+=") == 0) return "+=";
    if (strcmp(op, "-=") == 0) return "-=";
    if (strcmp(op, "*=") == 0) return "*=";
    if (strcmp(op, "/=") == 0) return "/=";
    if (strcmp(op, "%=") == 0) return "%=";
    
    // Operadores padrão
    return op;
}

// Utilitário: converte um valor para formato JavaScript
static void emit_js_value(FILE *out, const char *val) {
    if (!val) {
        fprintf(out, "0");
        return;
    }
    
    // Se for número, emite como está
    if (is_number(val)) {
        fprintf(out, "%s", val);
    } else {
        // Se for variável, emite o nome
        fprintf(out, "%s", val);
    }
}

// Coleta todas as variáveis usadas (exceto temporárias e labels)
typedef struct VarNode {
    char *name;
    struct VarNode *next;
} VarNode;

static VarNode *var_list = NULL;

static void add_variable(const char *name) {
    if (!name || name[0] == '\0') return;
    if (name[0] == 't' && isdigit(name[1])) return; // Ignora temporárias
    if (name[0] == 'L' && isdigit(name[1])) return; // Ignora labels
    if (is_number(name)) return; // Ignora números
    
    // Verifica se já existe
    for (VarNode *v = var_list; v; v = v->next) {
        if (strcmp(v->name, name) == 0) return;
    }
    
    // Adiciona nova variável
    VarNode *new_var = malloc(sizeof(VarNode));
    new_var->name = strdup(name);
    new_var->next = var_list;
    var_list = new_var;
}

static void clear_var_list() {
    VarNode *v = var_list;
    while (v) {
        VarNode *next = v->next;
        free(v->name);
        free(v);
        v = next;
    }
    var_list = NULL;
}

static void collect_variables(Instr *ir_head) {
    for (Instr *it = ir_head; it; it = it->next) {
        if (it->dest) add_variable(it->dest);
        if (it->arg1) add_variable(it->arg1);
        if (it->arg2) add_variable(it->arg2);
    }
}

// Gera declarações de variáveis JavaScript
static void emit_variable_declarations(FILE *out) {
    if (!var_list) return;
    
    fprintf(out, "// Declaração de variáveis\n");
    for (VarNode *v = var_list; v; v = v->next) {
        fprintf(out, "let %s = 0;\n", v->name);
    }
    fprintf(out, "\n");
}

// Estrutura para rastrear parâmetros de chamadas de função
static char *param_stack[128];
static int param_count = 0;

void generate_javascript(Instr *ir_head, FILE *output) {
    if (!ir_head || !output) return;
    
    // Coleta todas as variáveis
    collect_variables(ir_head);
    
    // Cabeçalho do arquivo JavaScript
    fprintf(output, "// Código JavaScript gerado automaticamente\n");
    fprintf(output, "// do compilador C para JavaScript\n\n");
    
    int in_function = 0;
    int need_main = 0;
    char *current_function = NULL;
    
    // Primeira passagem: detecta se precisamos de código top-level
    for (Instr *it = ir_head; it; it = it->next) {
        if (it->kind == INST_FUNC_BEGIN) {
            in_function = 1;
        } else if (it->kind == INST_FUNC_END) {
            in_function = 0;
        } else if (!in_function) {
            if (it->kind == INST_ASSIGN || it->kind == INST_BINARY || 
                it->kind == INST_CALL || it->kind == INST_LABEL) {
                need_main = 1;
                break;
            }
        }
    }
    
    // Emite declarações de variáveis globais (apenas se houver código top-level)
    if (need_main) {
        emit_variable_declarations(output);
    }
    
    in_function = 0;
    int func_param_count = 0;
    char *func_params[32];
    
    // Segunda passagem: gera o código
    for (Instr *it = ir_head; it; it = it->next) {
        switch (it->kind) {
            case INST_FUNC_BEGIN:
                in_function = 1;
                func_param_count = 0;
                if (current_function) free(current_function);
                current_function = it->op ? strdup(it->op) : strdup("func");
                
                // Não emitimos a declaração de função ainda, esperamos coletar os parâmetros
                break;
                
            case INST_RECV_PARAM:
                // Coleta parâmetros da função
                if (func_param_count < 32 && it->op) {
                    func_params[func_param_count++] = it->op;
                }
                
                // Se a próxima instrução não for RECV_PARAM, emitimos a declaração da função
                if (!it->next || it->next->kind != INST_RECV_PARAM) {
                    fprintf(output, "function %s(", current_function);
                    for (int i = 0; i < func_param_count; i++) {
                        fprintf(output, "%s", func_params[i]);
                        if (i < func_param_count - 1) fprintf(output, ", ");
                    }
                    fprintf(output, ") {\n");
                    
                    // Declarações de variáveis locais (temporárias e outras)
                    // Coleta todas as variáveis locais na função
                    char *local_vars[256];
                    int local_var_count = 0;
                    
                    for (Instr *scan = it->next; scan && scan->kind != INST_FUNC_END; scan = scan->next) {
                        // Adiciona dest se for uma variável local (não é parâmetro)
                        if (scan->dest && scan->dest[0] != '\0') {
                            int is_param = 0;
                            for (int p = 0; p < func_param_count; p++) {
                                if (func_params[p] && strcmp(scan->dest, func_params[p]) == 0) {
                                    is_param = 1;
                                    break;
                                }
                            }
                            
                            if (!is_param && !is_number(scan->dest)) {
                                // Verifica se já foi adicionada
                                int already_added = 0;
                                for (int v = 0; v < local_var_count; v++) {
                                    if (local_vars[v] && strcmp(local_vars[v], scan->dest) == 0) {
                                        already_added = 1;
                                        break;
                                    }
                                }
                                
                                if (!already_added && local_var_count < 256) {
                                    local_vars[local_var_count++] = scan->dest;
                                }
                            }
                        }
                    }
                    
                    // Emite declarações de variáveis locais
                    if (local_var_count > 0) {
                        fprintf(output, "  let ");
                        for (int v = 0; v < local_var_count; v++) {
                            if (local_vars[v]) {
                                fprintf(output, "%s", local_vars[v]);
                                if (v < local_var_count - 1) fprintf(output, ", ");
                            }
                        }
                        fprintf(output, ";\n");
                    }
                }
                break;
                
            case INST_FUNC_END:
                fprintf(output, "}\n\n");
                in_function = 0;
                func_param_count = 0;
                break;
                
            case INST_ASSIGN:
                if (in_function) {
                    fprintf(output, "  %s = ", it->dest ? it->dest : "_");
                    emit_js_value(output, it->arg1);
                    fprintf(output, ";\n");
                } else {
                    fprintf(output, "%s = ", it->dest ? it->dest : "_");
                    emit_js_value(output, it->arg1);
                    fprintf(output, ";\n");
                }
                break;
                
            case INST_BINARY: {
                const char *js_op = map_operator(it->op);
                
                // Verifica se é um operador composto (++, --)
                if (strcmp(it->op, "++") == 0 || strcmp(it->op, "--") == 0) {
                    if (in_function) {
                        fprintf(output, "  %s%s;\n", it->arg1 ? it->arg1 : it->dest, it->op);
                    } else {
                        fprintf(output, "%s%s;\n", it->arg1 ? it->arg1 : it->dest, it->op);
                    }
                } else if (strstr(js_op, "=") && strlen(js_op) == 2) {
                    // Operador composto (+=, -=, etc.)
                    if (in_function) {
                        fprintf(output, "  %s %s ", it->dest ? it->dest : "_", js_op);
                        emit_js_value(output, it->arg2);
                        fprintf(output, ";\n");
                    } else {
                        fprintf(output, "%s %s ", it->dest ? it->dest : "_", js_op);
                        emit_js_value(output, it->arg2);
                        fprintf(output, ";\n");
                    }
                } else {
                    // Operador binário normal
                    if (in_function) {
                        fprintf(output, "  %s = ", it->dest ? it->dest : "_");
                    } else {
                        fprintf(output, "%s = ", it->dest ? it->dest : "_");
                    }
                    emit_js_value(output, it->arg1);
                    fprintf(output, " %s ", js_op);
                    emit_js_value(output, it->arg2);
                    fprintf(output, ";\n");
                }
                break;
            }
                
            case INST_PARAM:
                // Acumula parâmetros para a próxima chamada
                if (param_count < 128) {
                    param_stack[param_count++] = it->arg1 ? strdup(it->arg1) : strdup("0");
                }
                break;
                
            case INST_CALL: {
                if (in_function) {
                    fprintf(output, "  %s = %s(", it->dest ? it->dest : "_", it->op ? it->op : "func");
                } else {
                    fprintf(output, "%s = %s(", it->dest ? it->dest : "_", it->op ? it->op : "func");
                }
                
                // Emite os argumentos acumulados
                for (int i = 0; i < param_count; i++) {
                    emit_js_value(output, param_stack[i]);
                    if (i < param_count - 1) fprintf(output, ", ");
                    free(param_stack[i]);
                }
                fprintf(output, ");\n");
                param_count = 0;
                break;
            }
                
            case INST_LABEL:
                // JavaScript suporta labels, mas apenas para break/continue
                // Usamos comentário para marcar o label
                if (in_function) {
                    fprintf(output, "  // %s:\n", it->op ? it->op : "label");
                } else {
                    fprintf(output, "// %s:\n", it->op ? it->op : "label");
                }
                break;
                
            case INST_GOTO:
                // JavaScript não tem goto nativo
                // Podemos simular com throw/catch ou reestruturar com loops
                if (in_function) {
                    fprintf(output, "  // goto %s (não suportado diretamente em JS)\n", it->op ? it->op : "label");
                } else {
                    fprintf(output, "// goto %s (não suportado diretamente em JS)\n", it->op ? it->op : "label");
                }
                break;
                
            case INST_IFFALSE:
                if (in_function) {
                    fprintf(output, "  if (!(");
                    emit_js_value(output, it->arg1);
                    fprintf(output, ")) {\n");
                    fprintf(output, "    // goto %s\n", it->op ? it->op : "label");
                    fprintf(output, "  }\n");
                } else {
                    fprintf(output, "if (!(");
                    emit_js_value(output, it->arg1);
                    fprintf(output, ")) {\n");
                    fprintf(output, "  // goto %s\n", it->op ? it->op : "label");
                    fprintf(output, "}\n");
                }
                break;
                
            case INST_IFTRUE:
                if (in_function) {
                    fprintf(output, "  if (");
                    emit_js_value(output, it->arg1);
                    fprintf(output, ") {\n");
                    fprintf(output, "    // goto %s\n", it->op ? it->op : "label");
                    fprintf(output, "  }\n");
                } else {
                    fprintf(output, "if (");
                    emit_js_value(output, it->arg1);
                    fprintf(output, ") {\n");
                    fprintf(output, "  // goto %s\n", it->op ? it->op : "label");
                    fprintf(output, "}\n");
                }
                break;
                
            case INST_RETURN:
                if (it->arg1) {
                    fprintf(output, "  return ");
                    emit_js_value(output, it->arg1);
                    fprintf(output, ";\n");
                } else {
                    fprintf(output, "  return;\n");
                }
                break;
                
            default:
                fprintf(output, "  // Instrução não suportada: %d\n", it->kind);
                break;
        }
    }
    
    // Emite código top-level se necessário
    if (need_main) {
        fprintf(output, "// Código principal\n");
    }
    
    // Cleanup
    if (current_function) free(current_function);
    clear_var_list();
}
