# 🚨 INSTALAÇÃO RÁPIDA - As-Built v2.0

## ⚡ MÉTODO RÁPIDO (Recomendado)

### 1. Baixar ficheiros
- ✅ `as_built_redesign.zip` (16 KB)
- ✅ `INSTALAR.ps1` (script automático)

### 2. Executar script automático
```powershell
# Botão direito em INSTALAR.ps1 → "Executar com PowerShell"
# OU no PowerShell:
cd Downloads
.\INSTALAR.ps1
```

O script vai:
- ✅ Verificar Flutter
- ✅ Criar pasta `C:\src\AS_BUILT\as_built_redesign`
- ✅ Extrair ficheiros do ZIP
- ✅ Executar `flutter pub get`

---

## 🔧 MÉTODO MANUAL (Se script falhar)

### 1. Extrair ZIP
```powershell
# Extrai para:
C:\src\AS_BUILT\as_built_redesign\
```

### 2. Abrir pasta no terminal
```powershell
cd C:\src\AS_BUILT\as_built_redesign
```

### 3. Instalar dependências
```bash
flutter pub get
```

---

## 🔥 CONFIGURAR FIREBASE

### 1. Abrir ficheiro
`C:\src\AS_BUILT\as_built_redesign\lib\main.dart`

### 2. Ir ao Firebase Console
https://console.firebase.google.com

Clica no projeto → **as_built_app (web)** → Copia as credenciais

### 3. Substituir no main.dart (linha ~11)

**ANTES:**
```dart
await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID",
  ),
);
```

**DEPOIS:**
```dart
await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: "AIzaSy...", // ← Cola aqui
    authDomain: "as-built-xxx.firebaseapp.com",
    projectId: "as-built-xxx",
    storageBucket: "as-built-xxx.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123...:web:abc",
  ),
);
```

---

## ▶️ EXECUTAR APP

```bash
# Windows Desktop
flutter run -d windows

# OU Web (Chrome)
flutter run -d chrome
```

---

## 📂 ESTRUTURA DO PROJETO

```
as_built_redesign/
├── lib/
│   ├── main.dart                    ← EDITAR AQUI (Firebase)
│   ├── core/
│   │   └── theme/
│   │       ├── app_colors.dart      ← Cores profissionais
│   │       └── app_theme.dart       ← Tema Material 3
│   ├── models/
│   │   ├── project.dart
│   │   ├── turbina.dart
│   │   └── componente.dart
│   └── screens/
│       ├── auth/
│       │   └── login_screen.dart    ← Tela de login
│       └── dashboard/
│           └── dashboard_screen.dart ← Dashboard
├── assets/
│   └── master_template.json         ← 20 componentes base
└── pubspec.yaml                     ← Dependências
```

---

## ⚠️ PROBLEMAS COMUNS

### "Flutter não encontrado"
```bash
# Adiciona Flutter ao PATH:
$env:Path += ";C:\flutter\bin"
```

### "Erro ao extrair ZIP"
- Extrai manualmente (botão direito → Extract All)
- Move pasta para `C:\src\AS_BUILT\`

### "Firebase not initialized"
- Verifica se copiaste TODAS as credenciais no `main.dart`
- Confirma que não há espaços/aspas extra

---

## 📞 SUPORTE

Se tudo falhar:
1. Copia mensagem de erro COMPLETA
2. Cola no chat
3. Indico próximos passos

**Boa sorte! 🚀**
