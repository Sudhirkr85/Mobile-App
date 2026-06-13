import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';

class AboutCentreView extends StatelessWidget {
  const AboutCentreView({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link open nahi ho saka: $urlString'),
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
                    color: AppColors.primary.withOpacity(0.1),
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
            const SizedBox(height: 20),

            // 2. Stats Grid (हमारी उपलब्धियां)
            Text(
              'हमारी उपलब्धियां (Coaching Stats)',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('5000+', 'Students Coached'),
                _buildStatCard('500+', 'Govt School Selections'),
                _buildStatCard('4', 'YouTube Channels'),
                _buildStatCard('7+ Years', 'Teaching Experience'),
              ],
            ),
            const SizedBox(height: 25),

            // 3. Contact Details (संपर्क सूत्र)
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
            const SizedBox(height: 25),

            // 4. Social Media Channels (तैयारी के लिए चैनल्स)
            Text(
              'यूट्यूब ऑनलाइन तैयारी (YouTube Channels)',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  _buildSocialListTile(
                    context,
                    Icons.video_library,
                    'NMMS Exam (Main Channel)',
                    'Bhagwanpur Classes',
                    'https://youtube.com/@sagarcoachingcentrebhagwanpur',
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSocialListTile(
                    context,
                    Icons.play_circle_fill,
                    'NMMS MAT + SAT Preparation',
                    'NMMS King Sagar Sir',
                    'https://youtube.com/@NmmsKingSagarSir',
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSocialListTile(
                    context,
                    Icons.school,
                    'CMMSS & Shrestha NETS',
                    'Yogita Online Classes',
                    'https://youtube.com/@YogitaOnlineClasses',
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSocialListTile(
                    context,
                    Icons.star_purple500,
                    'Navodaya, Sainik & Simultala',
                    'Akanksha Junior Classes',
                    'https://youtube.com/@AkankshaJuniorClasses',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 5. Connect On Social Portals
            Text(
              'सोशल मीडिया पर जुड़ें (Follow Us)',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialIcon(context, 'assets/images/logo.png', 'WhatsApp', 'https://wa.me/919110113671', iconData: Icons.chat),
                _buildSocialIcon(context, 'assets/images/logo.png', 'Facebook', 'https://facebook.com/SagarCoachingCentreBhagwanpur59', iconData: Icons.facebook),
                _buildSocialIcon(context, 'assets/images/logo.png', 'Instagram', 'https://instagram.com/sagarcoachingcentrebhagwanpur', iconData: Icons.camera_alt),
                _buildSocialIcon(context, 'assets/images/logo.png', 'Telegram', 'https://t.me/ShrvanKumarSagar', iconData: Icons.telegram),
              ],
            ),
            const SizedBox(height: 30),

            // 6. Ratings & Book Details
            Text(
              'परीक्षा गाइड बुक (NMMSE Study Guide)',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.book, size: 36, color: AppColors.accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BIHAR NMMSE 2026',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'By Shrvan K. Sagar, Vinod K., Ajay K.',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Price: ₹395',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Pages: 350',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  Text(
                    'ISBN: 9789360136772 | Publisher: Raghav Prakashan',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 7. Establish Details & Ratings
            Row(
              children: [
                Expanded(
                  child: _buildRatingBox('Google Review', '5.0 ⭐', '7 Reviews'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRatingBox('JustDial Rating', '4.7 ⭐', '16 Reviews'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Established: 2018 | Supaul, Bihar',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String val, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            val,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialListTile(
    BuildContext context,
    IconData icon,
    String title,
    String channelName,
    String url,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text(channelName, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Text(
          'Subscribe',
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () => _launchUrl(context, url),
    );
  }

  Widget _buildSocialIcon(
    BuildContext context,
    String assetPath,
    String label,
    String url, {
    required IconData iconData,
  }) {
    return InkWell(
      onTap: () => _launchUrl(context, url),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surface,
              child: Icon(iconData, color: AppColors.accent, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBox(String platform, String rating, String count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
      ),
      child: Column(
        children: [
          Text(
            platform,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            rating,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
