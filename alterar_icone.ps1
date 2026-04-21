param(
    [string]$IconPath = "C:\Users\Utilizador\OneDrive - 2windservice\Imagens\As-Built.ico",
    [switch]$Rebuild,
    [switch]$NoPause
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "================================" -ForegroundColor Cyan
Write-Host "As-Built - Alterar Ícone da App" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$iconeAtual = "windows\runner\resources\app_icon.ico"
$fallbackIcone = "app_icon_novo.ico"

if (-not (Test-Path $IconPath) -and (Test-Path $fallbackIcone)) {
    $IconPath = (Resolve-Path $fallbackIcone).Path
}

if (-not (Test-Path $IconPath)) {
    Write-Host "[!] Arquivo de ícone não encontrado:" -ForegroundColor Red
    Write-Host "    $IconPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Dica: passe o caminho com -IconPath ou coloque app_icon_novo.ico na raiz." -ForegroundColor Yellow
    if (-not $NoPause) {
        Write-Host ""
        Write-Host "Pressione qualquer tecla para sair..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    exit 1
}

if (Test-Path $iconeAtual) {
    $backup = "windows\runner\resources\app_icon.ico.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $iconeAtual $backup -Force
    Write-Host "[✓] Backup criado: $backup" -ForegroundColor Green
}

Copy-Item $IconPath $iconeAtual -Force
Write-Host "[✓] Novo ícone copiado para: $iconeAtual" -ForegroundColor Green
Write-Host "[✓] Origem utilizada: $IconPath" -ForegroundColor Green

if (-not $Rebuild) {
    $recompilar = Read-Host "Deseja recompilar a aplicação agora? (S/N)"
    if ($recompilar -eq "S" -or $recompilar -eq "s") {
        $Rebuild = $true
    }
}

if ($Rebuild) {
    Write-Host ""
    Write-Host "Limpando build anterior..." -ForegroundColor Yellow
    flutter clean

    Write-Host ""
    Write-Host "Obtendo dependências..." -ForegroundColor Yellow
    flutter pub get

    Write-Host ""
    Write-Host "Compilando aplicação Windows..." -ForegroundColor Yellow
    flutter build windows --release

    Write-Host ""
    Write-Host "[✓] Compilação concluída!" -ForegroundColor Green
    Write-Host "Localização do executável:" -ForegroundColor Cyan
    Write-Host "  build\windows\x64\runner\Release\as_built.exe" -ForegroundColor White
}

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
