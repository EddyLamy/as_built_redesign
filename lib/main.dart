import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/translation_helper.dart';
import 'providers/locale_provider.dart';
import 'screens/auth/login_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// 🪟 MAIN.DART - WINDOWS + ANDROID + IOS + TECLAS ESPECIAIS FUNCIONANDO
// ════════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 CONFIGURAR ERROR HANDLER - APENAS PARA ERROS CRÍTICOS
  // ══════════════════════════════════════════════════════════════════════════
  if (!kIsWeb && Platform.isWindows) {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exceptionString = details.exception.toString();

      // ✅ APENAS ignorar erros de threading do Firebase
      if (exceptionString.contains('platform thread') ||
          exceptionString.contains('firebase_auth_plugin/auth-state') ||
          exceptionString.contains('firebase_auth_plugin/id-token')) {
        // Log mas não crasha
        debugPrint('⚠️ Firebase Windows limitation: ${details.exception}');
        return;
      }

      // ✅ PERMITIR que erros de teclado sejam processados normalmente
      // Isto permite que ç, ã, õ, etc funcionem

      // Mostrar outros erros
      FlutterError.presentError(details);
    };

    print('🪟 Running on Windows Desktop');
    print('✅ Keyboard special characters enabled (ç, ã, õ, etc.)');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔥 INICIALIZAR FIREBASE
  // ══════════════════════════════════════════════════════════════════════════
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBvMyAPqDM2dvpixj6a7ZNXWFjMlwSx8iQ",
        authDomain: "asbuilt-app.firebaseapp.com",
        projectId: "asbuilt-app",
        storageBucket: "asbuilt-app.firebasestorage.app",
        messagingSenderId: "813412897876",
        appId: "1:813412897876:web:033587b2bb0aa41a6189c1",
      ),
    );
    print('✅ Firebase inicializado com sucesso!');
  } catch (e, stackTrace) {
    print('❌ Erro ao inicializar Firebase: $e');
    print('StackTrace: $stackTrace');
  }

  runApp(const ProviderScope(child: AsBuiltApp()));
}

class AsBuiltApp extends ConsumerWidget {
  const AsBuiltApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeString = ref.watch(localeProvider);

    return MaterialApp(
      title: 'As-Built - Wind Turbine Installation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // i18n Configuration
      locale: Locale(localeString),
      supportedLocales: const [
        Locale('pt'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        TranslationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const LoginScreen(),
    );
  }
}
