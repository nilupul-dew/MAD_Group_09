import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherForecast {
  final String condition;
  final double temp;
  final DateTime date;

  WeatherForecast({
    required this.condition,
    required this.temp,
    required this.date,
  });
}

class DailyForecastStrip extends StatelessWidget {
  final List<WeatherForecast> forecasts;

  const DailyForecastStrip({Key? key, required this.forecasts})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            forecasts.asMap().entries.map((entry) {
              final forecast = entry.value;
              final index = entry.key;
              final dayLabel = _getDayAbbreviation(forecast.date, index);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _getWeatherIcon(forecast.condition),
                    const SizedBox(height: 6),
                    Text(
                      '${forecast.temp.round()}°C',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayLabel,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  String _getDayAbbreviation(DateTime date, int index) {
    if (index == 0) return 'TOM';
    return DateFormat('EEE').format(date).toUpperCase();
  }

  Icon _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const Icon(Icons.wb_sunny, color: Colors.orange);
      case 'clouds':
        return const Icon(Icons.cloud, color: Colors.grey);
      case 'rain':
        return const Icon(Icons.umbrella, color: Colors.blue);
      case 'thunderstorm':
        return const Icon(Icons.flash_on, color: Colors.deepPurple);
      case 'snow':
        return const Icon(Icons.ac_unit, color: Colors.lightBlue);
      default:
        return const Icon(Icons.help_outline, color: Colors.black);
    }
  }
}
