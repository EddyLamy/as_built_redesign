/// Conteúdo de documentação para diferentes tópicos e idiomas
class DocumentationContent {
  /// Obter conteúdo de documentação por tópico e idioma
  static String getContent(String topic, String locale) {
    final content = locale == 'pt' ? _contentPT : _contentEN;
    return content[topic] ?? 'Conteúdo não disponível';
  }

  // ══════════════════════════════════════════════════════════════
  // CONTEÚDO EM PORTUGUÊS
  // ══════════════════════════════════════════════════════════════
  static final Map<String, String> _contentPT = {
    'quick_start': '''
# 🚀 Guia de Início Rápido

  Bem-vindo ao **As-Built**. A aplicação concentra o acompanhamento da instalação, documentação, NCRs, equipas e relatórios do projeto num único fluxo.

## 📋 Primeiros Passos

  ### 1. Entrar e selecionar um projeto
  • Faça login com a sua conta
  • No dashboard, selecione o projeto no topo
  • Se ainda não existir projeto, use **Novo Projeto** no menu lateral

### 2. Adicionar Turbinas
  • No dashboard, use o botão flutuante com o ícone de turbina
  • Confirme o nome sugerido, a sequência e o número de middle sections
  • A turbina é criada com componentes e fases base automaticamente

  ### 3. Registar progresso da instalação
  • Abra os detalhes da turbina a partir da lista do dashboard
  • Registe dados nas fases de Receção, Preparação, Pré-Assemblagem, Assemblagem, Torque & Tensionamento e Fases Finais
  • Use observações, datas, fotografias e checkpoints para manter o histórico completo

  ### 4. Complementar com módulos de apoio
  • **Daily Journal** para o resumo diário do site
  • **NCRs** para não conformidades e ações corretivas
  • **Documentation** para ficheiros, tags e categorias
  • **Team** para empresas, membros e permissões

  ### 5. Gerar relatórios
  • Use o botão de relatórios disponível nos ecrãs com projeto selecionado
  • Escolha fases, NCRs, equipamentos, gruas e Daily Journal
  • Gere o ficheiro e valide o resultado antes de partilhar

## 💡 Dicas Úteis

  ✓ Selecione sempre o projeto correto antes de editar dados
  ✓ Registe a informação logo após a atividade em campo
  ✓ Reveja permissões do projeto antes de adicionar novos utilizadores
  ✓ Use a Central de Ajuda como referência rápida para os módulos principais
    ''',
    'add_turbines': '''
# 🌪️ Como Adicionar Turbinas

  ## Fluxo recomendado

  ### Passo 1: Selecionar o projeto
  • No dashboard, confirme que o projeto certo está selecionado no topo
  • O botão de adicionar turbina só aparece para quem tem permissões de gestão

### Passo 2: Preencher Dados
  Ao abrir o diálogo, valide os campos disponíveis:

  • **Nome da turbina** - o sistema sugere um código com base na sequência
  • **Sequência de instalação** - preenchida automaticamente
  • **Número de middle sections** - entre 1 e 6, conforme a torre real
  • **Localização** - opcional, útil para pad/setor

### Passo 3: Confirmar
  Clique em **Criar Turbina**. O sistema irá:
  ✓ Guardar a turbina no projeto selecionado
  ✓ Gerar automaticamente os componentes base
  ✓ Preparar as fases e estruturas necessárias para o acompanhamento

  ### Passo 4: Rever a estrutura criada
  • Abra a turbina recém-criada
  • Confirme os componentes, secções de torre e fases disponíveis
  • Ajuste localização e observações iniciais se necessário

  ## 🎯 Boas Práticas

✓ Use nomenclatura consistente (WTG-01, WTG-02, etc.)
  ✓ Defina corretamente o número de middle sections antes de começar os registos
  ✓ Crie as turbinas do projeto antes do arranque da instalação em campo
  ✓ Verifique os componentes automáticos logo após a criação
  ✓ Use a localização para facilitar filtros e navegação
    ''',
    'phases': '''
# 📊 Gestão de Fases de Instalação

  ## Visão Geral

  Cada turbina centraliza o progresso em fases operacionais. Entre nos detalhes da turbina para atualizar estado, datas, observações, imagens e controlos de qualidade.

## 1. 📦 Receção / Descarga
  Registe chegada de componentes, data, VUI, número de série e condição à receção.

## 2. 📋 Preparação
  Documente preparação, recursos envolvidos e pré-requisitos antes da montagem.

## 3. 🔧 Pré-Assemblagem
  Registe montagens preliminares, checkpoints e validações intermédias.

## 4. 🏗️ Assemblagem
  Documente a montagem principal, incluindo gruas, condições meteorológicas e conclusão por componente.

## 5. 🔩 Torque & Tensionamento
  Registe valores por ligação, equipamento utilizado, lotes e evidências associadas.

## 6. ✅ Fases Finais
  Feche trabalhos finais, inspeções, commissioning e entrega.

  ## 📌 O que manter atualizado

  • Datas de início e fim
  • Observações operacionais e bloqueios
  • Fotografias e evidências
  • Estado dos componentes e checkpoints

## 🎯 Boas Práticas

✓ Registe dados imediatamente após conclusão
  ✓ Use observações para explicar desvios ou bloqueios
  ✓ Mantenha QC checks e evidências coerentes com o estado final
  ✓ Revise a turbina no dashboard para confirmar progresso global
    ''',
    'daily_journal': '''
  # 📘 Daily Journal

  ## Quando usar

  Use o **Daily Journal** para consolidar o que aconteceu no dia por projeto: progresso, equipas, remarks, tempos de espera e medições de vento.

  ## Como aceder

  • Selecione um projeto
  • Abra o menu lateral
  • Entre em **Daily Journal**

  ## Estrutura do formulário

  O ecrã segue o template Excel original e inclui:

  • **Cabeçalho** com identificação do projeto e controlo do documento
  • **Equipa em obra** e contagens por função/empresa
  • **Progress / Daily Remarks** para descrever atividade executada
  • **Pessoas / Horas** para lançar mão de obra e horas
  • **Waiting Time** para tempos improdutivos
  • **Wind Measurements** para registo das condições de vento

  ## Guardar e reutilizar

  • Guarde o diário pelo ícone ou botão **Guardar Daily Journal**
  • Pode reabrir registos guardados do mesmo projeto e dia para edição
  • O módulo integra-se no gerador de relatórios quando essa opção é selecionada

  ## 🎯 Boas Práticas

  ✓ Preencha o diário no próprio dia
  ✓ Mantenha remarks objetivos e auditáveis
  ✓ Registe tempos de espera com motivo claro
  ✓ Revise vento e horas antes de guardar
    ''',
    'ncrs': '''
  # 📋 NCRs e Não Conformidades

  ## Objetivo

  O módulo de **NCRs** permite registar desvios de qualidade, segurança, logística, documentação ou instalação e acompanhar o fecho até à resolução.

  ## Como aceder

  • Selecione um projeto
  • Abra o menu lateral
  • Entre em **NCRs**

  ## O que pode fazer

  • Pesquisar NCRs por código, título, turbina ou responsável
  • Filtrar por estado, severidade, categoria ou atrasos
  • Alternar entre vista em lista e grelha
  • Criar ou editar NCRs com histórico de estado

  ## Dados principais de uma NCR

  • **Título** e **descrição** do desvio
  • **Turbina associada**
  • **Categoria** e **severidade**
  • **Data limite**
  • **Responsável**
  • **Evidências** e notas de alteração de estado

  ## Fluxo de acompanhamento

  1. Criar a NCR com informação mínima completa
  2. Atribuir responsável e prazo
  3. Atualizar o estado à medida que a ação avança
  4. Anexar evidências e nota de fecho quando estiver resolvida

  ## 🎯 Boas Práticas

  ✓ Use títulos curtos e específicos
  ✓ Associe sempre a NCR à turbina correta
  ✓ Não altere o estado sem justificar a mudança
  ✓ Revise NCRs em atraso antes de emitir relatórios
    ''',
    'safety_alerts': '''
  # 🛡️ Sistema de Gestão de Incidentes (SGI)

  ## Objetivo

  O módulo **Sistema de Gestão de Incidentes (SGI)** regista situações de risco, observações e ações corretivas no projeto, mantendo histórico e evidências.

  ## Como aceder

  • Selecione um projeto
  • Abra o menu lateral
  • Entre em **Sistema de Gestão de Incidentes (SGI)**

  ## O que pode fazer

  • Criar registos por categoria (Alerta de Segurança, Near Miss, Walk and Talk)
  • Definir o estado do problema (Em estudo, Em fase de resolução, Resolvido, Requer ação futura)
  • Registar destino e departamento responsável
  • Escrever descrição do problema, possível solução e ação corretiva aplicada
  • Anexar fotos do problema e da resolução

  ## Fluxo recomendado

  1. Criar o registo com descrição clara e categoria correta
  2. Adicionar evidência fotográfica do problema
  3. Definir responsável (destino/departamento) e estado inicial
  4. Atualizar progresso até resolução
  5. Registar ação corretiva aplicada e fotos de resolução

  ## Exportação

  • Pode exportar ou imprimir cada registo em PDF
  • O relatório inclui campos principais e evidências disponíveis
  • O módulo também integra o relatório global quando selecionado

  ## 🎯 Boas Práticas

  ✓ Escreva descrições objetivas e auditáveis
  ✓ Atualize o estado sempre que houver evolução
  ✓ Use fotos antes/depois para comprovar a resolução
  ✓ Evite encerrar registos sem ação corretiva registada
    ''',
    'reports': '''
# 📈 Relatórios - Guia Completo

## Como Gerar Relatórios

  ### Passo 1: Aceder ao botão
  Abra um ecrã com projeto selecionado e clique no **botão de relatórios**.

### Passo 2: Selecionar Fases
  No diálogo pode selecionar, conforme necessário:
☐ Receção / Descarga
☐ Preparação
☐ Pré-Assemblagem
☐ Assemblagem
☐ Torque & Tensionamento
☐ Fases Finais
  ☐ Equipamentos
  ☐ NCRs
☐ Gruas (Pads)
☐ Gruas Gerais
  ☐ Daily Journal

  Também pode ativar **Relatório Completo** para incluir tudo de uma só vez.

### Passo 3: Gerar
  Clique em **Gerar e enviar** e aguarde a criação do ficheiro.

  ## 📍 Resultado esperado

  • O relatório é aberto automaticamente após geração
  • O conteúdo depende apenas das opções assinaladas
  • Revise dados vazios ou módulos sem acesso antes de reenviar

## 🎯 Dicas

  ✓ Gere relatórios por módulo quando estiver a validar equipas diferentes
  ✓ Use NCRs e Daily Journal no mesmo pacote para relatórios diários/semanais
  ✓ Confirme permissões de relatório para visitantes antes de delegar exportações
    ''',
    'cranes': '''
# 🏗️ Gestão de Gruas e Logística

## Dois Tipos de Gruas

### 1. 🌪️ Gruas de Pads (Atribuídas a Turbinas)
  Gruas associadas a uma turbina/pad específico.
  Aceder: Dashboard → abrir turbina → área de gruas/atividades da turbina

### 2. 🏭 Gruas Gerais
  Gruas móveis usadas em várias turbinas ou tarefas de apoio.
  Aceder: Menu lateral → módulo de gruas gerais / logística

## Tipos de Atividades
• **Mobilização** — Chegada e setup da grua
• **Trabalho** — Operação normal
• **Paragem** — Tempo parado (Vento, Mecânico, Componentes, Segurança)
• **Transferência** — Movimentação entre pads (Origem → Destino)
• **Desmobilização** — Saída do site

  ## O que deve ser registado

  • Datas e horas coerentes com a atividade
  • Motivo correto de paragem
  • Pad de origem/destino em transferências
  • Observações para eventos fora do plano

## 🎯 Boas Práticas

✓ Registe mobilizações/desmobilizações sempre
✓ Documente paragens com motivos corretos
  ✓ Use observações para detalhes de segurança e bloqueios
  ✓ Gere relatórios semanais para validar produtividade e indisponibilidades
    ''',
    'users_permissions': '''
# 👥 Utilizadores e Permissões

## Visão Geral

O As-Built tem um sistema de dois níveis de permissões:
• **GlobalRole** — quem é a pessoa na empresa
• **ProjectRole** — o que pode fazer em cada projeto

---

## 🌍 GlobalRole — Roles Globais

Definem o nível de acesso geral na aplicação:

### 👔 Director
• Vê **todos os projetos** automaticamente
• Acesso completo a todos os módulos
• Pode gerir utilizadores (mudar roles)
• Não precisa de ser adicionado a projetos

### 🦺 Site Manager
• Vê **todos os projetos** automaticamente
• Acesso completo a todos os módulos
• Não precisa de ser adicionado a projetos

### 👤 Utilizador
• Vê apenas os projetos onde foi adicionado
• Acesso definido pelo ProjectRole de cada projeto

---

## 🏗️ ProjectRole — Roles por Projeto

Definem o que a pessoa pode fazer num projeto específico:

### 🧑‍💼 Project Manager
• CRUD completo (criar, editar, apagar)
• Gerir equipa e permissões do projeto
• Acesso a todos os módulos do projeto

### 👷 Site Supervisor
• Editar instalação, equipamento e documentação
• Não pode gerir equipa ou permissões
• Acesso operacional completo

### 👁️ Visitante
• Só leitura — não pode editar nada
• Pode gerar relatórios (se autorizado)

---

## ➕ Como Adicionar Utilizadores

### Passo 1: Criar conta no Firebase
O administrador cria a conta em **Firebase Console → Authentication** com email e password.

### Passo 2: Primeiro login
A pessoa faz login na app — o perfil é criado automaticamente com `globalRole: "user"`.

### Passo 3: Definir GlobalRole (se necessário)
Menu lateral → **Utilizadores** → seleciona a pessoa → muda o role no dropdown.

### Passo 4: Adicionar ao Projeto
No projeto → **Team → Permissions → botão "+"** → seleciona a pessoa → escolhe o ProjectRole → define se pode gerar relatórios → Adicionar.

A partir deste momento a pessoa vê o projeto no seu dashboard e pode trabalhar com as permissões atribuídas.

---

## 🔐 Regras de Acesso por Módulo

| Módulo | Project Manager | Site Supervisor | Visitante |
|--------|:-:|:-:|:-:|
| Ver Dashboard | ✅ | ✅ | ✅ |
| Editar Turbinas | ✅ | ✅ | ❌ |
| Módulo Instalação | ✅ | ✅ | ❌ |
| Equipamento | ✅ | ✅ | ❌ |
| Documentação | ✅ | ✅ | ❌ |
| Gerir Equipa | ✅ | ❌ | ❌ |
| Gerar Relatórios | ✅ | ✅ | ✅* |

*Se tiver "Pode gerar relatórios" activado

---

## 💡 Dicas

✓ Directors e Site Managers nunca precisam de ser adicionados a projetos
✓ Um técnico de campo típico tem globalRole "Utilizador" + projectRole "Site Supervisor"
✓ O ProjectRole pode ser diferente em cada projeto
✓ Para remover acesso a um projeto, remove o membro em Team → Permissions
    ''',
    'team_management': '''
# 🏢 Gestão de Equipa por Projeto

## Aceder à Equipa

No dashboard → selecione o projeto → abra **Equipa**.

A equipa está dividida em duas tabs:

---

## 🏭 Tab Companies (Empresas)

Organiza a equipa por empresa subcontratada.

### Adicionar Empresa
1. Clique em **"Adicionar Empresa"**
2. Insira o nome da empresa
3. Confirme

### Adicionar Pessoa à Empresa
1. Clique em **"add_person"** na empresa
2. Insira nome e cargo
3. Confirme

> **Nota:** As pessoas em Companies são registos organizacionais — não são necessariamente utilizadores da app.

---

## 🔐 Tab Permissions (Permissões)

Define quem tem acesso à app e com que role no projeto.

### Ver Membros
Lista todos os utilizadores com acesso ao projeto, mostrando:
• Nome e email
• ProjectRole (Project Manager, Site Supervisor, Visitante)
• Se pode gerar relatórios

### Adicionar Membro
1. Clique no **botão "+"**
2. Selecione o utilizador da lista
3. Escolha o ProjectRole:
   - **Project Manager** — gestão completa
   - **Site Supervisor** — trabalho operacional
   - **Visitante** — só leitura
4. Active/desactive **Pode gerar relatórios**
5. Clique **Adicionar**

> A pessoa aparece na lista de utilizadores disponíveis **apenas após ter feito login** na app pela primeira vez.

### Editar Membro
Clique no membro → mude o role → Guardar

### Remover Membro
Clique no membro → **Remover do Projeto**

---

## 💡 Diferença entre Companies e Permissions

| | Companies | Permissions |
|---|---|---|
| **Para quê** | Organização por empresa | Acesso à app |
| **Quem aparece** | Qualquer pessoa registada | Utilizadores com conta |
| **Efeito** | Visual/organizacional | Define o que podem fazer |

---

## 🎯 Boas Práticas

✓ Adicione sempre as pessoas a Permissions antes de começarem a trabalhar
✓ Use Site Supervisor para técnicos de campo
✓ Use Visitante para clientes ou auditores
✓ Reveja as permissões regularmente
✓ Remova membros quando saírem do projeto
    ''',
  };

  // ══════════════════════════════════════════════════════════════
  // CONTEÚDO EM INGLÊS
  // ══════════════════════════════════════════════════════════════
  static final Map<String, String> _contentEN = {
    'quick_start': '''
# 🚀 Quick Start Guide

  Welcome to **As-Built**. The app brings installation tracking, documentation, NCRs, team access, and reporting into one project workflow.

## 📋 First Steps

  ### 1. Sign in and select a project
  • Log in with your account
  • On the dashboard, select the active project at the top
  • If needed, create a new project from the side menu

### 2. Add Turbines
  • Use the turbine floating action button on the dashboard
  • Confirm the suggested name, sequence, and number of middle sections
  • Base components and installation phases are created automatically

  ### 3. Record installation progress
  • Open the turbine details from the dashboard list
  • Update Reception, Preparation, Pre-Assembly, Assembly, Torque & Tensioning, and Final Phases
  • Keep observations, dates, photos, and checkpoints current

  ### 4. Use the support modules
  • **Daily Journal** for daily site records
  • **NCRs** for non-conformities and corrective actions
  • **Documentation** for files, tags, and categories
  • **Team** for companies, members, and permissions

  ### 5. Generate reports
  • Open the report dialog from any screen with a selected project
  • Choose phases, NCRs, equipment, cranes, and Daily Journal
  • Review the generated file before sharing it

## 💡 Useful Tips

  ✓ Always confirm the selected project before editing data
  ✓ Record field information as soon as the work happens
  ✓ Review project permissions before onboarding new users
  ✓ Use the Help Center as a fast reference for core modules
    ''',
    'add_turbines': '''
# 🌪️ How to Add Turbines

  ## Recommended flow

  ### Step 1: Select the project
  • On the dashboard, confirm the correct project is selected
  • The add turbine button is only available to users with management permissions

### Step 2: Fill Data
  Validate the fields shown in the dialog:

  • **Turbine name** - a code is suggested from the installation sequence
  • **Installation sequence** - filled automatically
  • **Number of middle sections** - from 1 to 6 based on the actual tower
  • **Location** - optional, useful for pad/sector identification

### Step 3: Confirm
  Click **Create Turbine**. The app will:
  ✓ Save the turbine in the selected project
  ✓ Generate the base components automatically
  ✓ Prepare the structure needed for installation tracking

  ### Step 4: Review the generated structure
  • Open the new turbine
  • Confirm sections, components, and phases
  • Adjust initial notes or location if required

## 🎯 Best Practices

✓ Use consistent nomenclature (WTG-01, WTG-02, etc.)
  ✓ Set the middle-section count correctly before field records start
  ✓ Create the project turbines before installation begins on site
  ✓ Review generated components right after creation
  ✓ Use location values to improve filtering and navigation
    ''',
    'phases': '''
# 📊 Installation Phase Management

  Each turbine detail view centralises operational progress. Use it to update statuses, dates, observations, photos, and quality checkpoints.

  1. 📦 **Reception** — Log arrival, VUI, serial number, and condition
  2. 📋 **Preparation** — Register preparation tasks and prerequisites
  3. 🔧 **Pre-Assembly** — Record preliminary assemblies and checks
  4. 🏗️ **Assembly** — Document main erection, cranes, and weather
  5. 🔩 **Torque & Tensioning** — Register values, tools, lots, and evidence
  6. ✅ **Final Phases** — Close inspections, commissioning, and handover

  ## Keep these items updated

  • Start and finish dates
  • Operational remarks and blockers
  • Photos and supporting evidence
  • Component state and checkpoints

## 🎯 Best Practices

✓ Record data immediately after completion
  ✓ Use observations to explain deviations and blockers
  ✓ Keep QC checks and evidence aligned with the final status
  ✓ Review the dashboard to confirm overall turbine progress
    ''',
    'daily_journal': '''
  # 📘 Daily Journal

  ## When to use it

  Use **Daily Journal** to consolidate the daily project record: progress, crews, remarks, waiting time, and wind measurements.

  ## How to access it

  • Select a project
  • Open the side menu
  • Enter **Daily Journal**

  ## Form structure

  The screen follows the original Excel template and includes:

  • **Header** with project and document identification
  • **Site Team** counts by role/company
  • **Progress / Daily Remarks** for executed work
  • **People / Hours** for manpower and hours
  • **Waiting Time** for idle time entries
  • **Wind Measurements** for site conditions

  ## Save and reuse

  • Save with the toolbar icon or **Save Daily Journal** button
  • Reopen saved entries for the same project/day when editing is required
  • The module can be included in the report generator

  ## 🎯 Best Practices

  ✓ Fill the journal on the same day
  ✓ Keep remarks objective and audit-friendly
  ✓ Register waiting time with a clear reason
  ✓ Review wind data and hours before saving
    ''',
    'ncrs': '''
  # 📋 NCRs & Non-Conformities

  ## Purpose

  The **NCR** module is used to record deviations related to quality, safety, logistics, documentation, or installation and to follow them through closure.

  ## How to access it

  • Select a project
  • Open the side menu
  • Enter **NCRs**

  ## What you can do

  • Search NCRs by code, title, turbine, or owner
  • Filter by status, severity, category, or overdue items
  • Switch between list and grid views
  • Create or edit NCRs with status history

  ## Key NCR fields

  • **Title** and **description**
  • **Linked turbine**
  • **Category** and **severity**
  • **Due date**
  • **Assigned owner**
  • **Evidence** and status change notes

  ## Tracking workflow

  1. Create the NCR with complete minimum data
  2. Assign an owner and due date
  3. Update the status as actions progress
  4. Attach evidence and a closure note when resolved

  ## 🎯 Best Practices

  ✓ Keep titles short and specific
  ✓ Always link the NCR to the correct turbine
  ✓ Do not change status without a reason
  ✓ Review overdue NCRs before issuing reports
    ''',
    'safety_alerts': '''
  # 🛡️ Incident Management System (IMS)

  ## Purpose

  The **Incident Management System (IMS)** module is used to register risk situations, observations, and corrective actions while keeping evidence and progress history.

  ## How to access

  • Select a project
  • Open the side menu
  • Enter **Incident Management System (IMS)**

  ## What you can do

  • Create records by category (Safety Alert, Near Miss, Walk and Talk)
  • Set problem status (Under study, In resolution, Resolved, Future company action)
  • Register destination and responsible department
  • Fill in problem description, possible solution, and corrective action taken
  • Attach problem and resolution photos

  ## Recommended workflow

  1. Create the record with a clear description and correct category
  2. Attach problem evidence photos
  3. Define destination/department and initial status
  4. Update progress as actions evolve
  5. Register corrective action and resolution photos

  ## Export

  • You can export or print each record as PDF
  • The report includes key fields and available evidence
  • The module is also included in the global report when selected

  ## 🎯 Best Practices

  ✓ Keep descriptions objective and audit-ready
  ✓ Update status whenever there is progress
  ✓ Use before/after photos to prove resolution
  ✓ Avoid closing records without recording corrective action
    ''',
    'reports': '''
# 📈 Reports - Complete Guide

  ### Step 1: Access
  Open a screen with a selected project and click the **reports** button.

### Step 2: Select Phases
  In the dialog you can include:

  ☐ Reception
  ☐ Preparation
  ☐ Pre-Assembly
  ☐ Assembly
  ☐ Torque & Tensioning
  ☐ Final Phases
  ☐ Equipment
  ☐ NCRs
  ☐ Pad Cranes
  ☐ General Cranes
  ☐ Daily Journal

  You can also enable **Complete Report** to include everything at once.

### Step 3: Generate
  Click **Generate and send** and wait for the file to be created.

  ## Expected result

  • The report opens automatically after generation
  • The final content depends on the selected options
  • Empty sections usually mean no data was available or the user had no access
    ''',
    'cranes': '''
# 🏗️ Crane & Logistics Management

## Two Types of Cranes

### 1. 🌪️ Pad Cranes (Assigned to Turbines)
  Access: Dashboard → open turbine → turbine crane/activity area

### 2. 🏭 General Cranes
  Access: Side menu → general crane / logistics module

## Activity Types
• **Mobilisation** — Crane arrival and setup
• **Work** — Normal operation
• **Stoppage** — Downtime (Wind, Mechanical, Components, Safety)
• **Transfer** — Movement between pads
• **Demobilisation** — Site departure

  ## What to record

  • Consistent dates and times
  • Correct stoppage reason
  • Origin/destination pad during transfers
  • Remarks for out-of-plan events

## 🎯 Best Practices

✓ Always log mobilisations/demobilisations
✓ Document stoppages with correct reasons
  ✓ Use remarks for safety and blockage details
  ✓ Generate weekly crane reports to validate productivity and downtime
    ''',
    'users_permissions': '''
# 👥 Users & Permissions

## Two-Level Permission System

• **GlobalRole** — who the person is in the company
• **ProjectRole** — what they can do in each project

---

## 🌍 GlobalRole — Global Roles

### 👔 Director
• Sees **all projects** automatically
• Full access to all modules
• Can manage users

### 🦺 Site Manager
• Sees **all projects** automatically
• Full access to all modules

### 👤 User
• Sees only projects they were added to
• Access defined by ProjectRole per project

---

## 🏗️ ProjectRole — Per-Project Roles

### 🧑‍💼 Project Manager
• Full CRUD access
• Manage team and permissions

### 👷 Site Supervisor
• Edit installation, equipment and documentation
• Cannot manage team

### 👁️ Visitor
• Read-only access
• Can generate reports (if authorised)

---

## ➕ How to Add Users

1. **Create account** in Firebase Console → Authentication
2. **Person logs in** → profile created automatically
3. **Set GlobalRole** if needed: Side menu → Users → change role
4. **Add to project**: Project → Team → Permissions → "+" → select person → choose ProjectRole → define whether they can generate reports

---

## 💡 Tips

✓ Directors and Site Managers never need to be added to projects
✓ A typical field technician has globalRole "User" + projectRole "Site Supervisor"
✓ ProjectRole can differ per project
    ''',
    'team_management': '''
# 🏢 Project Team Management

## Access Team
  Dashboard → select project → open **Team**.

---

## 🏭 Companies Tab

Organises team by subcontracted company.

• Add companies and people per company
• People here are organisational records — not necessarily app users

---

## 🔐 Permissions Tab

Defines who has app access and their role in the project.

### Add Member
1. Click **"+"** button
2. Select user from list
3. Choose ProjectRole
4. Toggle "Can generate reports"
5. Click **Add**

> The person appears in the available users list **only after logging in** to the app for the first time.

### Edit / Remove Member
Click on the member → change role or remove.

---

## 💡 Best Practices

✓ Always add people to Permissions before they start working
✓ Use Site Supervisor for field technicians
✓ Use Visitor for clients or auditors
✓ Review permissions regularly
    ''',
  };
}
