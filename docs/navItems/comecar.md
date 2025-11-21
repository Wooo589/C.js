## Passo a passo 

### Compilar o projeto
Se direcione à raiz do projeto e execute:

```bash
make all
```

Isso gera os arquivos:

```bash
c_parser
lex.yy.c
parser.tab.c
parser.tab.h
```

---

## Estrutura de testes

A estrutura de diretórios de testes é:

```
tests/
├── lexico/             # Testes de análise léxica
├── sintatico/          # Testes de análise sintática
├── semantico/          # Testes de análise semântica
└── otimizacao/         # Testes de otimização / código final
```

Cada teste tem a forma: `tests/<categoria>/<nome>.txt`

Saídas geradas vão para:

```
outputs/<categoria>/<nome>
```

## Como executar a suíte

Execute o seguinte comando:
```bash
./scripts/run_tests.sh
```


## O que o compilador gera

Ao rodar um teste, você obtém:

### Saída padrão (stdout)
- Tabela de símbolos  
- AST (Árvore Sintática Abstrata)

---

## Arquivos gerados

### Código intermediário (IR)
Gerado em:

```
outputs/<categoria>/<nome>
```

### Código C gerado

```
outputs/<categoria>/<nome>.c
```

### Código JavaScript gerado

```
outputs/<categoria>/<nome>.js
```

### Binário compilado do C  

```
outputs/<cat>/<nome>
```

---

## Verificando saídas

### Ver IR:

```
cat outputs/<categoria>/<nome>.ir
```
### Ver o código C:

```
cat outputs/<categoria>/<nome>.c
```
### Ver o código JavaScript:

```
cat outputs/<categoria>/<nome>.js
```

## Limpar os arquivos

```bash
make clean
```

## Como executar a documentação

Na raiz do projeto e em um terminal separado, execute o seguinte comando:

```bash
docsify serve ./docs
```

## Histórico de versão

| **Data** | **Versão** | **Descrição** | **Autor(es)** | **Revisor(es)** | **Data de revisão** |
| :----: | :------: | :---------: | :---------: | :-----------: | :-----------: |
| 04/10/2025 | `1.0` | Versão inicial do documento. | [`@Willian`](https://github.com/Wooo589) | | |
| 21/11/2025 | `1.1` | Preenchimento preliminar do documento. | [`@Willian`](https://github.com/Wooo589) e [`@Yan`](https://github.com/Yanmatheus0812) | | |