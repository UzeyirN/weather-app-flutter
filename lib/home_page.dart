import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:re_air/search_page.dart';
import 'package:re_air/styles/styles.dart';
import 'package:re_air/widgets/daily_weather_card.dart';

import 'const.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String weatherImage = 'home';
  String location = 'Baku';
  var locationData;
  double? temperature;
  String? weatherIcon;
  Position? devicePosition;

  List<String> icons = ['01d', '01d', '01d' '01d', '01d'];
  List<double> temperatures = [
    20,
    20,
    20,
    20,
    20,
  ];
  List<String> dates = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  Future<void> getLocationDataFromAPI() async {
    locationData = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'),
    );
    var locationDataParsed = jsonDecode(locationData.body);

    setState(() {
      temperature = locationDataParsed['main']['temp'];
      location = locationDataParsed['name'];
      weatherImage = locationDataParsed['weather'].first['main'];
      weatherIcon = locationDataParsed['weather'].first['icon'];
    });
  }

  Future<void> getLocationDataFromAPIByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'),
      );
      var locationDataParsed = jsonDecode(locationData.body);

      setState(() {
        temperature = locationDataParsed['main']['temp'];
        location = locationDataParsed['name'];
        weatherImage = locationDataParsed['weather'].first['main'];
        weatherIcon = locationDataParsed['weather'].first['icon'];
      });
    }
  }

  Future<void> getDevicePosition() async {
    try {
      devicePosition = await _determinePosition();
      print(
          "Device position: ${devicePosition!.latitude}, ${devicePosition!.longitude}");
    } catch (error) {
      print("Error fetching device position: $error");
    }
  }

  Future<void> getDailyForecastByLatLon() async {
    var forecastData = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric',
      ),
    );

    var forecastDataParsed = jsonDecode(forecastData.body);

    icons.clear();
    temperatures.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i += 8) {
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  Future<void> getDailyForecastByLocation() async {
    var forecastData = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric',
      ),
    );

    var forecastDataParsed = jsonDecode(forecastData.body);

    icons.clear();
    temperatures.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i += 8) {
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  void getInitialData() async {
    try {
      await getDevicePosition();
      await getLocationDataFromAPIByLatLon();
      await getDailyForecastByLatLon();
    } catch (e) {
      print('error: $e in getInitialData');
    }
  }

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return temperature == null ||
            devicePosition == null ||
            icons.isEmpty ||
            temperatures.isEmpty ||
            dates.isEmpty
        ? SpinKitFadingCircle(
            itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.blue : Colors.white,
                ),
              );
            },
          )
        : Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/$weatherImage.jpg'),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Image.network(
                      'https://openweathermap.org/img/wn/$weatherIcon@4x.png'),
                ),
                Text('$temperature° C', style: tempStyle),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      location,
                      style: cityTextStyle,
                    ),
                    IconButton(
                      onPressed: () async {
                        final selectedCity = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchPage(),
                          ),
                        );
                        setState(() {
                          location = selectedCity;
                          getLocationDataFromAPI();
                          getDailyForecastByLocation();
                        });
                      },
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 25,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(3, 1),
                            blurRadius: 3.0,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                buildWeatherCard(context),
              ],
            ),
          );
  }

  SizedBox buildWeatherCard(BuildContext context) {
    List<DailyWeatherCard> cards = [];
    int itemCount = [icons.length, temperatures.length, dates.length]
        .reduce((value, element) => value < element ? value : element);
    for (int i = 0; i < itemCount; ++i) {
      cards.add(
        DailyWeatherCard(
          weatherIcon: icons[i],
          temperature: temperatures[i],
          date: dates[i],
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.35,
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
