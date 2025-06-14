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
  // StreamSubscription<Position>? _positionStreamSubscription;
  Socket? _socket;
  final ipController = TextEditingController();
  final portController = TextEditingController();
  Timer? locationTimer;

  @override
  void dispose() {
    locationTimer?.cancel();
    disconnectSocket();
    super.dispose();
  }

  Future<bool> connectSocket() async {
    try {
      _socket = await Socket.connect(
        ipController.text,
        int.parse(portController.text),
      );
      return true;
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
      return false;
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

  Future<void> startTimer() async {
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
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    if (!await connectSocket()) {
      return;
    }
    if (_socket == null) {
      showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: Text('Server Error'),
              content: Text('Could not connect to the server'),
              actions: [
                CupertinoDialogAction(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
      return;
    }

    locationTimer?.cancel();
    locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _determinePosition();
    });
  }

  Future<void> _determinePosition() async {
    Position? position;

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition();
    setState(() {
      lat = position?.latitude;
      longtitude = position?.longitude;
    });
    sendLocation(lat, longtitude);
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
            IconButton(onPressed: startTimer, icon: Icon(Icons.start)),
            Expanded(child: Spacer(flex: 1)),
          ],
        ),
      ),
    );
  }
}
