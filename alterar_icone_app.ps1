# Script Unificado - Alterar Ícone da Aplicação As-Built
# Suporta: Windows e Android

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    As-Built - Alterar Ícone da App    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Escolha a plataforma:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Android" -ForegroundColor White
Write-Host "  [2] Windows" -ForegroundColor White
Write-Host "  [3] Ambas" -ForegroundColor White
Write-Host "  [0] Sair" -ForegroundColor Gray
Write-Host ""

$opcao = Read-Host "Digite sua escolha (0-3)"

switch ($opcao) {
    "1" {
        Write-Host ""
        Write-Host "=== Alterar Ícone Android ===" -ForegroundColor Cyan
        Write-Host ""
        & ".\alterar_icone_android.ps1"
    }
    "2" {
        Write-Host ""
        Write-Host "=== Alterar Ícone Windows ===" -ForegroundColor Cyan
        Write-Host ""
        & ".\alterar_icone.ps1"
    }
    "3" {
        Write-Host ""
        Write-Host "=== Alterar Ícone Android ===" -ForegroundColor Cyan
        Write-Host ""
        & ".\alterar_icone_android.ps1"
        
        Write-Host ""
        Write-Host ""
        Write-Host "=== Alterar Ícone Windows ===" -ForegroundColor Cyan
        Write-Host ""
        & ".\alterar_icone.ps1"
    }
    "0" {
        Write-Host "Saindo..." -ForegroundColor Gray
        exit
    }
    default {
        Write-Host ""
        Write-Host "[!] Opção inválida!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Documentação disponível:" -ForegroundColor Yellow
        Write-Host "  - Android: ALTERAR_ICONE_ANDROID.md" -ForegroundColor White
        Write-Host "  - Windows: ALTERAR_ICONE.md" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
