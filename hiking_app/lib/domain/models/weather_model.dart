class Weather {
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}
