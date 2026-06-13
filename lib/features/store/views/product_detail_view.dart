import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductDetailView extends StatelessWidget {
  final ProductModel product;

  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPercent > 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Details',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            AspectRatio(
              aspectRatio: 4 / 3,
              child: product.coverImageUrl != null
                  ? (product.coverImageUrl!.startsWith('http')
                      ? Image.network(product.coverImageUrl!, fit: BoxFit.cover)
                      : Image.asset(product.coverImageUrl!, fit: BoxFit.cover))
                  : Container(
                      color: AppColors.border,
                      child: const Center(
                        child: Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textMuted),
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.productType == 'PHYSICAL_BOOK'
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.productType == 'PHYSICAL_BOOK' ? '📖 Printed Book' : '📱 E-Book (PDF)',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product.productType == 'PHYSICAL_BOOK'
                                ? AppColors.primary
                                : AppColors.accent,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Discount indicator
                  if (hasDiscount) ...[
                    Row(
                      children: [
                        Text(
                          '₹${product.originalPriceINR}',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 15,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Save ${product.discountPercent}%',
                            style: GoogleFonts.inter(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Sale Price
                  Text(
                    '₹${product.priceINR}',
                    style: GoogleFonts.outfit(
                      color: AppColors.success,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stock warning status
                  if (product.inventoryCount != null) ...[
                    Text(
                      product.inventoryCount! > 0
                          ? '✅ In stock (${product.inventoryCount} units remaining)'
                          : '❌ Out of stock',
                      style: GoogleFonts.inter(
                        color: product.inventoryCount! > 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  Text(
                    'Product Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? 'No description provided.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Buy Button card
                  ElevatedButton(
                    onPressed: () async {
                      final url = Uri.parse('${ApiConstants.baseUrl}/store/${product.slug}');
                      try {
                        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unable to open purchase page. Please check your internet connection.')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Center(
                      child: Text(
                        'BUY NOW',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
