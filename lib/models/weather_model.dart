class WeatherModel {
  final String cityName;
  final String region;
  final String country;
  final double temperature;
  final double feelsLike;
  final String description;
  final int humidity;
  final double windKph;

  const WeatherModel({
    required this.cityName,
    required this.region,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.humidity,
    required this.windKph,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['location']['name'] as String,
      region: json['location']['region'] as String,
      country: json['location']['country'] as String,
      temperature: (json['current']['temp_c'] as num).toDouble(),
      feelsLike: (json['current']['feelslike_c'] as num).toDouble(),
      description: json['current']['condition']['text'] as String,
      humidity: json['current']['humidity'] as int,
      windKph: (json['current']['wind_kph'] as num).toDouble(),
    );
  }

  String get formattedTemp => temperature.toStringAsFixed(0);
  String get formattedFeelsLike => feelsLike.toStringAsFixed(0);
  String get formattedHumidity => '$humidity%';
  String get formattedWind => '${windKph.toStringAsFixed(0)} км/г';
  String get fullRegion => '$region, $country';
}