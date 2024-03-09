import 'dart:async';

import 'package:databv2/SelectBondedDevicePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './ChatPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled == false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Bluetooth',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        //actions: [IconButton(
        //icon: _bluetoothState.isEnabled? Icon(Icons.bluetooth_disabled, color: Colors.white) : Icon(Icons.bluetooth_disabled, color: Colors.grey),
        //tooltip: 'Bluetooth status',
        //onPressed: () {
        // code here
        //},
        //),],
      ),
      body: ListView(
        children: [
          //Divider(),
          ListTile(title: const Text('General')),
          Enable_Bluetooth(),
          Bluetooth_Status(),
          Local_Address(),
          Local_Name(),
          Divider(),
          Scan_Button(size, context),
        ],
      ),
    );
  }

  Row Scan_Button(double size, BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 16),
              width: size * 0.2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () async {
                  final BluetoothDevice selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    print('Discovery -> selected ' + selectedDevice.address);
                    _startChat(context, selectedDevice);
                  } else {
                    print('Discovery -> no device selected');
                  }
                },
                child: Text('Scan',style: TextStyle(color: Colors.white,fontSize: 20),),
              ),
            ),
          ],
        );
  }

  ListTile Local_Name() {
    return ListTile(
      title: const Text('Local adapter name'),
      subtitle: Text(_name),
      onLongPress: null,
    );
  }

  ListTile Local_Address() {
    return ListTile(
      title: const Text('Local adapter address'),
      subtitle: Text(_address),
    );
  }

  ListTile Bluetooth_Status() {
    return ListTile(
      title: const Text('Bluetooth status'),
      subtitle: Text(_bluetoothState.toString()),
      trailing: ElevatedButton(
        child: const Text('Settings', style: TextStyle(color: Colors.teal),),
        onPressed: () {
          FlutterBluetoothSerial.instance.openSettings();
        },
      ),
    );
  }

  SwitchListTile Enable_Bluetooth() {
    return SwitchListTile(
      title: const Text('Enable Bluetooth'),
      activeColor: Colors.teal,
      value: _bluetoothState.isEnabled,
      onChanged: (bool value) {
        // Do the request and update with the true value then
        future() async {
          // async lambda seems to not working
          if (value)
            await FlutterBluetoothSerial.instance.requestEnable();
          else
            await FlutterBluetoothSerial.instance.requestDisable();
        }

        future().then((_) {
          setState(() {});
        });
      },
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}
