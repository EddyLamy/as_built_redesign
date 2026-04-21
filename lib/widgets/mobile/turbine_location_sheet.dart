import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../utils/map_launcher.dart';

class TurbineLocationSheet extends ConsumerStatefulWidget {
  const TurbineLocationSheet({
    super.key,
    required this.turbinaId,
    required this.turbinaNome,
    required this.initialLocation,
    this.embedded = false,
    this.onCancel,
  });

  final String turbinaId;
  final String turbinaNome;
  final String? initialLocation;
  final bool embedded;
  final VoidCallback? onCancel;

  @override
  ConsumerState<TurbineLocationSheet> createState() =>
      _TurbineLocationSheetState();
}

class _TurbineLocationSheetState extends ConsumerState<TurbineLocationSheet> {
  late final TextEditingController _locationController;
  bool _isSaving = false;
  bool _isCapturingGps = false;

  @override
  void initState() {
    super.initState();
    _locationController =
        TextEditingController(text: widget.initialLocation ?? '');
    _locationController.addListener(_handleLocationChanged);
  }

  @override
  void dispose() {
    _locationController.removeListener(_handleLocationChanged);
    _locationController.dispose();
    super.dispose();
  }

  void _handleLocationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  ParsedCoordinates? get _coordinates =>
      MapLauncher.tryParseCoordinates(_locationController.text);

  Future<void> _captureGps() async {
    if (_isCapturingGps || _isSaving) {
      return;
    }

    final t = TranslationHelper.of(context);
    setState(() => _isCapturingGps = true);

    try {
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        _showMessage(t.translate('location_services_disabled'), isError: true);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showMessage(t.translate('location_permission_denied'), isError: true);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          t.translate('location_permission_denied_forever'),
          isError: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      _locationController.text = MapLauncher.formatCoordinates(
        position.latitude,
        position.longitude,
      );

      _showMessage(t.translate('gps_capture_success'));
    } catch (_) {
      _showMessage(t.translate('gps_capture_error'), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isCapturingGps = false);
      }
    }
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final t = TranslationHelper.of(context);
    final value = _locationController.text.trim();
    if (value.isNotEmpty && _coordinates == null) {
      _showMessage(t.translate('invalid_gps_coordinates'), isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(turbinaServiceProvider).updateTurbina(widget.turbinaId, {
        'localizacao': value.isEmpty ? null : value,
      });

      if (!mounted) {
        return;
      }

      if (!widget.embedded) {
        Navigator.of(context).pop();
      }
      _showMessage(t.translate('save_success'));
    } catch (_) {
      _showMessage(t.translate('error_saving'), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteLocation() async {
    if (_isSaving) {
      return;
    }

    final t = TranslationHelper.of(context);
    setState(() => _isSaving = true);

    try {
      await ref.read(turbinaServiceProvider).updateTurbina(widget.turbinaId, {
        'localizacao': null,
      });

      if (!mounted) {
        return;
      }

      _locationController.clear();
      if (!widget.embedded) {
        Navigator.of(context).pop();
      }
      _showMessage(t.translate('delete_success'));
    } catch (_) {
      _showMessage(t.translate('error_deleting'), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openInMaps() async {
    final t = TranslationHelper.of(context);
    final opened = await MapLauncher.openLocation(_locationController.text);
    if (!opened && mounted) {
      _showMessage(t.translate('unable_to_open_map'), isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final coordinates = _coordinates;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.embedded ? 0 : 28),
        boxShadow: widget.embedded ? null : AppColors.strongShadow,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            widget.embedded ? 20 : 18,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.embedded)
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderGray,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              if (!widget.embedded) const SizedBox(height: 18),
              Text(
                t.translate('gps_coordinates'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.turbinaNome,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: t.translate('location'),
                        hintText: t.translate('coordinates_hint_turbine'),
                        helperText: t.translate('manual_coordinates_hint'),
                        prefixIcon: const Icon(Icons.edit_location_alt),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      minLines: 1,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    width: 56,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _captureGps,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isCapturingGps
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildMapPreview(t, coordinates),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (coordinates != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openInMaps,
                        icon: const Icon(Icons.map_outlined),
                        label: Text(t.translate('open_in_maps')),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  if (coordinates != null) const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              if (widget.embedded) {
                                widget.onCancel?.call();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(t.translate('cancel')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _deleteLocation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(t.translate('delete')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(t.translate('save')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 24, 12, bottomInset + 12),
        child: Material(
          color: Colors.transparent,
          child: content,
        ),
      ),
    );
  }

  Widget _buildMapPreview(TranslationHelper t, ParsedCoordinates? coordinates) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFF4F7FB),
        border: Border.all(color: AppColors.borderGray),
      ),
      clipBehavior: Clip.antiAlias,
      child: coordinates == null
          ? _buildEmptyMapState(t)
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        LatLng(coordinates.latitude, coordinates.longitude),
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.asbuilt.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            coordinates.latitude,
                            coordinates.longitude,
                          ),
                          width: 56,
                          height: 56,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.errorRed,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        coordinates.displayValue,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyMapState(TranslationHelper t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map,
                size: 34,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.translate('map_preview_waiting'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.translate('map_preview_hint'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
