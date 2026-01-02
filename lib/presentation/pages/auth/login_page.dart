import 'package:flutter/material.dart';
import '../../../core/gen/assets.gen.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/routes/navigation_service.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil!')),
        );
        
        // Navigate to home page
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            NavigationService.pushReplacementNamed(AppRoutes.home);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Use center width constraint but keep hardcoded 328 for the containers as requested
    return Scaffold(
      body: GestureDetector(
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
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                color: Color(0xFF1B3C53),
                                fontSize: 14,
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nomor Handphone',
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
                                  return 'Masukkan nomor handphone';
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
                                  onTap: () {
                                    setState(
                                      () =>
                                          _isPasswordVisible =
                                              !_isPasswordVisible,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
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
                                          color: const Color(0xFF1B3C53),
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
                                if ((value?.length ?? 0) < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
                            ),
                          ),

                            // Forgot Password
                            Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                              NavigationService.goToForgotPassword();
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
                            ),
                          

                          const SizedBox(height: 32),

                          // Login Button
                          GestureDetector(
                            onTap: _isLoading ? null : _login,
                            child: SizedBox(
                              width: 328,
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B3C53),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
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
      ),
    );
  }
}