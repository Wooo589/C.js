#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_SIZE 211  // Número primo para melhor distribuição no hash

// Tipos de símbolos que podem ser armazenados
typedef enum {
    SYMBOL_VARIABLE,
    SYMBOL_FUNCTION,
    SYMBOL_PARAMETER,
    SYMBOL_TYPEDEF
} SymbolType;

// Estrutura para representar um símbolo
typedef struct Symbol {
    char *name;              // Nome do identificador
    char *type;              // Tipo (int, float, char, etc.)
    SymbolType symbol_type;  // Tipo do símbolo (variável, função, etc.)
    int line;                // Linha onde foi declarado
    int initialized;         // Flag para verificar se foi inicializado
    int is_constant;         // Para verificar se é uma constante
    double constant_value;   // Valor da constante
    struct Symbol *next;     // Para tratar colisões (encadeamento)
} Symbol;

// Estrutura da tabela de símbolos (hash table)
typedef struct SymbolTable {
    Symbol *table[TABLE_SIZE];
    struct SymbolTable *parent;  // Para suportar escopos aninhados
} SymbolTable;

// Funções de gerenciamento da tabela de símbolos

// Criar uma nova tabela de símbolos
SymbolTable* create_symbol_table(SymbolTable *parent);

// Liberar memória da tabela de símbolos
void free_symbol_table(SymbolTable *table);

// Função hash para distribuir símbolos
unsigned int hash_function(const char *name);

// Inserir um novo símbolo na tabela
// Retorna 0 em caso de sucesso, -1 se já existir
int insert_symbol(SymbolTable *table, const char *name, const char *type, 
                  SymbolType symbol_type, int line, int initialized);

// Buscar um símbolo na tabela (procura no escopo atual e pais)
Symbol* lookup_symbol(SymbolTable *table, const char *name);

// Buscar um símbolo apenas no escopo atual
Symbol* lookup_symbol_current_scope(SymbolTable *table, const char *name);

// Imprimir a tabela de símbolos (para debug)
void print_symbol_table(SymbolTable *table);

// Atualizar o flag de inicialização de uma variável
int update_symbol_initialization(SymbolTable *table, const char *name);

extern SymbolTable *global_table;
#endif // SYMBOL_TABLE_H
