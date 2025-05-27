import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:hiking_app/domain/models/weather_model.dart';

class WeatherService {
  final String apiKey = '2a8c6b6a7cfda04afbc3645345e1c03a';

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
}
