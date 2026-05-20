import 'package:flutter/material.dart';
import 'package:pandara_health/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class ChangeEmailPage extends StatelessWidget {
  const ChangeEmailPage({super.key});

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
                    'Keamanan Akun',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Card
                    _buildBrandCard(),
                    const SizedBox(height: 32),
                    
                    const Text('Ubah Email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text(
                      'Masukkan alamat email baru Anda. Kami akan mengirimkan kode verifikasi ke email tersebut untuk memastikan keamanan akun Anda.',
                      style: TextStyle(color: Colors.black45, height: 1.5, fontSize: 14),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Form
                    const Text('Email Saat Ini', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildCurrentEmailField(),
                    
                    const SizedBox(height: 24),
                    
                    const Text('Email Baru', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildNewEmailField(),
                    
                    const SizedBox(height: 32),
                    
                    // Security Info
                    _buildSecurityInfo(),
                    
                    const SizedBox(height: 40),
                    
                    // Action Button
                    _buildActionButton(context),
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

  Widget _buildBrandCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Center(
        child: Image.asset('assets/images/logo_health_fix.png', height: 60),
      ),
    );
  }

  Widget _buildCurrentEmailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.email_outlined, color: Colors.black26),
          SizedBox(width: 16),
          Text('andrea.revina@zenith.com', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNewEmailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Text('@', style: TextStyle(color: Colors.black26, fontSize: 18, fontWeight: FontWeight.bold)),
          hintText: 'Contoh: nama@email.com',
          hintStyle: TextStyle(color: Colors.black12, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFC5CAE9).withValues(alpha: 0.5), shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, color: Color(0xFF3F51B5), size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keamanan Terjamin', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF283593))),
                SizedBox(height: 4),
                Text(
                  'Proses perubahan email memerlukan verifikasi 2 langkah untuk melindungi data medis Anda.',
                  style: TextStyle(color: Color(0xFF5C6BC0), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 18),
        ],
      ),
    );
  }
}
