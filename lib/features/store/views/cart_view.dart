import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/cart_provider.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final TextEditingController _couponController = TextEditingController();
  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _handleApplyCoupon(CartProvider cartProvider) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final success = await cartProvider.applyCoupon(code);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coupon "$code" applied successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid coupon code or cart mismatch.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => cartProvider.clearCart(),
              child: Text(
                'Clear',
                style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
            )
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Small cover image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 70,
                                  height: 50,
                                  child: item.coverImageUrl != null
                                      ? Image.network(item.coverImageUrl!, fit: BoxFit.cover)
                                      : Container(color: AppColors.border, child: const Icon(Icons.shopping_bag)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Product text details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${item.priceINR}',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              // Remove button
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                                onPressed: () {
                                  cartProvider.removeFromCart(item.id);
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Pricing details and checkout drawer
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(color: AppColors.borderLight, width: 0.8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Coupon Application Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              style: GoogleFonts.inter(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Enter Coupon Code',
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: cartProvider.isLoading ? null : () => _handleApplyCoupon(cartProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: cartProvider.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                  )
                                : Text('APPLY', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Order Invoice Receipt Subtotal / Discount / Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                          Text('₹${cartProvider.subtotal.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (cartProvider.appliedCoupon != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount (${cartProvider.appliedCoupon!["code"]})',
                              style: GoogleFonts.inter(color: AppColors.success),
                            ),
                            Text(
                              '- ₹${cartProvider.discountAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Price', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(
                            '₹${cartProvider.total.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Checkout Razorpay Redirection button
                      ElevatedButton(
                        onPressed: () => cartProvider.checkout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'PROCEED TO SECURE CHECKOUT',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
                        ),
                      )
                    ],
                  ),
                )
              ],
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
            const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Browse playbooks, references, or courses and add them to your cart to purchase.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
