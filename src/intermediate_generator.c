#include "intermediate_generator.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <math.h>

static int temp_count = 0;
static int label_count = 0;

static char *novaTemp() {
    char buf[32];
    snprintf(buf, sizeof(buf), "t%d", temp_count++);
    return strdup(buf);
}

static char *novoLabel() {
    char buf[32];
    snprintf(buf, sizeof(buf), "L%d", label_count++);
    return strdup(buf);
}

// IR representation
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

static Instr *ir_head = NULL;
static Instr *ir_tail = NULL;

static void ir_clear() {
    Instr *it = ir_head;
    while (it) {
        Instr *nx = it->next;
        free(it->dest);
        free(it->arg1);
        free(it->arg2);
        free(it->op);
        free(it);
        it = nx;
    }
    ir_head = ir_tail = NULL;
}

static Instr* ir_new(InstKind kind, const char *dest, const char *arg1, const char *arg2, const char *op, int aux) {
    Instr *i = (Instr*)calloc(1, sizeof(Instr));
    i->kind = kind;
    i->dest = dest ? strdup(dest) : NULL;
    i->arg1 = arg1 ? strdup(arg1) : NULL;
    i->arg2 = arg2 ? strdup(arg2) : NULL;
    i->op = op ? strdup(op) : NULL;
    i->aux = aux;
    i->next = NULL;
    return i;
}

static void ir_emit(Instr *i) {
    if (!ir_head) ir_head = ir_tail = i;
    else { ir_tail->next = i; ir_tail = i; }
}

// Emit helpers
static void emit_assign(const char *dest, const char *src) { ir_emit(ir_new(INST_ASSIGN, dest, src, NULL, NULL, 0)); }
static void emit_binary(const char *dest, const char *left, const char *op, const char *right) { ir_emit(ir_new(INST_BINARY, dest, left, right, op, 0)); }
static void emit_param(const char *arg) { ir_emit(ir_new(INST_PARAM, NULL, arg, NULL, NULL, 0)); }
static void emit_call(const char *dest, const char *name, int nargs) { ir_emit(ir_new(INST_CALL, dest, NULL, NULL, name, nargs)); }
static void emit_iffalse(const char *cond, const char *label) { ir_emit(ir_new(INST_IFFALSE, NULL, cond, NULL, label, 0)); }
static void emit_iftrue(const char *cond, const char *label) { ir_emit(ir_new(INST_IFTRUE, NULL, cond, NULL, label, 0)); }
static void emit_goto(const char *label) { ir_emit(ir_new(INST_GOTO, NULL, NULL, NULL, label, 0)); }
static void emit_label(const char *label) { ir_emit(ir_new(INST_LABEL, NULL, NULL, NULL, label, 0)); }
static void emit_func_begin(const char *name) { ir_emit(ir_new(INST_FUNC_BEGIN, NULL, NULL, NULL, name, 0)); }
static void emit_func_end(const char *name) { ir_emit(ir_new(INST_FUNC_END, NULL, NULL, NULL, name, 0)); }
static void emit_recv_param(const char *name) { ir_emit(ir_new(INST_RECV_PARAM, NULL, NULL, NULL, name, 0)); }
static void emit_return(const char *arg) { ir_emit(ir_new(INST_RETURN, NULL, arg, NULL, NULL, 0)); }

// utility
static int is_number_str(const char *s, double *out) {
    if (!s) return 0;
    char *end;
    double v = strtod(s, &end);
    if (end == s) return 0;
    while (*end) { if (!isspace((unsigned char)*end)) return 0; end++; }
    if (out) *out = v;
    return 1;
}

// Pass: constant folding (handles INST_BINARY where arg1 and arg2 are numeric)
static void pass_constant_folding() {
    for (Instr *it = ir_head; it; it = it->next) {
        if (it->kind == INST_BINARY) {
            double a,b;
            if (is_number_str(it->arg1, &a) && is_number_str(it->arg2, &b) && it->op) {
                double res = 0;
                int ok = 1;
                if (strcmp(it->op, "+") == 0) res = a + b;
                else if (strcmp(it->op, "-") == 0) res = a - b;
                else if (strcmp(it->op, "*") == 0) res = a * b;
                else if (strcmp(it->op, "/") == 0) { if (b == 0) ok = 0; else res = a / b; }
                else if (strcmp(it->op, "%") == 0) { if (b == 0) ok = 0; else res = fmod(a,b); }
                else ok = 0;
                if (ok) {
                    free(it->arg1); it->arg1 = NULL;
                    free(it->arg2); it->arg2 = NULL;
                    free(it->op); it->op = NULL;
                    it->kind = INST_ASSIGN;
                    char buf[64]; snprintf(buf, sizeof(buf), "%f", res);
                    it->arg1 = strdup(buf);
                }
            } else {
                Symbol *sa = lookup_symbol(global_table, it->arg1);
                if (sa && sa->is_constant) {
                    char buf[64]; snprintf(buf, sizeof(buf), "%f", sa->constant_value);
                    free(it->arg1); it->arg1 = strdup(buf);
                    a = sa->constant_value;
                }
            }
        }
    }
}

// Simple copy propagation: map dest->src for simple assigns, replace uses
typedef struct MapEntry { char *key; char *value; struct MapEntry *next; } MapEntry;
static MapEntry *map_head = NULL;
static void map_clear() { MapEntry *it = map_head; while (it) { MapEntry *nx = it->next; free(it->key); free(it->value); free(it); it = nx; } map_head = NULL; }
static void map_set(const char *k, const char *v) { MapEntry **pp = &map_head; while (*pp) { if (strcmp((*pp)->key, k)==0) { MapEntry *rm = *pp; *pp = rm->next; free(rm->key); free(rm->value); free(rm); break; } pp=&(*pp)->next; } MapEntry *e = calloc(1,sizeof(MapEntry)); e->key = strdup(k); e->value = strdup(v); e->next = map_head; map_head = e; }
static const char* map_resolve(const char *k) { for (MapEntry *it = map_head; it; it = it->next) { if (strcmp(it->key, k) == 0) return it->value; } return NULL; }
static void map_unset(const char *k) { MapEntry **pp = &map_head; while (*pp) { if (strcmp((*pp)->key, k) == 0) { MapEntry *rm = *pp; *pp = rm->next; free(rm->key); free(rm->value); free(rm); return; } pp = &(*pp)->next; } }

static void pass_copy_propagation() {
    map_clear();
    for (Instr *it = ir_head; it; it = it->next) {
        if (it->arg1) { const char *r = map_resolve(it->arg1); if (r) { free(it->arg1); it->arg1 = strdup(r); } }
        if (it->arg2) { const char *r = map_resolve(it->arg2); if (r) { free(it->arg2); it->arg2 = strdup(r); } }
        if (it->kind == INST_ASSIGN && it->dest && it->arg1) {
    map_set(it->dest, it->arg1);
    continue;
}
        if ((it->kind == INST_BINARY || it->kind == INST_CALL || it->kind == INST_ASSIGN) && it->dest) { map_unset(it->dest); }
    }
    map_clear();
}

// Dead code elimination: remove instructions that assign to temporaries (t*) never used
static void pass_dead_code_elimination() {
    typedef struct Use { char *name; int count; struct Use *next; } Use;
    Use *uses = NULL;
    // helper to add
    void use_add(Use **uses_ptr, const char *n) {
        if (!n) return; if (n[0]=='\0') return;
        Use *it = *uses_ptr;
        while (it) { if (strcmp(it->name, n) == 0) { it->count++; return; } it = it->next; }
        Use *e = (Use*)calloc(1, sizeof(Use)); e->name = strdup(n); e->count = 1; e->next = *uses_ptr; *uses_ptr = e;
    }
    for (Instr *it = ir_head; it; it = it->next) { if (it->arg1) use_add(&uses, it->arg1); if (it->arg2) use_add(&uses, it->arg2); }
    Instr **pp = &ir_head;
    while (*pp) {
        Instr *cur = *pp;
        int removable = 0;
        if (cur->dest && cur->dest[0]=='t') {
            int count = 0;
            for (Use *u = uses; u; u = u->next) if (strcmp(u->name, cur->dest) == 0) { count = u->count; break; }
            if (count == 0) {
                if (cur->kind == INST_ASSIGN || cur->kind == INST_BINARY) removable = 1;
            }
        }
        if (removable) {
            *pp = cur->next;
            free(cur->dest); free(cur->arg1); free(cur->arg2); free(cur->op); free(cur);
        } else pp = &(*pp)->next;
    }
    while (uses) { Use *nx = uses->next; free(uses->name); free(uses); uses = nx; }
}

// Emit IR to file
static void ir_emit_to_file(FILE *saida) {
    if (!saida) return;
    fprintf(saida, "; --- Início do Código Intermediário ---\n");
    for (Instr *it = ir_head; it; it = it->next) {
        switch (it->kind) {
            case INST_ASSIGN: fprintf(saida, "  %s = %s\n", it->dest ? it->dest : "", it->arg1 ? it->arg1 : "0"); break;
            case INST_BINARY: fprintf(saida, "  %s = %s %s %s\n", it->dest ? it->dest : "", it->arg1 ? it->arg1 : "", it->op ? it->op : "", it->arg2 ? it->arg2 : ""); break;
            case INST_PARAM: fprintf(saida, "  param %s\n", it->arg1 ? it->arg1 : ""); break;
            case INST_CALL: fprintf(saida, "  %s = call %s, %d\n", it->dest ? it->dest : "", it->op ? it->op : "", it->aux); break;
            case INST_IFFALSE: fprintf(saida, "  ifFalse %s goto %s\n", it->arg1 ? it->arg1 : "", it->op ? it->op : ""); break;
            case INST_IFTRUE: fprintf(saida, "  ifTrue %s goto %s\n", it->arg1 ? it->arg1 : "", it->op ? it->op : ""); break;
            case INST_GOTO: fprintf(saida, "  goto %s\n", it->op ? it->op : ""); break;
            case INST_LABEL: fprintf(saida, "%s:\n", it->op ? it->op : ""); break;
            case INST_FUNC_BEGIN: fprintf(saida, "\nfunc %s\n", it->op ? it->op : ""); break;
            case INST_FUNC_END: fprintf(saida, "end func %s\n", it->op ? it->op : ""); break;
            case INST_RECV_PARAM: fprintf(saida, "  recv_param %s\n", it->op ? it->op : ""); break;
            case INST_RETURN: if (it->arg1) fprintf(saida, "  return %s\n", it->arg1); else fprintf(saida, "  return\n"); break;
        }
    }
    fprintf(saida, "; --- Fim do Código Intermediário ---\n");
}

// Forward declaration
static char* gerarIR_no(ASTNode *no, SymbolTable *escopo, const char *breakLabel, const char *continueLabel);

static char* gerarIR_no(ASTNode *no, SymbolTable *escopo, const char *breakLabel, const char *continueLabel) {
    if (!no) return NULL;
    char *result = NULL;
    ASTNode *proximo_no_lista = no->next;

    switch (no->type) {
        case AST_EXPR_NUM: {
            result = novaTemp();
            char buf[64]; snprintf(buf, sizeof(buf), "%f", no->expr_value);
            emit_assign(result, buf);
            insert_symbol(global_table, result, no->expr_type ? no->expr_type : "float", SYMBOL_VARIABLE, no->line, 1);
            Symbol *st = lookup_symbol(global_table, result);
            if (st) { st->is_constant = 1; st->constant_value = no->expr_value; }
            break;
        }
        case AST_EXPR_VAR: { if (no->value) result = strdup(no->value); break; }
        case AST_EXPR_BINARY: {
            char *left = gerarIR_no(no->left, escopo, breakLabel, continueLabel);
            char *right = gerarIR_no(no->right, escopo, breakLabel, continueLabel);
            result = novaTemp(); emit_binary(result, left ? left : "", no->value ? no->value : "", right ? right : ""); free(left); free(right); break;
        }
        case AST_EXPR_CALL: {
            result = novaTemp(); int arg_count = 0; ASTNode *arg = no->children; char *arg_temps[100];
            while (arg) { arg_temps[arg_count++] = gerarIR_no(arg, escopo, breakLabel, continueLabel); arg = arg->next; }
            for (int i=0;i<arg_count;i++){ emit_param(arg_temps[i]); free(arg_temps[i]); }
            emit_call(result, no->value, arg_count); break;
        }
        case AST_PROGRAM: { gerarIR_no(no->children, escopo, NULL, NULL); break; }
        case AST_FUNCTION_DECLARATION: {
            emit_func_begin(no->value); SymbolTable *func_table = create_symbol_table(escopo); ASTNode *child = no->children; ASTNode *block = NULL;
            while (child) { if (child->type==AST_PARAMETER) { emit_recv_param(child->value); if (child->next && child->next->type==AST_BLOCK){ block=child->next; break;} child = child->next; } else if (child->type==AST_BLOCK) { block=child; break; } else child = child->next; }
            if (block) gerarIR_no(block, func_table, NULL, NULL); emit_func_end(no->value); free_symbol_table(func_table); break;
        }
        case AST_BLOCK: { SymbolTable *novo_escopo = create_symbol_table(escopo); gerarIR_no(no->children, novo_escopo, breakLabel, continueLabel); free_symbol_table(novo_escopo); break; }
        case AST_VARIABLE_DECLARATION: { if (no->children) { char *val = gerarIR_no(no->children, escopo, breakLabel, continueLabel); emit_assign(no->value, val ? val : "0"); free(val); } else { emit_assign(no->value, "0"); } break; }
        case AST_ASSIGNMENT: { char *val = gerarIR_no(no->children, escopo, breakLabel, continueLabel); emit_assign(no->value, val ? val : "0"); free(val); break; }
        case AST_RETURN: { if (no->children) { char *val = gerarIR_no(no->children, escopo, breakLabel, continueLabel); emit_return(val); free(val); } else emit_return(NULL); break; }
        case AST_BREAK: { if (breakLabel) emit_goto(breakLabel); else fprintf(stderr, "Erro linha %d: 'break' fora de loop ou switch.\n", no->line); break; }
        case AST_CONTINUE: { if (continueLabel) emit_goto(continueLabel); else fprintf(stderr, "Erro linha %d: 'continue' fora de loop.\n", no->line); break; }
        case AST_IF: {
            ASTNode *then_block = no->next; ASTNode *else_node = (then_block && then_block->next) ? then_block->next : NULL; char *label_else = novoLabel(); char *label_end = (else_node && else_node->type==AST_ELSE) ? novoLabel() : NULL; char *cond = gerarIR_no(no->children, escopo, breakLabel, continueLabel); emit_iffalse(cond, label_else); free(cond); gerarIR_no(then_block, escopo, breakLabel, continueLabel); if (label_end) { emit_goto(label_end); emit_label(label_else); gerarIR_no(else_node->children, escopo, breakLabel, continueLabel); emit_label(label_end); free(label_end); } else { emit_label(label_else); } free(label_else); proximo_no_lista = no->next; if (proximo_no_lista) proximo_no_lista = proximo_no_lista->next; if (proximo_no_lista && proximo_no_lista->type==AST_ELSE) proximo_no_lista = proximo_no_lista->next; break;
        }
        case AST_WHILE: { char *label_inicio = novoLabel(); char *label_fim = novoLabel(); emit_label(label_inicio); char *cond = gerarIR_no(no->children, escopo, breakLabel, continueLabel); emit_iffalse(cond, label_fim); free(cond); gerarIR_no(no->next, escopo, label_fim, label_inicio); emit_goto(label_inicio); emit_label(label_fim); free(label_inicio); free(label_fim); proximo_no_lista = no->next ? no->next->next : NULL; break; }
        case AST_SWITCH: {
            char *label_end_switch = novoLabel(); char *label_default = NULL; char *switch_val = gerarIR_no(no->children, escopo, breakLabel, continueLabel);
            typedef struct { char *label; ASTNode *node; } CaseEntry; CaseEntry jump_table[100]; int case_count=0; ASTNode *item = no->next;
            while (item) {
                if (item->type == AST_CASE) {
                    char *case_label = novoLabel(); jump_table[case_count].label = case_label; jump_table[case_count].node = item; case_count++; char *case_val = gerarIR_no(item->children, escopo, breakLabel, continueLabel); char *temp_cmp = novaTemp(); emit_binary(temp_cmp, switch_val ? switch_val : "", "==", case_val ? case_val : ""); emit_iftrue(temp_cmp, case_label); free(case_val); free(temp_cmp); item = item->next ? item->next->next : NULL;
                } else if (item->type == AST_DEFAULT) { label_default = novoLabel(); jump_table[case_count].label = label_default; jump_table[case_count].node = item; case_count++; item = item->next ? item->next->next : NULL; } else break; }
            if (label_default) emit_goto(label_default); else emit_goto(label_end_switch);
            for (int i=0;i<case_count;i++) { emit_label(jump_table[i].label); ASTNode *comandos = jump_table[i].node->next; gerarIR_no(comandos, escopo, label_end_switch, continueLabel); free(jump_table[i].label); }
            emit_label(label_end_switch); free(switch_val); free(label_end_switch); if (label_default) free(label_default);
            proximo_no_lista = no->next; while (proximo_no_lista) { if (proximo_no_lista->type==AST_CASE || proximo_no_lista->type==AST_DEFAULT) proximo_no_lista = proximo_no_lista->next ? proximo_no_lista->next->next : NULL; else break; }
            break;
        }
        case AST_PARAMETER: case AST_ELSE: case AST_CASE: case AST_DEFAULT: break;
        default: fprintf(stderr, "Aviso: Tipo de nó AST não suportado para IR: %d\n", no->type); break;
    }

    if (proximo_no_lista) gerarIR_no(proximo_no_lista, escopo, breakLabel, continueLabel);
    return result;
}

void gerar_ir_main(ASTNode *ast_root, SymbolTable *global_table, FILE *saida) {
    if (!ast_root || !saida) return;
    ir_clear(); temp_count = 0; label_count = 0;
    gerarIR_no(ast_root, global_table, NULL, NULL);
    // run passes
    pass_copy_propagation();
    pass_constant_folding();
    pass_dead_code_elimination();
    // emit
    ir_emit_to_file(saida);
    // cleanup
    ir_clear();
}