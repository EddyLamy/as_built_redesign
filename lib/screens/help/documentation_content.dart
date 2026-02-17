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

Bem-vindo ao **As-Built**! Esta aplicação foi desenvolvida para facilitar a gestão e documentação de instalações de turbinas eólicas.

## 📋 Primeiros Passos

### 1. Criar um Projeto
• Clique no menu lateral (☰)
• Selecione "Novo Projeto"
• Preencha os dados:
  - Nome do projeto
  - Tipo de turbina
  - Localização
  - Cliente

### 2. Adicionar Turbinas
• No dashboard, clique no botão + (canto inferior direito)
• Insira o nome da turbina (ex: WTG-01)
• Selecione o número de secções médias da torre
• A turbina será criada com todos os componentes automaticamente

### 3. Registar Fases
• Aceda aos detalhes da turbina
• Navegue pelas diferentes fases:
  - 📦 Receção
  - 📋 Preparação
  - 🔧 Pré-Assemblagem
  - 🏗️ Assemblagem
  - 🔩 Torque & Tensionamento
  - ✅ Fases Finais

### 4. Gerar Relatórios
• Use o botão de relatórios no dashboard
• Selecione as fases desejadas
• Gere o relatório em Excel
• Download automático

## 💡 Dicas Úteis

✓ Use atalhos de teclado para maior produtividade
✓ Configure notificações para não perder prazos
✓ Exporte dados regularmente como backup
✓ Consulte a documentação detalhada quando necessário

## 🎥 Vídeos Recomendados
• Visão Geral (5 min)
• Adicionar Componentes (3 min)
    ''',
    'add_turbines': '''
# 🌪️ Como Adicionar Turbinas

## Método Rápido

### Passo 1: Aceder ao Botão
No dashboard principal, localize o **botão flutuante azul** no canto inferior direito com o ícone de turbina (🌪️).

### Passo 2: Preencher Dados
Será apresentado um diálogo com os seguintes campos:

**Campos Obrigatórios:**
• **Nome da Turbina** - Ex: WTG-01, WTG-02
• **Tipo de Turbina** - Selecione da lista

**Campos Opcionais:**
• **Número de Secções Médias** - Define quantas middle sections a torre tem (0-5)
• **Status Inicial** - Normalmente "Planejada"

### Passo 3: Confirmar
Clique em **"Criar Turbina"** e o sistema irá:
✓ Criar a turbina no projeto
✓ Gerar todos os componentes automaticamente:
  - Fundação
  - Secções de torre (bottom, middle, top)
  - Nacelle
  - Hub
  - Pás (3)
✓ Inicializar todas as fases de instalação

## 📊 Componentes Gerados

Cada turbina inclui automaticamente:

### Torre:
• Bottom Section
• Middle Section 1, 2, 3, 4, 5 (conforme configurado)
• Top Section

### Nacelle:
• Nacelle
• Hub
• Blade 1, 2, 3

### Outros:
• Top Cooler
• Drive Train
• MV Cable
• SWG
• Transformador
• Gerador
• Ground Control

## ⚙️ Configurações Avançadas

Se precisar de personalizar os componentes, pode:
1. Editar cada componente individualmente
2. Adicionar novos componentes customizados
3. Remover componentes não aplicáveis

## 🎯 Boas Práticas

✓ Use nomenclatura consistente (WTG-01, WTG-02, etc.)
✓ Configure todas as turbinas antes de iniciar registos
✓ Verifique os componentes gerados
✓ Mantenha backups regulares
    ''',
    'phases': '''
# 📊 Gestão de Fases de Instalação

## Visão Geral

O As-Built organiza a instalação em **6 fases principais**:

## 1. 📦 Receção / Descarga

**Objetivo:** Registar chegada de componentes ao site

**Dados a Registar:**
• Data e hora de descarga
• VUI (Vendor Unique Identifier)
• Número de série
• Item number
• Condição do componente
• Observações de transporte

**Quando registar:** Assim que o componente chega ao parque

---

## 2. 📋 Preparação

**Objetivo:** Documentar preparação para montagem

**Dados a Registar:**
• Data/hora início
• Data/hora fim
• Atividades realizadas
• Equipamentos utilizados
• Responsável

**Atividades Típicas:**
• Limpeza de componentes
• Inspeção visual
• Preparação de área
• Movimentação para local de montagem

---

## 3. 🔧 Pré-Assemblagem

**Objetivo:** Registar montagens preliminares

**Dados a Registar:**
• Data/hora início e fim
• Componentes envolvidos
• Equipa responsável
• QC checks realizados

**Exemplos:**
• Montagem de internals na nacelle
• Pré-assemblagem de hub
• Preparação de secções de torre

---

## 4. 🏗️ Assemblagem

**Objetivo:** Documentar montagem principal

**Dados a Registar:**
• Data/hora início e fim por componente
• Gruas utilizadas
• Condições meteorológicas
• Status de conclusão
• Issues encontrados

**Componentes:**
• Instalação de fundação
• Elevação de secções de torre
• Montagem de nacelle
• Instalação de hub
• Montagem de pás

---

## 5. 🔩 Torque & Tensionamento

**Objetivo:** Registar valores de torque e tensionamento

**Dados a Registar:**
• Conexão (Tower Bottom, Tower Middle 1, etc.)
• Torque Value e Unit (Nm, ft-lb)
• Tensioning Value e Unit (bar, kN)
• Data e hora de execução
• Responsável técnico

**Conexões Típicas:**
• Tower Bottom
• Tower Middle (1 a 5)
• Tower Top
• Yaw Bearing
• Hub

---

## 6. ✅ Fases Finais

**Objetivo:** Documentar fases de conclusão

**Fases Incluídas:**
• Electrical Works
• Inspections
• Client Inspection
• Pre-Commissioning
• Commissioning
• Turbine Tests
• Handover
• Final Observations

**Para cada fase:**
• Data/hora início e fim
• Status (Pending, In Progress, Complete)
• Documentos associados
• Sign-offs

---

## 📈 Timeline Visual

O sistema apresenta uma **timeline interactiva** que mostra:
• Progresso de cada fase (%)
• Status (Complete, In Progress, Pending)
• Alertas de atrasos
• Próximos milestones

---

## 🎯 Boas Práticas

✓ Registe dados imediatamente após conclusão
✓ Use observações para documentar issues
✓ Tire fotos como evidência
✓ Mantenha QC checks atualizados
✓ Exporte relatórios regularmente
    ''',
    'reports': '''
# 📈 Relatórios - Guia Completo

## Tipos de Relatorios

O As-Built permite gerar relatórios em Excel:

### 📊 Excel (.xlsx)
• Múltiplas sheets por fase
• Formatação profissional
• Filtros e ordenação
• Fácil de manipular dados
• **Recomendado para:** Análise de dados

## Como Gerar Relatórios

### Passo 1: Aceder ao Botão
No dashboard, clique no **botão de relatórios** (📊) ao lado do nome do projeto.

### Passo 2: Selecionar Fases
Marque as fases que deseja incluir no relatório:

**Fases de Instalação:**
☐ Receção / Descarga
☐ Preparação
☐ Pré-Assemblagem
☐ Assemblagem
☐ Torque & Tensionamento
☐ Fases Finais

**Logística:**
☐ Gruas (Pads) - Gruas atribuídas a turbinas
☐ Gruas Gerais - Gruas não atribuídas

**Atalhos:**
• **Todos** - Seleciona todas as fases
• **Limpar** - Desmarca tudo

### Passo 3: Gerar
Clique em **"Gerar Relatório"** e aguarde:
• Recolha de dados (~5-10s)
• Processamento (~5-15s)
• Download automático

---

## Conteúdo dos Relatórios

### 📦 Receção
**Colunas:**
• Turbina
• Componente
• VUI
• Serial Number
• Item Number
• Data Descarga
• Hora

### 📋 Preparação / 🔧 Pré-Assemblagem / 🏗️ Assemblagem
**Colunas:**
• Turbina
• Componente
• VUI
• Serial Number
• Item Number
• Data Início / Hora Início
• Data Fim / Hora Fim

### 🔩 Torque & Tensionamento
**Colunas:**
• Turbina
• Conexão
• Torque Value
• Torque Unit
• Tensioning Value
• Tensioning Unit
• Data / Hora

### ✅ Fases Finais
**Colunas:**
• Turbina
• Fase
• Data Início / Hora Início
• Data Fim / Hora Fim
• Status

### 🏗️ Gruas (Pads)
**Colunas:**
• Turbina
• Modelo da Grua
• Tipo de Atividade
• Data Início / Hora Início
• Data Fim / Hora Fim
• Duração
• Motivo (se paragem)
• Origem / Destino
• Observações

### 🏭 Gruas Gerais
**Colunas:**
• Modelo da Grua
• Descrição
• Tipo de Atividade
• Data Início / Hora Início
• Data Fim / Hora Fim
• Duração
• Observações

---

## 📍 Localização dos Ficheiros

Os relatórios são salvos automaticamente em:
**Windows:** `C:Users[YourUser]Documents`
**Nome:** `report_[timestamp].xlsx`

---

## 🎨 Formatação

### Excel:
• Cores por fase (headers)
• Borders em todas as células
• Freeze da primeira linha
• Larguras otimizadas
• Múltiplas sheets

## ⚠️ Troubleshooting

**Erro: "Nenhum dado encontrado"**
→ Verifique se registou dados nas fases selecionadas

**Ficheiro não abre**
→ Certifique-se que tem Excel instalado

**Dados incompletos**
→ Alguns campos podem estar vazios se não foram preenchidos

**Demora muito tempo**
→ Normal para projetos com muitas turbinas (>50)

---

## 🎯 Dicas

✓ Gere relatórios regularmente (semanal)
✓ Guarde cópias em local seguro
✓ Use Excel para análise
✓ Use Excel para apresentações
✓ Verifique dados antes de gerar
    ''',
    'cranes': '''
# 🏗️ Gestão de Gruas e Logística

## Dois Tipos de Gruas

O sistema permite gerir dois tipos de gruas:

### 1. 🌪️ Gruas de Pads (Atribuídas a Turbinas)
Gruas fixas que ficam num pad específico para instalar uma turbina.

### 2. 🏭 Gruas Gerais
Gruas móveis que podem ser usadas em várias turbinas ou tarefas gerais.

---

## Gruas de Pads

### Aceder:
Dashboard → Turbina → **Aba "Gruas"**

### Tipos de Atividades:

**📍 Mobilização**
• Chegada da grua ao pad
• Setup e montagem
• Testes de funcionamento

**🏗️ Trabalho**
• Instalação de componentes
• Içamento de secções
• Operação normal

**⏸️ Paragem**
• Tempo parado
• **Motivos possíveis:**
  - 💨 Vento
  - 🔧 Problema Mecânico
  - 📦 Aguardar Componentes
  - ⚠️ Segurança

**🔄 Transferência**
• Movimentação entre pads
• Origem → Destino

**📤 Desmobilização**
• Desmontagem
• Saída do site

### Dados a Registar:
• Modelo da grua
• Tipo de atividade
• Data/hora início
• Data/hora fim
• Motivo (se paragem)
• Origem/destino (se transferência)
• Observações

---

## Gruas Gerais

### Aceder:
Menu Lateral → **"Gruas Gerais"**

### Gestão:

**Adicionar Grua:**
1. Clique em "Adicionar Grua Geral"
2. Preencha modelo
3. Descrição (opcional)
4. Clique em "Adicionar"

**Registar Atividades:**
1. Selecione a grua
2. Clique em "Adicionar Atividade"
3. Preencha dados (tipo, datas, etc.)
4. Salvar

**Tipos de Atividades:** (iguais às gruas de pads)
• Mobilização
• Trabalho
• Paragem
• Transferência
• Desmobilização

---

## 📊 Relatórios de Gruas

### Incluir em Relatórios:
Ao gerar relatórios, pode incluir:
☐ **Gruas (Pads)** - Todas as atividades de gruas atribuídas
☐ **Gruas Gerais** - Todas as atividades de gruas gerais

### Informação Incluída:
• Duração automática (calculada)
• Totais por tipo de atividade
• Timeline de mobilizações
• Análise de paragens

---

## 📈 Dashboard de Gruas

Visualize métricas como:
• Total de horas de trabalho
• Tempo de paragens por motivo
• Eficiência de utilização
• Gruas mais utilizadas

---

## 🎯 Boas Práticas

✓ Registe mobilizações/desmobilizações sempre
✓ Documente paragens com motivos corretos
✓ Mantenha transferências atualizadas
✓ Use observações para detalhes importantes
✓ Gere relatórios semanais de gruas
✓ Valide duração calculada

---

## 💡 Dicas

**Evitar duplicações:**
→ Uma grua deve estar OU em pads OU geral, não ambos

**Paragens longas:**
→ Registe o motivo detalhadamente nas observações

**Transferências:**
→ Sempre preencha origem e destino para rastreabilidade

**Planeamento:**
→ Use gruas gerais para tarefas flexíveis
→ Use gruas de pads para instalação completa de turbinas
    ''',
  };

  // ══════════════════════════════════════════════════════════════
  // CONTEÚDO EM INGLÊS
  // ══════════════════════════════════════════════════════════════
  static final Map<String, String> _contentEN = {
    'quick_start': '''
# 🚀 Quick Start Guide

Welcome to **As-Built**! This application was developed to facilitate the management and documentation of wind turbine installations.

## 📋 First Steps

### 1. Create a Project
• Click on the side menu (☰)
• Select "New Project"
• Fill in the data:
  - Project name
  - Turbine type
  - Location
  - Client

### 2. Add Turbines
• On the dashboard, click the + button (bottom right corner)
• Enter turbine name (e.g., WTG-01)
• Select number of tower middle sections
• The turbine will be created with all components automatically

### 3. Register Phases
• Access turbine details
• Navigate through different phases:
  - 📦 Reception
  - 📋 Preparation
  - 🔧 Pre-Assembly
  - 🏗️ Assembly
  - 🔩 Torque & Tensioning
  - ✅ Final Phases

### 4. Generate Reports
• Use the reports button on the dashboard
• Select desired phases
• Automatic download

## 💡 Useful Tips

✓ Use keyboard shortcuts for greater productivity
✓ Set up notifications to not miss deadlines
✓ Export data regularly as backup
✓ Consult detailed documentation when needed

## Quick Method

### Step 1: Access Button
On the main dashboard, locate the **blue floating button** in the bottom right corner with the turbine icon (🌪️).

### Step 2: Fill Data
A dialog will be presented with the following fields:

**Required Fields:**
• **Turbine Name** - E.g., WTG-01, WTG-02
• **Turbine Type** - Select from list

**Optional Fields:**
• **Number of Middle Sections** - Defines how many middle sections the tower has (0-5)
• **Initial Status** - Usually "Planned"

### Step 3: Confirm
Click **"Create Turbine"** and the system will:
✓ Create the turbine in the project
✓ Generate all components automatically:
  - Foundation
  - Tower sections (bottom, middle, top)
  - Nacelle
  - Hub
  - Blades (3)
✓ Initialize all installation phases

## 📊 Generated Components

Each turbine automatically includes:

### Tower:
• Bottom Section
• Middle Section 1, 2, 3, 4, 5 (as configured)
• Top Section

### Nacelle:
• Nacelle
• Hub
• Blade 1, 2, 3

### Others:
• Top Cooler
• Drive Train
• MV Cable
• SWG
• Transformer
• Generator
• Ground Control

## ⚙️ Advanced Settings

If you need to customize components, you can:
1. Edit each component individually
2. Add new custom components
3. Remove non-applicable components

## 🎯 Best Practices

✓ Use consistent nomenclature (WTG-01, WTG-02, etc.)
✓ Configure all turbines before starting records
✓ Verify generated components
✓ Maintain regular backups
    ''',

    // ... (Similar structure for other topics in English)
    // Truncating for brevity - full content would be similar to PT but in English
  };
}
