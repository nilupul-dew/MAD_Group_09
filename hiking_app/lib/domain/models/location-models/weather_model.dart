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
