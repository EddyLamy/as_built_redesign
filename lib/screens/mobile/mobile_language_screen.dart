import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/locale_provider.dart';

class MobileLanguageScreen extends ConsumerWidget {
  const MobileLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.language,
                  size: 100,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'As-Built',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seleccione o idioma',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 48),
                _LanguageOption(
                  label: 'Português',
                  code: 'pt',
                  isSelected: currentLocale == 'pt',
                  onTap: () async {
                    await ref.read(localeProvider.notifier).setLocale('pt');
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('language_selected', true);
                    ref.invalidate(languageSelectedProvider);
                  },
                ),
                const SizedBox(height: 16),
                _LanguageOption(
                  label: 'English',
                  code: 'en',
                  isSelected: currentLocale == 'en',
                  onTap: () async {
                    await ref.read(localeProvider.notifier).setLocale('en');
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('language_selected', true);
                    ref.invalidate(languageSelectedProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    code.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryBlue,
                size: 32,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: AppColors.lightGray,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
