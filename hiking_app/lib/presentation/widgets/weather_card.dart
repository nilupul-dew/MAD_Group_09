// import 'package:flutter/material.dart';
// import 'package:hiking_app/data/firebase_services/weather_service.dart';
// //import 'package:hiking_app/domain/models/weather_model.dart';

// class WeatherCard extends StatefulWidget {
//   final double latitude;
//   final double longitude;

//   const WeatherCard({Key? key, required this.latitude, required this.longitude})
//     : super(key: key);

//   @override
//   State<WeatherCard> createState() => _WeatherCardState();
// }

// class _WeatherCardState extends State<WeatherCard> {
//   Weather? _weather;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadWeather();
//   }

//   Future<void> _loadWeather() async {
//     final data = await WeatherService().fetchWeather(
//       widget.latitude,
//       widget.longitude,
//     );
//     setState(() {
//       _weather = data;
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_weather == null) {
//       return const Center(child: Text("Weather data not available."));
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         elevation: 3,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.wb_sunny,
//                 size: 48,
//                 color: Colors.orangeAccent,
//               ), // Example icon
//               const SizedBox(width: 16),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _weather!.description,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text("Temp: ${_weather!.temperature}°C"),
//                   Text("Wind: ${_weather!.windSpeed} km/h"),
//                   Text("Humidity: ${_weather!.humidity}%"),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//-----------above work------------//
import 'package:flutter/material.dart';
import 'package:hiking_app/data/firebase_services/weather_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking_app/domain/models/weather_model.dart'; // Contains WeatherForecast

import 'daily_forecast_strip.dart';

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
  List<WeatherForecast> _forecasts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final weather = await WeatherService().fetchWeather(
      widget.latitude,
      widget.longitude,
    );

    // Mock forecasts for now
    final now = DateTime.now();
    final mockForecasts = List.generate(3, (index) {
      return WeatherForecast(
        condition:
            index == 0
                ? 'Clouds'
                : index == 1
                ? 'Rain'
                : 'Clear',
        temp: 25 + index.toDouble(),
        date: now.add(Duration(days: index + 1)),
      );
    });

    setState(() {
      _weather = weather;
      _forecasts = mockForecasts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 158, 182, 235).withOpacity(0.09),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //  Today's weather
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      color: Colors.orange.shade600,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.temperatureHalf,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '${_weather!.temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.wind,
                      color: const Color.fromARGB(255, 170, 197, 243),
                      size: 22,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '${_weather!.windSpeed.toStringAsFixed(1)} km/h',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.droplet,
                      color: const Color.fromARGB(255, 9, 62, 161),
                      size: 22,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '${_weather!.humidity}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Next 3 days forecast
            DailyForecastStrip(forecasts: _forecasts),
          ],
        ),
      ),
    );
  }
}
