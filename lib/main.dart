/////////////////////////////////////////////////////////////////
/*
  ESP32 | BLUETOOTH CLASSIC | FLUTTER - Let's build BT Serial based on the examples. (Ft. Chat App)
  Video Tutorial: https://youtu.be/WUw-_X66dLE
  Created by Eric N. (ThatProject)
*/

// Updated 06-21-2021
// Due to Flutter's update, many parts have changed from the tutorial video.
// You need to keep @dart=2.9 before starting main to avoid null safety in Flutter 2
/////////////////////////////////////////////////////////////////

// @dart=3.3.0
import 'package:databv2/setting.dart';
import 'package:databv2/utility/my_constant.dart';
import 'package:flutter/material.dart';

import 'BluetoothSettings.dart';
import 'MainPage.dart';

final Map<String, WidgetBuilder> map = {
  '/BluetoothSettings': (BuildContext) => BluetoothSettingsPage(),
  '/setting': (BuildContext) => SettingPage(),
  
};

String? initialRoute;

void main() {
  initialRoute = MyConstant.routeBluetoothSettings;
  runApp(ExampleApplication());
}

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //return MaterialApp(debugShowCheckedModeBanner: false, home: BluetoothSettingsPage());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: MyConstant.appName,
      routes: map,
      initialRoute: initialRoute,
    );
  }
}
