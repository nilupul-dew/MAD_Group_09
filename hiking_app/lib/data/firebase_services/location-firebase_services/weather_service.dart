import 'dart:convert';
import 'package:hiking_app/domain/models/location-models/weather_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '2a8c6b6a7cfda04afbc3645345e1c03a';

  /// Get current weather for a given location
  Future<Weather> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather');
    }
  }

  /// Get 3-day forecast for the given location
  Future<List<WeatherForecast>> fetchForecast(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List<dynamic> forecastList = data['list'];

      // Select one forecast per day (every 8th item = 24 hours)
      List<WeatherForecast> dailyForecasts = [];
      for (int i = 0; i < forecastList.length; i += 8) {
        final item = forecastList[i];
        dailyForecasts.add(WeatherForecast.fromJson(item));
      }

      return dailyForecasts.take(3).toList(); // Only 3-day forecast
    } else {
      throw Exception('Failed to load forecast');
    }
  }
}

/// For current weather
class Weather {
  final String description;
  final double temperature;
  final double windSpeed;
  final int humidity;

  Weather({
    required this.description,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['main'],
      temperature: json['main']['temp'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      humidity: json['main']['humidity'].toInt(),
    );
  }
}
