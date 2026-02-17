# 🚀 COMO ALTERAR O ÍCONE - RESUMO RÁPIDO

## Para Android (Você está aqui agora! 📱)

### Passo 1️⃣: Criar Imagem do Ícone
Crie uma imagem PNG **1024x1024 pixels** com:
- **Design**: Turbina eólica (ícone wind_power)
- **Cores**: Gradiente azul (#0F4C81) → turquesa (#00BCD4)
- **Margem**: 10-15% de padding
- **Ferramentas sugeridas**:
  - Online: https://www.canva.com/
  - Desktop: GIMP (https://www.gimp.org/)

### Passo 2️⃣: Salvar na Pasta Correta
- Salve como: `assets/icons/app_icon_android.png`
- A pasta já está criada ✅

### Passo 3️⃣: Executar Script
Abra o PowerShell na raiz do projeto e execute:
```powershell
.\alterar_icone_android.ps1
```

O script vai:
- ✅ Verificar se a imagem existe
- ✅ Configurar o pubspec.yaml automaticamente
- ✅ Gerar todos os tamanhos de ícone (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ Criar ícones adaptativos para Android 8.0+
- ✅ Recompilar a aplicação

### Passo 4️⃣: Testar
```powershell
# Desinstalar versão antiga (limpa cache de ícones)
adb uninstall com.example.as_built_app

# Instalar nova versão
flutter install
```

---

## Para Windows (Futuro) 🪟

### Passo 1️⃣: Converter Imagem para .ICO
- Use: https://www.icoconverter.com/
- Upload da imagem PNG 1024x1024
- Marque todos os tamanhos (16, 32, 48, 64, 128, 256)
- Baixe o arquivo .ico

### Passo 2️⃣: Salvar na Raiz
- Salve como: `app_icon_novo.ico` (raiz do projeto)

### Passo 3️⃣: Executar Script
```powershell
.\alterar_icone.ps1
```

---

## 📚 Documentação Completa

Se precisar de mais detalhes:
- **Guia Geral**: [GUIA_ICONES.md](GUIA_ICONES.md)
- **Android Detalhado**: [ALTERAR_ICONE_ANDROID.md](ALTERAR_ICONE_ANDROID.md)
- **Windows Detalhado**: [ALTERAR_ICONE.md](ALTERAR_ICONE.md)

---

## 🎨 Inspiração de Design

```
┌──────────────────────────────┐
│                              │
│            ⚡                 │
│         ╱  │  ╲               │  Turbina eólica
│       ╱    │    ╲             │  moderna com
│     ╱      │      ╲           │  gradiente azul
│           │                  │  → turquesa
│                              │
│   Gradiente Suave:           │
│   #0F4C81 ────────► #00BCD4  │
│   (Deep Blue) → (Turquoise)  │
│                              │
└──────────────────────────────┘
```

---

## ⚡ Checklist Rápido

Android:
- [ ] Criar `assets/icons/app_icon_android.png` (1024x1024)
- [ ] Executar `.\alterar_icone_android.ps1`
- [ ] Desinstalar e reinstalar app no dispositivo
- [ ] Verificar ícone no launcher e configurações

Windows:
- [ ] Criar `app_icon_novo.ico` (múltiplos tamanhos)
- [ ] Executar `.\alterar_icone.ps1`
- [ ] Recompilar com `flutter build windows`
- [ ] Verificar executável em `build\windows\x64\runner\Release\`

---

## 🆘 Problemas?

**Ícone não aparece após compilar:**
```powershell
# Limpar tudo
flutter clean

# Android: desinstalar completamente
adb uninstall com.example.as_built_app

# Reinstalar
flutter install
```

**Não sei como criar a imagem:**
- Use Canva (mais fácil): https://www.canva.com/
- Busque por "wind turbine icon gradient"
- Ajuste cores para #0F4C81 e #00BCD4
- Exporte 1024x1024 PNG

**Script não funciona:**
- Verifique se a imagem está na pasta correta
- Certifique-se que o nome é exato: `app_icon_android.png`
- Execute `flutter pub get` primeiro

---

## 📞 Onde Pedir Ajuda

Leia os guias detalhados:
1. [GUIA_ICONES.md](GUIA_ICONES.md) - Visão geral
2. [ALTERAR_ICONE_ANDROID.md](ALTERAR_ICONE_ANDROID.md) - Android passo a passo
3. [assets/icons/README.md](assets/icons/README.md) - Especificações da imagem
