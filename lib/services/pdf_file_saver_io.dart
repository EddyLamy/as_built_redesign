import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';

Future<String?> savePdfBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  try {
    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar PDF',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (selectedPath == null || selectedPath.isEmpty) {
      return null;
    }

    final finalPath = selectedPath.toLowerCase().endsWith('.pdf')
        ? selectedPath
        : '$selectedPath.pdf';

    final file = File(finalPath);
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(finalPath);
    return finalPath;
  } catch (_) {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
    return null;
  }
}
