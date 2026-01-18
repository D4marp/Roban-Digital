import 'package:flutter/material.dart';
import '../../../core/gen/assets.gen.dart';
import '../../../config/routes/navigation_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simulate password reset process
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link reset password telah dikirim ke ${_emailController.text}'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            NavigationService.pop();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
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
                  SizedBox(height: size.height * 0.04),

                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => NavigationService.pop(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                            const Text(
                              'Kembali',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.08),

                  // Logo
                  Assets.images.logoLogin.image(
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                  ),

                  SizedBox(height: size.height * 0.08),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      spacing: 8,
                      children: [
                        const Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Masukkan nomor handphone atau email Anda untuk mereset password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Form
                  if (!_isSubmitted)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 20,
                          children: [
                            // Email/Phone Field
                            SizedBox(
                              width: 328,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  color: Color(0xFF1B3C53),
                                  fontSize: 14,
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Nomor Handphone atau Email',
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
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 16, right: 12),
                                    child: Icon(
                                      Icons.mail_outline,
                                      color: Color(0xFF1B3C53),
                                      size: 20,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Masukkan nomor handphone atau email';
                                  }
                                  // Simple validation for email or phone
                                  final isEmail = value!.contains('@');
                                  if (isEmail) {
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value)) {
                                      return 'Format email tidak valid';
                                    }
                                  } else {
                                    if (value.length < 10) {
                                      return 'Nomor handphone tidak valid';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),

                            // Reset Button
                            GestureDetector(
                              onTap: _isLoading ? null : _resetPassword,
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
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'KIRIM LINK RESET',
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
                    )
                  else
                    // Success Message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        spacing: 16,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 48,
                            ),
                          ),
                          const Text(
                            'Permintaan Terkirim!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Kami telah mengirimkan link reset password ke ${_emailController.text}.\n\nSilakan periksa email atau SMS Anda untuk melanjutkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
