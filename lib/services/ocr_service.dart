abstract class OCRService {
  /// Extrai texto completo da imagem
  ///
  /// **Mobile:** Usa ML Kit para reconhecer texto
  /// **Desktop:** Retorna string vazia (sem crash)
  Future<String> extrairTexto(String imagePath);

  /// Extrai campos específicos (VUI, Serial, Item) da imagem
  ///
  /// **Mobile:** Extrai e parseia com regex
  /// **Desktop:** Retorna mapa vazio
  ///
  /// Retorna:
  /// ```dart
  /// {
  ///   'vui': 'VUI-001',      // ou ''
  ///   'serial': 'SN-123',    // ou ''
  ///   'item': 'ITEM-A',      // ou ''
  /// }
  /// ```
  Future<Map<String, String>> extrairDadosComponente(String imagePath);

  /// Inicializa o serviço (se necessário)
  ///
  /// **Mobile:** Verifica disponibilidade do ML Kit
  /// **Desktop:** Noop
  Future<void> inicializar();

  /// Libera recursos
  ///
  /// **Mobile:** Fecha o TextRecognizer
  /// **Desktop:** Noop
  void dispose();

  /// Verifica se OCR está disponível na plataforma atual
  ///
  /// **Retorna:**
  /// - `true` em Android/iOS
  /// - `false` em Windows/macOS/Linux
  bool get isOCRAvailable;
}
