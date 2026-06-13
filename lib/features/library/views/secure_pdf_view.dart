import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class SecurePdfView extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const SecurePdfView({super.key, required this.title, required this.pdfUrl});

  @override
  State<SecurePdfView> createState() => _SecurePdfViewState();
}

class _SecurePdfViewState extends State<SecurePdfView> {
  String? _localPath;
  bool _isLoading = true;
  String _loadingMessage = 'Downloading playbook securely...';
  int _totalPages = 0;
  int _currentPage = 0;
  bool _pdfReady = false;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  @override
  void dispose() {
    // SECURITY: Atomically delete local temporary file on screen close
    if (_localPath != null) {
      final file = File(_localPath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    super.dispose();
  }

  Future<void> _downloadPdf() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      
      final Map<String, String> headers = {
        'Accept': 'application/json, application/pdf, */*',
      };
      if (token != null) {
        headers['Cookie'] = token;
      }

      final response = await http.get(Uri.parse(widget.pdfUrl), headers: headers);
      
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        final isJson = contentType.contains('application/json') || 
                       (!widget.pdfUrl.endsWith('.pdf') && !response.body.startsWith('%PDF'));

        if (isJson) {
          final data = jsonDecode(response.body);
          final fileUrl = data['fileUrl'];
          if (fileUrl == null || fileUrl.toString().isEmpty) {
            _handleDownloadError('Secure URL not found.');
            return;
          }

          // Fetch actual PDF binary from the secure R2/S3 URL (doesn't require our cookie headers)
          final pdfResponse = await http.get(Uri.parse(fileUrl.toString()));
          if (pdfResponse.statusCode == 200) {
            final bytes = pdfResponse.bodyBytes;
            await _savePdfBytes(bytes);
          } else {
            _handleDownloadError('Asset server returned error: ${pdfResponse.statusCode}');
          }
        } else {
          // Already raw PDF binary
          final bytes = response.bodyBytes;
          await _savePdfBytes(bytes);
        }
      } else {
        _handleDownloadError('Server returned error status code: ${response.statusCode}');
      }
    } catch (e) {
      _handleDownloadError('Check internet connection: $e');
    }
  }

  Future<void> _savePdfBytes(List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final tempFileName = 'secure_ref_${DateTime.now().microsecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$tempFileName');
    await file.writeAsBytes(bytes, flush: true);
    if (mounted) {
      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    }
  }

  void _handleDownloadError(String err) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingMessage = 'Failed to load PDF. Please check your connection and try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load document. Please check your internet connection.'), backgroundColor: AppColors.error),
      );
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
          widget.title,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (_pdfReady)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'Page ${_currentPage + 1} of $_totalPages',
                  style: GoogleFonts.firaMono(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            )
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 20),
                  Text(
                    _loadingMessage,
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : _localPath == null
              ? Center(
                  child: Text(
                    'Error: Could not render secure PDF.',
                    style: GoogleFonts.inter(color: AppColors.error),
                  ),
                )
              : Stack(
                  children: [
                    PDFView(
                      filePath: _localPath,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: _currentPage,
                      fitPolicy: FitPolicy.WIDTH,
                      preventLinkNavigation: false,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages ?? 0;
                          _pdfReady = true;
                        });
                      },
                      onError: (error) {
                        _handleDownloadError(error.toString());
                      },
                      onPageError: (page, error) {
                        _handleDownloadError('Page $page error: $error');
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        setState(() {
                          _pdfViewController = pdfViewController;
                        });
                      },
                      onPageChanged: (int? page, int? total) {
                        setState(() {
                          _currentPage = page ?? 0;
                        });
                      },
                    ),
                    
                    // Security watermarks overlay
                    IgnorePointer(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Opacity(
                              opacity: 0.04,
                              child: Text(
                                'SECURE LEARNER PORTAL - COPY PROTECTED',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
      floatingActionButton: _pdfReady && _currentPage > 0
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primary,
              onPressed: () {
                _pdfViewController?.setPage(0);
              },
              child: const Icon(Icons.vertical_align_top, color: Colors.white),
            )
          : null,
    );
  }
}
