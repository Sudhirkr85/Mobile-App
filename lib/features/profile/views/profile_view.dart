import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/views/login_view.dart';
import 'order_history_view.dart';
import 'certificates_view.dart';
import 'about_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userProfile;
    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _phoneController.text = user['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
      // In a real application, we would call API client to upload the image
      // e.g. await apiClient.upload(ApiConstants.uploadAvatar, file);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar selected (Upload R2 placeholder active).')),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isEditing = false;
    });
    // In a real app, update profile details via API: ApiConstants.profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile details saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Student Profile',
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit_note, color: AppColors.accent),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Avatar selector with glow overlay
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.surface,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (user != null && user['image'] != null
                              ? NetworkImage(user['image'])
                              : null) as ImageProvider?,
                      child: _avatarFile == null && (user == null || user['image'] == null)
                          ? Text(
                              user != null && user['name'] != null
                                  ? user['name'].substring(0, 1).toUpperCase()
                                  : 'S',
                              style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: AppColors.accent,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        onPressed: _pickAvatar,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user != null ? (user['name'] ?? 'Sagar Student') : 'Student Name',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              user != null ? (user['email'] ?? '') : '',
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 2. Personal fields editing layout
            TextField(
              controller: _nameController,
              enabled: _isEditing,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              enabled: _isEditing,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 40),

            // 3. Navigation shortcuts to stubs (History & Certificates)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.history, color: AppColors.accent),
                    title: Text('Order History', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    subtitle: Text('Track shipments & order status', style: GoogleFonts.inter(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderHistoryView()),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.workspace_premium, color: AppColors.success),
                    title: Text('Certificates Cabinet', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    subtitle: Text('Download or share earned graduation keys', style: GoogleFonts.inter(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CertificatesView()),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppColors.accent),
                    title: Text('About Coaching Centre (हमारे बारे में)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    subtitle: Text('Contact info, founder, & official stats', style: GoogleFonts.inter(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutCentreView()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 4. Logout trigger
            OutlinedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(
                'LOG OUT',
                style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
