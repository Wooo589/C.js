#!/usr/bin/env bash

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

# Contadores (agora com nome maiúsculo pra ficar igual ao antigo)
total=0
passed=0
failed=0
LEXICO_PASS=0; LEXICO_FAIL=0
SEMANTICO_PASS=0; SEMANTICO_FAIL=0
SINTATICO_PASS=0; SINTATICO_FAIL=0

echo -e "${WHITE}Executando testes (geração C → gcc → execução)...${NC}\n"

for test_file in $(find "$TEST_DIR" -name "*.txt" | sort); do
    ((total++))

    rel_path="${test_file#tests/}"
    rel_path="${rel_path%.txt}"

    # Categoria
    if   [[ $test_file == */lexico/* ]];    then CAT="LEXICO"
    elif [[ $test_file == */semantico/* ]]; then CAT="SEMANTICO"
    elif [[ $test_file == */sintatico/* ]]; then CAT="SINTATICO"
    else                                         CAT="OUTRO"
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
    # 1. Testes que devem dar erro
    # =============================================
    if [[ -f "$expected_err" ]]; then
        if [[ $compiler_exit -ne 0 ]]; then
            echo -e "${GREEN}✓${NC} $rel_path"
            ((passed++))
            case $CAT in LEXICO) ((LEXICO_PASS++));; SEMANTICO) ((SEMANTICO_PASS++));; SINTATICO) ((SINTATICO_PASS++));; esac
        else
            echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(deveria falhar, mas passou)${NC}"
            ((failed++))
            case $CAT in LEXICO) ((LEXICO_FAIL++));; SEMANTICO) ((SEMANTICO_FAIL++));; SINTATICO) ((SINTATICO_FAIL++));; esac
        fi
        continue
    fi

    # =============================================
    # 2. Testes que devem passar
    # =============================================
    if [[ ! -f "$c_file" ]]; then
        echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(.c não foi gerado)${NC}"
        ((failed++))
        case $CAT in LEXICO) ((LEXICO_FAIL++));; SEMANTICO) ((SEMANTICO_FAIL++));; SINTATICO) ((SINTATICO_FAIL++));; esac
        continue
    fi

    gcc -w -std=c99 -lm -o "$bin_file" "$c_file" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(falha ao compilar com gcc)${NC}"
        ((failed++))
        case $CAT in LEXICO) ((LEXICO_FAIL++));; SEMANTICO) ((SEMANTICO_FAIL++));; SINTATICO) ((SINTATICO_FAIL++));; esac
        continue
    fi

    timeout 3s "$bin_file" > /tmp/out.tmp 2>/dev/null
    exec_exit=$?

    if [[ $exec_exit -eq 124 ]]; then
        echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(timeout)${NC}"
        ((failed++))
    elif [[ $exec_exit -ne 0 ]]; then
        echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(segfault ou erro)${NC}"
        ((failed++))
    elif [[ -f "$expected_out" ]] && cmp -s /tmp/out.tmp "$expected_out"; then
        echo -e "${GREEN}✓${NC} $rel_path"
        ((passed++))
        case $CAT in LEXICO) ((LEXICO_PASS++));; SEMANTICO) ((SEMANTICO_PASS++));; SINTATICO) ((SINTATICO_PASS++));; esac
    else
        if [[ ! -f "$expected_out" ]]; then
            echo -e "${YELLOW}!${NC} $rel_path  ${YELLOW}(passou mas sem .expected.out)${NC}"
        else
            echo -e "${RED}✗${NC} $rel_path  ${YELLOW}(saída diferente)${NC}"
        fi
        ((failed++))
        case $CAT in LEXICO) ((LEXICO_FAIL++));; SEMANTICO) ((SEMANTICO_FAIL++));; SINTATICO) ((SINTATICO_FAIL++));; esac
    fi
done

rm -f /tmp/out.tmp

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
echo -e "${BLUE}LÉXICO:${NC}     ${GREEN}$LEXICO_PASS pass${NC} / ${RED}$LEXICO_FAIL fail${NC}"
echo -e "${BLUE}SEMÂNTICO:${NC}  ${GREEN}$SEMANTICO_PASS pass${NC} / ${RED}$SEMANTICO_FAIL fail${NC}"
echo -e "${BLUE}SINTÁTICO:${NC}  ${GREEN}$SINTATICO_PASS pass${NC} / ${RED}$SINTATICO_FAIL fail${NC}"
echo
echo -e "${WHITE}============================================${NC}"

if (( failed == 0 )); then
    echo -e "${GREEN}✓ TODOS OS TESTES PASSARAM!${NC}"
else
    echo -e "${RED}Faltam testes para consertar!${NC}"
fi

echo -e "${WHITE}============================================${NC}"
exit $failed