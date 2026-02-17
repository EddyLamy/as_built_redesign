# Pasta de Ícones da Aplicação

## 📁 Esta pasta deve conter:

### Para Android:
- **app_icon_android.png** - Imagem 1024x1024 pixels

## 🎨 Especificações do Ícone

### Tamanho:
- **1024x1024 pixels** (base para gerar todos os outros tamanhos)

### Design Recomendado:
- **Símbolo**: Turbina eólica (ícone wind_power do Material Icons)
- **Gradiente**: #0F4C81 (azul escuro) → #00BCD4 (turquesa)
- **Formato**: PNG com transparência
- **Padding**: Deixe 10-15% de margem para evitar cortes

### Exemplo Visual:
```
┌─────────────────────┐
│     [margem]        │
│                     │
│   ⚡ Turbina Eólica │  <- Ícone wind_power
│      Gradiente      │     centralizado
│   Azul → Turquesa   │
│                     │
│     [margem]        │
└─────────────────────┘
```

## 🛠️ Como Criar:

### Opção 1: Online (Fácil)
1. Acesse: https://www.canva.com/ ou https://www.figma.com/
2. Crie uma tela 1024x1024 pixels
3. Adicione um círculo/quadrado com gradiente #0F4C81 → #00BCD4
4. Adicione o ícone de turbina eólica no centro
5. Exporte como PNG
6. Salve nesta pasta como `app_icon_android.png`

### Opção 2: GIMP (Desktop Gratuito)
1. Baixe GIMP: https://www.gimp.org/
2. Novo > 1024x1024 pixels
3. Use a ferramenta de gradiente (azul → turquesa)
4. Adicione o símbolo de turbina eólica
5. Exportar como > PNG
6. Salve como `app_icon_android.png`

### Opção 3: Material Icons + Gradiente
1. Baixe o ícone wind_power: https://fonts.google.com/icons?icon.query=wind
2. Abra em editor de imagem
3. Aplique gradiente #0F4C81 → #00BCD4
4. Redimensione para 1024x1024
5. Salve como `app_icon_android.png`

## 📱 Após Criar o Ícone:

1. Copie o arquivo para esta pasta (`assets/icons/`)
2. Execute o script automatizado:
   ```powershell
   .\alterar_icone_android.ps1
   ```
3. Ou manualmente:
   ```powershell
   # Descomentar configuração no pubspec.yaml
   flutter pub get
   flutter pub run flutter_launcher_icons
   flutter build apk
   ```

## ✅ Verificação:

Seu ícone deve ter:
- [x] Tamanho: 1024x1024 pixels
- [x] Formato: PNG
- [x] Gradiente: Azul (#0F4C81) → Turquesa (#00BCD4)
- [x] Símbolo: Turbina eólica centralizada
- [x] Margem: 10-15% de padding
- [x] Nome: `app_icon_android.png`
- [x] Local: Esta pasta (`assets/icons/`)

## 🔗 Links Úteis:

- **Guia Completo**: [../GUIA_ICONES.md](../GUIA_ICONES.md)
- **Android**: [../ALTERAR_ICONE_ANDROID.md](../ALTERAR_ICONE_ANDROID.md)
- **Windows**: [../ALTERAR_ICONE.md](../ALTERAR_ICONE.md)
- **Material Icons**: https://fonts.google.com/icons?icon.query=wind
- **Canva**: https://www.canva.com/
- **Figma**: https://www.figma.com/
- **GIMP**: https://www.gimp.org/
