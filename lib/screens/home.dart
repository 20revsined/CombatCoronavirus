import 'package:us_states/us_states.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:geocoder/geocoder.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class CovidData {
  int worldWideCases;
  int totalDeaths;
  int stateCases;
  CovidData({this.worldWideCases, this.totalDeaths, this.stateCases});
}

Future<CovidData> fetchCovidData() async {
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  final coordinates = new Coordinates(position.latitude, position.longitude);
  print(coordinates);
  var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  var state = USStates.getAbbreviation(first.adminArea);
  final states_data = await http.get('https://covidtracking.com/api/states');
  final List stateData = json.decode(states_data.body);
  states_data != null ? print("Got Data") : print("Could not get Covid Data");
  var state_cases;
  stateData.forEach((f) => {if(f['state'] == state){state_cases = f['positive']}});
  final res =
      await http.get('https://thevirustracker.com/free-api?global=stats');
  res != null ? print("Got Data") : print("Could not get Covid Data");
  final Map parsedData = json.decode(res.body);
  CovidData covidData = new CovidData(
    worldWideCases: parsedData["results"][0]["total_cases"],
    totalDeaths: parsedData["results"][0]["total_deaths"],
    stateCases: state_cases,
  );
  return covidData;
}

//Creates a list of Covid Data passed in off a json list
List<CovidData> createCovidList(List data) {
  List<CovidData> list = new List();
  for (int i = 0; i < data.length; i++) {
    int world_wide_cases = data[i]["results"]["total_cases"];
    int total_deaths = data[i]["results"]["total_deaths"];
    CovidData covidData = new CovidData(
        worldWideCases: world_wide_cases, totalDeaths: total_deaths);
    list.add(covidData);
  }
  return list;
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Corona"),
            Text(
              "Tracker",
              style: TextStyle(color: Colors.red),
            )
          ],
        )),
        body: Container(
            child: FutureBuilder<CovidData>(
          future: fetchCovidData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? CovidCards(covidData: snapshot.data)
                : Center(child: CircularProgressIndicator());
          },
        )));
  }
}

class CovidCards extends StatelessWidget {
  final CovidData covidData;
  CovidCards({Key key, this.covidData}) : super(key: key);
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 6,
            width: MediaQuery.of(context).size.width / 12 * 11,
            color: Colors.black,
            child: Row(
              children: <Widget>[
                SizedBox(width: 20),
                Text(
                  "Cases in State",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                Spacer(),
                Text(
                  covidData.stateCases.toString(),
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 6,
            width: MediaQuery.of(context).size.width / 12 * 11,
            color: Colors.black,
            child: Row(
              children: <Widget>[
                SizedBox(width: 20),
                Text(
                  "Cases World Wide",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                Spacer(),
                Text(
                  covidData.worldWideCases.toString(),
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 6,
            width: MediaQuery.of(context).size.width / 12 * 11,
            color: Colors.black,
            child: Row(
              children: <Widget>[
                SizedBox(width: 20),
                Text(
                  "Deaths Total",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                Spacer(),
                Text(
                  covidData.totalDeaths.toString(),
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
