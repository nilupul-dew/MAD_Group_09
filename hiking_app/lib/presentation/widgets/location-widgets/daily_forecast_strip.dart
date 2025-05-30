import 'package:flutter/material.dart';
import 'package:hiking_app/domain/models/location-models/weather_model.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class DailyForecastStrip extends StatelessWidget {
  final List<WeatherForecast> forecasts;

  const DailyForecastStrip({super.key, required this.forecasts});

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return Icons.cloudy_snowing;
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'drizzle':
        return Icons.grain;
      case 'wind':
        return Icons.air;
      default:
        return Icons.help_outline;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        // 👈 Wrap with Center
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: forecasts.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          separatorBuilder: (_, __) => const SizedBox(width: 25),
          itemBuilder: (context, index) {
            final forecast = forecasts[index];
            final now = DateTime.now();
            final tomorrow = now.add(const Duration(days: 1));

            final isTomorrow = forecast.date.day == tomorrow.day &&
                forecast.date.month == tomorrow.month;

            final dayLabel = isTomorrow
                ? 'TOM'
                : DateFormat.E().format(forecast.date).toUpperCase();

            return Container(
              width: 45,
              padding: const EdgeInsets.symmetric(vertical: 19),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 248, 248, 248),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      53,
                      52,
                      52,
                    ).withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              //days weather  icon
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    _getWeatherIcon(forecast.condition),
                    size: 22,
                    color: Colors.orange.withOpacity(0.68),
                  ),
                  //C no style
                  Text(
                    '${forecast.temp.round()}°',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  //Day text style
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
