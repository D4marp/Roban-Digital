import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robandigital/presentation/providers/home_provider.dart';
import 'package:robandigital/config/routes/app_routes.dart';
import 'account_page.dart';
import 'change_password_page.dart';
import 'notification_page.dart';
import 'two_factor_auth_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F5F7F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Profile Picture
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/home/profile_picture.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Name
                Text(
                  homeProvider.userName.isNotEmpty 
                    ? homeProvider.userName 
                    : 'Loading...',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Email
                Text(
                  homeProvider.userEmail.isNotEmpty
                    ? homeProvider.userEmail
                    : 'Loading...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Role
                if (homeProvider.userRole != null)
                  Text(
                    homeProvider.userRole!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Akun',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountPage(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Ubah Password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifikasi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.verified_user_outlined,
                  title: 'Verifikasi 2 Langkah',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TwoFactorAuthPage(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => _showLogoutConfirmation(context),
                  isLast: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final homeProvider = context.read<HomeProvider>();
              final success = await homeProvider.logout();
              
              if (success && context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout gagal')),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
            ),
          ),
      ],
    );
  }
}
