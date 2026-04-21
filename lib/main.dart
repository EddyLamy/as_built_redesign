import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform, File, Directory;
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/translation_helper.dart';
import 'providers/locale_provider.dart';
import 'screens/auth/login_screen.dart';
import 'firebase_options.dart';
import 'utils/platform_helper.dart';
import 'screens/mobile/mobile_app.dart';
import 'providers/theme_provider.dart';
import 'utils/global_keyboard_handler.dart'
    show GlobalKeyboardHandler, shortcutRouteObserver;
import 'screens/equipment/equipment_screen.dart';
import 'widgets/liquid_glass_shell.dart';
// import 'screens/documentation/documentation_screen.dart'; // Quando criares a documentação, descomenta isto e adiciona a rota no LoginScreen

// Global navigator key para aceder ao Navigator de qualquer lugar
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ══════════════════════════════════════════════════════════════════════════
  // 1. CONFIGURAÇÃO ESPECÍFICA PARA WINDOWS
  // ══════════════════════════════════════════════════════════════════════════
  if (!kIsWeb && Platform.isWindows) {
    _setupWindowsErrorHandling();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. INICIALIZAÇÃO DO FIREBASE (UMA VEZ APENAS!)
  // ══════════════════════════════════════════════════════════════════════════
  try {
    if (kIsWeb || Platform.isWindows) {
      // Configuração manual para Windows/Web
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
    } else {
      // Android/iOS usa google-services.json/GoogleService-Info.plist
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('✅ Firebase inicializado com sucesso!');
  } catch (e) {
    debugPrint('❌ Erro ao inicializar Firebase: $e');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. PREPARAR OCR (Apenas Mobile)
  // ══════════════════════════════════════════════════════════════════════════
  await _prepareOCR();

  // ══════════════════════════════════════════════════════════════════════════
  // 4. INICIAR APP (UMA VEZ APENAS!)
  // ══════════════════════════════════════════════════════════════════════════
  runApp(
    ProviderScope(
      observers: [
        AuthStateObserver(),
      ],
      child: const AsBuiltApp(),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// FUNÇÕES AUXILIARES
// ════════════════════════════════════════════════════════════════════════════

void _setupWindowsErrorHandling() {
  // ══════════════════════════════════════════════════════════════════════════
  // FILTRO DE ERROS PARA WINDOWS
  // ══════════════════════════════════════════════════════════════════════════

  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionString = details.exception.toString();

    // 1. Erros do Firebase (threading)
    if (exceptionString.contains('platform thread') ||
        exceptionString.contains('firebase_auth_plugin')) {
      return; // Ignorar silenciosamente
    }

    // 2. Erros de teclado duplicados (APENAS o erro específico)
    // ⚠️ NÃO bloquear todos os KeyDownEvent, apenas o erro de tecla já pressionada!
    if (exceptionString.contains('physical key is already pressed')) {
      return; // Ignorar silenciosamente
    }

    // 3. Erros de JSON parsing vazios
    if (exceptionString.contains('Unable to parse JSON') ||
        exceptionString.contains('The document is empty')) {
      return; // Ignorar silenciosamente
    }

    // Todos os outros erros: mostrar normalmente
    FlutterError.presentError(details);
  };

  debugPrint('🪟 Running on Windows Desktop');
  debugPrint(
      '✅ All keyboard keys enabled (including Portuguese special characters and Backspace)');
}

Future<void> _prepareOCR() async {
  if (kIsWeb || Platform.isWindows) return;

  try {
    final Directory docDir = await getApplicationDocumentsDirectory();
    final String tessPath = '${docDir.path}/tessdata';

    if (!await Directory(tessPath).exists()) {
      await Directory(tessPath).create(recursive: true);
    }

    const String fileName = 'eng.traineddata';
    final File file = File('$tessPath/$fileName');

    if (!await file.exists()) {
      final ByteData data = await rootBundle.load('assets/tessdata/$fileName');
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await file.writeAsBytes(bytes);
      debugPrint('✅ OCR: Ficheiro de treino preparado para Mobile');
    }
  } catch (e) {
    debugPrint('⚠️ Erro ao preparar OCR: $e');
  }
}

// ════════════════════════════════════════════════════════════════════════════
// APP PRINCIPAL COM DETECÇÃO DE PLATAFORMA
// ════════════════════════════════════════════════════════════════════════════

class AsBuiltApp extends ConsumerWidget {
  const AsBuiltApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeString = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeProvider);

    // ══════════════════════════════════════════════════════════════════════════
    // DETECÇÃO DE PLATAFORMA
    // ══════════════════════════════════════════════════════════════════════════

    if (PlatformHelper.isMobile) {
      // ────────────────────────────────────────────────────────────────────────
      // 📱 MOBILE APP - Instalação Apenas
      // ────────────────────────────────────────────────────────────────────────
      debugPrint('🚀 Iniciando MOBILE APP (Instalação)');

      return MaterialApp(
        title: 'As-Built Mobile',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        themeAnimationDuration: const Duration(milliseconds: 280),
        themeAnimationCurve: Curves.easeInOutCubic,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: currentTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
        locale: Locale(localeString),
        supportedLocales: const [Locale('pt'), Locale('en')],
        localizationsDelegates: const [
          TranslationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => LiquidGlassShell(
          child: child ?? const SizedBox.shrink(),
        ),
        // MOBILE: Vai direto para MobileApp (que tem seu próprio auth check)
        home: const MobileApp(),
      );
    } else {
      // ────────────────────────────────────────────────────────────────────────
      // 💻 DESKTOP APP - Completa
      // ────────────────────────────────────────────────────────────────────────
      debugPrint('🚀 Iniciando DESKTOP APP (Completa)');

      return MaterialApp(
        title: 'As-Built - Wind Turbine Installation',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        themeAnimationDuration: const Duration(milliseconds: 280),
        themeAnimationCurve: Curves.easeInOutCubic,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: currentTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
        locale: Locale(localeString),
        supportedLocales: const [Locale('pt'), Locale('en')],
        localizationsDelegates: const [
          TranslationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // ══════════════════════════════════════════════════════════════════
        // 🗺️ ROTAS NOMEADAS
        // ══════════════════════════════════════════════════════════════════
        navigatorObservers: [shortcutRouteObserver],
        routes: {
          '/equipment': (context) => const EquipmentScreen(),
          // '/documentation': (context) => const DocumentationScreen(), // Próxima feature
        },
        // DESKTOP: Envolve tudo com GlobalKeyboardHandler
        builder: (context, child) => LiquidGlassShell(
          child: GlobalKeyboardHandler(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
        home: const LoginScreen(),
      );
    }
  }
}
