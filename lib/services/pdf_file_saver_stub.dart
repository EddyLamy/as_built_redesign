import 'dart:typed_data';

Future<String?> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  throw UnsupportedError('Saving PDF files is not supported on this platform.');
}
