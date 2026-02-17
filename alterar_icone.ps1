# Script para ajudar a alterar o ícone da aplicação As-Built
# Execute este script após criar seu arquivo app_icon.ico

Write-Host "================================" -ForegroundColor Cyan
Write-Host "As-Built - Alterar Ícone da App" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se existe um novo ícone
$novoIcone = "app_icon_novo.ico"
$iconeAtual = "windows\runner\resources\app_icon.ico"

if (Test-Path $novoIcone) {
    Write-Host "[✓] Arquivo $novoIcone encontrado!" -ForegroundColor Green
    Write-Host ""
    
    # Fazer backup do ícone atual
    if (Test-Path $iconeAtual) {
        $backup = "windows\runner\resources\app_icon.ico.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $iconeAtual $backup
        Write-Host "[✓] Backup criado: $backup" -ForegroundColor Green
    }
    
    # Copiar o novo ícone
    Copy-Item $novoIcone $iconeAtual -Force
    Write-Host "[✓] Novo ícone copiado para: $iconeAtual" -ForegroundColor Green
    Write-Host ""
    
    # Perguntar se deve recompilar
    $recompilar = Read-Host "Deseja recompilar a aplicação agora? (S/N)"
    
    if ($recompilar -eq "S" -or $recompilar -eq "s") {
        Write-Host ""
        Write-Host "Limpando build anterior..." -ForegroundColor Yellow
        flutter clean
        
        Write-Host ""
        Write-Host "Compilando aplicação Windows..." -ForegroundColor Yellow
        flutter build windows --release
        
        Write-Host ""
        Write-Host "[✓] Compilação concluída!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Localização do executável:" -ForegroundColor Cyan
        Write-Host "  build\windows\x64\runner\Release\as_built.exe" -ForegroundColor White
    }
    
} else {
    Write-Host "[!] Arquivo $novoIcone não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "INSTRUÇÕES:" -ForegroundColor Yellow
    Write-Host "1. Crie um arquivo de ícone .ico com o design desejado" -ForegroundColor White
    Write-Host "2. Salve-o como: $novoIcone na raiz do projeto" -ForegroundColor White
    Write-Host "3. Execute este script novamente" -ForegroundColor White
    Write-Host ""
    Write-Host "Ferramentas recomendadas para criar ícones:" -ForegroundColor Cyan
    Write-Host "  - https://www.icoconverter.com/ (online, grátis)" -ForegroundColor White
    Write-Host "  - GIMP (desktop, grátis)" -ForegroundColor White
    Write-Host "  - Inkscape + ImageMagick" -ForegroundColor White
    Write-Host ""
    Write-Host "Design recomendado:" -ForegroundColor Cyan
    Write-Host "  - Ícone wind_power (turbina eólica)" -ForegroundColor White
    Write-Host "  - Gradiente: #0F4C81 → #00BCD4" -ForegroundColor White
    Write-Host "  - Tamanhos: 16, 32, 48, 64, 128, 256 pixels" -ForegroundColor White
    Write-Host "  - Fundo transparente" -ForegroundColor White
    Write-Host ""
    Write-Host "Leia ALTERAR_ICONE.md para mais detalhes." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
