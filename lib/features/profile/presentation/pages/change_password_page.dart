import 'package:flutter/material.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Security Header
                    _buildSecurityHeader(),
                    const SizedBox(height: 32),
                    // Password Card
                    _buildPasswordCard(),
                    const SizedBox(height: 40),
                    // Action Button
                    _buildActionButton(context),
                    const SizedBox(height: 24),
                    _buildResetLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildSecurityHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 24),
        const Text('Keamanan Akun', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Pastikan kata sandi Anda kuat dan sulit ditebak untuk keamanan akun yang lebih baik.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45, height: 1.5, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPasswordField('Kata Sandi Saat Ini', Icons.lock_outline, _showCurrent, (v) => setState(() => _showCurrent = v)),
          const SizedBox(height: 24),
          _buildPasswordField('Kata Sandi Baru', Icons.vpn_key_outlined, _showNew, (v) => setState(() => _showNew = v)),
          const SizedBox(height: 16),
          _buildStrengthIndicator(),
          const SizedBox(height: 24),
          _buildPasswordField('Konfirmasi Kata Sandi Baru', Icons.lock_reset, _showConfirm, (v) => setState(() => _showConfirm = v)),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, IconData icon, bool isVisible, Function(bool) onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            obscureText: !isVisible,
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.black26),
              suffixIcon: IconButton(
                onPressed: () => onToggle(!isVisible),
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black26, size: 20),
              ),
              hintText: '........',
              hintStyle: const TextStyle(color: Colors.black12, fontSize: 18),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kekuatan Kata Sandi', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
            Text('Kuat', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                decoration: BoxDecoration(
                  color: index < 3 ? AppColors.primary : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        const Text(
          'Gunakan minimal 8 karakter dengan kombinasi huruf, angka, dan simbol.',
          style: TextStyle(color: Colors.black26, fontSize: 11, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.pop(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Perbarui Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 18),
        ],
      ),
    );
  }

  Widget _buildResetLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Lupa kata sandi Anda? ', style: TextStyle(color: Colors.black38, fontSize: 13)),
        TextButton(
          onPressed: () {},
          child: const Text('Reset di sini', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}
