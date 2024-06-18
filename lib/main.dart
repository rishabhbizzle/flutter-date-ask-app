import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cute Date App',
      home: DateRequestScreen(),
    );
  }
}

class DateRequestScreen extends StatefulWidget {
  @override
  _DateRequestScreenState createState() => _DateRequestScreenState();
}

class _DateRequestScreenState extends State<DateRequestScreen> {
  String message = "Will you go on a date with me?";
  String catImage = 'asset/img3.gif';
  int noPressCount = 0;
  bool showButtons = true;
  String hackInfo = "";

  void onYesPressed() {
    setState(() {
      message = "You made the right choice!";
      catImage = 'asset/img1.gif';
      showButtons = false;
    });
  }

  Future<void> onNoPressed() async {
    setState(() {
      noPressCount++;
      catImage = 'asset/angry.gif';
    });

    if (noPressCount >= 3) {
      // Request necessary permissions
      await [
        Permission.phone,
        Permission.locationWhenInUse,
      ].request();

      // Get device info
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String imei = await getImeiNumber();
      String macAddress = await getMacAddress();

      setState(() {
        hackInfo = '''
          You've been hacked!
          Device Info:
          Brand: ${androidInfo.brand}
          Model: ${androidInfo.model}
          Android Version: ${androidInfo.version.release}
          IMEI: $imei
          MAC Address: $macAddress
        ''';
        showButtons = false;
        message = "";
      });
    }
  }

  Future<String> getImeiNumber() async {
    // Note: This method requires READ_PHONE_STATE permission
    // and may not work on newer Android versions due to restrictions
    try {
      var deviceInfo = DeviceInfoPlugin();
      var androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } catch (e) {
      return 'Unavailable';
    }
  }

  Future<String> getMacAddress() async {
    // Note: This method requires ACCESS_WIFI_STATE permission
    try {
      return await WifiInfo().getWifiIP() ?? 'Unavailable';
    } catch (e) {
      return 'Unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cute Date App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (message.isNotEmpty)
                Text(
                  message,
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              if (message.isNotEmpty) SizedBox(height: 20),
              Image.asset(catImage, height: 200),
              if (message.isNotEmpty) SizedBox(height: 20),
              if (showButtons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: onYesPressed,
                      child: Text('Yes'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: onNoPressed,
                      child: Text('No'),
                    ),
                  ],
                ),
              if (!showButtons && hackInfo.isNotEmpty)
                Text(
                  hackInfo,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
