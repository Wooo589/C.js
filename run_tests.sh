RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[0m'

echo -e "Executando testes...\n"
make > /dev/null 2>&1

for file in tests/*.txt; do
    echo -e "${WHITE}=============================================="
    echo -e "Arquivo: ${CYAN}$file${RED}"

    output=$(./a.out < "$file")
    status=$?

    if [ $status -eq 0 ]; then
        echo -e "${WHITE}Resultado: ${GREEN}Ok${NC}"
    else
    
        echo -e "${WHITE}Resultado: ${RED}Falhou${NC}"
    fi

    echo ""
done
