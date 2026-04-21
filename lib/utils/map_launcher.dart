import 'package:url_launcher/url_launcher.dart';

class ParsedCoordinates {
  const ParsedCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  String get displayValue =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

class MapLauncher {
  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  static ParsedCoordinates? tryParseCoordinates(String? rawValue) {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }

    final normalized = value
        .replaceAll(';', ',')
        .replaceAll('|', ',')
        .replaceAll(RegExp(r'\s+'), ' ');

    final coordinatePattern = RegExp(r'-?\d+(?:[\.,]\d+)?');
    final matches = coordinatePattern.allMatches(normalized).toList();
    if (matches.length < 2) {
      return null;
    }

    for (var index = 0; index < matches.length - 1; index++) {
      final latitude = _parseNumber(matches[index].group(0));
      final longitude = _parseNumber(matches[index + 1].group(0));
      if (latitude == null || longitude == null) {
        continue;
      }
      if (latitude < -90 || latitude > 90) {
        continue;
      }
      if (longitude < -180 || longitude > 180) {
        continue;
      }
      return ParsedCoordinates(latitude: latitude, longitude: longitude);
    }

    return null;
  }

  static Uri buildMapsUri(String rawValue) {
    final coordinates = tryParseCoordinates(rawValue);
    final query = coordinates != null
        ? '${coordinates.latitude},${coordinates.longitude}'
        : rawValue.trim();

    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
  }

  static Future<bool> openLocation(String? rawValue) async {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) {
      return false;
    }

    final uri = buildMapsUri(value);

    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return true;
    }

    if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      return true;
    }

    return false;
  }

  static double? _parseNumber(String? rawNumber) {
    if (rawNumber == null || rawNumber.isEmpty) {
      return null;
    }

    final normalized = rawNumber.replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
