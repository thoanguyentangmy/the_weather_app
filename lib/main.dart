import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(TheWeatherApp());
}

class TheWeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('build ======= ');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int temperature = 0;
  String location = 'San Francisco';
  String woeid = '2487956';
  String weather = 'thunderstorm';
  String searchApiURL =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiURL = 'https://www.metaweather.com/api/location/';
  String abbrevation = '';

  @override
  void initState() {
    print('initState ======= ');
    fetchLocation();
    super.initState();
  }
  fetchSearch(String input) async {
    print('fetchLocation ======= ');
    var searchResult = await http.get(searchApiURL + input);
    var result = json.decode(searchResult.body)[0];

    setState(() {
      location = result['title'];
      woeid = result['woeid'];
    });
  }

  fetchLocation() async {
    print('fetchLocation ======= ');

    var locationResult = await http.get(locationApiURL + woeid.toString());
    var result = json.decode(locationResult.body)[0];
    var consolidatedWeather = result['consolidated_weather'];
    var data = consolidatedWeather[0];
    temperature = data['the_temp'].round();
    weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
    print('weather ======= '+ weather);
    abbrevation = data['weather_state_abbr'];

    setState(() {
      temperature = data['the_temp'].round();
      weather = data['weather_state_name'];
    });
  }

  void onTextFieldSubmitted(String input) {
    fetchSearch(input);
    fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    print('build 1 ======= ');

    final size = MediaQuery.of(context).size;
    double width = size.width;
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/$weather.png'),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.network(
                    'https://www.metaweather.com/static/img/weather/png/' +
                        abbrevation +
                        '.png',
                    width: 100,
                  ),
                  Text(
                    temperature.toString() + '°C',
                    style: TextStyle(color: Colors.white, fontSize: 60.0),
                  ),
                  Text(
                    location,
                    style: TextStyle(color: Colors.white, fontSize: 40.0),
                  )
                ],
              ),
              Container(
                width: width / 1.3,
                child: TextField(
                  onSubmitted: (String input) {
                    onTextFieldSubmitted(input);
                  },
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                  decoration: InputDecoration(
                      hintText: 'Search another location',
                      hintStyle: TextStyle(color: Colors.white, fontSize: 18.0),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white,
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
