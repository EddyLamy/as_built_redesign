# Como Alterar o Ícone da Aplicação Android

## Localização dos Ícones Atuais
Os ícones da aplicação Android estão em:
```
android/app/src/main/res/mipmap-mdpi/ic_launcher.png     (48x48 pixels)
android/app/src/main/res/mipmap-hdpi/ic_launcher.png     (72x72 pixels)
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png    (96x96 pixels)
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png   (144x144 pixels)
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png  (192x192 pixels)
```

## 🚀 Método Rápido (Recomendado): Usar Flutter Launcher Icons

### 1. Criar uma imagem base
Crie um arquivo PNG **1024x1024 pixels** com:
- Ícone wind_power (turbina eólica)
- Gradiente: #0F4C81 (azul) → #00BCD4 (turquesa)
- Fundo: Transparente ou com cor sólida
- Nome: `app_icon_android.png`
- Salve em: `assets/icons/app_icon_android.png`

### 2. Adicionar dependência (já instalada)
Verifique se está no `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### 3. Configurar flutter_launcher_icons
Adicione ao final do `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icons/app_icon_android.png"
  adaptive_icon_background: "#0F4C81"  # Cor de fundo para ícones adaptativos
  adaptive_icon_foreground: "assets/icons/app_icon_android.png"
```

### 4. Gerar os ícones automaticamente
Execute no terminal:
```powershell
flutter pub get
flutter pub run flutter_launcher_icons
```

### 5. Recompilar a aplicação
```powershell
flutter clean
flutter build apk
# ou
flutter run
```

---

## 🎨 Método Manual (Alternativo)

### 1. Criar imagens em múltiplas densidades

Você precisa criar 5 versões da mesma imagem:
- **mdpi**: 48x48 pixels
- **hdpi**: 72x72 pixels
- **xhdpi**: 96x96 pixels
- **xxhdpi**: 144x144 pixels
- **xxxhdpi**: 192x192 pixels

### 2. Ferramentas para criar ícones

#### Opção A: Android Asset Studio (Online - MELHOR)
1. Acesse: https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
2. Faça upload da sua imagem base (1024x1024)
3. Ajuste padding, shape, cor de fundo
4. Clique em "Download .ZIP"
5. Extraia e copie os arquivos para as pastas mipmap-*

#### Opção B: easyappicon.com
1. Acesse: https://easyappicon.com/
2. Faça upload da imagem 1024x1024
3. Selecione "Android"
4. Baixe o ZIP com todas as densidades

#### Opção C: appicon.co
1. Acesse: https://www.appicon.co/
2. Upload da imagem 1024x1024
3. Baixe os ícones Android

### 3. Substituir os arquivos manualmente

Faça backup primeiro:
```powershell
Copy-Item android/app/src/main/res/mipmap-mdpi/ic_launcher.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png.backup
Copy-Item android/app/src/main/res/mipmap-hdpi/ic_launcher.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png.backup
Copy-Item android/app/src/main/res/mipmap-xhdpi/ic_launcher.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png.backup
Copy-Item android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png.backup
Copy-Item android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png.backup
```

Depois copie os novos ícones:
```powershell
# Substitua os arquivos nas respectivas pastas
# Mantendo o nome: ic_launcher.png
```

---

## 📱 Ícones Adaptativos (Android 8.0+)

Para melhor aparência no Android moderno, use ícones adaptativos:

### Estrutura:
```
android/app/src/main/res/
  ├── mipmap-anydpi-v26/
  │   └── ic_launcher.xml
  ├── mipmap-mdpi/
  │   ├── ic_launcher_foreground.png
  │   └── ic_launcher.png
  ├── mipmap-hdpi/
  │   ├── ic_launcher_foreground.png
  │   └── ic_launcher.png
  └── values/
      └── ic_launcher_background.xml
```

O Android Asset Studio gera automaticamente ícones adaptativos.

---

## ✅ Verificar o Novo Ícone

1. Após gerar/copiar os ícones, limpe e recompile:
   ```powershell
   flutter clean
   flutter pub get
   flutter build apk
   ```

2. Instale no dispositivo:
   ```powershell
   flutter install
   # ou
   flutter run
   ```

3. Verifique:
   - Tela inicial (launcher)
   - Gaveta de aplicativos
   - Configurações do sistema
   - Multitarefa

---

## 🎨 Design Recomendado

### Para o Ícone As-Built:
- **Base**: Imagem 1024x1024 pixels
- **Símbolo**: Turbina eólica (wind_power icon)
- **Gradiente**: #0F4C81 → #00BCD4
- **Estilo**: Moderno, profissional
- **Formato**: PNG com transparência OU com fundo sólido circular
- **Padding**: Deixe 10-15% de margem para ícones adaptativos

### Exemplo de Design:
```
┌─────────────────┐
│                 │
│   ⚡ [Turbina]   │  <- Ícone wind_power centralizado
│                 │
│  Gradiente      │  <- Azul → Turquesa
│  #0F4C81        │
│  ↓              │
│  #00BCD4        │
│                 │
└─────────────────┘
```

---

## 🛠️ Script Automático

Use o script `alterar_icone_android.ps1` para automatizar todo o processo:
```powershell
.\alterar_icone_android.ps1
```

---

## 📚 Recursos Úteis

- **Android Asset Studio**: https://romannurik.github.io/AndroidAssetStudio/
- **Flutter Launcher Icons**: https://pub.dev/packages/flutter_launcher_icons
- **Material Icons**: https://fonts.google.com/icons?icon.query=wind
- **Android Icon Guidelines**: https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher

---

## ⚠️ Notas Importantes

1. **Formato**: Use PNG (não JPEG) para suporte a transparência
2. **Tamanho**: Sempre comece com 1024x1024 e reduza proporcionalmente
3. **Cache**: Android pode cachear ícones - desinstale e reinstale se necessário
4. **Adaptive Icons**: São obrigatórios para Android 8.0+ para melhor aparência
5. **Formato quadrado**: Evite cantos arredondados na imagem base (Android adiciona automaticamente)

---

## 🔧 Resolução de Problemas

### Ícone não muda após compilar:
```powershell
# Desinstale completamente a app
flutter clean
adb uninstall com.example.as_built_app
# Reinstale
flutter install
```

### Ícone aparece cortado:
- Adicione mais padding na imagem base (margem de 15-20%)
- Use Android Asset Studio para ajustar

### Cores diferentes em cada densidade:
- Use uma ferramenta automática (flutter_launcher_icons ou Android Asset Studio)
- Não redimensione manualmente com ferramentas de baixa qualidade
