import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = '42718b8c69764ebab14200518262303';
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  Future<WeatherModel> fetchWeather(String city) async {
    final url = Uri.parse(
      '$_baseUrl/current.json?key=$_apiKey&q=$city&lang=uk',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(data);
    } else {
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      final message = (err['error'] as Map<String, dynamic>?)?['message'] as String?;
      throw WeatherException(message ?? 'Місто не знайдено');
    }
  }
}

class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}