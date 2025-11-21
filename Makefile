EXEC = c_parser

BISON_DIR = parser
FLEX_DIR = lexer
SRC_DIR = src

BISON_FILE = $(BISON_DIR)/parser.y
FLEX_FILE  = $(FLEX_DIR)/lexer.l

BISON_C   = parser.tab.c
BISON_H   = parser.tab.h

FLEX_C    = lex.yy.c

SYMBOL_TABLE_C = $(SRC_DIR)/symbol_table.c
SYMBOL_TABLE_H = $(SRC_DIR)/symbol_table.h
AST_C = $(SRC_DIR)/ast.c
AST_H = $(SRC_DIR)/ast.h
INTERMEDIATE_C = $(SRC_DIR)/intermediate_generator.c
JS_GENERATOR_C = $(SRC_DIR)/js_generator.c
JS_GENERATOR_H = $(SRC_DIR)/js_generator.h

BISON_FLAGS = -d   
FLEX_FLAGS  =      

CC      = gcc
CFLAGS  = -I$(SRC_DIR)
LDFLAGS = -lm -lfl

all: $(EXEC)

$(EXEC): $(BISON_C) $(FLEX_C) $(SYMBOL_TABLE_C) $(AST_C) $(INTERMEDIATE_C) $(JS_GENERATOR_C)
	$(CC) $(CFLAGS) -o $@ $(BISON_C) $(FLEX_C) $(SYMBOL_TABLE_C) $(AST_C) $(INTERMEDIATE_C) $(JS_GENERATOR_C) $(LDFLAGS)

$(BISON_C) $(BISON_H): $(BISON_FILE)
	bison $(BISON_FLAGS) $(BISON_FILE)

$(FLEX_C): $(FLEX_FILE)
	flex $(FLEX_FLAGS) $(FLEX_FILE)

clean:
	rm -rf $(EXEC) $(BISON_C) $(BISON_H) $(FLEX_C) outputs