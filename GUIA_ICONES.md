# 🎨 Alterar Ícone da Aplicação As-Built

## 🚀 Início Rápido

### Para Android:
1. Crie uma imagem PNG **1024x1024 pixels** com o design desejado
2. Salve como: `assets/icons/app_icon_android.png`
3. Execute: `.\alterar_icone_android.ps1`

### Para Windows:
1. Crie um arquivo `.ico` com múltiplos tamanhos (use: https://www.icoconverter.com/)
2. Salve como: `app_icon_novo.ico` na raiz do projeto
3. Execute: `.\alterar_icone.ps1`

### Para Ambas as Plataformas:
Execute: `.\alterar_icone_app.ps1`

---

## 🎨 Design Recomendado

**Elemento Visual**: Turbina eólica (ícone wind_power do Material Icons)  
**Gradiente**: #0F4C81 (azul escuro) → #00BCD4 (turquesa)  
**Tamanho Base**: 1024x1024 pixels  
**Formato**: PNG com transparência  
**Padding**: 10-15% de margem

---

## 📚 Documentação Completa

- **Android**: [ALTERAR_ICONE_ANDROID.md](ALTERAR_ICONE_ANDROID.md)
- **Windows**: [ALTERAR_ICONE.md](ALTERAR_ICONE.md)

---

## 🛠️ Ferramentas Recomendadas

### Online (Fácil):
- **Android Asset Studio**: https://romannurik.github.io/AndroidAssetStudio/
- **Canva**: https://www.canva.com/ (design gráfico)
- **Figma**: https://www.figma.com/ (design profissional)
- **ICO Converter**: https://www.icoconverter.com/ (PNG → ICO para Windows)

### Desktop (Profissional):
- **GIMP** (grátis): https://www.gimp.org/
- **Inkscape** (grátis): https://inkscape.org/
- **Photoshop**

---

## ✅ Checklist

- [ ] Criar imagem base 1024x1024 pixels
- [ ] Design: turbina eólica + gradiente azul→turquesa
- [ ] Android: Executar `alterar_icone_android.ps1`
- [ ] Windows: Converter para .ico e executar `alterar_icone.ps1`
- [ ] Testar em dispositivo/emulador
- [ ] Verificar ícone em diferentes contextos (launcher, settings, multitask)

---

## 🔧 Método Manual (Avançado)

### Android:
```powershell
# 1. Instalar dependência
flutter pub get

# 2. Configurar pubspec.yaml (veja ALTERAR_ICONE_ANDROID.md)

# 3. Gerar ícones
flutter pub run flutter_launcher_icons

# 4. Compilar
flutter build apk
```

### Windows:
```powershell
# 1. Substituir arquivo
Copy-Item app_icon_novo.ico windows\runner\resources\app_icon.ico

# 2. Limpar e recompilar
flutter clean
flutter build windows
```

---

## 📱 Exemplo de Design

```
┌─────────────────────────────┐
│                             │
│         ⚡                   │  <- Turbina eólica
│      ╱  │  ╲                │     (ícone wind_power)
│    ╱    │    ╲              │
│  ╱      │      ╲            │
│         │                   │
│                             │
│  Gradiente:                 │
│  #0F4C81 ───────► #00BCD4   │
│  (Azul escuro) → (Turquesa) │
│                             │
└─────────────────────────────┘
```

---

## ⚠️ Notas Importantes

1. **Não use cantos arredondados** na imagem base - Android/Windows adicionam automaticamente
2. **Deixe margem (padding)** de 10-15% para evitar cortes
3. **Use PNG** para transparência (não JPEG)
4. **Teste em dispositivos reais** - emuladores podem cachear ícones antigos
5. **Desinstale e reinstale** se o ícone não atualizar (cache do sistema)

---

## 🆘 Problemas Comuns

**Ícone não muda após compilar:**
```powershell
flutter clean
adb uninstall com.example.as_built_app  # Android
flutter install
```

**Ícone aparece cortado:**
- Adicione mais padding (margem de 15-20%)
- Use ferramentas automáticas que respeitam as safe zones

**Cores diferentes em cada tamanho:**
- Use flutter_launcher_icons ou Android Asset Studio
- Não redimensione manualmente
