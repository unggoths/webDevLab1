import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../theme/weather_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_search_bar.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final _weatherService = WeatherService();
  final _cityController = TextEditingController();

  WeatherModel? _weather;
  String? _errorMessage;
  bool _isLoading = false;

  WeatherTheme _theme = WeatherTheme.defaultTheme;

  late AnimationController _cardAnimController;
  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _cardSlideAnim;

  @override
  void initState() {
    super.initState();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardFadeAnim = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    );
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _cityController.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() => _errorMessage = 'Введіть назву міста');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
    });
    _cardAnimController.reset();

    try {
      final weather = await _weatherService.fetchWeather(city);
      setState(() {
        _weather = weather;
        _theme = WeatherTheme.fromCondition(weather.description);
      });
      _cardAnimController.forward();
    } on WeatherException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Немає зʼєднання з мережею');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background fills the entire screen always
          Positioned.fill(child: AnimatedBackground(theme: _theme)),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 36),
                          WeatherSearchBar(
                            controller: _cityController,
                            theme: _theme,
                            isLoading: _isLoading,
                            onSearch: _fetchWeather,
                          ),
                          const SizedBox(height: 24),
                          if (_errorMessage != null) _buildError(),
                          if (_weather != null)
                            WeatherCard(
                              weather: _weather!,
                              theme: _theme,
                              fadeAnimation: _cardFadeAnim,
                              slideAnimation: _cardSlideAnim,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEATHER',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 6,
            color: _theme.accentColor.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Погода',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
            shadows: [
              Shadow(
                color: _theme.accentColor.withOpacity(0.4),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
          ),
        ],
      ),
    );
  }
}