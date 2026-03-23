import 'package:flutter/material.dart';
import 'models/product.dart';
import 'screens/product_detail_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Card',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: ProductDetailScreen(product: sampleProduct),
    );
  }
}