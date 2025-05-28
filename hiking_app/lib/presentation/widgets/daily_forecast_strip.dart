// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class WeatherForecast {
//   final String condition;
//   final double temp;
//   final DateTime date;

//   WeatherForecast({
//     required this.condition,
//     required this.temp,
//     required this.date,
//   });
// }

// class DailyForecastStrip extends StatelessWidget {
//   final List<WeatherForecast> forecasts;

//   const DailyForecastStrip({Key? key, required this.forecasts})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children:
//             forecasts.asMap().entries.map((entry) {
//               final forecast = entry.value;
//               final index = entry.key;
//               final dayLabel = _getDayAbbreviation(forecast.date, index);

//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Column(
//                   children: [
//                     _getWeatherIcon(forecast.condition),
//                     const SizedBox(height: 6),
//                     Text(
//                       '${forecast.temp.round()}°C',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       dayLabel,
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//       ),
//     );
//   }

//   String _getDayAbbreviation(DateTime date, int index) {
//     if (index == 0) return 'TOM';
//     return DateFormat('EEE').format(date).toUpperCase();
//   }

//   Icon _getWeatherIcon(String condition) {
//     switch (condition.toLowerCase()) {
//       case 'clear':
//         return const Icon(Icons.wb_sunny, color: Colors.orange);
//       case 'clouds':
//         return const Icon(Icons.cloud, color: Colors.grey);
//       case 'rain':
//         return const Icon(Icons.umbrella, color: Colors.blue);
//       case 'thunderstorm':
//         return const Icon(Icons.flash_on, color: Colors.deepPurple);
//       case 'snow':
//         return const Icon(Icons.ac_unit, color: Colors.lightBlue);
//       default:
//         return const Icon(Icons.help_outline, color: Colors.black);
//     }
//   }
// }
//--------------------------------------------//
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherForecast {
  final String condition; // e.g., "Clear", "Rain", "Thunderstorm"
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

  const DailyForecastStrip({super.key, required this.forecasts});

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return Icons.water_drop;
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: forecasts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final forecast = forecasts[index];
          final isTomorrow =
              forecast.date.day ==
              DateTime.now().add(const Duration(days: 1)).day;
          final day =
              isTomorrow
                  ? 'TOM'
                  : DateFormat.E().format(forecast.date).toUpperCase();

          return Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 248, 248, 248),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  _getWeatherIcon(forecast.condition),
                  size: 28,
                  color: Colors.orange.shade600,
                ),
                Text(
                  '${forecast.temp.round()}°',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
