## Cronograma do projeto
| Título/Sprint | Período | Objetivos | Entregas |
| :------: | :-------: | ---------- | -------- |
| **1** | **17/09 - 23/09** | <ul><li>Definir a sintaxe e a semântica básica do compilador.</li><li>Elaborar a primeira versão da gramática formal.</li></ul> | <ul><li>Documento inicial com a descrição da linguagem (tokens, estruturas, exemplos de código).</li><li>Planejamento do protótipo da gramática reconhecida pelo Bison.</li></ul> |
| **2** | **24/09 - 30/09** | <ul><li>Concluir a análise léxica e iniciar a análise sintática.</li><li>Implementar identificação de tokens e testar o reconhecimento básico da linguagem.</li><li>Preparar o material para o Ponto de Controle P1.</li></ul> | <ul><li>Analisador léxico funcional, com o reconhecimento dos tokens definidos.</li><li>Primeiras regras sintáticas implementadas no arquivo .y.</li><li>Formulário de apresentação do P1 preenchido.</li></ul> |
| **3** | **01/10 - 14/10** | <ul><li>Evoluir o analisador sintático com novas produções gramaticais.</li><li>Iniciar a estrutura interna do compilador (árvore sintática, tabela de símbolos).</li><li>Dar os primeiros passos na análise semântica (tipo de variáveis, escopos).</li></ul> | <ul><li>Parser com cobertura mais ampla da gramática (incluindo estruturas de controle, declarações etc.).</li><li>Estrutura de dados (AST e tabela de símbolos) definidas e parcialmente implementadas.</li><li>Analisador semântico inicial identificando erros básicos (variáveis não declaradas, tipos simples).</li></ul> |
| **4** | **15/10 - 02/11** | <ul><li>Concluir análise semântica principal.</li><li>Implementar a geração de código intermediário (código de três endereços ou equivalente).</li><li>Preparar o ponto de controle P2.</li></ul> | <ul><li>Analisador semântico robusto (tratando coerência de tipos, escopos, variáveis).</li><li>Módulo de geração de código intermediário, ainda que sem otimizações avançadas.</li><li>Formulário do P2 preenchido.</li></ul> |
| **Semana Universitária** | **03/11 - 07/11** |  |  |
| **5** | **08/11 - 26/11** | <ul><li>Testar otimizações no código intermediário</li><li>Implementar a geração de código final</li><li>Revisar testes implementados e verificar possibilidade de integração</li><li>Correções de bugs.</li></ul> | <ul><li>Otimização básica: pode envolver remoção de código inutilizado e simplificação de expressões.</li><li>Geração de código final.</li><li>Testes revisados e implementados de forma integrada.</li></ul> |
| **Entrega do arquivo .zip do compilador** | **26/11** |  |  |
| **6** | **27/11-03/12** | <ul><li>Realizar as entrevistas finais.</li><li>Ajustar eventuais pendências do compilador.</li><li>Concluir a documentação e finalizar a disciplina.</li></ul> | <ul><li>Apresentação do compilador nas entrevistas.</li><li>Correções finais e documentação completa (manual de uso, README, passos de compilação)</li></ul> |

## Atas de reunião

### Sprint 1 

#### Ata 17/09

| Data | Horário | Local | Participantes | Link |
| :------: | :-------: | :----------: | -------- | :----------: |
| 17/09/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | |

<h5>Assuntos discutidos</h5>

- assunto discutido 1;
- assunto discutido 2.

<h5>Deliberações</h5>

- deliberação 1;
- deliberação 2.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)|  |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) |  |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) |  |

### Sprint 2

#### Ata 26/09

| Data | Horário | Local | Participantes | Link |
| :------: | :-------: | :----------: | -------- | :----------: |
| 26/09/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | |

<h5>Assuntos discutidos</h5>

- assunto discutido 1;
- assunto discutido 2.

<h5>Deliberações</h5>

- deliberação 1;
- deliberação 2.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)|  |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) |  |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) |  |

### Sprint 3

#### Ata 01/10

| Data | Horário | Local | Participantes | Link |
| :------: | :-------: | :----------: | -------- | :----------: |
| 01/10/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li></ul> | |

<h5>Assuntos discutidos</h5>

- assunto discutido 1;
- assunto discutido 2.

<h5>Deliberações</h5>

- deliberação 1;
- deliberação 2.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)|  |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) |  |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) |  |

#### Ata 08/10

| Data | Horário | Local | Participantes | Link |
| :------: | :-------: | :----------: | -------- | :----------: |
| 08/10/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | |

<h5>Assuntos discutidos</h5>

- assunto discutido 1;
- assunto discutido 2.

<h5>Deliberações</h5>

- deliberação 1;
- deliberação 2.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)|  |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) |  |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) |  |

### Sprint 4

#### Ata 15/10

| Data | Horário | Local | Participantes | Link |
| :------: | :-------: | :----------: | -------- | :----------: |
| 15/10/2025 | 20h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | |

<h5>Assuntos discutidos</h5>

- assunto discutido 1;
- assunto discutido 2.

<h5>Deliberações</h5>

- deliberação 1;
- deliberação 2.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)|  |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) |  |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) |  |

#### Ata 22/10

| Data | Horário | Local | Participantes |
| :------: | :-------: | :----------: | -------- |
| 22/10/2025 | 14h | Presencial na faculdade | <ul><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | 

<h5>Assuntos discutidos</h5>

- Mudanças no cronograma do projeto;
- Progresso do analisador semântico;
- Resolução dos impasses na geração do código intermediário.

<h5>Deliberações</h5>

- Cronograma será ajustado;
- Atualizações do analisador semântico serão enviadas para uma branch separada no repositório;
- Equipe responsável pela geração do código intermediário permanecerá a mesma.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)| Atualizar cronograma e apoio nas tarefas |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) | Subir alterações do analisador semântico |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) | Dar continuidade ao gerador de código intermediário |

## Histórico de versão

| **Data** | **Versão** | **Descrição** | **Autor(es)** | **Revisor(es)** | **Data de revisão** |
| :----: | :------: | :---------: | :---------: | :-----------: | :-----------: |
| 29/09/2025 | `1.0` | Versão inicial do documento. | [`@Willian`](https://github.com/Wooo589) | | |
| 15/10/2025 | `1.1` | Adição da 3ª e 4ª sprint no cronograma. | [`@Willian`](https://github.com/Wooo589) | | |
| 27/10/2025 | `1.2` | Inserção da 5ª e 6ª sprint no cronograma. | [`@Willian`](https://github.com/Wooo589) | | |