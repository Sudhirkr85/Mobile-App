import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class CertificatesView extends StatefulWidget {
  const CertificatesView({super.key});

  @override
  State<CertificatesView> createState() => _CertificatesViewState();
}

class _CertificatesViewState extends State<CertificatesView> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.get('/api/student/certificates', requiresAuth: true);
      if (response != null && response['certificates'] != null && response['certificates'] is List) {
        setState(() {
          _certificates = response['certificates'];
        });
      } else {
        setState(() {
          _certificates = [];
        });
      }
    } catch (_) {
      setState(() {
        _certificates = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadCertificate(String verificationCode) async {
    final downloadUrl = Uri.parse('${ApiConstants.baseUrl}/api/certificates/$verificationCode/download');
    try {
      await launchUrl(downloadUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to download certificate. Please check your internet connection.')),
        );
      }
    }
  }

  void _shareCertificate(String verificationCode, String courseTitle) {
    final verificationUrl = '${ApiConstants.baseUrl}/verify/$verificationCode';
    Share.share(
      '🎓 I just graduated and earned my certification in "$courseTitle" from Sagar Coaching Centre! Verify my credential here: $verificationUrl',
      subject: 'My Blockchain-Verified Course Certificate',
    );
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
          'My Certificates',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _certificates.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _certificates.length,
                  itemBuilder: (context, index) {
                    final cert = _certificates[index];
                    final courseTitle = cert['enrollment']?['course']?['title'] ?? 'LMS Course Graduation';
                    final code = cert['verificationCode'] ?? 'SCC-XXXXXX';
                    final date = DateTime.parse(cert['issuedAt'] ?? DateTime.now().toIso8601String());
                    final formattedDate = '${date.day}/${date.month}/${date.year}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.verified, color: AppColors.success, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        courseTitle,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Verification Code: $code',
                                        style: GoogleFonts.firaMono(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                      Text(
                                        'Issued Date: $formattedDate',
                                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const Divider(height: 28, color: AppColors.border),
                            
                            // Action Panel
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _downloadCertificate(code),
                                    icon: const Icon(Icons.download, size: 16, color: Colors.white),
                                    label: Text('DOWNLOAD', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _shareCertificate(code, courseTitle),
                                    icon: const Icon(Icons.share, size: 16, color: AppColors.accent),
                                    label: Text('SHARE LINK', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.accent),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 24),
            Text(
              'No certificates awarded yet',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Graduation certificates will automatically compile when you complete 100% of a course syllabus.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
