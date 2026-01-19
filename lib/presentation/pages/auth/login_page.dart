import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/gen/assets.gen.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/routes/navigation_service.dart';
import '../../providers/login_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';
  static const String _rememberMeKey = 'remember_me';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_savedEmailKey);
    final savedPassword = prefs.getString(_savedPasswordKey);
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _phoneController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = rememberMe;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(_savedEmailKey, _phoneController.text.trim());
      await prefs.setString(_savedPasswordKey, _passwordController.text.trim());
      await prefs.setBool(_rememberMeKey, true);
    } else {
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);
      await prefs.setBool(_rememberMeKey, false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final loginProvider = context.read<LoginProvider>();
      
      await loginProvider.login(
        email: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        portal: 'MOBILE',
      );

      if (mounted) {
        final state = loginProvider.state;
        
        if (state.toString().endsWith('success')) {
          // Save credentials if remember me is checked
          await _saveCredentials();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login berhasil!')),
          );
          
          // Navigate to home page
          // Wait a bit to ensure login state is processed
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              NavigationService.pushReplacementNamed(AppRoutes.home);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginProvider.errorMessage ?? 'Login gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Use center width constraint but keep hardcoded 328 for the containers as requested
    return Scaffold(
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, _) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.images.bgImage.provider(),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.08),

                      // Logo
                        Assets.images.logoLogin.image(
                        width: size.width * 0.5,
                        height: size.width * 0.5,
                        ),

                      SizedBox(height: size.height * 0.14),

                      // Form
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 15,
                            children: [
                              // Phone Number Field
                              SizedBox(
                                width: 328,
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !loginProvider.isLoading,
                                  style: const TextStyle(
                                    color: Color(0xFF1B3C53),
                                    fontSize: 14,
                                    fontFamily: 'Ubuntu',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Email Address',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF1B3C53),
                                      fontSize: 14,
                                      fontFamily: 'Ubuntu',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFCEF2FF),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Masukkan email';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              // Password Field with show/hide
                              SizedBox(
                                width: 328,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  enabled: !loginProvider.isLoading,
                                  style: const TextStyle(
                                    color: Color(0xFF1B3C53),
                                    fontSize: 14,
                                    fontFamily: 'Ubuntu',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF1B3C53),
                                      fontSize: 14,
                                      fontFamily: 'Ubuntu',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFCEF2FF),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: loginProvider.isLoading
                                          ? null
                                          : () {
                                              setState(
                                                () =>
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible,
                                              );
                                            },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 4,
                                          children: [
                                            Text(
                                              _isPasswordVisible
                                                  ? 'Tutup'
                                                  : 'Lihat',
                                              style: const TextStyle(
                                                color: Color(0xFF1B3C53),
                                                fontSize: 12,
                                                fontFamily: 'Ubuntu',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color:
                                                  const Color(0xFF1B3C53),
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Masukkan password';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Remember Me Checkbox
                              SizedBox(
                                width: 328,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: loginProvider.isLoading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                });
                                              },
                                        activeColor: const Color(0xFF1B3C53),
                                        checkColor: Colors.white,
                                        side: const BorderSide(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: loginProvider.isLoading
                                          ? null
                                          : () {
                                              setState(() {
                                                _rememberMe = !_rememberMe;
                                              });
                                            },
                                      child: const Text(
                                        'Ingat Saya',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontFamily: 'Ubuntu',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    // Forgot Password
                                    GestureDetector(
                                      onTap: loginProvider.isLoading
                                          ? null
                                          : () {
                                              NavigationService
                                                  .goToForgotPassword();
                                            },
                                      child: const Text(
                                        'Lupa Password?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontFamily: 'Ubuntu',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              

                              const SizedBox(height: 32),

                              // Login Button
                              GestureDetector(
                                onTap: loginProvider.isLoading ? null : _login,
                                child: SizedBox(
                                  width: 328,
                                  height: 48,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B3C53),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: loginProvider.isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                      Colors.white,
                                                    ),
                                              ),
                                            )
                                          : const Text(
                                              'MASUK',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Ubuntu',
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.15),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}