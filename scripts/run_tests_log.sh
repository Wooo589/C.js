#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

TEST_DIR="tests"
COMPILER_EXEC="./c_parser"
PASSED=0
FAILED=0
TOTAL=0

echo -e "${WHITE}================ EXECUTANDO TESTES COM GERAÇÃO+EXECUÇÃO ================${NC}"
make -B > /dev/null 2>&1 || exit 1


if [ $# -eq 1 ]; then
    TEST_FILES=("$1")
else
    TEST_FILES=($(find "$TEST_DIR" -name "*.txt" | sort))
fi

for test_file in "${TEST_FILES[@]}"; do
    ((TOTAL++))
    name=$(basename "${test_file%.txt}")
    rel_path="${test_file#tests/}"
    rel_path="${rel_path%.txt}"
    display_name="${rel_path:-$name}"

    echo -e "${CYAN}Testando:${NC} $display_name"

    expected_out="tests/$rel_path.expected.out"
    expected_err="tests/$rel_path.expected.err"

    # --- Roda o parser (já gera .ir + .c + tenta compilar) ---
    export TEST_INPUT="$test_file"
    timeout 10s $COMPILER_EXEC < "$test_file" > /dev/null 2> /dev/null
    parser_status=$?

    # Caminho base que o seu código já define via OUTPUT_BASE
    base_path="outputs/$rel_path"

    c_file="$base_path.c"
    exec_file="$base_path"        # gcc gera executável sem extensão
    compile_err="$base_path.compile.err"

    # =================================================================
    # Caso 1: Teste de erro esperado (sintático/semântico)
    # =================================================================
    if [ -f "$expected_err" ]; then
        if [ $parser_status -ne 0 ]; then
            # Parser falhou como esperado → sucesso
            echo -e "  └─ ${GREEN}[PASS]${NC} Erro esperado detectado."
            ((PASSED++))
        else
            echo -e "  └─ ${RED}[FAIL]${NC} Deveria ter falhado, mas passou."
            ((FAILED++))
        fi
        echo
        continue
    fi

    # =================================================================
    # Caso 2: Teste de sucesso → queremos saída correta
    # =================================================================
    if [ ! -f "$expected_out" ]; then
        echo -e "  └─ ${YELLOW}[SKIP]${NC} Sem .expected.out → pulando execução"
        echo
        continue
    fi

    # Verifica se o .c foi gerado
    if [ ! -f "$c_file" ]; then
        echo -e "  └─ ${RED}[FAIL]${NC} Código final não foi gerado ($c_file ausente)"
        ((FAILED++))
        echo
        continue
    fi

    # Se ainda não compilou (ou compilou com erro), força recompilar com feedback
    if [ ! -f "$exec_file" ] || [ -s "$compile_err" ]; then
        echo -e "  ${YELLOW}Compilando código gerado...${NC}"
        gcc -O2 -std=c99 -lm -o "$exec_file" "$c_file" 2> "$compile_err"
        gcc_status=$?
        if [ $gcc_status -ne 0 ]; then
            echo -e "  └─ ${RED}[FAIL]${NC} Falha na compilação do código gerado"
            echo -e "     $(cat "$compile_err" | sed 's/^/     │ /')"
            ((FAILED++))
            echo
            continue
        fi
    fi

    # Executa o binário gerado
    actual_out=$(mktemp)
    actual_exec_err=$(mktemp)
    timeout 5s "$exec_file" > "$actual_out" 2> "$actual_exec_err"
    exec_status=$?

    if [ $exec_status -eq 124 ]; then
        echo -e "  └─ ${RED}[FAIL]${NC} Timeout na execução"
        ((FAILED++))
    elif [ $exec_status -ne 0 ]; then
        echo -e "  └─ ${RED}[FAIL]${NC} Programa travou/segfaultou (status $exec_status)"
        ((FAILED++))
    else
        # Compara saída
        if diff -u --strip-trailing-cr "$expected_out" "$actual_out" > /dev/null; then
            echo -e "  └─ ${GREEN}[PASS]${NC} Saída correta!"
            ((PASSED++))
        else
            echo -e "  └─ ${RED}[FAIL]${NC} Saída incorreta"
            echo -e "     ${YELLOW}Esperado:${NC}"
            sed 's/^/     │  /' "$expected_out"
            echo -e "     ${RED}Recebido:${NC}"
            sed 's/^/     │  /' "$actual_out"
            ((FAILED++))
        fi
    fi

    rm -f "$actual_out" "$actual_exec_err"
    echo
done

echo -e "${WHITE}==================== RELATÓRIO FINAL ====================${NC}"
echo -e "Total : $TOTAL"
echo -e "${GREEN}Passaram : $PASSED${NC}"
echo -e "${RED}Falharam : $FAILED${NC}"
echo -e "${WHITE}=========================================================${NC}"

(( FAILED > 0 )) && exit 1
exit 0