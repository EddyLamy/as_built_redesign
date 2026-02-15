import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../providers/locale_provider.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Helper para verificar se é mobile
  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      final t = TranslationHelper.of(context);
      String errorMessage = t.translate('login_error');

      switch (e.code) {
        case 'user-not-found':
          errorMessage = t.translate('user_not_found');
          break;
        case 'wrong-password':
          errorMessage = t.translate('wrong_password');
          break;
        case 'invalid-email':
          errorMessage = t.translate('invalid_email');
          break;
        case 'user-disabled':
          errorMessage = t.translate('user_disabled');
          break;
        case 'invalid-credential':
          errorMessage = t.translate('invalid_credentials');
          break;
        default:
          errorMessage = '${t.translate("error")}: ${e.code}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final localeString = ref.watch(localeStringProvider);

    // ════════════════════════════════════════════════════════════════════
    // MOBILE: Ecrã completo com botão de idioma proeminente
    // ════════════════════════════════════════════════════════════════════
    if (_isMobile) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ══════════════════════════════════════════════════════
                // HEADER COM BOTÃO DE IDIOMA
                // ══════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildLanguageButton(localeString),
                    ],
                  ),
                ),

                // ══════════════════════════════════════════════════════
                // FORMULÁRIO DE LOGIN
                // ══════════════════════════════════════════════════════
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildLoginForm(t),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ════════════════════════════════════════════════════════════════════
    // DESKTOP: Layout com card centralizado
    // ════════════════════════════════════════════════════════════════════
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language Toggle (desktop - canto superior)
                  Align(
                    alignment: Alignment.topRight,
                    child: _buildLanguageButton(localeString),
                  ),
                  _buildLoginForm(t),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // 🌐 BOTÃO DE IDIOMA (MOBILE E DESKTOP)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildLanguageButton(String currentLocale) {
    return Container(
      decoration: BoxDecoration(
        color: _isMobile ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: _isMobile
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final newLocale =
                ref.read(localeStringProvider) == 'pt' ? 'en' : 'pt';
            await ref.read(localeProvider.notifier).setLocale(newLocale);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _isMobile ? 16 : 8,
              vertical: _isMobile ? 12 : 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: _isMobile ? 24 : 20,
                  color: _isMobile ? Colors.white : AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  currentLocale.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _isMobile ? 16 : 12,
                    color: _isMobile ? Colors.white : AppColors.darkGray,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: _isMobile ? 24 : 20,
                  color: _isMobile ? Colors.white : AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // 📝 FORMULÁRIO DE LOGIN (REUTILIZÁVEL)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildLoginForm(TranslationHelper t) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo/Icon
          Icon(
            Icons.wind_power,
            size: _isMobile ? 80 : 64,
            color: _isMobile ? Colors.white : AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            t.translate('login_title'),
            style: TextStyle(
              fontSize: _isMobile ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: _isMobile ? Colors.white : AppColors.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            t.translate('login_subtitle'),
            style: TextStyle(
              fontSize: 14,
              color:
                  _isMobile ? Colors.white.withOpacity(0.9) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: t.translate('email'),
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: _isMobile,
              fillColor: _isMobile ? Colors.white : null,
            ),
            style: TextStyle(
              color: _isMobile ? AppColors.darkGray : null,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return t.translate('required_field');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: t.translate('password'),
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: _isMobile,
              fillColor: _isMobile ? Colors.white : null,
            ),
            style: TextStyle(
              color: _isMobile ? AppColors.darkGray : null,
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return t.translate('required_field');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isMobile ? Colors.white : AppColors.primaryBlue,
                foregroundColor:
                    _isMobile ? AppColors.primaryBlue : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _isMobile ? AppColors.primaryBlue : Colors.white,
                      ),
                    )
                  : Text(
                      t.translate('login_button'),
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
