import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart'; // ← CORRETO!
import '../../providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import 'mobile_projects_screen.dart';
import 'mobile_login_screen.dart';
import 'mobile_language_screen.dart';

/// App Mobile - Apenas Instalação
/// Fluxo: Login → Seleção de Idioma → Projetos → Turbinas → Instalação
class MobileApp extends ConsumerWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // ────────────────────────────────────────────────────────────────────────
      // USER AUTENTICADO OU NÃO
      // ────────────────────────────────────────────────────────────────────────
      data: (user) {
        if (user == null) {
          return const MobileLoginScreen();
        }
        return const _MobileAuthenticatedFlow();
      },

      // ────────────────────────────────────────────────────────────────────────
      // LOADING
      // ────────────────────────────────────────────────────────────────────────
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
              SizedBox(height: 16),
              Text(
                'A carregar...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ),

      // ────────────────────────────────────────────────────────────────────────
      // ERRO
      // ────────────────────────────────────────────────────────────────────────
      error: (error, stack) {
        debugPrint('❌ Erro no authState: $error');
        return const MobileLoginScreen();
      },
    );
  }
}

/// Widget que controla o fluxo após autenticação
class _MobileAuthenticatedFlow extends ConsumerWidget {
  const _MobileAuthenticatedFlow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageSelectedAsync = ref.watch(languageSelectedProvider);

    return languageSelectedAsync.when(
      data: (languageSelected) {
        if (!languageSelected) {
          return const MobileLanguageScreen();
        }
        return const MobileProjectsScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
              SizedBox(height: 16),
              Text(
                'A carregar...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) {
        debugPrint('❌ Erro ao carregar idioma: $error');
        return const MobileProjectsScreen();
      },
    );
  }
}
