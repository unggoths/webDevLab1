class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> sizes;
  final List<ProductColor> colors;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.sizes,
    required this.colors,
  });
}

class ProductColor {
  final String name;
  final int hexValue;

  const ProductColor({required this.name, required this.hexValue});
}

final sampleProduct = Product(
  id: '1',
  name: 'AOT IoT Dotnet',
  brand: 'Red Flag',
  description:
  'Легкі кросівки з адаптивною підошвою та дихаючою сіткою. '
      'Ідеальні для щоденних тренувань та активного відпочинку. '
      'Підошва з піни EVA-00 забезпечує максимальну амортизацію.',
  price: 2499.00,
  rating: 4.7,
  reviewCount: 312,
  imageUrl:
  'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=800&q=80',
  sizes: ['38', '39', '40', '41', '42', '43', '44', '45'],
  colors: const [
    ProductColor(name: 'Coral', hexValue: 0xFFFF6B6B),
    ProductColor(name: 'Navy', hexValue: 0xFF2C3E7A),
    ProductColor(name: 'Mint', hexValue: 0xFF4ECDC4),
    ProductColor(name: 'Sand', hexValue: 0xFFE8C99A),
    ProductColor(name: 'Graphite', hexValue: 0xFF555566),
  ],
);