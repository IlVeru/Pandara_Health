import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:pandara_health/features/auth/data/repositories/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isAgreed = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi harus diisi')),
      );
      return;
    }

    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui Syarat & Ketentuan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        if (mounted) {
          context.go('/dashboard');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email atau kata sandi salah')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header Logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              alignment: Alignment.centerLeft,
              color: Colors.white,
              child: Image.asset(
                'assets/images/logo_health_fix.png',
                height: 40,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Selamat Datang Kembali',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D1D1D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Masuk ke akun Anda untuk melanjutkan kemajuan Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildInputField(
                            label: 'Email',
                            hint: 'name@example.com',
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Kata Sandi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Handle forgot password
                                    },
                                    child: const Text(
                                      'Lupa Kata Sandi?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: '........',
                                  hintStyle: const TextStyle(color: Colors.black26),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.black26),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: Colors.black26,
                                    ),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF1F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Checkbox(
                                value: _isAgreed,
                                onChanged: (val) => setState(() => _isAgreed = val!),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'Saya setuju dengan Syarat & Ketentuan serta Kebijakan Privasi Pandara Health',
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: () => context.push('/register'),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Tidak punya akun? ',
                                  style: TextStyle(color: Colors.black54),
                                  children: [
                                    TextSpan(
                                      text: 'Daftar Sekarang',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Kebijakan Privasi',
                          style: TextStyle(color: Colors.black38, fontSize: 14),
                        ),
                        SizedBox(width: 24),
                        Text(
                          'Syarat & Ketentuan',
                          style: TextStyle(color: Colors.black38, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26),
            prefixIcon: Icon(icon, color: Colors.black26),
            filled: true,
            fillColor: const Color(0xFFF1F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
