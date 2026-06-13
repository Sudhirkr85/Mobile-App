import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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
      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        
        // Random secure temp name to prevent user interception
        final tempFileName = 'secure_ref_${DateTime.now().microsecondsSinceEpoch}.pdf';
        final file = File('${dir.path}/$tempFileName');
        
        await file.writeAsBytes(bytes, flush: true);
        
        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        _handleDownloadError('Server returned error status code: ${response.statusCode}');
      }
    } catch (e) {
      _handleDownloadError('Check internet connection: $e');
    }
  }

  void _handleDownloadError(String err) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingMessage = 'Failed to load PDF. $err';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification Failed: $err'), backgroundColor: AppColors.error),
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
