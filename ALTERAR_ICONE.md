# Como Alterar o Ícone da Aplicação As-Built

Este documento contém instruções para alterar o ícone da aplicação em diferentes plataformas.

---

## 📱 Android

Para alterar o ícone no Android, consulte o guia detalhado:
**[ALTERAR_ICONE_ANDROID.md](ALTERAR_ICONE_ANDROID.md)**

### Método Rápido (Android):
1. Crie uma imagem PNG 1024x1024 pixels com ícone wind_power + gradiente
2. Salve como: `assets/icons/app_icon_android.png`
3. Execute: `.\alterar_icone_android.ps1`
4. O script gerará automaticamente todos os tamanhos necessários

---

## 🪟 Windows

## Localização do Ícone Atual
O ícone da aplicação está em:
```
windows/runner/resources/app_icon.ico
```

## Passos para Criar um Novo Ícone

### Opção 1: Usar Ferramenta Online (Recomendado)
1. Acesse: https://www.icoconverter.com/ ou https://convertio.co/pt/png-ico/
2. Crie uma imagem PNG com o ícone wind_power com gradiente:
   - Tamanho: 256x256 pixels (mínimo)
   - Fundo transparente
   - Cores: Gradiente azul (#0F4C81) → turquesa (#00BCD4)
3. Faça upload da imagem PNG
4. Converta para formato .ICO (selecione múltiplos tamanhos: 16x16, 32x32, 48x48, 64x64, 128x128, 256x256)
5. Baixe o arquivo .ico gerado

### Opção 2: Usar GIMP (Gratuito)
1. Instale GIMP: https://www.gimp.org/downloads/
2. Crie uma nova imagem 256x256 pixels
3. Desenhe o ícone wind_power com gradiente
4. Exporte como .ico (File → Export As → app_icon.ico)
5. Marque as opções para incluir múltiplos tamanhos

### Opção 3: Usar Inkscape + ImageMagick
1. Crie o ícone em formato SVG no Inkscape
2. Exporte como PNG em vários tamanhos
3. Use ImageMagick para converter:
   ```bash
   convert icon_256.png icon_128.png icon_64.png icon_48.png icon_32.png icon_16.png app_icon.ico
   ```

## Design Recomendado para o Ícone

### Estilo 1: Ícone Wind Power com Gradiente
- Símbolo: Turbina eólica (wind_power icon)
- Gradiente: #0F4C81 (azul escuro) → #00BCD4 (turquesa)
- Fundo: Transparente ou circular com gradiente
- Estilo: Moderno, limpo, profissional

### Estilo 2: Iniciais "AB" com Turbina
- Letras "AB" (As-Built)
- Mini turbina eólica integrada
- Gradiente de fundo
- Borda arredondada

## Substituir o Ícone

1. Faça backup do arquivo original:
   ```powershell
   Copy-Item windows/runner/resources/app_icon.ico windows/runner/resources/app_icon.ico.backup
   ```

2. Substitua o arquivo:
   - Copie seu novo `app_icon.ico` para `windows/runner/resources/app_icon.ico`

3. Recompile a aplicação:
   ```powershell
   flutter clean
   flutter build windows
   ```

## Verificar o Novo Ícone

Após compilar:
1. Navegue até: `build/windows/x64/runner/Release/as_built.exe`
2. Verifique se o ícone mudou no executável
3. Execute a aplicação e verifique na barra de tarefas

## Ferramentas Adicionais

### Online (Grátis)
- https://favicon.io/ - Gera ícones a partir de texto/emoji
- https://www.icoconverter.com/ - Converte PNG para ICO
- https://cloudconvert.com/png-to-ico - Conversão em lote

### Desktop (Grátis)
- GIMP - Editor de imagem completo
- Inkscape - Editor de vetores (SVG)
- Paint.NET - Editor simples (Windows)

### Exemplo de Comando PowerShell para Criar Ícone Simples
```powershell
# Se você tiver ImageMagick instalado:
magick convert -background none -fill "#0F4C81" -font Arial -pointsize 200 -gravity center label:A app_icon_256.png
magick convert app_icon_256.png -resize 16x16 app_icon_16.png
magick convert app_icon_256.png -resize 32x32 app_icon_32.png
magick convert app_icon_256.png -resize 48x48 app_icon_48.png
magick convert app_icon_256.png -resize 64x64 app_icon_64.png
magick convert app_icon_256.png -resize 128x128 app_icon_128.png
magick convert app_icon_16.png app_icon_32.png app_icon_48.png app_icon_64.png app_icon_128.png app_icon_256.png app_icon.ico
```

## Nota Importante
O arquivo `.ico` precisa conter múltiplos tamanhos (16x16, 32x32, 48x48, 64x64, 128x128, 256x256) para aparecer corretamente em diferentes contextos do Windows (barra de tarefas, explorador de arquivos, etc.).
