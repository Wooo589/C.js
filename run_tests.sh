#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

TEST_DIR="tests"
COMPILER_EXEC="./a.out"
PASSED_COUNT=0
FAILED_COUNT=0
TOTAL_TESTS=0

echo -e "${WHITE}================ EXECUTANDO TESTES ================${NC}"
make > /dev/null 2>&1

if [ $# -eq 1 ]; then
    SINGLE_TEST="$1"
    if [ ! -f "$SINGLE_TEST" ]; then
        echo -e "${RED}Arquivo de teste não encontrado:${NC} $SINGLE_TEST"
        exit 1
    fi
    TEST_FILES=("$SINGLE_TEST")
else
    TEST_FILES=($(find ${TEST_DIR} -name "*.txt"))
fi

for test_file in "${TEST_FILES[@]}"; do
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    display_name=${test_file#"$TEST_DIR/"}
    echo -e "${CYAN}Testando:${NC} $display_name"

    full_base_name="${test_file%.txt}"
    expected_err_file="${full_base_name}.expected.err"
    expected_out_file="${full_base_name}.expected.out"
    
    actual_out_file=$(mktemp)
    actual_err_file=$(mktemp)

    $COMPILER_EXEC < "$test_file" > "$actual_out_file" 2> "$actual_err_file"
    status=$?

    if [ -f "$expected_err_file" ]; then
        if [ $status -ne 0 ]; then
            diff_output=$(diff -u --strip-trailing-cr "$expected_err_file" "$actual_err_file")
            if [ -z "$diff_output" ]; then
                echo -e "  └─ ${GREEN}[PASS]${NC} O programa falhou como esperado."
                PASSED_COUNT=$((PASSED_COUNT + 1))
            else
                echo -e "  └─ ${RED}[FAIL]${NC} A mensagem de erro não é a esperada."
                echo -e "     ├─ ${YELLOW}Esperado:${NC}"
                sed 's/^/     │  /' "$expected_err_file"
                echo -e "     ├─ ${RED}Recebido:${NC}"
                sed 's/^/     │  /' "$actual_err_file"
                echo -e "     └─"
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        else
            echo -e "  └─ ${RED}[FAIL]${NC} O programa deveria falhar, mas passou (exit code 0)."
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi

    elif [ -f "$expected_out_file" ]; then
        if [ $status -eq 0 ]; then
            diff_output=$(diff -u --strip-trailing-cr "$expected_out_file" "$actual_out_file")
            if [ -z "$diff_output" ]; then
                 echo -e "  └─ ${GREEN}[PASS]${NC} O programa passou e a saída está correta."
                 PASSED_COUNT=$((PASSED_COUNT + 1))
            else
                 echo -e "  └─ ${RED}[FAIL]${NC} A saída do programa não é a esperada."
                 echo -e "     ├─ ${YELLOW}Esperado:${NC}"
                 sed 's/^/     │  /' "$expected_out_file"
                 echo -e "     ├─ ${RED}Recebido:${NC}"
                 sed 's/^/     │  /' "$actual_out_file"
                 echo -e "     └─"
                 FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        else
            # --- MUDANÇA NESTE BLOCO ---
            echo -e "  └─ ${RED}[FAIL]${NC} O programa deveria passar, mas falhou (exit code $status)."
            echo -e "     ├─ ${YELLOW}Saída Esperada (stdout):${NC}"
            sed 's/^/     │  /' "$expected_out_file"
            echo -e "     ├─ ${RED}Erro Inesperado (stderr):${NC}"
            sed 's/^/     │  /' "$actual_err_file"
            echo -e "     └─"
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    else
        echo -e "  └─ ${YELLOW}[WARN]${NC} Nenhum arquivo .expected.* encontrado para $display_name. Pulando verificação."
    fi

    rm "$actual_out_file" "$actual_err_file"
    echo ""
done

echo -e "${WHITE}================== RELATÓRIO FINAL ==================${NC}"
echo -e "${WHITE}Total de testes executados: ${TOTAL_TESTS}${NC}"
echo -e "${GREEN}Passaram: ${PASSED_COUNT}${NC}"
echo -e "${RED}Falharam: ${FAILED_COUNT}${NC}"
echo -e "${WHITE}=====================================================${NC}"

if [ $FAILED_COUNT -ne 0 ]; then
    exit 1
fi

exit 0