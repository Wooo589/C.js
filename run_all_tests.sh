RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${WHITE}============================================${NC}"
echo -e "${WHITE}    SUITE DE TESTES - COMPILADOR C.js (2025)${NC}"
echo -e "${WHITE}============================================${NC}"
echo

echo -e "${CYAN}Compilando o compilador...${NC}"
make -B > /dev/null 2>&1 || { echo -e "${RED}✗ Erro no make${NC}"; exit 1; }
echo -e "${GREEN}✓ Compilação concluída${NC}"
echo

TEST_DIR="tests"
COMPILER="./c_parser"

# Contadores
total=0
passed=0
failed=0
lex_pass=0; lex_fail=0
sem_pass=0; sem_fail=0
sin_pass=0; sin_fail=0
out_pass=0; out_fail=0

echo -e "${WHITE}Executando testes (geração C → gcc → execução)...${NC}\n"

for test_file in $(find "$TEST_DIR" -name "*.txt" | sort); do
    ((total++))

    rel_path="${test_file#tests/}"
    rel_path="${rel_path%.txt}"
    name=$(basename "$rel_path")

    # Categoria
    if   [[ $test_file == */lexico/* ]];    then cat="LÉXICO";    cpass=lex_pass; cfail=lex_fail
    elif [[ $test_file == */semantico/* ]]; then cat="SEMÂNTICO"; cpass=sem_pass; cfail=sem_fail
    elif [[ $test_file == */sintatico/* ]]; then cat="SINTÁTICO"; cpass=sin_pass; cfail=sin_fail
    else                                        cat="OUTRO";     cpass=out_pass; cfail=out_fail
    fi

    expected_err="tests/${rel_path}.expected.err"
    expected_out="tests/${rel_path}.expected.out"

    export TEST_INPUT="$test_file"
    timeout 8s "$COMPILER" < "$test_file" > /dev/null 2> /dev/null
    compiler_exit=$?
    unset TEST_INPUT

    c_file="outputs/${rel_path}.c"
    bin_file="outputs/${rel_path}"

    # =============================================
    # 1. Testes que devem dar erro (léxico/sintático/semântico)
    # =============================================
    if [[ -f "$expected_err" ]]; then
        if [[ $compiler_exit -ne 0 ]]; then
            echo -e "${GREEN}✓${NC} $rel_path"
            ((passed++))
            ((cpass++))
        else
            echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(deveria falhar, mas passou)${NC}"
            ((failed++))
            ((cfail++))
        fi
        continue
    fi

    # =============================================
    # 2. Testes que devem passar (gerar .c válido)
    # =============================================
    if [[ ! -f "$c_file" ]]; then
        echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(.c não foi gerado)${NC}"
        ((failed++))
        ((cfail++))
        continue
    fi

    # Compila
    gcc -w -std=c99 -lm -o "$bin_file" "$c_file" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(falha ao compilar com gcc)${NC}"
        ((failed++))
        ((cfail++))
        continue
    fi

    # Executa
    timeout 3s "$bin_file" > /tmp/out_test.tmp 2>/dev/null
    exec_exit=$?

    if [[ $exec_exit -eq 124 ]]; then
        echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(timeout)${NC}"
        ((failed++))
        ((cfail++))
    elif [[ $exec_exit -ne 0 ]]; then
        echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(segfault ou erro em tempo de execução)${NC}"
        ((failed++))
        ((cfail++))
    elif [[ -f "$expected_out" ]] && cmp -s "/tmp/out_test.tmp" "$expected_out"; then
        echo -e "${GREEN}✓${NC} $rel_path"
        ((passed++))
        ((cpass++))
    else
        # Saída diferente ou arquivo .expected.out não existe
        if [[ ! -f "$expected_out" ]]; then
            echo -e "${YELLOW}!${NC} $rel_path  ${YELLOW}(passou mas sem .expected.out — considerar verde?)${NC}"
        else
            echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(saída diferente do esperado)${NC}"
        fi
        ((failed++))
        ((cfail++))
    fi
done

rm -f /tmp/out_test.tmp

percent=$(( passed * 100 / total ))

echo
echo -e "${WHITE}============================================${NC}"
echo -e "${WHITE}           RESULTADO FINAL${NC}"
echo -e "${WHITE}============================================${NC}"
echo
echo -e "${WHITE}Total de testes:${NC} $total"
echo -e "${GREEN}Passaram:${NC} $passed ($percent%)"
echo -e "${RED}Falharam:${NC} $failed"
echo
echo -e "${WHITE}Por Categoria:${NC}"
printf "${BLUE}LÉXICO:   ${NC} ${GREEN}%2d pass${NC} / ${RED}%2d fail${NC}\n" $lex_pass $lex_fail
printf "${BLUE}SEMÂNTICO:${NC} ${GREEN}%2d pass${NC} / ${RED}%2d fail${NC}\n" $sem_pass $sem_fail
printf "${BLUE}SINTÁTICO:${NC}${GREEN}%2d pass${NC} / ${RED}%2d fail${NC}\n" $sin_pass $sin_fail
echo -e "${WHITE}============================================${NC}"

if (( failed == 0 )); then
    echo -e "${GREEN}✓ TODOS OS TESTES PASSARAM!${NC}"
else
    echo -e "${RED}Faltam testes para consertar!${NC}"
fi

echo -e "${WHITE}============================================${NC}"
exit $failed