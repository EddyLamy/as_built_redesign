import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart'; // ← CORRETO!
import '../../providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import 'mobile_projects_screen.dart';
import 'mobile_login_screen.dart';
import 'mobile_language_screen.dart';

/// App Mobile - Apenas Instalação
/// Fluxo: Seleção de Idioma → Login → Projetos → Turbinas → Instalação
class MobileApp extends ConsumerWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageSelectedAsync = ref.watch(languageSelectedProvider);

    return languageSelectedAsync.when(
      // ────────────────────────────────────────────────────────────────────────
      // VERIFICAR SE IDIOMA FOI SELECIONADO
      // ────────────────────────────────────────────────────────────────────────
      data: (languageSelected) {
        if (!languageSelected) {
          return const MobileLanguageScreen();
        }
        return const _MobileAuthenticationFlow();
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
        debugPrint('❌ Erro ao carregar idioma: $error');
        return const MobileLanguageScreen();
      },
    );
  }
}

/// Widget que controla o fluxo de autenticação após seleção de idioma
class _MobileAuthenticationFlow extends ConsumerWidget {
  const _MobileAuthenticationFlow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const MobileLoginScreen();
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
        debugPrint('❌ Erro no authState: $error');
        return const MobileLoginScreen();
      },
    );
  }
}
