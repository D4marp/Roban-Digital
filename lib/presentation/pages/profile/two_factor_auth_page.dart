import 'package:flutter/material.dart';

class TwoFactorAuthPage extends StatefulWidget {
  const TwoFactorAuthPage({super.key});

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  bool _isTwoFactorEnabled = false;
  String _selectedMethod = 'SMS';

  void _toggleTwoFactor(bool value) {
    if (value) {
      _showEnableTwoFactorDialog();
    } else {
      _showDisableTwoFactorDialog();
    }
  }

  void _showEnableTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Aktifkan Verifikasi 2 Langkah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Dengan mengaktifkan verifikasi 2 langkah, akun Anda akan lebih aman. Anda akan menerima kode verifikasi setiap kali login.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isTwoFactorEnabled = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verifikasi 2 langkah berhasil diaktifkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5F7F),
              ),
              child: const Text('Aktifkan'),
            ),
          ],
        );
      },
    );
  }

  void _showDisableTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Nonaktifkan Verifikasi 2 Langkah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menonaktifkan verifikasi 2 langkah? Akun Anda akan kurang aman.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isTwoFactorEnabled = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verifikasi 2 langkah berhasil dinonaktifkan'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Nonaktifkan'),
            ),
          ],
        );
      },
    );
  }

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
          'Verifikasi 2 Langkah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2F5F7F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2F5F7F).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2F5F7F),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Verifikasi 2 langkah menambahkan lapisan keamanan ekstra ke akun Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Enable/Disable Switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktifkan Verifikasi 2 Langkah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lindungi akun Anda dengan lapisan keamanan tambahan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isTwoFactorEnabled,
                  onChanged: _toggleTwoFactor,
                  activeColor: const Color(0xFF2F5F7F),
                ),
              ],
            ),
          ),
          
          if (_isTwoFactorEnabled) ...[
            const SizedBox(height: 30),
            
            const Text(
              'Metode Verifikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // SMS Method
            _buildMethodTile(
              title: 'SMS',
              subtitle: 'Terima kode verifikasi melalui SMS',
              icon: Icons.message,
              isSelected: _selectedMethod == 'SMS',
              onTap: () {
                setState(() {
                  _selectedMethod = 'SMS';
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // Email Method
            _buildMethodTile(
              title: 'Email',
              subtitle: 'Terima kode verifikasi melalui email',
              icon: Icons.email,
              isSelected: _selectedMethod == 'Email',
              onTap: () {
                setState(() {
                  _selectedMethod = 'Email';
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // Authenticator App Method
            _buildMethodTile(
              title: 'Authenticator App',
              subtitle: 'Gunakan aplikasi authenticator',
              icon: Icons.qr_code_scanner,
              isSelected: _selectedMethod == 'Authenticator',
              onTap: () {
                setState(() {
                  _selectedMethod = 'Authenticator';
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F5F7F)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color(0xFF2F5F7F).withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2F5F7F)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF2F5F7F)
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2F5F7F),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
