class ProductModel {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? coverImageUrl;
  final int priceCents;
  final int? originalPriceCents;
  final String productType;
  final int? inventoryCount;

  ProductModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.coverImageUrl,
    required this.priceCents,
    this.originalPriceCents,
    required this.productType,
    this.inventoryCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? json['shortDescription'],
      coverImageUrl: json['coverImageUrl'],
      priceCents: json['priceCents'] ?? 0,
      originalPriceCents: json['originalPriceCents'],
      productType: json['productType'] ?? 'DIGITAL_RESOURCE',
      inventoryCount: json['inventoryCount'] ?? json['stockQuantity'],
    );
  }

  double get priceINR => priceCents / 100.0;
  double? get originalPriceINR => originalPriceCents != null ? originalPriceCents! / 100.0 : null;

  int get discountPercent {
    if (originalPriceCents == null || originalPriceCents == 0 || priceCents >= originalPriceCents!) {
      return 0;
    }
    return (((originalPriceCents! - priceCents) / originalPriceCents!) * 100).round();
  }
}
