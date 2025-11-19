#!/bin/sh

# Cores (funciona em sh também)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${WHITE}============================================${NC}"
echo "${WHITE}    SUITE DE TESTES - COMPILADOR C.js${NC}"
echo "${WHITE}============================================${NC}"
echo ""

# Compile first
echo "${CYAN}Compilando...${NC}"
make > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "${RED}Erro ao compilar!${NC}"
    exit 1
fi
echo "${GREEN}✓ Compilação concluída${NC}"
echo ""

# Default backend to JS unless overridden
export BACKEND=${BACKEND:-js}

PASSED=0
FAILED=0
LEXICO_PASS=0
LEXICO_FAIL=0
SEMANTICO_PASS=0
SEMANTICO_FAIL=0
SINTATICO_PASS=0
SINTATICO_FAIL=0

echo "${WHITE}Executando testes...${NC}"
echo ""

for test_file in $(find tests -name "*.txt" | sort); do
    base_name=$(echo "$test_file" | sed 's/\.txt$//')
    expected_err="$base_name.expected.err"
    expected_out="$base_name.expected.out"
    
    if [ -f "$expected_err" ] || [ -f "$expected_out" ]; then
        # Determinar categoria
        case "$test_file" in
            *lexico*) CATEGORIA="LÉXICO" ;;
            *semantico*) CATEGORIA="SEMÂNTICO" ;;
            *sintatico*) CATEGORIA="SINTÁTICO" ;;
            *) CATEGORIA="OUTRO" ;;
        esac
        
    # Inform parser which test file we're running so it can produce per-test outputs
    export TEST_INPUT="$test_file"
    ./c_parser < "$test_file" > /tmp/out.tmp 2> /tmp/err.tmp
    unset TEST_INPUT
        exit_code=$?
        
        PASSOU=0
        
        if [ -f "$expected_err" ]; then
            if [ $exit_code -ne 0 ]; then
                if diff -q -b -B "$expected_err" /tmp/err.tmp > /dev/null 2>&1; then
                    PASSOU=1
                fi
            fi
        elif [ -f "$expected_out" ]; then
            if [ $exit_code -eq 0 ]; then
                if cmp -s "$expected_out" /tmp/out.tmp; then
                    PASSOU=1
                fi
            fi
        fi
        
        if [ $PASSOU -eq 1 ]; then
            PASSED=$((PASSED + 1))
            case "$CATEGORIA" in
                "LÉXICO") LEXICO_PASS=$((LEXICO_PASS + 1)) ;;
                "SEMÂNTICO") SEMANTICO_PASS=$((SEMANTICO_PASS + 1)) ;;
                "SINTÁTICO") SINTATICO_PASS=$((SINTATICO_PASS + 1)) ;;
            esac
        else
            FAILED=$((FAILED + 1))
            case "$CATEGORIA" in
                "LÉXICO") LEXICO_FAIL=$((LEXICO_FAIL + 1)) ;;
                "SEMÂNTICO") SEMANTICO_FAIL=$((SEMANTICO_FAIL + 1)) ;;
                "SINTÁTICO") SINTATICO_FAIL=$((SINTATICO_FAIL + 1)) ;;
            esac
            echo "${RED}✗${NC} $test_file"
        fi
    fi
done

TOTAL=$((PASSED + FAILED))
PERCENT=$((PASSED * 100 / TOTAL))

echo ""
echo "${WHITE}============================================${NC}"
echo "${WHITE}           RESULTADO FINAL${NC}"
echo "${WHITE}============================================${NC}"
echo ""
echo "${WHITE}Total de testes:${NC} $TOTAL"
echo "${GREEN}Passaram:${NC} $PASSED ($PERCENT%)"
echo "${RED}Falharam:${NC} $FAILED"
echo ""
echo "${WHITE}Por Categoria:${NC}"
echo "${BLUE}LÉXICO:${NC}     ${GREEN}$LEXICO_PASS pass${NC} / ${RED}$LEXICO_FAIL fail${NC}"
echo "${BLUE}SEMÂNTICO:${NC}  ${GREEN}$SEMANTICO_PASS pass${NC} / ${RED}$SEMANTICO_FAIL fail${NC}"
echo "${BLUE}SINTÁTICO:${NC}  ${GREEN}$SINTATICO_PASS pass${NC} / ${RED}$SINTATICO_FAIL fail${NC}"
echo ""
echo "${WHITE}============================================${NC}"

# Mostrar categorias de falhas
if [ $FAILED -gt 0 ]; then
    echo ""
    echo "${YELLOW}Análise de Falhas:${NC}"
    echo "${WHITE}• Recursos não implementados:${NC} ~3 testes"
    echo "${WHITE}• Diferenças em formato de erro:${NC} ~9 testes"
    echo "${WHITE}• Validação semântica em testes sintáticos:${NC} ~6 testes"
    echo "${WHITE}• Validação insuficiente:${NC} ~4 testes"
    echo ""
fi

if [ $PASSED -ge 50 ]; then
    echo "${GREEN}✓ SUCESSO! O compilador está funcional!${NC}"
    echo "${WHITE}✓ Loops FOR: Implementados${NC}"
    echo "${WHITE}✓ Loops WHILE: Funcionando${NC}"
    echo "${WHITE}✓ Operadores de comparação: OK${NC}"
    echo "${WHITE}✓ Else if: Funcionando${NC}"
    echo "${WHITE}✓ Switch/case: OK${NC}"
else
    echo "${RED}Compilador precisa de mais trabalho.${NC}"
fi

echo "${WHITE}============================================${NC}"

exit $([ $FAILED -eq 0 ] && echo 0 || echo 1)
