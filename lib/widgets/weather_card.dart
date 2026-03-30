import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../theme/weather_theme.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final WeatherTheme theme;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.theme,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Column(
          children: [
            _MainWeatherCard(weather: weather, theme: theme),
            const SizedBox(height: 16),
            _DetailRow(weather: weather, theme: theme),
          ],
        ),
      ),
    );
  }
}

class _MainWeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final WeatherTheme theme;

  const _MainWeatherCard({required this.weather, required this.theme});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      theme: theme,
      child: Column(
        children: [
          _CardHeader(weather: weather, theme: theme),
          const SizedBox(height: 32),
          _TemperatureRow(weather: weather, theme: theme),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Відчувається як ${weather.formattedFeelsLike}°',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final WeatherModel weather;
  final WeatherTheme theme;

  const _CardHeader({required this.weather, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.cityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                weather.fullRegion,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          fit: FlexFit.loose,
          child: _ConditionBadge(description: weather.description, theme: theme),
        ),
      ],
    );
  }
}

class _ConditionBadge extends StatelessWidget {
  final String description;
  final WeatherTheme theme;

  const _ConditionBadge({required this.description, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accentColor.withOpacity(0.3)),
      ),
      child: Text(
        description,
        style: TextStyle(
          color: theme.accentColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}

class _TemperatureRow extends StatelessWidget {
  final WeatherModel weather;
  final WeatherTheme theme;

  const _TemperatureRow({required this.weather, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          weather.formattedTemp,
          style: TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            height: 1,
            shadows: [
              Shadow(color: theme.accentColor.withOpacity(0.5), blurRadius: 30),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            '°C',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Icon(
              theme.icon,
              key: ValueKey(theme.icon),
              size: 64,
              color: theme.accentColor,
              shadows: [
                Shadow(color: theme.accentColor.withOpacity(0.6), blurRadius: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final WeatherModel weather;
  final WeatherTheme theme;

  const _DetailRow({required this.weather, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WeatherDetailCard(
            icon: Icons.water_drop_rounded,
            label: 'Вологість',
            value: weather.formattedHumidity,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: WeatherDetailCard(
            icon: Icons.air_rounded,
            label: 'Вітер',
            value: weather.formattedWind,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class WeatherDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final WeatherTheme theme;

  const WeatherDetailCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.accentColor, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final WeatherTheme theme;
  final Widget child;

  const _GlassCard({required this.theme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: theme.accentColor.withOpacity(0.05),
            blurRadius: 60,
            spreadRadius: -10,
          ),
        ],
      ),
      child: child,
    );
  }
}