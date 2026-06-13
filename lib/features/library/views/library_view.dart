import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'secure_pdf_view.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPurchasedBooks();
  }

  Future<void> _fetchPurchasedBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.get(ApiConstants.library, requiresAuth: true);
      if (response != null && response['books'] != null && response['books'] is List) {
        setState(() {
          _books = response['books'];
        });
      }
    } catch (e) {
      // Fallback to empty state
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Bookshelf',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _books.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    final productName = book['productName'] ?? 'Playbook resource';
                    final coverUrl = book['product']?['coverImageUrl'];
                    final orderId = book['orderId'].toString();
                    final productId = book['productId'].toString();
                    
                    // Generate a dynamic gradient based on name hash (matching next.js bookshelf page.tsx)
                    final coverGradient = _getGradientForTitle(productName);

                    return Card(
                      child: InkWell(
                        onTap: () {
                          // PDF secure viewer page url redirect hook
                          final secureUrl = '${ApiConstants.baseUrl}${ApiConstants.pdfProxy}/$orderId/pdf-access?productId=$productId';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SecurePdfView(
                                title: productName,
                                pdfUrl: secureUrl,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Book cover
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: coverUrl == null ? coverGradient : null,
                                  image: coverUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(coverUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: coverUrl == null
                                    ? Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.book, size: 28, color: Colors.white60),
                                            const SizedBox(height: 8),
                                            Text(
                                              productName,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      )
                                    : null,
                              ),
                            ),

                            // Book metadata footer
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Secure Playbook',
                                    style: GoogleFonts.inter(
                                      color: AppColors.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
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
            const Text('📚', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              'Your bookshelf is empty',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Guides and reference PDF playbooks purchased from our store will appear here for instant secure reading.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradientForTitle(String title) {
    final gradients = [
      const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF059669), Color(0xFF0D9488)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFFDB2777), Color(0xFF9333EA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ];
    final hash = title.codeUnits.fold(0, (prev, curr) => prev + curr);
    return gradients[hash % gradients.length];
  }
}
