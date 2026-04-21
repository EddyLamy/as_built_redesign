import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/gradient_button.dart';
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
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  bool _emailExpanded = false;
  bool _passwordExpanded = false;

  void _moveToEmailField() {
    setState(() => _emailExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _emailFocusNode.requestFocus();
      }
    });
  }

  void _moveToPasswordField() {
    setState(() => _passwordExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  KeyEventResult _handleEmailFieldKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.tab &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _moveToPasswordField();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _handlePasswordFieldKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.tab &&
        HardwareKeyboard.instance.isShiftPressed) {
      _moveToEmailField();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _expandEmail() {
    if (!_emailExpanded) {
      setState(() => _emailExpanded = true);
      // Give the field time to appear before requesting focus
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _emailFocusNode.requestFocus();
      });
    }
  }

  void _expandPassword() {
    if (!_passwordExpanded) {
      setState(() => _passwordExpanded = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _passwordFocusNode.requestFocus();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() => _emailFocused = _emailFocusNode.hasFocus);
      if (!_emailFocusNode.hasFocus && _emailController.text.isEmpty) {
        setState(() => _emailExpanded = false);
      }
    });
    _passwordFocusNode.addListener(() {
      setState(() => _passwordFocused = _passwordFocusNode.hasFocus);
      if (!_passwordFocusNode.hasFocus && _passwordController.text.isEmpty) {
        setState(() => _passwordExpanded = false);
      }
    });
  }

  // Helper para verificar se é mobile
  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Garante que o documento users/{uid} existe no Firestore.
  /// Se não existir, cria-o com globalRole: "user".
  /// Se já existir, não faz nada.
  Future<void> _ensureUserProfile(User firebaseUser, String email) async {
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);

    final doc = await docRef.get();
    final nameFallback = email.contains('@') ? email.split('@')[0] : email;

    if (!doc.exists) {
      await docRef.set({
        'uid': firebaseUser.uid,
        'name': (firebaseUser.displayName != null &&
                firebaseUser.displayName!.isNotEmpty)
            ? firebaseUser.displayName!
            : nameFallback,
        'email': email,
        'globalRole': 'user',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': null,
      });
      debugPrint('✅ Perfil criado com nome: $nameFallback');
    } else {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['name'] as String? ?? '').isEmpty) {
        await docRef.update({'name': nameFallback, 'email': email});
        debugPrint('👤 Nome vazio corrigido para: $nameFallback');
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ Garantir que o documento users/{uid} existe
      if (credential.user != null) {
        await _ensureUserProfile(
            credential.user!, _emailController.text.trim());
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
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
    final currentTheme = ref.watch(themeProvider);

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
              colors: [
                Color(0xFF0A2540),
                AppColors.primaryBlueDark,
                AppColors.accentTeal,
                AppColors.accentTealLight,
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildThemeButton(currentTheme, t),
                      _buildLanguageButton(localeString),
                    ],
                  ),
                ),
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
            colors: [
              Color(0xFF0A2540),
              AppColors.primaryBlueDark,
              AppColors.accentTeal,
              AppColors.accentTealLight,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            color: Colors.white.withValues(alpha: 0.75),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildThemeButton(currentTheme, t),
                      _buildLanguageButton(localeString),
                    ],
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

  Widget _buildLanguageButton(String currentLocale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    final surfaceColor = _isMobile
        ? Colors.white.withValues(alpha: 0.18)
        : (isDark
            ? AppColors.glassSurfaceDark.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.18));

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isMobile ? Colors.white.withValues(alpha: 0.3) : outlineColor,
          width: 1,
        ),
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
                  color: _isMobile ? Colors.white : secondaryText,
                ),
                const SizedBox(width: 8),
                Text(
                  currentLocale.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _isMobile ? 16 : 12,
                    color: _isMobile ? Colors.white : primaryText,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: _isMobile ? 24 : 20,
                  color: _isMobile ? Colors.white : secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeButton(String currentTheme, TranslationHelper t) {
    final isDark = currentTheme == 'dark';
    final buttonIcon =
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined;
    final iconColor =
        _isMobile ? Colors.white : AppColors.adaptivePrimaryText(context);
    final outlineColor = _isMobile
        ? Colors.white.withValues(alpha: 0.3)
        : AppColors.adaptiveOutline(context);
    final surfaceColor = _isMobile
        ? Colors.white.withValues(alpha: 0.18)
        : (isDark
            ? AppColors.glassSurfaceDark.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.18));

    return Tooltip(
      message: t.translate('toggle_theme'),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: outlineColor, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _isMobile ? 14 : 10,
                vertical: _isMobile ? 12 : 8,
              ),
              child: Icon(
                buttonIcon,
                size: _isMobile ? 22 : 18,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleField({
    required String label,
    required IconData icon,
    required bool isExpanded,
    required bool isFocused,
    required VoidCallback onTap,
    required Widget field,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? Colors.white38 : Colors.grey.shade400;
    final labelColor =
        isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: isExpanded
            ? _buildGlowContainer(isFocused: isFocused, child: field)
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 18, color: labelColor),
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: Divider(
                        color: lineColor,
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGlowContainer({required bool isFocused, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF90CAF9).withValues(alpha: 0.65),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }

  Widget _buildLoginForm(TranslationHelper t) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wind_power,
            size: _isMobile ? 80 : 64,
            color: _isMobile ? Colors.white : AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),
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
          Text(
            t.translate('login_subtitle'),
            style: TextStyle(
              fontSize: 14,
              color: _isMobile
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildCollapsibleField(
            label: t.translate('email'),
            icon: Icons.email_outlined,
            isExpanded: _emailExpanded,
            isFocused: _emailFocused,
            onTap: _expandEmail,
            field: Focus(
              onKeyEvent: _handleEmailFieldKey,
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: _moveToPasswordField,
                decoration: InputDecoration(
                  labelText: t.translate('email'),
                  prefixIcon: const Icon(Icons.email_outlined),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF64B5F6),
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: AppColors.darkGray),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.translate('required_field');
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCollapsibleField(
            label: t.translate('password'),
            icon: Icons.lock_outlined,
            isExpanded: _passwordExpanded,
            isFocused: _passwordFocused,
            onTap: _expandPassword,
            field: Focus(
              onKeyEvent: _handlePasswordFieldKey,
              child: TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: t.translate('password'),
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF64B5F6),
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: AppColors.darkGray),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.translate('required_field');
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GradientButton(
              label: t.translate('login_button'),
              onPressed: _handleLogin,
              isLoading: _isLoading,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
