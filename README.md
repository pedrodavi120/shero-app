# SHERO - Gerenciador Tático de Super-Heróis

**Universidade Federal do Rio Grande do Norte (UFRN)**  
**Componente Curricular:** Programação para Dispositivos Móveis (PDM)  
**Docente:** Prof. Dr. Taniro C. Rodrigues  
**Discente:** Trabalho Individual de Implementação (1ª Unidade)  

---

## 1. Descrição do Projeto

O **SHERO** é uma aplicação móvel desenvolvida no framework Flutter com o objetivo de consumir uma API RESTful local de super-heróis, implementar persistência em cache local segundo a diretriz de arquitetura *Offline-First*, gerenciar um esquadrão tático com regras estritas de capacidade e simular cenários de combate baseados em atributos.

A estrutura da aplicação segue o padrão arquitetural em camadas baseado nos conceitos apresentados em aula (Clean Architecture e Service/Repository Pattern), utilizando `Provider` para injeção de dependências e gerência de estado.

---

## 2. Instruções de Execução

### 2.1. Execução do Servidor Local (Mock REST com `json-server`)

O backend simulado utiliza a base de dados contendo 563 super-heróis obtida do repositório público `akabab/superhero-api`. Os dados encontram-se estruturados no arquivo `server/db.json`.

Para iniciar o servidor local via Node.js / npm:

```bash
cd server
npm install
npm start
```

Alternativamente, a execução pode ser realizada a partir do diretório raiz:

```bash
npx json-server --host 0.0.0.0 --port 3000 server/db.json
```

**Configuração de Rede:**
* Emuladores Android mapeiam o endereço do host local através de `http://10.0.2.2:3000`.
* Execuções no ambiente Desktop (Windows/macOS/Linux) utilizam `http://localhost:3000`.
* O cliente HTTP (`ApiClient`) possui rotina de contingência com cache local e espelhamento remoto em caso de indisponibilidade momentânea da porta local.

### 2.2. Execução da Aplicação Móvel

1. Baixar os pacotes e dependências especificadas no `pubspec.yaml`:
```bash
flutter pub get
```

2. Executar no emulador configurado ou dispositivo físico conectado:
```bash
flutter run
```

---

## 3. Arquitetura e Decisões de Projeto

A aplicação está dividida em camadas bem definidas sob o diretório `lib/`:

* **`core/di/`**: Configuração centralizada da árvore de dependências (`ConfigureProviders`), injetando instâncias singleton de DAOs, repositórios, cliente de rede e persistência chave-valor.
* **`data/network/`**: Contém o cliente HTTP baseado em `dio` (`ApiClient`), o mapeador de rede (`NetworkMapper`) e as entidades de transferência de dados (`HeroNetworkEntity`).
* **`data/database/`**: Implementa o acesso ao SQLite via `sqflite`. Define os contratos das tabelas, os objetos de acesso a dados (`HeroDao` e `SquadDao`) e o conversor de entidades (`DatabaseMapper`).
* **`data/repository/`**: Implementa o repositório de dados (`HeroRepositoryImpl`), aplicando as regras de negócio de sincronização, cache e sorteios.
* **`domain/`**: Entidades puras do domínio (`HeroModel`) e classes de exceção desacopladas de frameworks.
* **`ui/`**: Camada de apresentação contendo telas (`ui/page/`) e componentes reutilizáveis (`ui/widgets/`).

---

## 4. Conformidade com os Requisitos da Avaliação

### 4.1. Catálogo Geral de Agentes (Slide 5)
* Implementação via `PagedListView` utilizando a biblioteca `infinite_scroll_pagination`.
* Mecanismo *Offline-First*: cada requisição remota persiste os registros na tabela SQLite `heroes_cache`. Em caso de falha de conexão ou ausência de sinal, a consulta é redirecionada automaticamente para o banco local.
* Exibição de cards contendo nome, miniaturas em cache via `cached_network_image`, gênero, raça e destaques de powerstats.
* Navegação para a visualização detalhada ao selecionar um card.

### 4.2. Detalhes do Agente (Slide 6)
* Carregamento preferencial da API remota com fallback para o banco local.
* Renderização da imagem em alta resolução através de `cached_network_image`.
* Apresentação integral dos atributos biográficos, alinhamento, ocupação, relações familiares e afiliações.
* Apresentação individualizada dos seis atributos de combate (*Intelligence, Strength, Speed, Durability, Power, Combat*) por meio da biblioteca `primer_progress_bar`.

### 4.3. Contrato Diário e Recrutamento (Slide 7)
* Disponibilização de um agente aleatório com janela de atualização de 24 horas.
* Persistência da data da última convocação e do identificador do agente sorteado via `shared_preferences`.
* Card formatado exclusivamente com identificação, imagem e powerstats.
* Operação de recrutamento com validação estrita da capacidade do esquadrão (teto máximo de 15 integrantes).
* Inclusão de funcionalidade de teste no cabeçalho para possibilitar a simulação de novos sorteios durante a avaliação docente.

### 4.4. Gestão do Esquadrão (Slides 8 e 9)
* Listagem restrita aos heróis persistidos na tabela local `squad`.
* Identificação automática do papel tático preponderante e maior atributo de combate de cada membro.
* Operação de dispensa com obrigatoriedade de diálogo de confirmação acionado pela biblioteca `awesome_dialog`.

### 4.5. Central Tática de Missões e Combate (Slides 10 a 13)
* Validação de pré-requisito mínimo de 5 integrantes no esquadrão para liberação do módulo.
* Sorteio aleatório de Desafios de Crise com extensão variável entre 3 e 5 rodadas.
* Em cada rodada, é sorteado um atributo determinante e um oponente do catálogo geral, aplicando filtro de exclusão para impedir que membros do próprio esquadrão atuem como adversários.
* Ocultação prévia dos atributos numéricos do inimigo durante a etapa de apresentação.
* Escalação em grade 3x5 de agentes com representação circular e bloqueio estrito contra reutilização de agentes no mesmo combate.
* Avaliação matemática da disputa:
  * Valor do Herói > Valor do Inimigo: Sucesso (Vitória).
  * Valor do Herói < Valor do Inimigo: Falha (Derrota).
  * Valores Iguais: Empate tático.
* Fechamento da missão com apresentação de sumário estatístico e acionamento de modalidade correspondente da biblioteca `awesome_dialog`:
  * **Vitória global** (`DialogType.success`): aplicada quando o esquadrão obtém vitórias em mais da metade dos rounds. Sorteia um dos agentes participantes da campanha vitoriosa, incrementa permanentemente +1 ponto em um atributo aleatório no banco SQLite e exibe a imagem do herói agraciado.
  * **Derrota global** (`DialogType.error`): aplicada nos demais casos, informando a falha operacional da campanha.

---

## 5. Bibliotecas Integradas

* `json-server`: v1.0.0-beta.3
* `infinite_scroll_pagination`: ^4.0.0
* `cached_network_image`: ^3.4.1
* `primer_progress_bar`: ^0.1.0
* `awesome_dialog`: ^3.2.1
* `shared_preferences`: ^2.3.0
* `sqflite`: ^2.3.3+1
* `dio`: ^5.6.0
* `provider`: ^6.1.2
