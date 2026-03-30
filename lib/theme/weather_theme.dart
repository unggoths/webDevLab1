import 'package:flutter/material.dart';

class WeatherTheme {
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  const WeatherTheme({
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });

  static const WeatherTheme defaultTheme = WeatherTheme(
    gradientColors: [Color(0xFF0B0C10), Color(0xFF1F2833), Color(0xFF0B3D0B)],
    accentColor: Color(0xFF66FCF1),
    icon: Icons.wb_cloudy_rounded,
  );

  static WeatherTheme fromCondition(String condition) {
    final c = condition.toLowerCase();

    if (c.contains('sun') || c.contains('clear') || c.contains('ясно')) {
      return const WeatherTheme(
        gradientColors: [Color(0xFFFF6B35), Color(0xFFFFB347), Color(0xFF87CEEB)],
        accentColor: Color(0xFFFFD700),
        icon: Icons.wb_sunny_rounded,
      );
    }
    if (c.contains('rain') || c.contains('дощ') || c.contains('drizzle')) {
      return const WeatherTheme(
        gradientColors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        accentColor: Color(0xFF4FC3F7),
        icon: Icons.grain_rounded,
      );
    }
    if (c.contains('cloud') || c.contains('хмар') || c.contains('overcast')) {
      return const WeatherTheme(
        gradientColors: [Color(0xFF485461), Color(0xFF28313B), Color(0xFF485461)],
        accentColor: Color(0xFFB0BEC5),
        icon: Icons.cloud_rounded,
      );
    }
    if (c.contains('snow') || c.contains('сніг')) {
      return const WeatherTheme(
        gradientColors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC), Color(0xFFD4E6F1)],
        accentColor: Color(0xFFFFFFFF),
        icon: Icons.ac_unit_rounded,
      );
    }
    if (c.contains('thunder') || c.contains('storm') || c.contains('гроза')) {
      return const WeatherTheme(
        gradientColors: [Color(0xFF0D0D0D), Color(0xFF1A0533), Color(0xFF2D1B69)],
        accentColor: Color(0xFFFFEB3B),
        icon: Icons.bolt_rounded,
      );
    }
    if (c.contains('fog') || c.contains('mist') || c.contains('туман')) {
      return const WeatherTheme(
        gradientColors: [Color(0xFF757F9A), Color(0xFFD7DDE8), Color(0xFF757F9A)],
        accentColor: Color(0xFFECEFF1),
        icon: Icons.water_rounded,
      );
    }

    return defaultTheme;
  }
}