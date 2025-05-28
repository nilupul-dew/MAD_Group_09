import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/weather_service.dart';
import 'package:hiking_app/domain/models/weather_model.dart';

class WeatherCard extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherCard({Key? key, required this.latitude, required this.longitude})
    : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Weather? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final data = await WeatherService().fetchWeather(
      widget.latitude,
      widget.longitude,
    );
    setState(() {
      _weather = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weather == null) {
      return const Center(child: Text("Weather data not available."));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.wb_sunny,
                size: 48,
                color: Colors.orangeAccent,
              ), // Example icon
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weather!.description,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Temp: ${_weather!.temperature}°C"),
                  Text("Wind: ${_weather!.windSpeed} km/h"),
                  Text("Humidity: ${_weather!.humidity}%"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
