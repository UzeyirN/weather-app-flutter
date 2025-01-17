import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard(
      {super.key,
      required this.weatherIcon,
      required this.temperature,
      required this.date});

  final String weatherIcon;
  final double temperature;
  final String date;

  @override
  Widget build(BuildContext context) {
    List<String> weekdays = [
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
      'SUN',
    ];

    String weekday = weekdays[DateTime.parse(date).weekday - 1];

    return Card(
      color: Colors.transparent,
      child: SizedBox(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network('https://openweathermap.org/img/wn/$weatherIcon.png'),
            Text(
              '$temperature° C',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(4, 1),
                    blurRadius: 3.0,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            Text(
              textAlign: TextAlign.center,
              weekday,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(2, 1),
                    blurRadius: 3.0,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
