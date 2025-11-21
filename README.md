## C.js

Projeto pertencente ao grupo 05 de Compiladores 2025.2 da FCTE/UnB com o objetivo de colocar em prática os conhecimentos da matéria em um compilador de C para JavaScript. 

## Equipe

<table align="center">
  <tr>
    <td align="center">
      <img src="https://avatars.githubusercontent.com/u/63979948?v=4" width="100" style="border-radius: 50%;"><br>
      <strong><a href="https://github.com/LeanArs" target="_blank" rel="noopener noreferrer" style="">Leandro Almeida</a></strong><br>
    </td>
    <td align="center">
      <img src="https://avatars.githubusercontent.com/u/155484556?v=4" width="100" style="border-radius: 50%;"><br>
      <strong><a href="https://github.com/LucasAlves71" target="_blank" rel="noopener noreferrer">Lucas Alves</a></strong><br>
    </td>
    <td align="center">
      <img src="https://avatars.githubusercontent.com/u/111506459?v=4" width="100" style="border-radius: 50%;"><br>
      <strong><a href="https://github.com/renantfm4" target="_blank" rel="noopener noreferrer">Renan Araújo</a></strong><br>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://avatars.githubusercontent.com/u/75449306?v=4" width="100" style="border-radius: 50%;"><br>
      <strong><a href="https://github.com/Wooo589" target="_blank" rel="noopener noreferrer">Willian da Silva</a></strong><br>
    </td>
    <td align="center">
      <img src="https://avatars.githubusercontent.com/u/92001158?v=4" width="100" style="border-radius: 50%;"><br>
      <strong><a href="https://github.com/Yanmatheus0812" target="_blank" rel="noopener noreferrer">Yan Matheus</a></strong><br>
    </td>
  </tr>
</table>


## Configuração Inicial

### Compilar o Projeto
Antes de rodar qualquer teste, compile o projeto:

```bash
cd C.js
make clean && make -j$(nproc)
```

**O que faz:**
- Limpa arquivos gerados anteriormente (`lex.yy.c`, `parser.tab.c`, `parser.tab.h`)
- Executa **Flex** (lexer) para gerar `lex.yy.c`
- Executa **Bison** (parser) para gerar `parser.tab.c` e `parser.tab.h`
- Compila tudo com **GCC** e gera o executável `./c_parser`

---

## Estrutura de Testes

A estrutura de diretórios de testes é:

```
tests/
├── lexico/             # Testes de análise léxica
├── sintatico/          # Testes de análise sintática
├── semantico/          # Testes de análise semântica
└── otimizacao/         # Testes de otimização / código final
```

Cada teste tem a forma: `tests/<categoria>/<nome>.txt`

Arquivos associados (opcionais):
- `tests/<categoria>/<nome>.expected.out` - saída esperada em stdout
- `tests/<categoria>/<nome>.expected.err` - saída esperada em stderr

---

## Rodando Testes

### 1. Rodar Todos os Testes

```bash
./run_tests.sh
```

**Saída:**
- Lista cada teste (LEXICO, SINTATICO, SEMANTICO, OTIMIZAÇÃO)
- Mostra ✓ (verde) para PASSOU ou ✗ (vermelho) para FALHOU
- Resumo final: testes passados vs falhados por categoria

### 2. Rodar Um Teste Específico

#### Opção A: Com o Runner
```bash
./run_tests.sh tests/otimizacao/constantFolding.txt
```

**O que faz:**
- Executa `make` (rebuild rápido)
- Exporta `TEST_INPUT=tests/otimizacao/constantFolding.txt`
- Invoca `./c_parser < tests/otimizacao/constantFolding.txt`
- Gera outputs em `outputs/otimizacao/constantFolding.*`

#### Opção B: Manualmente
```bash
export TEST_INPUT=tests/otimizacao/constantFolding.txt
./c_parser < tests/otimizacao/constantFolding.txt
```

### 3. Rodar Todos os Testes de Uma Categoria

```bash
# Todos os testes léxicos
for test in tests/lexico/*.txt; do ./run_tests.sh "$test"; done

# Todos os testes sintáticos
for test in tests/sintatico/*.txt; do ./run_tests.sh "$test"; done

# Todos os testes semânticos
for test in tests/semantico/*.txt; do ./run_tests.sh "$test"; done

# Todos os testes de otimização
for test in tests/otimizacao/*.txt; do ./run_tests.sh "$test"; done
```

---

## Entendendo Saídas

Quando você roda um teste, o compilador produz **três tipos de saída**:

### 1. **Tabela de Símbolos** (stdout)

Mostra todas as variáveis, funções e constantes declaradas:

```
╔════════════════════════════════════════╗
║           TABELA DE SÍMBOLOS           ║
╚════════════════════════════════════════╝

 [GLOBAL]
  Name: x, Type: int, Symbol Type: 2 (VAR), Line: 1, Initialized: 1, Constant: 0

 [FUNCTION: main]
```

**Campos:**
- `Name`: nome do símbolo
- `Type`: tipo (int, char, float, etc)
- `Symbol Type`: 1=FUNCTION, 2=VARIABLE, 3=CONSTANT
- `Line`: linha do código fonte onde foi declarado
- `Initialized`: 1 se foi inicializado
- `Constant`: 1 se é constante

### 2. **Árvore Sintática (AST)** (stdout)

Mostra a estrutura do programa após parsing:

```
┌─ PROGRAM
   ├─ VARIABLE_DECLARATION (x)
   │  └─ EXPR_NUM (10.0)
   ├─ EXPR_BINARY (+ | left: x | right: 4)
   └─ RETURN
      └─ EXPR_NUM (0)
```

### 3. **Código Intermediário (IR)** 

Salvo em: `outputs/<categoria>/<nome>.ir`

Exemplo:
```
; --- Início do Código Intermediário ---
  x = 10.000000
  t0 = x + 4
  return 0
; --- Fim do Código Intermediário ---
```

**Instruções IR:**
- `x = 10`: ASSIGN (atribuição)
- `t0 = x + 4`: BINARY (operação binária)
- `t1 = foo()`: CALL (chamada de função)
- `ifTrue cond goto L1`: salto condicional
- `goto L1`: salto incondicional
- `func main`: FUNC_BEGIN (início de função)
- `end func main`: FUNC_END (fim de função)

---

## Testes Avançados

### 1. Ver Tabela de Símbolos em Detalhes

```bash
export TEST_INPUT=tests/semantico/escopoAninhado.txt
./c_parser < tests/semantico/escopoAninhado.txt 2>&1 | grep -A 50 "TABELA DE SÍMBOLOS"
```

### 2. Ver Apenas o Código Intermediário

```bash
cat outputs/semantico/escopoAninhado.ir
```

### 3. Gerar e Compilar Código C Final

Ao rodar um teste, o compilador **automaticamente**:
- Gera `outputs/<categoria>/<nome>.c` (código C gerado)
- Tenta compilar com GCC
- Gera `outputs/<categoria>/<nome>` (executável)
- Salva erros de compilação em `outputs/<categoria>/<nome>.compile.err`

Verificar resultado:

```bash
# Ver código C gerado
cat outputs/otimizacao/constantFolding.c

# Ver erros de compilação (se houver)
cat outputs/otimizacao/constantFolding.compile.err

# Executar o binário gerado
./outputs/otimizacao/constantFolding
```

### 4. Gerar e Executar Código JavaScript

O compilador também gera JavaScript em: `outputs/<categoria>/<nome>.js`

```bash
# Ver código JS gerado
cat outputs/otimizacao/constantFolding.js

# Executar com Node.js
node outputs/otimizacao/constantFolding.js

# Ver variáveis finais (rápido)
echo "console.log('x =', x);" >> outputs/otimizacao/constantFolding.js
node outputs/otimizacao/constantFolding.js
```

---

## Fluxo Completo de um Teste

Ao executar:
```bash
./run_tests.sh tests/otimizacao/constantFolding.txt
```

Aqui está o que acontece internamente:

1. **Compilação** (`make`)
   - Flex gera lexer
   - Bison gera parser
   - GCC compila tudo → `./c_parser`

2. **Execução** (`./c_parser < teste.txt`)
   - Lexer tokeniza o código
   - Parser constrói a AST
   - Análise semântica e construção da tabela de símbolos
   - Geração de IR (intermediate representation)
   - Otimizações: constant folding, copy propagation, dead code elimination

3. **Saídas Geradas**
   - stdout: tabela de símbolos + AST
   - `outputs/otimizacao/constantFolding.ir` - código intermediário
   - `outputs/otimizacao/constantFolding.c` - código C gerado
   - `outputs/otimizacao/constantFolding.js` - código JavaScript gerado
   - `outputs/otimizacao/constantFolding` - executável C (se compilou)
   - `outputs/otimizacao/constantFolding.compile.err` - erros de compilação

4. **Comparação** (em `run_all_tests.sh`)
   - Compara stdout/stderr com `.expected.out` e `.expected.err`
   - Mostra PASSOU ✓ ou FALHOU ✗

---

## Criando Novos Testes

### Para testar otimização:

```bash
cat > tests/otimizacao/meuTeste.txt << 'EOF'
int main() {
    int x = 5 + 5;  // constant folding: deve virar 10
    int y = x;      // copy propagation: x pode ser propagado
    int z = y;      // dead code: z não é usado
    return 0;
}
EOF
```

### Para testar erro semântico:

```bash
cat > tests/semantico/meuErro.txt << 'EOF'
int main() {
    int x = 5;
    int x = 10;     // variável duplicada - erro semântico
    return 0;
}
EOF

# Criar arquivo de erro esperado
cat > tests/semantico/meuErro.expected.err << 'EOF'
Erro linha 3: Variável 'x' já foi declarada neste escopo.
EOF
```

---

## Dicas Úteis

### Limpeza de Outputs
```bash
rm -rf outputs/
```

### Ver Todos os Outputs de Uma Categoria
```bash
ls -lh outputs/otimizacao/
ls -lh outputs/semantico/
```

### Recompilar Rápido
```bash
make -j$(nproc)
```

### Debug: Ver Exatamente o Que Está Sendo Comparado
```bash
./run_tests.sh tests/otimizacao/constantFolding.txt > /tmp/saida.txt 2>&1
diff tests/otimizacao/constantFolding.expected.out /tmp/saida.txt
```

### Executar Todos os Testes e Gerar Relatório
```bash
./run_all_tests.sh 2>&1 | tee test_report.log
grep "FALHOU" test_report.log
```

---

## Estrutura dos Arquivos do Compilador

Para entender melhor o que cada etapa faz:

- **Lexer** (`lexer/lexer.l`): tokeniza o código
- **Parser** (`parser/parser.y`): constrói a AST
- **AST** (`src/ast.c`, `src/ast.h`): define estrutura da árvore
- **Tabela de Símbolos** (`src/symbol_table.c`): rastreia variáveis/funções
- **IR Generator** (`src/intermediate_generator.c`): gera código intermediário + C + JS
- **JS Generator** (`src/js_generator.c`): traduz IR para JavaScript
- **Otimizações** (em `intermediate_generator.c`):
  - `pass_constant_folding()`: calcula expressões constantes
  - `pass_copy_propagation()`: propaga cópias de variáveis
  - `pass_dead_code_elimination()`: remove código morto

---

## Troubleshooting

### Erro: "Permissão negada" ao rodar `run_tests.sh`
```bash
chmod +x run_tests.sh run_all_tests.sh
```

### Erro: "make not found"
```bash
sudo apt-get install build-essential bison flex
```

### Erro: "gcc: command not found"
```bash
sudo apt-get install gcc
```

### Compilação do C gerado falha
Verifique `outputs/<categoria>/<nome>.compile.err`:
```bash
cat outputs/otimizacao/constantFolding.compile.err
```

### Node.js não encontrado (para testar JS)
```bash
sudo apt-get install nodejs
```

---

## Exemplos Rápidos

### Testar otimização de constantes:
```bash
./run_tests.sh tests/otimizacao/constantFolding.txt
cat outputs/otimizacao/constantFolding.ir
```

### Testar escopo aninhado:
```bash
./run_tests.sh tests/semantico/escopoAninhado.txt
cat outputs/semantico/escopoAninhado.ir
```

### Compilar e rodar gerado:
```bash
./run_tests.sh tests/otimizacao/constantFolding.txt
./outputs/otimizacao/constantFolding
echo $?  # mostra o valor de retorno
```

### Gerar e testar JavaScript:
```bash
./run_tests.sh tests/otimizacao/constantFolding.txt
node outputs/otimizacao/constantFolding.js
```

---
