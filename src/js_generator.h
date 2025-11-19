#ifndef JS_GENERATOR_H
#define JS_GENERATOR_H

#include <stdio.h>

// Forward declaration of Instr
struct Instr;

/**
 * Gera código JavaScript a partir de uma lista encadeada de instruções IR
 * @param ir_head Ponteiro para a primeira instrução IR
 * @param output Arquivo de saída onde o código JavaScript será escrito
 */
void generate_javascript(struct Instr *ir_head, FILE *output);

#endif // JS_GENERATOR_H
