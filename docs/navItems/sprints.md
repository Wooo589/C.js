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

| Data | Horário | Local | Participantes |
| :------: | :-------: | :----------: | -------- | 
| 17/09/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | 

<h5>Assuntos discutidos</h5>

- Alocação de atividades para cada membro;
- Apresentação das tarefas das sprints 1 e 2, e como as sprints serão documentadas.

<h5>Deliberações</h5>

- Todos irão focar no léxico;
- A documentação preliminar deve ser elaborada a partir desssa sprint.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)| Documentação preliminar e apoio no analisador léxico |
| [`@Leandro`](https://github.com/LeanArs), [`@Lucas`](https://github.com/LucasAlves71), [`@Renan`](https://github.com/renantfm4) e [`@Yan`](https://github.com/Yanmatheus0812) | Construção do analisador léxico |

### Sprint 2

#### Ata 26/09

| Data | Horário | Local | Participantes | 
| :------: | :-------: | :----------: | -------- | 
| 26/09/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> |

<h5>Assuntos discutidos</h5>

- Discussão do progresso do analisador léxico;
- Construção das primeiras regras do analisador sintático;
- Envio do formulário do P1.

<h5>Deliberações</h5>

- Revisão do que foi implementado do analisador léxico;
- O analisador sintático será trabalhado ao decorrer da revisão do analisador léxico;
- A documentação preliminar que inclui as sprints 1 e 2 será lançada na página do repositório;
- O líder está encarregado de preencher o formulário do P1.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)| Envio do formulaŕio P1, documentação com deploy e apoio nas atividades da sprint |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) | Implementação das primeiras regras do analisador sintático |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) | Finalização do analisador léxico e implementação de testes |

### Sprint 3

#### Ata 01/10

| Data | Horário | Local | Participantes | 
| :------: | :-------: | :----------: | -------- | 
| 01/10/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li></ul> | 

<h5>Assuntos discutidos</h5>

- Progresso do que foi elaborado na sprint passada;
- Análise semântica já estava sendo desenvolvida na sprint 2;
- Alocação de tarefas para a sprint 3.

<h5>Deliberações</h5>

- A cobertura de testes será revisada e ampliada;
- A documentação será atualizada para guiar o usuário em como executar o compilador;
- O analisador semântico será revisado para que haja um melhor entendimento do que foi implementado;
- O analisador sintático terá a sua ampliação e implementação de sua estrutura de dados (AST e tabela de símbolos).

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Leandro`](https://github.com/LeanArs) | Aumentar a cobertura de testes |
| [`@Willian`](https://github.com/Wooo589) e [`@Yan`](https://github.com/Yanmatheus0812)| Revisão da documentação e do analisador semântico |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) | Aprimoramento do analisador sintático |

#### Ata 08/10

| Data | Horário | Local | Participantes | 
| :------: | :-------: | :----------: | -------- | 
| 08/10/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | 

<h5>Assuntos discutidos</h5>

- Progresso do que foi elaborado até o ponto de controle da sprint;
- Atividades com dificuldades de avanço por conta de obrigações de outras matérias da faculdade.

<h5>Deliberações</h5>

- Uma nova revisão dos analisadores será feita até o último dia da sprint;
- As funções estabelecidas na reunião passada estarão mantidas.

### Sprint 4

#### Ata 15/10

| Data | Horário | Local | Participantes | 
| :------: | :-------: | :----------: | -------- | 
| 15/10/2025 | 20h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | 

<h5>Assuntos discutidos</h5>

- Progresso do analisador semântico e sintático;
- Evolução da cobertura de testes nos analisadores;
- Envio do formulário do P2.

<h5>Deliberações</h5>

- O analisador semântico será finalizado;
- A geração do código intermediário será trabalhado;
- A otimização do módulo de geração do código intermediário será focada na próxima sprint;
- O líder está encarregado de preencher o formulário do P2.

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)| Apoio nas tarefas da sprint |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) | Finalizar o analisador semântico |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) | Implementar a geração do código intermediário |

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

### Sprint 5

#### Ata 12/11

| Data | Horário | Local | Participantes | 
| :------: | :-------: | :----------: | -------- | 
| 12/11/2025 | 20h30 | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | 

<h5>Assuntos discutidos</h5>

- Progresso do analisador semântico e da geração do código intermediário;
- Revisão da cobertura de testes até esse momento;
- Módulo de geração do código final;
- Possibilidade de finalizar o trabalho para a avaliação preliminar do professor.

<h5>Deliberações</h5>

- O analisador semântico terá os seus erros corrigidos;
- A geração do código intermediário será otimizado;
- O rito da daily será implementado nessa sprint;
- Um ponto de controle será feito na segunda-feira (17/11).

<h5>Ações e responsáveis:</h5>

| Ação | Responsável |
| ---- | ----------- |
| [`@Willian`](https://github.com/Wooo589)| Organização do repositório e apoio nas tarefas da sprint |
| [`@Lucas`](https://github.com/LucasAlves71) e [`@Renan`](https://github.com/renantfm4) | Arrumar erros no analisador semântico |
| [`@Leandro`](https://github.com/LeanArs) e [`@Yan`](https://github.com/Yanmatheus0812) | Otimização da geração do código intermediário |

#### Ata 17/11

| Data | Horário | Local | Participantes | 
| :------: | :-------: | :----------: | -------- | 
| 17/11/2025 | 21h | Microsoft Teams | <ul><li>[`@Leandro`](https://github.com/LeanArs)</li><li>[`@Lucas`](https://github.com/LucasAlves71)</li><li>[`@Renan`](https://github.com/renantfm4)</li><li>[`@Willian`](https://github.com/Wooo589)</li><li>[`@Yan`](https://github.com/Yanmatheus0812)</li></ul> | 

<h5>Assuntos discutidos</h5>

- Progresso do que foi arrumado no analisador semântico;
- Progresso do que foi implementado na otimização do gerador de código intermediário.

<h5>Deliberações</h5>

- A geração de código final preliminar deve ser finalizado até quinta-feira (20/11);
- Para dar garantia da continuidade do nosso trabalho, começaremos a enviar alinhamentos assíncronos de dia e nos reuniremos à noite para agilizarmos eventuais pendências que surgirem no dia.

## Histórico de versão

| **Data** | **Versão** | **Descrição** | **Autor(es)** | **Revisor(es)** | **Data de revisão** |
| :----: | :------: | :---------: | :---------: | :-----------: | :-----------: |
| 29/09/2025 | `1.0` | Versão inicial do documento. | [`@Willian`](https://github.com/Wooo589) | | |
| 15/10/2025 | `1.1` | Adição da 3ª e 4ª sprint no cronograma. | [`@Willian`](https://github.com/Wooo589) | | |
| 27/10/2025 | `1.2` | Inserção da 5ª e 6ª sprint no cronograma. | [`@Willian`](https://github.com/Wooo589) | | |
 04/11/2025 | `1.3` | Preenchimento das atas das sprints. | [`@Willian`](https://github.com/Wooo589) | | |
 19/11/2025 | `1.4` | Preenchimento das atas da sprint 5. | [`@Willian`](https://github.com/Wooo589) | | |