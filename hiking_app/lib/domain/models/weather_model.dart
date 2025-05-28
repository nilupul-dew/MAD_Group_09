// class Weather {
//   final double temperature;
//   final String description;
//   final String iconCode;
//   final int humidity;
//   final double windSpeed;

//   Weather({
//     required this.temperature,
//     required this.description,
//     required this.iconCode,
//     required this.humidity,
//     required this.windSpeed,
//   });

//   factory Weather.fromJson(Map<String, dynamic> json) {
//     return Weather(
//       temperature: json['main']['temp'].toDouble(),
//       description: json['weather'][0]['description'],
//       iconCode: json['weather'][0]['icon'],
//       humidity: json['main']['humidity'],
//       windSpeed: json['wind']['speed'].toDouble(),
//     );
//   }
// }
//----------------------------------------//
// class Weather {
//   final String description;
//   final double temperature;
//   final double windSpeed;
//   final int humidity;

//   Weather({
//     required this.description,
//     required this.temperature,
//     required this.windSpeed,
//     required this.humidity,
//   });

//   factory Weather.fromJson(Map<String, dynamic> json) {
//     return Weather(
//       description:
//           json['weather'][0]['main'], // <-- this is "Clear", "Rain", etc.
//       temperature: json['main']['temp'].toDouble(),
//       windSpeed: json['wind']['speed'].toDouble(),
//       humidity: json['main']['humidity'].toInt(),
//     );
//   }
// }

//-------------------------------------//
class WeatherForecast {
  final String condition;
  final double temp;
  final DateTime date;

  WeatherForecast({
    required this.condition,
    required this.temp,
    required this.date,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      condition: json['weather'][0]['main'],
      temp: json['main']['temp'].toDouble(),
      date: DateTime.parse(json['dt_txt']),
    );
  }
}
