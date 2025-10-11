#include "symbol_table.h"

// Criar uma nova tabela de símbolos
SymbolTable* create_symbol_table(SymbolTable *parent) {
    SymbolTable *table = (SymbolTable*)malloc(sizeof(SymbolTable));
    if (!table) {
        fprintf(stderr, "Erro: Falha ao alocar memória para tabela de símbolos\n");
        exit(1);
    }
    
    // Inicializar todas as entradas como NULL
    for (int i = 0; i < TABLE_SIZE; i++) {
        table->table[i] = NULL;
    }
    
    table->parent = parent;
    return table;
}

// Liberar memória da tabela de símbolos
void free_symbol_table(SymbolTable *table) {
    if (!table) return;
    
    // Liberar cada símbolo na tabela
    for (int i = 0; i < TABLE_SIZE; i++) {
        Symbol *current = table->table[i];
        while (current) {
            Symbol *temp = current;
            current = current->next;
            free(temp->name);
            free(temp->type);
            free(temp);
        }
    }
    
    free(table);
}

// Função hash simples mas eficiente (djb2)
unsigned int hash_function(const char *name) {
    unsigned long hash = 5381;
    int c;
    
    while ((c = *name++)) {
        hash = ((hash << 5) + hash) + c; // hash * 33 + c
    }
    
    return hash % TABLE_SIZE;
}

// Inserir um novo símbolo na tabela
int insert_symbol(SymbolTable *table, const char *name, const char *type, 
                  SymbolType symbol_type, int line, int initialized) {
    if (!table || !name || !type) {
        return -1;
    }
    
    // Verificar se já existe no escopo atual
    if (lookup_symbol_current_scope(table, name) != NULL) {
        return -1;  // Símbolo já existe
    }
    
    // Calcular o índice hash
    unsigned int index = hash_function(name);
    
    // Criar novo símbolo
    Symbol *new_symbol = (Symbol*)malloc(sizeof(Symbol));
    if (!new_symbol) {
        fprintf(stderr, "Erro: Falha ao alocar memória para símbolo\n");
        exit(1);
    }
    
    new_symbol->name = strdup(name);
    new_symbol->type = strdup(type);
    new_symbol->symbol_type = symbol_type;
    new_symbol->line = line;
    new_symbol->initialized = initialized;
    
    // Inserir no início da lista encadeada (tratamento de colisões)
    new_symbol->next = table->table[index];
    table->table[index] = new_symbol;
    
    return 0;  // Sucesso
}

// Buscar um símbolo na tabela (procura no escopo atual e pais)
Symbol* lookup_symbol(SymbolTable *table, const char *name) {
    if (!table || !name) {
        return NULL;
    }
    
    unsigned int index = hash_function(name);
    
    // Procurar no escopo atual
    Symbol *current = table->table[index];
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    
    // Se não encontrou, procurar nos escopos pais
    if (table->parent) {
        return lookup_symbol(table->parent, name);
    }
    
    return NULL;  // Não encontrado
}

// Buscar um símbolo apenas no escopo atual
Symbol* lookup_symbol_current_scope(SymbolTable *table, const char *name) {
    if (!table || !name) {
        return NULL;
    }
    
    unsigned int index = hash_function(name);
    
    Symbol *current = table->table[index];
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    
    return NULL;  // Não encontrado no escopo atual
}

// Atualizar o flag de inicialização de uma variável
int update_symbol_initialization(SymbolTable *table, const char *name) {
    Symbol *symbol = lookup_symbol(table, name);
    if (symbol) {
        symbol->initialized = 1;
        return 0;
    }
    return -1;
}

// Imprimir a tabela de símbolos (para debug)
void print_symbol_table(SymbolTable *table) {
    if (!table) return;
    
    printf("\n===== Tabela de Símbolos =====\n");
    printf("%-20s %-15s %-15s %-10s %-10s\n", 
           "Nome", "Tipo", "Categoria", "Linha", "Inicializado");
    printf("----------------------------------------------------------------------\n");
    
    for (int i = 0; i < TABLE_SIZE; i++) {
        Symbol *current = table->table[i];
        while (current) {
            const char *category;
            switch (current->symbol_type) {
                case SYMBOL_VARIABLE:
                    category = "Variável";
                    break;
                case SYMBOL_FUNCTION:
                    category = "Função";
                    break;
                case SYMBOL_PARAMETER:
                    category = "Parâmetro";
                    break;
                case SYMBOL_TYPEDEF:
                    category = "Typedef";
                    break;
                default:
                    category = "Desconhecido";
            }
            
            printf("%-20s %-15s %-15s %-10d %-10s\n",
                   current->name,
                   current->type,
                   category,
                   current->line,
                   current->initialized ? "Sim" : "Não");
            
            current = current->next;
        }
    }
    
    printf("===============================\n\n");
}
