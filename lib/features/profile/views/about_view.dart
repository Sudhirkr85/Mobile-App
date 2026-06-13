import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';

class AboutCentreView extends StatelessWidget {
  const AboutCentreView({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link open nahi ho saka: $urlString ($e)'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Sagar Coaching Centre',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share Coaching Details',
            onPressed: () {
              Share.share(
                'Join Sagar Coaching Centre Supaul, Bihar by Shrvan Kumar Sagar (Aapka Bhai)!\n\n'
                ' माना कि अंधेरा घना है, पर दीया जलाना कहां मना है\n\n'
                'Official Website: ${ApiConstants.officialWebsite}\n'
                'Support Contact: ${ApiConstants.supportPhone}',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Founder Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Founder Photo Placement / Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.background,
                      backgroundImage: AssetImage('assets/images/app_icon.png'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Shrvan Kumar Sagar',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '("Aapka Bhai" — Supaul, Bihar)',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '“ माना कि अंधेरा घना है, पर दीया जलाना कहां मना है ”',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'India\'s Trusted Online Scholarship Exam Coaching',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Contact Details (संपर्क सूत्र)
            Text(
              'संपर्क करें (Contact Info)',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone, color: AppColors.accent),
                    title: Text('Call / WhatsApp', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    subtitle: Text(ApiConstants.supportPhone, style: GoogleFonts.inter()),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => _launchUrl(context, 'tel:${ApiConstants.supportPhone.replaceAll(' ', '')}'),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.email, color: AppColors.primary),
                    title: Text('Email Support', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    subtitle: Text(ApiConstants.supportEmail, style: GoogleFonts.inter()),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => _launchUrl(context, 'mailto:${ApiConstants.supportEmail}'),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.language, color: AppColors.success),
                    title: Text('Official Website', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    subtitle: Text(ApiConstants.officialWebsite.replaceAll('https://', '').replaceAll('http://', ''), style: GoogleFonts.inter()),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => _launchUrl(context, ApiConstants.officialWebsite),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.error),
                    title: Text('Coaching Address', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      ApiConstants.coachingAddress,
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
