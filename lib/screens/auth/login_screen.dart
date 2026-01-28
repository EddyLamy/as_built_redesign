import 'package:flutter/material.dart';
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
    final localeString = ref.watch(localeProvider); // ✅ MUDADO: agora é String

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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Language Toggle
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              localeString
                                  .toUpperCase(), // ✅ CORRIGIDO: String direto
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.language, size: 20),
                          ],
                        ),
                        onPressed: () {
                          ref.read(localeProvider.notifier).toggleLanguage();
                        },
                        tooltip:
                            localeString == 'pt' // ✅ CORRIGIDO: String direto
                                ? 'Switch to English'
                                : 'Mudar para Português',
                      ),
                    ),

                    // Logo/Icon
                    const Icon(
                      Icons.wind_power,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      t.translate('login_title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      t.translate('login_subtitle'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
                        border: const OutlineInputBorder(),
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
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
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
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
