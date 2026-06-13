import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  final List<ProductModel> _items = [];
  Map<String, dynamic>? _appliedCoupon;
  bool _isLoading = false;

  CartProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  List<ProductModel> get items => _items;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get appliedCoupon => _appliedCoupon;

  void addToCart(ProductModel product) {
    if (!_items.any((item) => item.id == product.id)) {
      _items.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.id == productId);
    // Reset coupon if cart becomes invalid
    if (_items.isEmpty) {
      _appliedCoupon = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    notifyListeners();
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.priceINR);
  }

  double get discountAmount {
    if (_appliedCoupon == null) return 0.0;
    
    final type = _appliedCoupon!['couponType'] ?? 'PERCENTAGE';
    final val = _appliedCoupon!['discountValue'] ?? 0;
    
    if (type == 'PERCENTAGE') {
      double calculated = subtotal * (val / 100.0);
      // Enforce coupon max discount cap if defined in schema/metadata
      final maxCapCents = _appliedCoupon!['maxDiscountCents'];
      if (maxCapCents != null) {
        double maxCap = maxCapCents / 100.0;
        if (calculated > maxCap) {
          calculated = maxCap;
        }
      }
      return calculated;
    } else {
      // Fixed amount discount
      double fixedVal = val / 100.0;
      return fixedVal > subtotal ? subtotal : fixedVal;
    }
  }

  double get total {
    double finalVal = subtotal - discountAmount;
    return finalVal < 0.0 ? 0.0 : finalVal;
  }

  // Applies discount coupon via API validation
  Future<bool> applyCoupon(String code) async {
    if (_items.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.validateCoupon,
        body: {
          'code': code,
          'cartItems': _items.map((item) => {'productId': item.id}).toList(),
        },
        requiresAuth: true,
      );

      if (response != null && response['valid'] == true) {
        _appliedCoupon = response['coupon'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {
      _appliedCoupon = null;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Redirects to secure web checkout
  Future<void> checkout(BuildContext context) async {
    if (_items.isEmpty) return;

    // Build the query parameters for checkout redirection
    final itemIds = _items.map((item) => item.id).join(',');
    final couponCode = _appliedCoupon != null ? _appliedCoupon!['code'] : '';
    
    final checkoutUrl = Uri.parse(
      '${ApiConstants.baseUrl}/checkout?items=$itemIds&coupon=$couponCode',
    );

    try {
      await launchUrl(checkoutUrl, mode: LaunchMode.externalApplication);
      clearCart(); // Clear locally on checkout launch
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open checkout. Please check your internet connection and try again.')),
        );
      }
    }
  }
}
