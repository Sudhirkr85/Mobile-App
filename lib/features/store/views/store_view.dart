import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import 'product_detail_view.dart';
import 'cart_view.dart';

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  final ApiClient _apiClient = ApiClient();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  static final List<ProductModel> _fallbackProducts = [
    ProductModel(
      id: 'bihar-nmmse-book',
      title: 'BIHAR NMMSE — Bihar Exam Book 2026',
      slug: 'bihar-nmmse-exam-book',
      description: 'BIHAR NMMSE Preparation Book 2026. Authors: Shrvan Kumar Sagar, Vinod Kumar, Ajay Kumar. Publisher: Raghav Prakashan. Price: ₹395 | Pages: 350 | ISBN: 9789360136772. Complete coverage of SAT & MAT topics with practice sets.',
      coverImageUrl: 'assets/images/logo.png', // Fallback to asset
      priceCents: 39500, // ₹395
      originalPriceCents: 49500, // ₹495 (20% discount!)
      productType: 'DIGITAL_RESOURCE',
      inventoryCount: 100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchStoreProducts();
  }

  Future<void> _fetchStoreProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.get(ApiConstants.storeProducts, requiresAuth: false);
      if (response != null && response['products'] != null && response['products'] is List && (response['products'] as List).isNotEmpty) {
        setState(() {
          _products = (response['products'] as List)
              .map((p) => ProductModel.fromJson(p))
              .toList();
        });
      } else {
        setState(() {
          _products = List.from(_fallbackProducts);
        });
      }
    } catch (_) {
      setState(() {
        _products = List.from(_fallbackProducts);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Digital Store',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartView()),
                  );
                },
              ),
              if (cartProvider.items.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${cartProvider.items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _products.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final hasDiscount = product.discountPercent > 0;

                    return Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailView(product: product),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Product Image & Discount Badge
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      image: product.coverImageUrl != null
                                          ? DecorationImage(
                                              image: product.coverImageUrl!.startsWith('http')
                                                  ? NetworkImage(product.coverImageUrl!)
                                                  : AssetImage(product.coverImageUrl!) as ImageProvider,
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: AppColors.border,
                                    ),
                                    child: product.coverImageUrl == null
                                        ? const Center(
                                            child: Icon(Icons.shopping_bag, size: 40, color: AppColors.textMuted),
                                          )
                                        : null,
                                  ),
                                  if (hasDiscount)
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${product.discountPercent}% OFF',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),

                            // Product details metadata
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                   Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: product.productType == 'PHYSICAL_BOOK'
                                          ? AppColors.primary.withOpacity(0.15)
                                          : AppColors.accent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      product.productType == 'PHYSICAL_BOOK' ? '📖 Printed Book' : '📱 E-Book (PDF)',
                                      style: GoogleFonts.inter(
                                        color: product.productType == 'PHYSICAL_BOOK'
                                            ? AppColors.primary
                                            : AppColors.accent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (hasDiscount)
                                            Text(
                                              '₹${product.originalPriceINR}',
                                              style: GoogleFonts.inter(
                                                color: AppColors.textMuted,
                                                fontSize: 11,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          Text(
                                            '₹${product.priceINR}',
                                            style: GoogleFonts.outfit(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Add to Cart Action
                                      IconButton(
                                        icon: const Icon(Icons.add_shopping_cart, size: 20, color: AppColors.primary),
                                        onPressed: () {
                                          cartProvider.addToCart(product);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${product.title} added to cart.'),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
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
            const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 24),
            Text(
              'No products in store',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
