import 'package:flutter/material.dart';
import 'screens/weather_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const WeatherScreen(),
    );
  }
}