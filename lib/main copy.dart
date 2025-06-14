import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const MyHomePage(title: 'GPS System'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double? lat = 0;
  double? longtitude = 0;
  StreamSubscription<Position>? _positionStreamSubscription;
  Socket? _socket;
  final ipController = TextEditingController();
  final portController = TextEditingController();

  Future<void> connectSocket() async {
    try {
      _socket = await Socket.connect(
        ipController.text,
        int.parse(portController.text),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('Either the port or ip is incorrect'),
              actions: [
                CupertinoDialogAction(
                  child: Text('Ok'),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
              ],
            ),
      );
    }
  }

  void sendLocation(double? lat, double? lng) {
    if (_socket != null) {
      String locationJson = jsonEncode({'latitude': lat, 'longitude': lng});
      _socket!.write(locationJson);
    }
  }

  void disconnectSocket() {
    _socket?.destroy();
    _socket = null;
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // return await Geolocator.getCurrentPosition();
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionStreamSubscription?.cancel();
    // Connecting to the socket
    connectSocket();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) {
      setState(() {
        lat = position?.latitude;
        longtitude = position?.longitude;
        sendLocation(lat, longtitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(flex: 1),
            Row(
              children: [
                Expanded(child: Spacer(flex: 1)),
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Ip:'),
                    controller: ipController,
                  ),
                ),
                Expanded(child: Spacer(flex: 1)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Spacer(flex: 1)),
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Port:'),
                    controller: portController,
                  ),
                ),
                Expanded(child: Spacer(flex: 1)),
              ],
            ),
            Expanded(child: Spacer(flex: 1)),
            Text('Latitude:$lat'),
            Text('Longtitude:$longtitude'),
            IconButton(onPressed: _determinePosition, icon: Icon(Icons.start)),
            Expanded(child: Spacer(flex: 1)),
          ],
        ),
      ),
    );
  }
}
