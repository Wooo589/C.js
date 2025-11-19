#!/bin/sh

PASSED=0
FAILED=0

for test_file in $(find tests -name "*.txt"); do
    base_name=$(echo "$test_file" | sed 's/\.txt$//')
    expected_err="$base_name.expected.err"
    expected_out="$base_name.expected.out"
    
    if [ -f "$expected_err" ] || [ -f "$expected_out" ]; then
        ./c_parser < "$test_file" > /tmp/out.tmp 2> /tmp/err.tmp
        exit_code=$?
        
        if [ -f "$expected_err" ]; then
            if [ $exit_code -ne 0 ]; then
                # Compare ignoring trailing whitespace
                if diff -q -b -B "$expected_err" /tmp/err.tmp > /dev/null 2>&1; then
                    PASSED=$((PASSED + 1))
                else
                    FAILED=$((FAILED + 1))
                    echo "FAIL: $test_file (erro diferente do esperado)"
                fi
            else
                FAILED=$((FAILED + 1))
                echo "FAIL: $test_file (deveria falhar mas passou)"
            fi
        elif [ -f "$expected_out" ]; then
            if [ $exit_code -eq 0 ]; then
                if cmp -s "$expected_out" /tmp/out.tmp; then
                    PASSED=$((PASSED + 1))
                else
                    FAILED=$((FAILED + 1))
                    echo "FAIL: $test_file (saída diferente da esperada)"
                fi
            else
                FAILED=$((FAILED + 1))
                echo "FAIL: $test_file (deveria passar mas falhou - exit code: $exit_code)"
            fi
        fi
    fi
done

echo ""
echo "==================== RESUMO ===================="
echo "Total: $((PASSED + FAILED))"
echo "Passaram: $PASSED"
echo "Falharam: $FAILED"
echo "==============================================="
