# Script para alterar o ícone da aplicação Android - As-Built
# Execute este script após criar a imagem base do ícone

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "As-Built - Alterar Ícone Android" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se existe uma imagem base
$imagemBase = "assets\icons\app_icon_android.png"
$pubspecPath = "pubspec.yaml"

# Criar pasta assets/icons se não existir
if (!(Test-Path "assets\icons")) {
    New-Item -ItemType Directory -Path "assets\icons" -Force | Out-Null
    Write-Host "[+] Pasta assets/icons criada" -ForegroundColor Green
}

if (Test-Path $imagemBase) {
    Write-Host "[✓] Imagem base encontrada: $imagemBase" -ForegroundColor Green
    
    # Verificar se tem tamanho adequado (pelo menos 512x512)
    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile((Resolve-Path $imagemBase))
    $largura = $img.Width
    $altura = $img.Height
    $img.Dispose()
    
    Write-Host "[i] Tamanho da imagem: ${largura}x${altura} pixels" -ForegroundColor Cyan
    
    if ($largura -lt 512 -or $altura -lt 512) {
        Write-Host "[!] AVISO: Tamanho recomendado é 1024x1024 pixels!" -ForegroundColor Yellow
        Write-Host "    Sua imagem pode ficar com baixa qualidade." -ForegroundColor Yellow
    } elseif ($largura -eq 1024 -and $altura -eq 1024) {
        Write-Host "[✓] Tamanho perfeito (1024x1024)!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "MÉTODO RECOMENDADO: Flutter Launcher Icons (Automático)" -ForegroundColor Yellow
    Write-Host ""
    
    # Verificar se flutter_launcher_icons está no pubspec
    $pubspecContent = Get-Content $pubspecPath -Raw
    
    if ($pubspecContent -notmatch "flutter_launcher_icons:") {
        Write-Host "[!] Adicionando flutter_launcher_icons ao pubspec.yaml..." -ForegroundColor Yellow
        
        # Adicionar ao dev_dependencies
        if ($pubspecContent -match "dev_dependencies:") {
            $pubspecContent = $pubspecContent -replace "(dev_dependencies:)", "`$1`n  flutter_launcher_icons: ^0.13.1"
        }
        
        Set-Content $pubspecPath $pubspecContent
        Write-Host "[✓] flutter_launcher_icons adicionado!" -ForegroundColor Green
    }
    
    # Verificar se config do flutter_launcher_icons existe
    if ($pubspecContent -notmatch "flutter_launcher_icons:") {
        Write-Host "[!] Adicionando configuração do flutter_launcher_icons..." -ForegroundColor Yellow
        
        $config = @"

# Flutter Launcher Icons Configuration
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icons/app_icon_android.png"
  adaptive_icon_background: "#0F4C81"
  adaptive_icon_foreground: "assets/icons/app_icon_android.png"
"@
        
        Add-Content $pubspecPath $config
        Write-Host "[✓] Configuração adicionada!" -ForegroundColor Green
    }
    
    Write-Host ""
    $escolha = Read-Host "Deseja gerar os ícones automaticamente agora? (S/N)"
    
    if ($escolha -eq "S" -or $escolha -eq "s") {
        Write-Host ""
        Write-Host "Obtendo dependências..." -ForegroundColor Yellow
        flutter pub get
        
        Write-Host ""
        Write-Host "Gerando ícones para Android..." -ForegroundColor Yellow
        flutter pub run flutter_launcher_icons
        
        Write-Host ""
        Write-Host "[✓] Ícones gerados com sucesso!" -ForegroundColor Green
        Write-Host ""
        
        $recompilar = Read-Host "Deseja recompilar a aplicação agora? (S/N)"
        
        if ($recompilar -eq "S" -or $recompilar -eq "s") {
            Write-Host ""
            Write-Host "Limpando build anterior..." -ForegroundColor Yellow
            flutter clean
            
            Write-Host ""
            Write-Host "Compilando APK..." -ForegroundColor Yellow
            flutter build apk
            
            Write-Host ""
            Write-Host "[✓] Compilação concluída!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Localização do APK:" -ForegroundColor Cyan
            Write-Host "  build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
            Write-Host ""
            
            $instalar = Read-Host "Deseja instalar no dispositivo conectado? (S/N)"
            if ($instalar -eq "S" -or $instalar -eq "s") {
                Write-Host ""
                Write-Host "Instalando no dispositivo..." -ForegroundColor Yellow
                flutter install
                Write-Host ""
                Write-Host "[✓] Aplicação instalada!" -ForegroundColor Green
            }
        }
    } else {
        Write-Host ""
        Write-Host "Para gerar manualmente, execute:" -ForegroundColor Cyan
        Write-Host "  flutter pub get" -ForegroundColor White
        Write-Host "  flutter pub run flutter_launcher_icons" -ForegroundColor White
        Write-Host "  flutter build apk" -ForegroundColor White
    }
    
} else {
    Write-Host "[!] Imagem base não encontrada: $imagemBase" -ForegroundColor Red
    Write-Host ""
    Write-Host "INSTRUÇÕES:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. CRIAR IMAGEM BASE" -ForegroundColor Cyan
    Write-Host "   - Tamanho: 1024x1024 pixels" -ForegroundColor White
    Write-Host "   - Formato: PNG" -ForegroundColor White
    Write-Host "   - Design: Turbina eólica com gradiente azul→turquesa" -ForegroundColor White
    Write-Host "   - Salve como: $imagemBase" -ForegroundColor White
    Write-Host ""
    Write-Host "2. FERRAMENTAS RECOMENDADAS" -ForegroundColor Cyan
    Write-Host "   Online (fácil):" -ForegroundColor Yellow
    Write-Host "     - Android Asset Studio: https://romannurik.github.io/AndroidAssetStudio/" -ForegroundColor White
    Write-Host "     - Canva: https://www.canva.com/" -ForegroundColor White
    Write-Host "     - Figma: https://www.figma.com/" -ForegroundColor White
    Write-Host ""
    Write-Host "   Desktop (profissional):" -ForegroundColor Yellow
    Write-Host "     - GIMP (grátis): https://www.gimp.org/" -ForegroundColor White
    Write-Host "     - Inkscape (grátis): https://inkscape.org/" -ForegroundColor White
    Write-Host "     - Photoshop" -ForegroundColor White
    Write-Host ""
    Write-Host "3. DESIGN RECOMENDADO" -ForegroundColor Cyan
    Write-Host "   - Ícone: wind_power (turbina eólica)" -ForegroundColor White
    Write-Host "   - Gradiente: #0F4C81 (azul escuro) → #00BCD4 (turquesa)" -ForegroundColor White
    Write-Host "   - Fundo: Circular ou quadrado com cantos arredondados" -ForegroundColor White
    Write-Host "   - Padding: Deixe 10-15% de margem" -ForegroundColor White
    Write-Host ""
    Write-Host "4. DEPOIS DE CRIAR O ÍCONE" -ForegroundColor Cyan
    Write-Host "   Execute este script novamente" -ForegroundColor White
    Write-Host ""
    Write-Host "Leia ALTERAR_ICONE_ANDROID.md para mais detalhes." -ForegroundColor Yellow
    Write-Host ""
    
    # Opção: Criar ícone básico automaticamente
    $criar = Read-Host "Deseja que eu crie um ícone básico temporário? (S/N)"
    
    if ($criar -eq "S" -or $criar -eq "s") {
        Write-Host ""
        Write-Host "[i] NOTA: Você vai precisar de ImageMagick instalado!" -ForegroundColor Yellow
        Write-Host "    Baixe em: https://imagemagick.org/script/download.php" -ForegroundColor Cyan
        Write-Host ""
        
        # Tentar criar um ícone básico com ImageMagick
        try {
            $comando = "magick -size 1024x1024 gradient:'#0F4C81'-'#00BCD4' -font Arial -pointsize 300 -gravity center -fill white -annotate +0+0 'W' $imagemBase"
            Invoke-Expression $comando
            
            if (Test-Path $imagemBase) {
                Write-Host "[✓] Ícone básico criado!" -ForegroundColor Green
                Write-Host "    IMPORTANTE: Edite este ícone para adicionar o símbolo wind_power!" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Execute o script novamente para gerar os ícones Android." -ForegroundColor Cyan
            }
        } catch {
            Write-Host "[!] Erro ao criar ícone básico." -ForegroundColor Red
            Write-Host "    Crie manualmente usando as ferramentas recomendadas acima." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
