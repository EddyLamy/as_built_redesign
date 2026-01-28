# Script de Instalação Automática - As-Built v2.0
# PowerShell Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  As-Built v2.0 - Instalação Automática" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar se Flutter está instalado
Write-Host "[1/5] Verificando Flutter..." -ForegroundColor Yellow
$flutterVersion = flutter --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO: Flutter não encontrado!" -ForegroundColor Red
    Write-Host "Instala Flutter primeiro: https://flutter.dev" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Flutter encontrado" -ForegroundColor Green

# 2. Criar diretório de destino
Write-Host ""
Write-Host "[2/5] Criando diretório..." -ForegroundColor Yellow
$destinoPath = "C:\src\AS_BUILT\as_built_redesign"
if (Test-Path $destinoPath) {
    Write-Host "Diretório já existe. Apagar? (S/N)" -ForegroundColor Yellow
    $resposta = Read-Host
    if ($resposta -eq "S" -or $resposta -eq "s") {
        Remove-Item -Recurse -Force $destinoPath
        Write-Host "✓ Diretório antigo removido" -ForegroundColor Green
    } else {
        Write-Host "Instalação cancelada." -ForegroundColor Red
        exit 0
    }
}
New-Item -ItemType Directory -Path $destinoPath -Force | Out-Null
Write-Host "✓ Diretório criado: $destinoPath" -ForegroundColor Green

# 3. Extrair ficheiros (assumindo que o ZIP está no Desktop)
Write-Host ""
Write-Host "[3/5] Extraindo ficheiros..." -ForegroundColor Yellow
$zipPath = "$env:USERPROFILE\Downloads\as_built_redesign.zip"
if (-not (Test-Path $zipPath)) {
    Write-Host "ERRO: Ficheiro $zipPath não encontrado!" -ForegroundColor Red
    Write-Host "Baixa o ficheiro as_built_redesign.zip para Downloads primeiro." -ForegroundColor Red
    exit 1
}
Expand-Archive -Path $zipPath -DestinationPath "C:\src\AS_BUILT\" -Force
Write-Host "✓ Ficheiros extraídos" -ForegroundColor Green

# 4. Instalar dependências
Write-Host ""
Write-Host "[4/5] Instalando dependências Flutter..." -ForegroundColor Yellow
Set-Location $destinoPath
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO: Falha ao instalar dependências!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Dependências instaladas" -ForegroundColor Green

# 5. Instruções finais
Write-Host ""
Write-Host "[5/5] Configuração Firebase pendente..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Abre: $destinoPath\lib\main.dart" -ForegroundColor White
Write-Host "2. Localiza a linha 11 (Firebase.initializeApp)" -ForegroundColor White
Write-Host "3. Substitui 'YOUR_API_KEY', 'YOUR_PROJECT_ID', etc" -ForegroundColor White
Write-Host "   pelas credenciais do Firebase Console" -ForegroundColor White
Write-Host ""
Write-Host "4. Depois executa:" -ForegroundColor White
Write-Host "   cd $destinoPath" -ForegroundColor Cyan
Write-Host "   flutter run -d windows" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Instalação concluída!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
