import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'dart:typed_data';
import 'dart:developer';

import 'package:databv2/FileStorage.dart';
import 'package:databv2/read_excel_file.dart';

import 'package:databv2/setting.dart';
import 'package:databv2/show_excel_page.dart';
import 'package:databv2/utility/my_constant.dart';
import 'package:databv2/widgets/show_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:syncfusion_flutter_xlsio/xlsio.dart'
//     hide Column
//     hide Row
//     hide Stack;

import 'package:excel/excel.dart' as FromExcel;
//import 'package:path/path.dart';

import 'package:timelines/timelines.dart';

import 'package:async/async.dart';

import 'package:sample_statistics/sample_statistics.dart';

late SharedPreferences prefs;

String read_point_selected = '1';
String read_preset_selected = 'Preset1';
String read_preset_name = 'Preset1';

String read_min1 = '0';
String read_min2 = '0';
String read_min3 = '0';
String read_min4 = '0';
String read_min5 = '0';

String read_max1 = '0';
String read_max2 = '0';
String read_max3 = '0';
String read_max4 = '0';
String read_max5 = '0';

const kTileHeight = 50.0;

// const completeColor = Color(0xff5e6172);
// const inProgressColor = Color(0xff5ec792);
// const todoColor = Color(0xffd1d2d7);

const inProgressColor = Colors.yellow;
const completeColor = Colors.green;
const todoColor = Colors.white;

int? cnt_ok;
int? cnt_ng;
int? cnt_total;

int? cnt_;
String timenow = '';

bool isSaving = false;

String filename_excel = '';

class Mainpage extends StatefulWidget {
  final BluetoothDevice server;
  const Mainpage({required this.server});

  @override
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  List<String> data_recived = [
    'Waiting',
    'Waiting',
    'Waiting',
    'Waiting',
    'Waiting'
  ];

  List<String> unit = ['', '', '', '', ''];

  int index_recive = 0;
  int index_image = 1;

  var connection; //BluetoothConnection

  List<String> buffer = [];

  bool isConnecting = true;
  bool isDisconnecting = false;

  final status_result = [true, true, true, true, true];
  late bool judge = false;

  var excel;

  List<List<int>> chunks = <List<int>>[];
  int contentLength = 0;
  late Uint8List _bytes;
  late RestartableTimer _timer;

  late String imagePathDownloadFolder = '/storage/emulated/0/Download/';
  late String FileImagePath;
  bool isFolderName = false;
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Color getColor(int index) {
    if (index == index_recive) {
      return inProgressColor;
    } else if (index < index_recive) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void getBTdata() {
    if (chunks.length == 0 || contentLength == 0) return;

    _bytes = Uint8List(contentLength);
    int offset = 0;
    for (final List<int> chunk in chunks) {
      _bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    //print('Bytes ------------------------------------> $_bytes');

    String dataString = String.fromCharCodes(_bytes);
    var value_unit = dataString.split(',');

    setState(() {
      data_recived[index_recive] = value_unit[0];
      unit[index_recive] = value_unit[1];

      process_data();
      final DateTime now = DateTime.now();
      timenow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    });

    contentLength = 0;
    chunks.clear();
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<Null> read_setting() async {
    prefs = await SharedPreferences.getInstance();

    read_point_selected = prefs.getString('key_point_selected')!;
    read_preset_selected = prefs.getString('key_preset_selected')!;
    read_preset_name =
        prefs.getString('key_preset_name_' + read_preset_selected.toString())!;

    read_min1 = prefs.getString('key_min1_' + read_preset_selected.toString())!;
    read_max1 = prefs.getString('key_max1_' + read_preset_selected.toString())!;

    read_min2 = prefs.getString('key_min2_' + read_preset_selected.toString())!;
    read_max2 = prefs.getString('key_max2_' + read_preset_selected.toString())!;

    read_min3 = prefs.getString('key_min3_' + read_preset_selected.toString())!;
    read_max3 = prefs.getString('key_max3_' + read_preset_selected.toString())!;

    read_min4 = prefs.getString('key_min4_' + read_preset_selected.toString())!;
    read_max4 = prefs.getString('key_max4_' + read_preset_selected.toString())!;

    read_min5 = prefs.getString('key_min5_' + read_preset_selected.toString())!;
    read_max5 = prefs.getString('key_max5_' + read_preset_selected.toString())!;

    String path = imagePathDownloadFolder + read_preset_selected;
    isFolderName = await Directory(path).exists();

    setState(() {
      isFolderName = isFolderName;

      read_point_selected = read_point_selected;
      read_preset_selected = read_preset_selected;
      read_preset_name = read_preset_name;

      read_min1 = read_min1.toString();
      read_max1 = read_max1.toString();

      read_min2 = read_min2.toString();
      read_max2 = read_max2.toString();

      read_min3 = read_min3.toString();
      read_max3 = read_max3.toString();

      read_min4 = read_min4.toString();
      read_max4 = read_max4.toString();

      read_min5 = read_min5.toString();
      read_max5 = read_max5.toString();

      FileImagePath = imagePathDownloadFolder +
          read_preset_selected +
          '/' +
          index_image.toString() +
          '.jpg';
    });

    print('Point selected = $read_point_selected');
    print('Preset selected = $read_preset_selected');
    print('Preset name = $read_preset_name');

    print('Min1 = $read_min1');
    print('Max1 = $read_max1');

    print('Min2 = $read_min2');
    print('Max2 = $read_max2');

    print('Min3 = $read_min3');
    print('Max3 = $read_max3');

    print('Min4 = $read_min4');
    print('Max4 = $read_max4');

    print('Min5 = $read_min5');
    print('Max5 = $read_max5');
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<Null> save_count() async {
    prefs = await SharedPreferences.getInstance();

    prefs.setString('key_ok', cnt_ok.toString());
    prefs.setString('key_ng', cnt_ng.toString());
    prefs.setString('key_total', cnt_total.toString());
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<Null> read_counter() async {
    prefs = await SharedPreferences.getInstance();

    String? ok = prefs.getString('key_ok');
    String? ng = prefs.getString('key_ng');
    String? total = prefs.getString('key_total');

    setState(() {
      cnt_ok = int.parse(ok.toString());
      cnt_ng = int.parse(ng.toString());
      cnt_total = int.parse(total.toString());
    });

    print('Cnt OK = $cnt_ok');
    print('Cnt NG = $cnt_ng');
    print('Cnt Total = $cnt_total');
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    read_setting();
    read_counter();

    _getBTConnection();

    _timer = new RestartableTimer(Duration(milliseconds: 100), getBTdata);
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected()) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    _timer.cancel();
    super.dispose();
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  _getBTConnection() {
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      connection = _connection;
      isConnecting = false;
      isDisconnecting = false;
      setState(() {});
      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally');
        } else {
          print('Disconnecting remotely');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void _onDataReceived(Uint8List data) {
    if (data != null && data.length > 0) {
      chunks.add(data);
      contentLength += data.length;
      _timer.reset();
    }

    //print("Data Length: ${data.length}, chunks: ${chunks.length}");
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void process_data() {
    setState(() {
      index_recive++;

      // Index Image
      if (index_recive <= 0) {
        index_image = 1;
        FileImagePath = imagePathDownloadFolder +
            read_preset_selected +
            '/' +
            index_image.toString() +
            '.jpg';
      } else if (index_recive == 1) {
        index_image = 2;
        FileImagePath = imagePathDownloadFolder +
            read_preset_selected +
            '/' +
            index_image.toString() +
            '.jpg';
      } else if (index_recive == 2) {
        index_image = 3;
        FileImagePath = imagePathDownloadFolder +
            read_preset_selected +
            '/' +
            index_image.toString() +
            '.jpg';
      } else if (index_recive == 3) {
        index_image = 4;
        FileImagePath = imagePathDownloadFolder +
            read_preset_selected +
            '/' +
            index_image.toString() +
            '.jpg';
      } else if (index_recive == 4) {
        index_image = 5;
        FileImagePath = imagePathDownloadFolder +
            read_preset_selected +
            '/' +
            index_image.toString() +
            '.jpg';
      } else if (index_recive >= 5) {
        index_recive = 5;
      }

      if (index_recive >= int.parse(read_point_selected)) {
        FileImagePath = imagePathDownloadFolder + '/Img/Done.jpg';
      }

      print('Index recive: ' + index_recive.toString());

      if (read_point_selected == '1') {
        calculate_result_1_points();
      } else if (read_point_selected == '2') {
        calculate_result_2_points();
      } else if (read_point_selected == '3') {
        calculate_result_3_points();
      } else if (read_point_selected == '4') {
        calculate_result_4_points();
      } else if (read_point_selected == '5') {
        calculate_result_5_points();
      }
    });
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void calculate_result_1_points() {
    double min1 = double.parse(read_min1.toString());
    double max1 = double.parse(read_max1.toString());

    double dat_0;

    if (data_recived[0] == 'Waiting') {
      dat_0 = 0;
    } else {
      dat_0 = double.parse(data_recived[0].toString());
    }

    if (index_recive >= 1) {
      if ((dat_0 >= min1) && (dat_0 <= max1)) {
        status_result[0] = true;
        print('Point1 OK: Min:$min1  Value:$dat_0  Max: $max1');
      } else {
        status_result[0] = false;
        print('Point1 NG: Min:$min1  Value:$dat_0  Max: $max1');
      }

      if ((status_result[0] == true)) {
        judge = true;
      } else {
        judge = false;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void calculate_result_2_points() {
    double min1 = double.parse(read_min1.toString());
    double max1 = double.parse(read_max1.toString());

    double min2 = double.parse(read_min2.toString());
    double max2 = double.parse(read_max2.toString());

    double dat_0;
    double dat_1;

    if (data_recived[0] == 'Waiting') {
      dat_0 = 0;
    } else {
      dat_0 = double.parse(data_recived[0].toString());
    }

    if (data_recived[1] == 'Waiting') {
      dat_1 = 0;
    } else {
      dat_1 = double.parse(data_recived[1].toString());
    }

    if (index_recive == 1) {
      if ((dat_0 >= min1) && (dat_0 <= max1)) {
        status_result[0] = true;
        print('Point1 OK: Min:$min1  Value:$dat_0  Max: $max1');
      } else {
        status_result[0] = false;
        print('Point1 NG: Min:$min1  Value:$dat_0  Max: $max1');
      }
    } else if (index_recive >= 2) {
      if ((dat_1 >= min2) && (dat_1 <= max2)) {
        status_result[1] = true;
        print('Point2 OK: Min:$min2  Value:$dat_1  Max: $max2');
      } else {
        status_result[1] = false;
        print('Point2 NG: Min:$min2  Value:$dat_1  Max: $max2');
      }
      if ((status_result[0] == true) && (status_result[1] == true)) {
        judge = true;
      } else {
        judge = false;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void calculate_result_3_points() {
    double min1 = double.parse(read_min1.toString());
    double max1 = double.parse(read_max1.toString());

    double min2 = double.parse(read_min2.toString());
    double max2 = double.parse(read_max2.toString());

    double min3 = double.parse(read_min3.toString());
    double max3 = double.parse(read_max3.toString());

    double dat_0;
    double dat_1;
    double dat_2;

    if (data_recived[0] == 'Waiting') {
      dat_0 = 0;
    } else {
      dat_0 = double.parse(data_recived[0].toString());
    }

    if (data_recived[1] == 'Waiting') {
      dat_1 = 0;
    } else {
      dat_1 = double.parse(data_recived[1].toString());
    }

    if (data_recived[2] == 'Waiting') {
      dat_2 = 0;
    } else {
      dat_2 = double.parse(data_recived[2].toString());
    }

    if (index_recive == 1) {
      if ((dat_0 >= min1) && (dat_0 <= max1)) {
        status_result[0] = true;
        print('Point1 OK: Min:$min1  Value:$dat_0  Max: $max1');
      } else {
        status_result[0] = false;
        print('Point1 NG: Min:$min1  Value:$dat_0  Max: $max1');
      }
    } else if (index_recive == 2) {
      if ((dat_1 >= min2) && (dat_1 <= max2)) {
        status_result[1] = true;
        print('Point2 OK: Min:$min2  Value:$dat_1  Max: $max2');
      } else {
        status_result[1] = false;
        print('Point2 NG: Min:$min2  Value:$dat_1  Max: $max2');
      }
    } else if (index_recive >= 3) {
      if ((dat_2 >= min3) && (dat_2 <= max3)) {
        status_result[2] = true;
        print('Point3 OK: Min:$min3  Value:$dat_2  Max: $max3');
      } else {
        status_result[2] = false;
        print('Point3 NG: Min:$min3  Value:$dat_2  Max: $max3');
      }

      if ((status_result[0] == true) &&
          (status_result[1] == true) &&
          (status_result[2] == true)) {
        judge = true;
      } else {
        judge = false;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void calculate_result_4_points() {
    double min1 = double.parse(read_min1.toString());
    double max1 = double.parse(read_max1.toString());

    double min2 = double.parse(read_min2.toString());
    double max2 = double.parse(read_max2.toString());

    double min3 = double.parse(read_min3.toString());
    double max3 = double.parse(read_max3.toString());

    double min4 = double.parse(read_min4.toString());
    double max4 = double.parse(read_max4.toString());

    double dat_0;
    double dat_1;
    double dat_2;
    double dat_3;

    if (data_recived[0] == 'Waiting') {
      dat_0 = 0;
    } else {
      dat_0 = double.parse(data_recived[0].toString());
    }

    if (data_recived[1] == 'Waiting') {
      dat_1 = 0;
    } else {
      dat_1 = double.parse(data_recived[1].toString());
    }

    if (data_recived[2] == 'Waiting') {
      dat_2 = 0;
    } else {
      dat_2 = double.parse(data_recived[2].toString());
    }

    if (data_recived[3] == 'Waiting') {
      dat_3 = 0;
    } else {
      dat_3 = double.parse(data_recived[3].toString());
    }

    if (index_recive == 1) {
      if ((dat_0 >= min1) && (dat_0 <= max1)) {
        status_result[0] = true;
        print('Point1 OK: Min:$min1  Value:$dat_0  Max: $max1');
      } else {
        status_result[0] = false;
        print('Point1 NG: Min:$min1  Value:$dat_0  Max: $max1');
      }
    } else if (index_recive == 2) {
      if ((dat_1 >= min2) && (dat_1 <= max2)) {
        status_result[1] = true;
        print('Point2 OK: Min:$min2  Value:$dat_1  Max: $max2');
      } else {
        status_result[1] = false;
        print('Point2 NG: Min:$min2  Value:$dat_1  Max: $max2');
      }
    } else if (index_recive == 3) {
      if ((dat_2 >= min3) && (dat_2 <= max3)) {
        status_result[2] = true;
        print('Point3 OK: Min:$min3  Value:$dat_2  Max: $max3');
      } else {
        status_result[2] = false;
        print('Point3 NG: Min:$min3  Value:$dat_2  Max: $max3');
      }
    } else if (index_recive >= 4) {
      if ((dat_3 >= min4) && (dat_3 <= max4)) {
        status_result[3] = true;
        print('Point4 OK: Min:$min4  Value:$dat_3  Max: $max4');
      } else {
        status_result[3] = false;
        print('Point4 NG: Min:$min4  Value:$dat_3  Max: $max4');
      }

      if ((status_result[0] == true) &&
          (status_result[1] == true) &&
          (status_result[2] == true) &&
          (status_result[3] == true)) {
        judge = true;
      } else {
        judge = false;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void calculate_result_5_points() {
    double min1 = double.parse(read_min1.toString());
    double max1 = double.parse(read_max1.toString());

    double min2 = double.parse(read_min2.toString());
    double max2 = double.parse(read_max2.toString());

    double min3 = double.parse(read_min3.toString());
    double max3 = double.parse(read_max3.toString());

    double min4 = double.parse(read_min4.toString());
    double max4 = double.parse(read_max4.toString());

    double min5 = double.parse(read_min5.toString());
    double max5 = double.parse(read_max5.toString());

    double dat_0;
    double dat_1;
    double dat_2;
    double dat_3;
    double dat_4;

    if (data_recived[0] == 'Waiting') {
      dat_0 = 0;
    } else {
      dat_0 = double.parse(data_recived[0].toString());
    }

    if (data_recived[1] == 'Waiting') {
      dat_1 = 0;
    } else {
      dat_1 = double.parse(data_recived[1].toString());
    }

    if (data_recived[2] == 'Waiting') {
      dat_2 = 0;
    } else {
      dat_2 = double.parse(data_recived[2].toString());
    }

    if (data_recived[3] == 'Waiting') {
      dat_3 = 0;
    } else {
      dat_3 = double.parse(data_recived[3].toString());
    }

    if (data_recived[4] == 'Waiting') {
      dat_4 = 0;
    } else {
      dat_4 = double.parse(data_recived[4].toString());
    }

    if (index_recive == 1) {
      if ((dat_0 >= min1) && (dat_0 <= max1)) {
        status_result[0] = true;
        print('Point1 OK: Min:$min1  Value:$dat_0  Max: $max1');
      } else {
        status_result[0] = false;
        print('Point1 NG: Min:$min1  Value:$dat_0  Max: $max1');
      }
    } else if (index_recive == 2) {
      if ((dat_1 >= min2) && (dat_1 <= max2)) {
        status_result[1] = true;
        print('Point2 OK: Min:$min2  Value:$dat_1  Max: $max2');
      } else {
        status_result[1] = false;
        print('Point2 NG: Min:$min2  Value:$dat_1  Max: $max2');
      }
    } else if (index_recive == 3) {
      if ((dat_2 >= min3) && (dat_2 <= max3)) {
        status_result[2] = true;
        print('Point3 OK: Min:$min3  Value:$dat_2  Max: $max3');
      } else {
        status_result[2] = false;
        print('Point3 NG: Min:$min3  Value:$dat_2  Max: $max3');
      }
    } else if (index_recive == 4) {
      if ((dat_3 >= min4) && (dat_3 <= max4)) {
        status_result[3] = true;
        print('Point4 OK: Min:$min4  Value:$dat_3  Max: $max4');
      } else {
        status_result[3] = false;
        print('Point4 NG: Min:$min4  Value:$dat_3  Max: $max4');
      }
    } else if (index_recive >= 5) {
      if ((dat_4 >= min5) && (dat_4 <= max5)) {
        status_result[4] = true;
        print('Point5 OK: Min:$min5  Value:$dat_4  Max: $max5');
      } else {
        status_result[4] = false;
        print('Point5 NG: Min:$min5  Value:$dat_4  Max: $max5');
      }

      if ((status_result[0] == true) &&
          (status_result[1] == true) &&
          (status_result[2] == true) &&
          (status_result[3] == true) &&
          (status_result[4] == true)) {
        judge = true;
      } else {
        judge = false;
      }
    }
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void check_save_counter() {
    if (judge == true) {
      cnt_ok = cnt_ok! + 1;
    } else {
      cnt_ng = cnt_ng! + 1;
    }

    cnt_total = cnt_ok! + cnt_ng!;

    save_count();
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  bool isConnected() {
    return connection != null && connection.isConnected;
  }
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(MyConstant.logo_appbar),

        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.teal,
        centerTitle: true,

        title: (isConnecting
            ? Text(
                'Connecting to ${widget.server.name} ..........',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              )
            : isConnected()
                ? Text(
                    'BT Connected',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  )
                : Text(
                    'BT Disconnected !!!',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  )),

        // title: Text(read_preset_name.toString(),
        //     style: const TextStyle(
        //         fontSize: 30,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white)),
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Image.asset(
        //       MyConstant.logo_appbar,
        //       scale: 3,
        //     ),
        //     const SizedBox(
        //       width: 10,
        //     ),
        //     (Text(
        //       read_preset_name.toString(),
        //       style: const TextStyle(
        //           fontSize: 40,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.white),
        //     )),
        //   ],
        // ),

        actions: [
          build_read_excel(context),
          build_show_excel(context),
          build_setting_icon(context)
        ],
      ),
      body: Column(
        children: [
          build_timeline(context, int.parse(read_point_selected)),
          //Divider(color: Colors.grey, height: 40,),
          Container(
            //color: Colors.purple,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  //color: Colors.pink,
                  child: Column(
                    children: [
                      //show_counter(),
                      build_ok_counter(cnt_ok!),
                      build_ng_counter(cnt_ng!),
                      build_total_counter(cnt_total!),
                      build_step_image(),                      
                    ],
                  ),
                ),                
                build_table(size),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [                    
                    build_judge(size),
                    build_save_button(),                    
                  ],
                ),
                
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     Container(
      //         //color: Colors.pink,
      //         width: 1130,
      //         child: build_retry_button()),
      //   ],
      // ),
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Padding build_step_image() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 450,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.teal, width: 10),
          image: isFolderName
              ? DecorationImage(
                  image: FileImage(File(FileImagePath)),
                  fit: BoxFit.fill,
                )
              : DecorationImage(
                  image: AssetImage(MyConstant.no_image), fit: BoxFit.fill),
        ),
      ),
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  IconButton build_show_excel(BuildContext context) {
    return IconButton(
      onPressed: () {
        //OpenFile.open(MyConstant.path_excel);

        // Set excel filename for ShowExcelPage
        String product_name = read_preset_name.replaceAll(' ', '');

        final DateTime now = DateTime.now();
        timenow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
        String datenow = timenow.substring(0, 10);
        filename_excel = product_name + '_' + datenow + '.xlsx';

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ShowExcelPage(
                  filename: filename_excel,
                )));
      },
      icon: const Icon(
        Icons.file_copy_sharp,
      ),
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  IconButton build_read_excel(BuildContext context) {
    return IconButton(
      onPressed: () {
        //Set excel filename for ReadExcelPage
        String product_name = read_preset_name.replaceAll(' ', '');

        final DateTime now = DateTime.now();
        timenow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
        String datenow = timenow.substring(0, 10);
        filename_excel = product_name + '_' + datenow + '.xlsx';

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ReadExcelPage(
                  filename: filename_excel,
                )));
      },
      icon: const Icon(
        Icons.file_open_outlined,
      ),
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  IconButton build_setting_icon(BuildContext context) {
    return IconButton(
        onPressed: () async {
          //Navigator.pushNamed(context, MyConstant.routeSetting);
          final List<String> get_setting = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SettingPage(),
            ),
          );

          String path = imagePathDownloadFolder + get_setting[1];
          isFolderName = await Directory(path).exists();

          setState(() {
            read_point_selected = get_setting[0];
            read_preset_selected = get_setting[1];
            read_preset_name = get_setting[2];

            read_min1 = get_setting[3];
            read_max1 = get_setting[4];

            read_min2 = get_setting[5];
            read_max2 = get_setting[6];
            read_min3 = get_setting[7];
            read_max3 = get_setting[8];

            read_min4 = get_setting[9];
            read_max4 = get_setting[10];

            read_min5 = get_setting[11];
            read_max5 = get_setting[12];

            isFolderName = isFolderName;
            print(
                'Return Setting ==> $read_point_selected $read_preset_selected $read_preset_name $read_min1  $read_max1  $read_min2  $read_max2  $read_min3  $read_max3  $read_min4  $read_max4  $read_min5  $read_max5');
          });

          //read_register();
        },
        icon: const Icon(
          Icons.settings,
          size: 35,
        ));
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Row build_retry_button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        reset_button(),
        SizedBox(width: 20),
        if (read_point_selected == '1') retry_button_1_points(),
        if (read_point_selected == '2') retry_button_2_points(),
        if (read_point_selected == '3') retry_button_3_points(),
        if (read_point_selected == '4') retry_button_4_points(),
        if (read_point_selected == '5') retry_button_5_points(),
        //SizedBox(width: 8),
        //if (index_recive >= int.parse(read_point_selected)) save_button(),
      ],
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Expanded build_table(double size) {
    return Expanded(
      child: Container(
        //color: Colors.yellow,
        width: size * 0.1,
        //width: 500,
        //color: Colors.purple,
        child: Column(
          children: [
            
            Container(
                child: Text(read_preset_name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35,color: Colors.teal),)),
            SizedBox(height: 5,),
            show_timenow(),
            if (read_point_selected == '1') build_table_row1(),
            if (read_point_selected == '2') build_table_row2(),
            if (read_point_selected == '3') build_table_row3(),
            if (read_point_selected == '4') build_table_row4(),
            if (read_point_selected == '5') build_table_row5(),
            SizedBox(height: 30,),
            build_retry_button(),
          ],
        ),
      ),
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Table build_table_row1() {
    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FractionColumnWidth(0.15),
        1: FractionColumnWidth(0.25),
        2: FractionColumnWidth(0.25),
        3: FractionColumnWidth(0.25),
      },
      children: [
        buildRow(['Points', 'Min', 'Result', 'Max'], isHeader: true),
        buildRow(
            ['1', read_min1.toString(), data_recived[0], read_max1.toString()],
            isOK: status_result[0]),
      ],
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Table build_table_row2() {
    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FractionColumnWidth(0.15),
        1: FractionColumnWidth(0.25),
        2: FractionColumnWidth(0.25),
        3: FractionColumnWidth(0.25),
      },
      children: [
        buildRow(['Points', 'Min', 'Result', 'Max'], isHeader: true),
        buildRow(
            ['1', read_min1.toString(), data_recived[0], read_max1.toString()],
            isOK: status_result[0]),
        buildRow(
            ['2', read_min2.toString(), data_recived[1], read_max2.toString()],
            isOK: status_result[1]),
      ],
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Table build_table_row3() {
    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FractionColumnWidth(0.15),
        1: FractionColumnWidth(0.25),
        2: FractionColumnWidth(0.25),
        3: FractionColumnWidth(0.25),
      },
      children: [
        buildRow(['Points', 'Min', 'Result', 'Max'], isHeader: true),
        buildRow(
            ['1', read_min1.toString(), data_recived[0], read_max1.toString()],
            isOK: status_result[0]),
        buildRow(
            ['2', read_min2.toString(), data_recived[1], read_max2.toString()],
            isOK: status_result[1]),
        buildRow(
            ['3', read_min3.toString(), data_recived[2], read_max3.toString()],
            isOK: status_result[2]),
      ],
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Table build_table_row4() {
    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FractionColumnWidth(0.15),
        1: FractionColumnWidth(0.25),
        2: FractionColumnWidth(0.25),
        3: FractionColumnWidth(0.25),
      },
      children: [
        buildRow(['Points', 'Min', 'Result', 'Max'], isHeader: true),
        buildRow(
            ['1', read_min1.toString(), data_recived[0], read_max1.toString()],
            isOK: status_result[0]),
        buildRow(
            ['2', read_min2.toString(), data_recived[1], read_max2.toString()],
            isOK: status_result[1]),
        buildRow(
            ['3', read_min3.toString(), data_recived[2], read_max3.toString()],
            isOK: status_result[2]),
        buildRow(
            ['4', read_min4.toString(), data_recived[3], read_max4.toString()],
            isOK: status_result[3]),
      ],
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Table build_table_row5() {
    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FractionColumnWidth(0.15),
        1: FractionColumnWidth(0.25),
        2: FractionColumnWidth(0.25),
        3: FractionColumnWidth(0.25),
      },
      children: [
        buildRow(['Points', 'Min', 'Result', 'Max'], isHeader: true),
        buildRow(
            ['1', read_min1.toString(), data_recived[0], read_max1.toString()],
            isOK: status_result[0]),
        buildRow(
            ['2', read_min2.toString(), data_recived[1], read_max2.toString()],
            isOK: status_result[1]),
        buildRow(
            ['3', read_min3.toString(), data_recived[2], read_max3.toString()],
            isOK: status_result[2]),
        buildRow(
            ['4', read_min4.toString(), data_recived[3], read_max4.toString()],
            isOK: status_result[3]),
        buildRow(
            ['5', read_min5.toString(), data_recived[4], read_max5.toString()],
            isOK: status_result[4]),
      ],
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget build_judge(double size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.teal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (index_recive >= int.parse(read_point_selected))
              judge
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: size * 0.25,
                        child: ShowImage(path: MyConstant.image_ok),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: size * 0.25,
                        child: ShowImage(path: MyConstant.image_ng),
                      ),
                    ),
            if (index_recive < int.parse(read_point_selected))
              Container(
                width: size * 0.25,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ShowImage(path: MyConstant.image_wait),
                ),
              ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     child: Text(
            //       'Judge',
            //       style: TextStyle(
            //           fontSize: 30,
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            //show_timenow(),
          ],
        ),
      ),
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Container build_timeline(BuildContext context, int cnt_point) {
    return Container(
      height: 200,
      color: Colors.black,
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: ConnectorThemeData(
            space: 30.0,
            thickness: 5.0,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemExtentBuilder: (_, __) =>
              MediaQuery.of(context).size.width / cnt_point,
          oppositeContentsBuilder: (context, index) {
            return build_image_number(index);
          },
          contentsBuilder: (context, index) {
            if (data_recived[index] != 'Waiting') {
              if (status_result[index]) {
                return build_text_result_OK(index);
              } else {
                return build_text_result_NG(index);
              }
            } else {
              return build_text_result_waiting(index);
            }
          },
          indicatorBuilder: (_, index) {
            var color;
            var child;

            if (index == index_recive) {
              color = inProgressColor;
              child = build_circular_timeline();
            } else if (index < index_recive) {
              color = completeColor;
              child = Icon(
                Icons.check,
                color: Colors.white,
                size: 15.0,
              );
            } else {
              color = todoColor;
            }

            if (index <= index_recive) {
              return Stack(
                children: [
                  // CustomPaint(
                  //   size: Size(30.0, 30.0),
                  //   painter: _BezierPainter(
                  //     color: color,
                  //     drawStart: index > 0,
                  //     drawEnd: index < index_recive,
                  //   ),
                  // ),
                  DotIndicator(
                    size: 30.0,
                    color: color,
                    child: child,
                  ),
                ],
              );
            } else {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(15.0, 15.0),
                    painter: _BezierPainter(
                      color: color,
                      drawEnd: index < cnt_point - 1,
                    ),
                  ),
                  OutlinedDotIndicator(
                    borderWidth: 4.0,
                    color: color,
                  ),
                ],
              );
            }
          },
          connectorBuilder: (_, index, type) {
            if (index > 0) {
              if (index == index_recive) {
                final prevColor = getColor(index - 1);
                final color = getColor(index);
                List<Color> gradientColors;
                if (type == ConnectorType.start) {
                  gradientColors = [Color.lerp(prevColor, color, 0.5)!, color];
                } else {
                  gradientColors = [
                    prevColor,
                    Color.lerp(prevColor, color, 0.5)!
                  ];
                }
                return DecoratedLineConnector(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                  ),
                );
              } else {
                return SolidLineConnector(
                  color: getColor(index),
                );
              }
            } else {
              return null;
            }
          },
          itemCount: cnt_point,
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Padding build_circular_timeline() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: CircularProgressIndicator(
        strokeWidth: 4.0,
        valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Padding build_image_number(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Image.asset(
        'assets/images/process_timeline/step${index + 1}.png',
        width: 50.0,
        color: getColor(index),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Padding build_text_result_waiting(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Text(
        data_recived[index] + unit[index],
        style: TextStyle(
            fontWeight: FontWeight.normal, fontSize: 35, color: Colors.white),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Padding build_text_result_NG(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Text(
        data_recived[index] + unit[index],
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 35, color: Colors.red),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Padding build_text_result_OK(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Text(
        data_recived[index] + unit[index],
        style: TextStyle(
            fontWeight: FontWeight.normal, fontSize: 35, color: Colors.green),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> write_to_excel() async {
    try {
      var res = await Permission.storage.request();
      String product_name = read_preset_name.replaceAll(' ', '');
      String datenow = timenow.substring(0, 10);
      String filename = '/storage/emulated/0/Download/' +
          product_name +
          '_' +
          datenow +
          '.xlsx';

      File outputFile = File((filename));
      if (res.isGranted) {
        if (await outputFile.exists()) {
          print("File exist Append Mode");
          await excel_append_data(filename)
              .then((value) => excel_update_cell(filename));
        } else {
          print("New Excel File");
          await excel_write_header(filename).then((value) =>
              excel_append_data(filename)
                  .then((value) => excel_update_cell(filename)));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  double standardDeviation(List<double> list) {
    if (list.length > 1) {
      final stats = Stats(list);
      return stats.stdDev;
    } else {
      return 0;
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  // void st_dev()
  // {
  //   final sample = [1, 2, 3, 4, 5,6,7,8];
  //   final stats = Stats(sample);
  //   print('standard deviation:  ${stats.stdDev}');
  // }
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> excel_update_cell(String filepath) async {
    try {
      var res = await Permission.storage.request();
      File InputFile = File((filepath));
      if (res.isGranted) {
        print('Permission OK Append Mode');
      }

      //var filename = MyConstant.path_excel;
      List<int> bytes = await (InputFile).readAsBytes();
      var excel = FromExcel.Excel.decodeBytes(bytes);
      var sheet1 = excel['Sheet1'];

      // Read Excel file
      //List<String>? row0 = [];
      List<String>? row1 = [];
      List<String>? row2 = [];
      List<String>? row3 = [];
      List<String>? row4 = [];
      List<String>? row5 = [];

      List<double>? row1_double = [];
      List<double>? row2_double = [];
      List<double>? row3_double = [];
      List<double>? row4_double = [];
      List<double>? row5_double = [];

      for (var table in excel.tables.keys) {
        print(table); //sheet Name
        print('Max Column: ' + excel.tables[table]!.maxColumns.toString());
        print('Max Rows: ' + excel.tables[table]!.maxRows.toString());

        for (var row in excel.tables[table]!.rows) {
          //row0.add(row[0]?.value.toString() ?? "");
          row1.add(row[1]?.value.toString() ?? "");
          row2.add(row[2]?.value.toString() ?? "");
          row3.add(row[3]?.value.toString() ?? "");
          row4.add(row[4]?.value.toString() ?? "");
          row5.add(row[5]?.value.toString() ?? "");
        }
      }

      // Remove Header and Min max avg cp cpk ...
      //row0.removeRange(0,10);
      row1.removeRange(0, 11);
      row2.removeRange(0, 11);
      row3.removeRange(0, 11);
      row4.removeRange(0, 11);
      row5.removeRange(0, 11);

      //row0.removeWhere((item) => item == "");
      row1.removeWhere((item) => item == "");
      row2.removeWhere((item) => item == "");
      row3.removeWhere((item) => item == "");
      row4.removeWhere((item) => item == "");
      row5.removeWhere((item) => item == "");

      //print(' Row  1 --------------> ${row0}');
      print(' Row  2 --------------> ${row1}');
      print(' Row  3 --------------> ${row2}');
      print(' Row  4 --------------> ${row3}');
      print(' Row  5 --------------> ${row4}');
      print(' Row  6 --------------> ${row5}');

      // Update Cell
      // ST MAX
      var cell_B2 = sheet1.cell(FromExcel.CellIndex.indexByString('B2'));
      var cell_C2 = sheet1.cell(FromExcel.CellIndex.indexByString('C2'));
      var cell_D2 = sheet1.cell(FromExcel.CellIndex.indexByString('D2'));
      var cell_E2 = sheet1.cell(FromExcel.CellIndex.indexByString('E2'));
      var cell_F2 = sheet1.cell(FromExcel.CellIndex.indexByString('F2'));

      cell_B2.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_C2.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_D2.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_E2.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_F2.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double

      // ST MIN
      var cell_B3 = sheet1.cell(FromExcel.CellIndex.indexByString('B3'));
      var cell_C3 = sheet1.cell(FromExcel.CellIndex.indexByString('C3'));
      var cell_D3 = sheet1.cell(FromExcel.CellIndex.indexByString('D3'));
      var cell_E3 = sheet1.cell(FromExcel.CellIndex.indexByString('E3'));
      var cell_F3 = sheet1.cell(FromExcel.CellIndex.indexByString('F3'));

      cell_B3.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_C3.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_D3.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_E3.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_F3.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double

      // MAX
      var cell_B4 = sheet1.cell(FromExcel.CellIndex.indexByString('B4'));
      var cell_C4 = sheet1.cell(FromExcel.CellIndex.indexByString('C4'));
      var cell_D4 = sheet1.cell(FromExcel.CellIndex.indexByString('D4'));
      var cell_E4 = sheet1.cell(FromExcel.CellIndex.indexByString('E4'));
      var cell_F4 = sheet1.cell(FromExcel.CellIndex.indexByString('F4'));

      cell_B4.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_C4.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_D4.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_E4.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_F4.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double

      // MIN
      var cell_B5 = sheet1.cell(FromExcel.CellIndex.indexByString('B5'));
      var cell_C5 = sheet1.cell(FromExcel.CellIndex.indexByString('C5'));
      var cell_D5 = sheet1.cell(FromExcel.CellIndex.indexByString('D5'));
      var cell_E5 = sheet1.cell(FromExcel.CellIndex.indexByString('E5'));
      var cell_F5 = sheet1.cell(FromExcel.CellIndex.indexByString('F5'));

      cell_B5.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_C5.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_D5.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_E5.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_F5.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double

      // AVERAGE
      var cell_B6 = sheet1.cell(FromExcel.CellIndex.indexByString('B6'));
      var cell_C6 = sheet1.cell(FromExcel.CellIndex.indexByString('C6'));
      var cell_D6 = sheet1.cell(FromExcel.CellIndex.indexByString('D6'));
      var cell_E6 = sheet1.cell(FromExcel.CellIndex.indexByString('E6'));
      var cell_F6 = sheet1.cell(FromExcel.CellIndex.indexByString('F6'));

      cell_B6.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_C6.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_D6.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_E6.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_F6.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double

      // ST DEV
      var cell_B7 = sheet1.cell(FromExcel.CellIndex.indexByString('B7'));
      var cell_C7 = sheet1.cell(FromExcel.CellIndex.indexByString('C7'));
      var cell_D7 = sheet1.cell(FromExcel.CellIndex.indexByString('D7'));
      var cell_E7 = sheet1.cell(FromExcel.CellIndex.indexByString('E7'));
      var cell_F7 = sheet1.cell(FromExcel.CellIndex.indexByString('F7'));

      cell_B7.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_C7.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_D7.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_E7.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_F7.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double

      // Cp
      var cell_B8 = sheet1.cell(FromExcel.CellIndex.indexByString('B8'));
      var cell_C8 = sheet1.cell(FromExcel.CellIndex.indexByString('C8'));
      var cell_D8 = sheet1.cell(FromExcel.CellIndex.indexByString('D8'));
      var cell_E8 = sheet1.cell(FromExcel.CellIndex.indexByString('E8'));
      var cell_F8 = sheet1.cell(FromExcel.CellIndex.indexByString('F8'));

      cell_B8.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_C8.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_D8.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_E8.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_F8.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double

      // Cpk
      var cell_B9 = sheet1.cell(FromExcel.CellIndex.indexByString('B9'));
      var cell_C9 = sheet1.cell(FromExcel.CellIndex.indexByString('C9'));
      var cell_D9 = sheet1.cell(FromExcel.CellIndex.indexByString('D9'));
      var cell_E9 = sheet1.cell(FromExcel.CellIndex.indexByString('E9'));
      var cell_F9 = sheet1.cell(FromExcel.CellIndex.indexByString('F9'));

      cell_B9.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_C9.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_D9.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_E9.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double
      cell_F9.cellStyle = FromExcel.CellStyle(
          numberFormat: FromExcel.NumFormat.standard_2); // Double

      if (read_point_selected == '1') {
        //---------------------------------------------------> 1
        // ST MAX
        cell_B2.value = FromExcel.DoubleCellValue(double.parse(read_max1));
        cell_C2.value = FromExcel.DoubleCellValue(0);
        cell_D2.value = FromExcel.DoubleCellValue(0);
        cell_E2.value = FromExcel.DoubleCellValue(0);
        cell_F2.value = FromExcel.DoubleCellValue(0);

        // ST MIN
        cell_B3.value = FromExcel.DoubleCellValue(double.parse(read_min1));
        cell_C3.value = FromExcel.DoubleCellValue(0);
        cell_D3.value = FromExcel.DoubleCellValue(0);
        cell_E3.value = FromExcel.DoubleCellValue(0);
        cell_F3.value = FromExcel.DoubleCellValue(0);

        // MAX MIN AVG
        double avg = 0;
        for (var i = 0; i < row1.length; i++) // Point1
        {
          var x = double.parse(row1[i]);
          row1_double.add(x);

          avg = avg + x;
        }
        double max1 =
            row1_double.reduce((curr, next) => curr > next ? curr : next);
        double min1 =
            row1_double.reduce((curr, next) => curr < next ? curr : next);
        double avg1 = avg / row1.length;

        double st_dev1 = standardDeviation(row1_double);
        double st_max1 = double.parse(read_max1);
        double st_min1 = double.parse(read_min1);
        double cp1 = (st_max1 - st_min1) / (6 * st_dev1);
        cp1.isInfinite ? cp1 = 0 : cp1 = cp1;

        double value1 = ((st_max1 - avg1) / (3 * st_dev1));
        double value2 = ((avg1 - st_min1) / (3 * st_dev1));

        double cpk1 = [value1, value2].reduce(min);
        cpk1.isInfinite ? cpk1 = 0 : cpk1 = cpk1;

        cell_B4.value =
            FromExcel.DoubleCellValue(double.parse((max1).toStringAsFixed(2)));
        cell_C4.value = FromExcel.DoubleCellValue(0);
        cell_D4.value = FromExcel.DoubleCellValue(0);
        cell_E4.value = FromExcel.DoubleCellValue(0);
        cell_F4.value = FromExcel.DoubleCellValue(0);

        cell_B5.value =
            FromExcel.DoubleCellValue(double.parse((min1).toStringAsFixed(2)));
        cell_C5.value = FromExcel.DoubleCellValue(0);
        cell_D5.value = FromExcel.DoubleCellValue(0);
        cell_E5.value = FromExcel.DoubleCellValue(0);
        cell_F5.value = FromExcel.DoubleCellValue(0);

        cell_B6.value =
            FromExcel.DoubleCellValue(double.parse((avg1).toStringAsFixed(2)));
        cell_C6.value = FromExcel.DoubleCellValue(0);
        cell_D6.value = FromExcel.DoubleCellValue(0);
        cell_E6.value = FromExcel.DoubleCellValue(0);
        cell_F6.value = FromExcel.DoubleCellValue(0);

        cell_B7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev1).toStringAsFixed(2)));
        cell_C7.value = FromExcel.DoubleCellValue(0);
        cell_D7.value = FromExcel.DoubleCellValue(0);
        cell_E7.value = FromExcel.DoubleCellValue(0);
        cell_F7.value = FromExcel.DoubleCellValue(0);

        cell_B8.value =
            FromExcel.DoubleCellValue(double.parse((cp1).toStringAsFixed(2)));
        cell_C8.value = FromExcel.DoubleCellValue(0);
        cell_D8.value = FromExcel.DoubleCellValue(0);
        cell_E8.value = FromExcel.DoubleCellValue(0);
        cell_F8.value = FromExcel.DoubleCellValue(0);

        cell_B9.value =
            FromExcel.DoubleCellValue(double.parse((cpk1).toStringAsFixed(2)));
        cell_C9.value = FromExcel.DoubleCellValue(0);
        cell_D9.value = FromExcel.DoubleCellValue(0);
        cell_E9.value = FromExcel.DoubleCellValue(0);
        cell_F9.value = FromExcel.DoubleCellValue(0);

        print(
            'MAX MIN AVG STDEV Cp Cpk POINT1 ----------------------------------> ' +
                max1.toString() +
                "  " +
                min1.toString() +
                "  " +
                avg1.toStringAsFixed(2) +
                "  " +
                st_dev1.toStringAsFixed(2) +
                "  " +
                cp1.toStringAsFixed(2) +
                "  " +
                cpk1.toStringAsFixed(2));
      } else if (read_point_selected == '2') {
        //---------------------------------------------------> 2
        // ST MAX
        cell_B2.value = FromExcel.DoubleCellValue(double.parse(read_max1));
        cell_C2.value = FromExcel.DoubleCellValue(double.parse(read_max2));
        cell_D2.value = FromExcel.DoubleCellValue(0);
        cell_E2.value = FromExcel.DoubleCellValue(0);
        cell_F2.value = FromExcel.DoubleCellValue(0);

        // ST MIN
        cell_B3.value = FromExcel.DoubleCellValue(double.parse(read_min1));
        cell_C3.value = FromExcel.DoubleCellValue(double.parse(read_min2));
        cell_D3.value = FromExcel.DoubleCellValue(0);
        cell_E3.value = FromExcel.DoubleCellValue(0);
        cell_F3.value = FromExcel.DoubleCellValue(0);

        // MAX MIN AVG
        double avg = 0;
        for (var i = 0; i < row1.length; i++) // Point1
        {
          var x = double.parse(row1[i]);
          row1_double.add(x);

          avg = avg + x;
        }
        double max1 =
            row1_double.reduce((curr, next) => curr > next ? curr : next);
        double min1 =
            row1_double.reduce((curr, next) => curr < next ? curr : next);
        double avg1 = avg / row1.length;
        double st_dev1 = standardDeviation(row1_double);

        double st_max1 = double.parse(read_max1);
        double st_min1 = double.parse(read_min1);
        double cp1 = (st_max1 - st_min1) / (6 * st_dev1);
        cp1.isInfinite ? cp1 = 0 : cp1 = cp1;

        double value1 = ((st_max1 - avg1) / (3 * st_dev1));
        double value2 = ((avg1 - st_min1) / (3 * st_dev1));
        double cpk1 = [value1, value2].reduce(min);
        cpk1.isInfinite ? cpk1 = 0 : cpk1 = cpk1;
        //------------------------------------------

        avg = 0;
        for (var i = 0; i < row2.length; i++) // Point2
        {
          var x = double.parse(row2[i]);
          row2_double.add(x);

          avg = avg + x;
        }
        double max2 =
            row2_double.reduce((curr, next) => curr > next ? curr : next);
        double min2 =
            row2_double.reduce((curr, next) => curr < next ? curr : next);
        double avg2 = avg / row2.length;
        double st_dev2 = standardDeviation(row2_double);

        double st_max2 = double.parse(read_max2);
        double st_min2 = double.parse(read_min2);
        double cp2 = (st_max2 - st_min2) / (6 * st_dev2);
        cp2.isInfinite ? cp2 = 0 : cp2 = cp2;

        value1 = ((st_max2 - avg2) / (3 * st_dev2));
        value2 = ((avg2 - st_min2) / (3 * st_dev2));
        double cpk2 = [value1, value2].reduce(min);
        cpk2.isInfinite ? cpk2 = 0 : cpk2 = cpk2;

        cell_B4.value =
            FromExcel.DoubleCellValue(double.parse((max1).toStringAsFixed(2)));
        cell_C4.value =
            FromExcel.DoubleCellValue(double.parse((max2).toStringAsFixed(2)));
        cell_D4.value = FromExcel.DoubleCellValue(0);
        cell_E4.value = FromExcel.DoubleCellValue(0);
        cell_F4.value = FromExcel.DoubleCellValue(0);

        cell_B5.value =
            FromExcel.DoubleCellValue(double.parse((min1).toStringAsFixed(2)));
        cell_C5.value =
            FromExcel.DoubleCellValue(double.parse((min2).toStringAsFixed(2)));
        cell_D5.value = FromExcel.DoubleCellValue(0);
        cell_E5.value = FromExcel.DoubleCellValue(0);
        cell_F5.value = FromExcel.DoubleCellValue(0);

        cell_B6.value =
            FromExcel.DoubleCellValue(double.parse((avg1).toStringAsFixed(2)));
        cell_C6.value =
            FromExcel.DoubleCellValue(double.parse((avg2).toStringAsFixed(2)));
        cell_D6.value = FromExcel.DoubleCellValue(0);
        cell_E6.value = FromExcel.DoubleCellValue(0);
        cell_F6.value = FromExcel.DoubleCellValue(0);

        cell_B7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev1).toStringAsFixed(2)));
        cell_C7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev2).toStringAsFixed(2)));
        cell_D7.value = FromExcel.DoubleCellValue(0);
        cell_E7.value = FromExcel.DoubleCellValue(0);
        cell_F7.value = FromExcel.DoubleCellValue(0);

        cell_B8.value =
            FromExcel.DoubleCellValue(double.parse((cp1).toStringAsFixed(2)));
        cell_C8.value =
            FromExcel.DoubleCellValue(double.parse((cpk2).toStringAsFixed(2)));
        cell_D8.value = FromExcel.DoubleCellValue(0);
        cell_E8.value = FromExcel.DoubleCellValue(0);
        cell_F8.value = FromExcel.DoubleCellValue(0);

        cell_B9.value =
            FromExcel.DoubleCellValue(double.parse((cpk1).toStringAsFixed(2)));
        cell_C9.value =
            FromExcel.DoubleCellValue(double.parse((cpk2).toStringAsFixed(2)));
        cell_D9.value = FromExcel.DoubleCellValue(0);
        cell_E9.value = FromExcel.DoubleCellValue(0);
        cell_F9.value = FromExcel.DoubleCellValue(0);

        print(
            'MAX MIN AVG STDEV Cp Cpk POINT1 ----------------------------------> ' +
                max1.toString() +
                "  " +
                min1.toString() +
                "  " +
                avg1.toStringAsFixed(2) +
                "  " +
                st_dev1.toStringAsFixed(2) +
                "  " +
                cp1.toStringAsFixed(2) +
                "  " +
                cpk1.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT2 ----------------------------------> ' +
                max2.toString() +
                "  " +
                min2.toString() +
                "  " +
                avg2.toStringAsFixed(2) +
                "  " +
                st_dev2.toStringAsFixed(2) +
                "  " +
                cp2.toStringAsFixed(2) +
                "  " +
                cpk2.toStringAsFixed(2));
      } else if (read_point_selected == '3') {
        //---------------------------------------------------> 3
        // ST MAX
        cell_B2.value = FromExcel.DoubleCellValue(double.parse(read_max1));
        cell_C2.value = FromExcel.DoubleCellValue(double.parse(read_max2));
        cell_D2.value = FromExcel.DoubleCellValue(double.parse(read_max3));
        cell_E2.value = FromExcel.DoubleCellValue(0);
        cell_F2.value = FromExcel.DoubleCellValue(0);

        // ST MIN
        cell_B3.value = FromExcel.DoubleCellValue(double.parse(read_min1));
        cell_C3.value = FromExcel.DoubleCellValue(double.parse(read_min2));
        cell_D3.value = FromExcel.DoubleCellValue(double.parse(read_min3));
        cell_E3.value = FromExcel.DoubleCellValue(0);
        cell_F3.value = FromExcel.DoubleCellValue(0);

        // MAX MIN AVG
        double avg = 0;
        for (var i = 0; i < row1.length; i++) // Point1
        {
          var x = double.parse(row1[i]);
          row1_double.add(x);

          avg = avg + x;
        }
        double max1 =
            row1_double.reduce((curr, next) => curr > next ? curr : next);
        double min1 =
            row1_double.reduce((curr, next) => curr < next ? curr : next);
        double avg1 = avg / row1.length;
        double st_dev1 = standardDeviation(row1_double);

        double st_max1 = double.parse(read_max1);
        double st_min1 = double.parse(read_min1);
        double cp1 = (st_max1 - st_min1) / (6 * st_dev1);
        cp1.isInfinite ? cp1 = 0 : cp1 = cp1;

        double value1 = ((st_max1 - avg1) / (3 * st_dev1));
        double value2 = ((avg1 - st_min1) / (3 * st_dev1));
        double cpk1 = [value1, value2].reduce(min);
        cpk1.isInfinite ? cpk1 = 0 : cpk1 = cpk1;

        //------------------------------------------

        // MAX MIN AVG
        avg = 0;
        for (var i = 0; i < row2.length; i++) // Point2
        {
          var x = double.parse(row2[i]);
          row2_double.add(x);

          avg = avg + x;
        }
        double max2 =
            row2_double.reduce((curr, next) => curr > next ? curr : next);
        double min2 =
            row2_double.reduce((curr, next) => curr < next ? curr : next);
        double avg2 = avg / row2.length;
        double st_dev2 = standardDeviation(row2_double);

        double st_max2 = double.parse(read_max2);
        double st_min2 = double.parse(read_min2);
        double cp2 = (st_max2 - st_min2) / (6 * st_dev2);
        cp2.isInfinite ? cp2 = 0 : cp2 = cp2;

        value1 = ((st_max2 - avg2) / (3 * st_dev2));
        value2 = ((avg2 - st_min2) / (3 * st_dev2));
        double cpk2 = [value1, value2].reduce(min);
        cpk2.isInfinite ? cpk2 = 0 : cpk2 = cpk2;

        //------------------------------------------

        // MAX MIN AVG
        avg = 0;
        for (var i = 0; i < row3.length; i++) // Point3
        {
          var x = double.parse(row3[i]);
          row3_double.add(x);

          avg = avg + x;
        }
        double max3 =
            row3_double.reduce((curr, next) => curr > next ? curr : next);
        double min3 =
            row3_double.reduce((curr, next) => curr < next ? curr : next);
        double avg3 = avg / row3.length;
        double st_dev3 = standardDeviation(row3_double);

        double st_max3 = double.parse(read_max3);
        double st_min3 = double.parse(read_min3);
        double cp3 = (st_max3 - st_min3) / (6 * st_dev3);
        cp3.isInfinite ? cp3 = 0 : cp3 = cp3;

        value1 = ((st_max3 - avg3) / (3 * st_dev3));
        value2 = ((avg3 - st_min3) / (3 * st_dev3));
        double cpk3 = [value1, value2].reduce(min);
        cpk3.isInfinite ? cpk3 = 0 : cpk3 = cpk3;

        print('Value1: $st_max3-$avg3 / 3*$st_dev3');
        print('Value2: $avg3-$st_min3 / 3*$st_dev3');
        print('Value1: $value1  Value2: $value2  Cpk3: $cpk3');

        cell_B4.value =
            FromExcel.DoubleCellValue(double.parse((max1).toStringAsFixed(2)));
        cell_C4.value =
            FromExcel.DoubleCellValue(double.parse((max2).toStringAsFixed(2)));
        cell_D4.value =
            FromExcel.DoubleCellValue(double.parse((max3).toStringAsFixed(2)));
        cell_E4.value = FromExcel.DoubleCellValue(0);
        cell_F4.value = FromExcel.DoubleCellValue(0);

        cell_B5.value =
            FromExcel.DoubleCellValue(double.parse((min1).toStringAsFixed(2)));
        cell_C5.value =
            FromExcel.DoubleCellValue(double.parse((min2).toStringAsFixed(2)));
        cell_D5.value =
            FromExcel.DoubleCellValue(double.parse((min3).toStringAsFixed(2)));
        cell_E5.value = FromExcel.DoubleCellValue(0);
        cell_F5.value = FromExcel.DoubleCellValue(0);

        cell_B6.value =
            FromExcel.DoubleCellValue(double.parse((avg1).toStringAsFixed(2)));
        cell_C6.value =
            FromExcel.DoubleCellValue(double.parse((avg2).toStringAsFixed(2)));
        cell_D6.value =
            FromExcel.DoubleCellValue(double.parse((avg3).toStringAsFixed(2)));
        cell_E6.value = FromExcel.DoubleCellValue(0);
        cell_F6.value = FromExcel.DoubleCellValue(0);

        cell_B7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev1).toStringAsFixed(2)));
        cell_C7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev2).toStringAsFixed(2)));
        cell_D7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev3).toStringAsFixed(2)));
        cell_E7.value = FromExcel.DoubleCellValue(0);
        cell_F7.value = FromExcel.DoubleCellValue(0);

        cell_B8.value =
            FromExcel.DoubleCellValue(double.parse((cp1).toStringAsFixed(2)));
        cell_C8.value =
            FromExcel.DoubleCellValue(double.parse((cp2).toStringAsFixed(2)));
        cell_D8.value =
            FromExcel.DoubleCellValue(double.parse((cp3).toStringAsFixed(2)));
        cell_E8.value = FromExcel.DoubleCellValue(0);
        cell_F8.value = FromExcel.DoubleCellValue(0);

        cell_B9.value =
            FromExcel.DoubleCellValue(double.parse((cpk1).toStringAsFixed(2)));
        cell_C9.value =
            FromExcel.DoubleCellValue(double.parse((cpk2).toStringAsFixed(2)));
        cell_D9.value =
            FromExcel.DoubleCellValue(double.parse((cpk3).toStringAsFixed(2)));
        cell_E9.value = FromExcel.DoubleCellValue(0);
        cell_F9.value = FromExcel.DoubleCellValue(0);

        print(
            'MAX MIN AVG STDEV Cp Cpk POINT1 ----------------------------------> ' +
                max1.toString() +
                "  " +
                min1.toString() +
                "  " +
                avg1.toStringAsFixed(2) +
                "  " +
                st_dev1.toStringAsFixed(2) +
                "  " +
                cp1.toStringAsFixed(2) +
                "  " +
                cpk1.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT2 ----------------------------------> ' +
                max2.toString() +
                "  " +
                min2.toString() +
                "  " +
                avg2.toStringAsFixed(2) +
                "  " +
                st_dev2.toStringAsFixed(2) +
                "  " +
                cp2.toStringAsFixed(2) +
                "  " +
                cpk2.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT3 ----------------------------------> ' +
                max3.toString() +
                "  " +
                min3.toString() +
                "  " +
                avg3.toStringAsFixed(2) +
                "  " +
                st_dev3.toStringAsFixed(2) +
                "  " +
                cp3.toStringAsFixed(2) +
                "  " +
                cpk3.toStringAsFixed(2));
      } else if (read_point_selected == '4') {
        //---------------------------------------------------> 4
        // ST MAX
        cell_B2.value = FromExcel.DoubleCellValue(double.parse(read_max1));
        cell_C2.value = FromExcel.DoubleCellValue(double.parse(read_max2));
        cell_D2.value = FromExcel.DoubleCellValue(double.parse(read_max3));
        cell_E2.value = FromExcel.DoubleCellValue(double.parse(read_max4));
        cell_F2.value = FromExcel.DoubleCellValue(0);

        // ST MIN
        cell_B3.value = FromExcel.DoubleCellValue(double.parse(read_min1));
        cell_C3.value = FromExcel.DoubleCellValue(double.parse(read_min2));
        cell_D3.value = FromExcel.DoubleCellValue(double.parse(read_min3));
        cell_E3.value = FromExcel.DoubleCellValue(double.parse(read_min4));
        cell_F3.value = FromExcel.DoubleCellValue(0);

        // MAX MIN AVG
        double avg = 0;
        for (var i = 0; i < row1.length; i++) // Point1
        {
          var x = double.parse(row1[i]);
          row1_double.add(x);

          avg = avg + x;
        }
        double max1 =
            row1_double.reduce((curr, next) => curr > next ? curr : next);
        double min1 =
            row1_double.reduce((curr, next) => curr < next ? curr : next);
        double avg1 = avg / row1.length;
        double st_dev1 = standardDeviation(row1_double);

        double st_max1 = double.parse(read_max1);
        double st_min1 = double.parse(read_min1);
        double cp1 = (st_max1 - st_min1) / (6 * st_dev1);
        cp1.isInfinite ? cp1 = 0 : cp1 = cp1;

        double value1 = ((st_max1 - avg1) / (3 * st_dev1));
        double value2 = ((avg1 - st_min1) / (3 * st_dev1));
        double cpk1 = [value1, value2].reduce(min);
        cpk1.isInfinite ? cpk1 = 0 : cpk1 = cpk1;

        //------------------------------------------

        avg = 0;
        for (var i = 0; i < row2.length; i++) // Point2
        {
          var x = double.parse(row2[i]);
          row2_double.add(x);

          avg = avg + x;
        }
        double max2 =
            row2_double.reduce((curr, next) => curr > next ? curr : next);
        double min2 =
            row2_double.reduce((curr, next) => curr < next ? curr : next);
        double avg2 = avg / row2.length;
        double st_dev2 = standardDeviation(row2_double);

        double st_max2 = double.parse(read_max2);
        double st_min2 = double.parse(read_min2);
        double cp2 = (st_max2 - st_min2) / (6 * st_dev2);
        cp2.isInfinite ? cp2 = 0 : cp2 = cp2;

        value1 = ((st_max2 - avg2) / (3 * st_dev2));
        value2 = ((avg2 - st_min2) / (3 * st_dev2));
        double cpk2 = [value1, value2].reduce(min);
        cpk2.isInfinite ? cpk2 = 0 : cpk2 = cpk2;

        //------------------------------------------

        avg = 0;
        for (var i = 0; i < row3.length; i++) // Point3
        {
          var x = double.parse(row3[i]);
          row3_double.add(x);

          avg = avg + x;
        }
        double max3 =
            row3_double.reduce((curr, next) => curr > next ? curr : next);
        double min3 =
            row3_double.reduce((curr, next) => curr < next ? curr : next);
        double avg3 = avg / row3.length;
        double st_dev3 = standardDeviation(row3_double);

        double st_max3 = double.parse(read_max3);
        double st_min3 = double.parse(read_min3);
        double cp3 = (st_max3 - st_min3) / (6 * st_dev3);
        cp3.isInfinite ? cp3 = 0 : cp3 = cp3;

        value1 = ((st_max3 - avg3) / (3 * st_dev3));
        value2 = ((avg3 - st_min3) / (3 * st_dev3));
        double cpk3 = [value1, value2].reduce(min);
        cpk3.isInfinite ? cpk3 = 0 : cpk3 = cpk3;

        //------------------------------------------

        avg = 0;
        for (var i = 0; i < row4.length; i++) // Point4
        {
          var x = double.parse(row4[i]);
          row4_double.add(x);

          avg = avg + x;
        }
        double max4 =
            row4_double.reduce((curr, next) => curr > next ? curr : next);
        double min4 =
            row4_double.reduce((curr, next) => curr < next ? curr : next);
        double avg4 = avg / row4.length;
        double st_dev4 = standardDeviation(row4_double);

        double st_max4 = double.parse(read_max4);
        double st_min4 = double.parse(read_min4);
        double cp4 = (st_max4 - st_min4) / (6 * st_dev4);
        cp4.isInfinite ? cp4 = 0 : cp4 = cp4;

        value1 = ((st_max4 - avg4) / (3 * st_dev4));
        value2 = ((avg4 - st_min4) / (3 * st_dev4));
        double cpk4 = [value1, value2].reduce(min);
        cpk4.isInfinite ? cpk4 = 0 : cpk4 = cpk4;

        cell_B4.value =
            FromExcel.DoubleCellValue(double.parse((max1).toStringAsFixed(2)));
        cell_C4.value =
            FromExcel.DoubleCellValue(double.parse((max2).toStringAsFixed(2)));
        cell_D4.value =
            FromExcel.DoubleCellValue(double.parse((max3).toStringAsFixed(2)));
        cell_E4.value =
            FromExcel.DoubleCellValue(double.parse((max4).toStringAsFixed(2)));
        cell_F4.value = FromExcel.DoubleCellValue(0);

        cell_B5.value =
            FromExcel.DoubleCellValue(double.parse((min1).toStringAsFixed(2)));
        cell_C5.value =
            FromExcel.DoubleCellValue(double.parse((min2).toStringAsFixed(2)));
        cell_D5.value =
            FromExcel.DoubleCellValue(double.parse((min3).toStringAsFixed(2)));
        cell_E5.value =
            FromExcel.DoubleCellValue(double.parse((min4).toStringAsFixed(2)));
        cell_F5.value = FromExcel.DoubleCellValue(0);

        cell_B6.value =
            FromExcel.DoubleCellValue(double.parse((avg1).toStringAsFixed(2)));
        cell_C6.value =
            FromExcel.DoubleCellValue(double.parse((avg2).toStringAsFixed(2)));
        cell_D6.value =
            FromExcel.DoubleCellValue(double.parse((avg3).toStringAsFixed(2)));
        cell_E6.value =
            FromExcel.DoubleCellValue(double.parse((avg4).toStringAsFixed(2)));
        cell_F6.value = FromExcel.DoubleCellValue(0);

        cell_B7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev1).toStringAsFixed(2)));
        cell_C7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev2).toStringAsFixed(2)));
        cell_D7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev3).toStringAsFixed(2)));
        cell_E7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev4).toStringAsFixed(2)));
        cell_F7.value = FromExcel.DoubleCellValue(0);

        cell_B8.value =
            FromExcel.DoubleCellValue(double.parse((cp1).toStringAsFixed(2)));
        cell_C8.value =
            FromExcel.DoubleCellValue(double.parse((cp2).toStringAsFixed(2)));
        cell_D8.value =
            FromExcel.DoubleCellValue(double.parse((cp3).toStringAsFixed(2)));
        cell_E8.value =
            FromExcel.DoubleCellValue(double.parse((cp4).toStringAsFixed(2)));
        cell_F8.value = FromExcel.DoubleCellValue(0);

        cell_B9.value =
            FromExcel.DoubleCellValue(double.parse((cpk1).toStringAsFixed(2)));
        cell_C9.value =
            FromExcel.DoubleCellValue(double.parse((cpk2).toStringAsFixed(2)));
        cell_D9.value =
            FromExcel.DoubleCellValue(double.parse((cpk3).toStringAsFixed(2)));
        cell_E9.value =
            FromExcel.DoubleCellValue(double.parse((cpk4).toStringAsFixed(2)));
        cell_F9.value = FromExcel.DoubleCellValue(0);

        print(
            'MAX MIN AVG STDEV Cp Cpk POINT1 ----------------------------------> ' +
                max1.toString() +
                "  " +
                min1.toString() +
                "  " +
                avg1.toStringAsFixed(2) +
                "  " +
                st_dev1.toStringAsFixed(2) +
                "  " +
                cp1.toStringAsFixed(2) +
                "  " +
                cpk1.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT2 ----------------------------------> ' +
                max2.toString() +
                "  " +
                min2.toString() +
                "  " +
                avg2.toStringAsFixed(2) +
                "  " +
                st_dev2.toStringAsFixed(2) +
                "  " +
                cp2.toStringAsFixed(2) +
                "  " +
                cpk2.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT3 ----------------------------------> ' +
                max3.toString() +
                "  " +
                min3.toString() +
                "  " +
                avg3.toStringAsFixed(2) +
                "  " +
                st_dev3.toStringAsFixed(2) +
                "  " +
                cp3.toStringAsFixed(2) +
                "  " +
                cpk3.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT4 ----------------------------------> ' +
                max4.toString() +
                "  " +
                min4.toString() +
                "  " +
                avg4.toStringAsFixed(2) +
                "  " +
                st_dev4.toStringAsFixed(2) +
                "  " +
                cp4.toStringAsFixed(2) +
                "  " +
                cpk4.toStringAsFixed(2));
      } else if (read_point_selected == '5') {
        //---------------------------------------------------> 5
        // ST MAX
        cell_B2.value = FromExcel.DoubleCellValue(double.parse(read_max1));
        cell_C2.value = FromExcel.DoubleCellValue(double.parse(read_max2));
        cell_D2.value = FromExcel.DoubleCellValue(double.parse(read_max3));
        cell_E2.value = FromExcel.DoubleCellValue(double.parse(read_max4));
        cell_F2.value = FromExcel.DoubleCellValue(double.parse(read_max5));
        // ST MIN
        cell_B3.value = FromExcel.DoubleCellValue(double.parse(read_min1));
        cell_C3.value = FromExcel.DoubleCellValue(double.parse(read_min2));
        cell_D3.value = FromExcel.DoubleCellValue(double.parse(read_min3));
        cell_E3.value = FromExcel.DoubleCellValue(double.parse(read_min4));
        cell_F3.value = FromExcel.DoubleCellValue(double.parse(read_min5));

        // MAX MIN AVG
        double avg = 0;
        for (var i = 0; i < row1.length; i++) // Point1
        {
          var x = double.parse(row1[i]);
          row1_double.add(x);

          avg = avg + x;
        }
        double max1 =
            row1_double.reduce((curr, next) => curr > next ? curr : next);
        double min1 =
            row1_double.reduce((curr, next) => curr < next ? curr : next);
        double avg1 = avg / row1.length;
        double st_dev1 = standardDeviation(row1_double);

        double st_max1 = double.parse(read_max1);
        double st_min1 = double.parse(read_min1);
        double cp1 = (st_max1 - st_min1) / (6 * st_dev1);
        cp1.isInfinite ? cp1 = 0 : cp1 = cp1;

        double value1 = ((st_max1 - avg1) / (3 * st_dev1));
        double value2 = ((avg1 - st_min1) / (3 * st_dev1));
        double cpk1 = [value1, value2].reduce(min);
        cpk1.isInfinite ? cpk1 = 0 : cpk1 = cpk1;

        //------------------------------------------

        avg = 0;
        for (var i = 0; i < row2.length; i++) // Point2
        {
          var x = double.parse(row2[i]);
          row2_double.add(x);

          avg = avg + x;
        }
        double max2 =
            row2_double.reduce((curr, next) => curr > next ? curr : next);
        double min2 =
            row2_double.reduce((curr, next) => curr < next ? curr : next);
        double avg2 = avg / row2.length;
        double st_dev2 = standardDeviation(row2_double);

        double st_max2 = double.parse(read_max2);
        double st_min2 = double.parse(read_min2);
        double cp2 = (st_max2 - st_min2) / (6 * st_dev2);
        cp2.isInfinite ? cp2 = 0 : cp2 = cp2;

        value1 = ((st_max2 - avg2) / (3 * st_dev2));
        value2 = ((avg2 - st_min2) / (3 * st_dev2));
        double cpk2 = [value1, value2].reduce(min);
        cpk2.isInfinite ? cpk2 = 0 : cpk2 = cpk2;

        //------------------------------------------

        avg = 0;
        for (var i = 0; i < row3.length; i++) // Point3
        {
          var x = double.parse(row3[i]);
          row3_double.add(x);

          avg = avg + x;
        }
        double max3 =
            row3_double.reduce((curr, next) => curr > next ? curr : next);
        double min3 =
            row3_double.reduce((curr, next) => curr < next ? curr : next);
        double avg3 = avg / row3.length;
        double st_dev3 = standardDeviation(row3_double);

        double st_max3 = double.parse(read_max3);
        double st_min3 = double.parse(read_min3);
        double cp3 = (st_max3 - st_min3) / (6 * st_dev3);
        cp3.isInfinite ? cp3 = 0 : cp3 = cp3;

        value1 = ((st_max3 - avg3) / (3 * st_dev3));
        value2 = ((avg3 - st_min3) / (3 * st_dev3));
        double cpk3 = [value1, value2].reduce(min);
        cpk3.isInfinite ? cpk3 = 0 : cpk3 = cpk3;

        //------------------------------------------

        avg = 0;
        for (var i = 0; i < row4.length; i++) // Point4
        {
          var x = double.parse(row4[i]);
          row4_double.add(x);

          avg = avg + x;
        }
        double max4 =
            row4_double.reduce((curr, next) => curr > next ? curr : next);
        double min4 =
            row4_double.reduce((curr, next) => curr < next ? curr : next);
        double avg4 = avg / row4.length;
        double st_dev4 = standardDeviation(row4_double);

        double st_max4 = double.parse(read_max4);
        double st_min4 = double.parse(read_min4);
        double cp4 = (st_max4 - st_min4) / (6 * st_dev4);
        cp4.isInfinite ? cp4 = 0 : cp4 = cp4;

        value1 = ((st_max4 - avg4) / (3 * st_dev4));
        value2 = ((avg4 - st_min4) / (3 * st_dev4));
        double cpk4 = [value1, value2].reduce(min);
        cpk4.isInfinite ? cpk4 = 0 : cpk4 = cpk4;

        //------------------------------------------

        avg = 0;
        for (var i = 0; i < row5.length; i++) // Point5
        {
          var x = double.parse(row5[i]);
          row5_double.add(x);

          avg = avg + x;
        }
        double max5 =
            row5_double.reduce((curr, next) => curr > next ? curr : next);
        double min5 =
            row5_double.reduce((curr, next) => curr < next ? curr : next);
        double avg5 = avg / row5.length;
        double st_dev5 = standardDeviation(row5_double);

        double st_max5 = double.parse(read_max5);
        double st_min5 = double.parse(read_min5);
        double cp5 = (st_max5 - st_min5) / (6 * st_dev5);
        cp5.isInfinite ? cp5 = 0 : cp5 = cp5;

        value1 = ((st_max5 - avg5) / (3 * st_dev5));
        value2 = ((avg5 - st_min5) / (3 * st_dev5));
        double cpk5 = [value1, value2].reduce(min);
        cpk5.isInfinite ? cpk5 = 0 : cpk5 = cpk5;

        cell_B4.value =
            FromExcel.DoubleCellValue(double.parse((max1).toStringAsFixed(2)));
        cell_C4.value =
            FromExcel.DoubleCellValue(double.parse((max2).toStringAsFixed(2)));
        cell_D4.value =
            FromExcel.DoubleCellValue(double.parse((max3).toStringAsFixed(2)));
        cell_E4.value =
            FromExcel.DoubleCellValue(double.parse((max4).toStringAsFixed(2)));
        cell_F4.value =
            FromExcel.DoubleCellValue(double.parse((max5).toStringAsFixed(2)));

        cell_B5.value =
            FromExcel.DoubleCellValue(double.parse((min1).toStringAsFixed(2)));
        cell_C5.value =
            FromExcel.DoubleCellValue(double.parse((min2).toStringAsFixed(2)));
        cell_D5.value =
            FromExcel.DoubleCellValue(double.parse((min3).toStringAsFixed(2)));
        cell_E5.value =
            FromExcel.DoubleCellValue(double.parse((min4).toStringAsFixed(2)));
        cell_F5.value =
            FromExcel.DoubleCellValue(double.parse((min5).toStringAsFixed(2)));

        cell_B6.value =
            FromExcel.DoubleCellValue(double.parse((avg1).toStringAsFixed(2)));
        cell_C6.value =
            FromExcel.DoubleCellValue(double.parse((avg2).toStringAsFixed(2)));
        cell_D6.value =
            FromExcel.DoubleCellValue(double.parse((avg3).toStringAsFixed(2)));
        cell_E6.value =
            FromExcel.DoubleCellValue(double.parse((avg4).toStringAsFixed(2)));
        cell_F6.value =
            FromExcel.DoubleCellValue(double.parse((avg5).toStringAsFixed(2)));

        cell_B7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev1).toStringAsFixed(2)));
        cell_C7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev2).toStringAsFixed(2)));
        cell_D7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev3).toStringAsFixed(2)));
        cell_E7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev4).toStringAsFixed(2)));
        cell_F7.value = FromExcel.DoubleCellValue(
            double.parse((st_dev5).toStringAsFixed(2)));

        cell_B8.value =
            FromExcel.DoubleCellValue(double.parse((cp1).toStringAsFixed(2)));
        cell_C8.value =
            FromExcel.DoubleCellValue(double.parse((cp2).toStringAsFixed(2)));
        cell_D8.value =
            FromExcel.DoubleCellValue(double.parse((cp3).toStringAsFixed(2)));
        cell_E8.value =
            FromExcel.DoubleCellValue(double.parse((cp4).toStringAsFixed(2)));
        cell_F8.value =
            FromExcel.DoubleCellValue(double.parse((cp5).toStringAsFixed(2)));

        cell_B9.value =
            FromExcel.DoubleCellValue(double.parse((cpk1).toStringAsFixed(2)));
        cell_C9.value =
            FromExcel.DoubleCellValue(double.parse((cpk2).toStringAsFixed(2)));
        cell_D9.value =
            FromExcel.DoubleCellValue(double.parse((cpk3).toStringAsFixed(2)));
        cell_E9.value =
            FromExcel.DoubleCellValue(double.parse((cpk4).toStringAsFixed(2)));
        cell_F9.value =
            FromExcel.DoubleCellValue(double.parse((cpk5).toStringAsFixed(2)));

        print(
            'MAX MIN AVG STDEV Cp Cpk POINT1 ----------------------------------> ' +
                max1.toString() +
                "  " +
                min1.toString() +
                "  " +
                avg1.toStringAsFixed(2) +
                "  " +
                st_dev1.toStringAsFixed(2) +
                "  " +
                cp1.toStringAsFixed(2) +
                "  " +
                cpk1.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT2 ----------------------------------> ' +
                max2.toString() +
                "  " +
                min2.toString() +
                "  " +
                avg2.toStringAsFixed(2) +
                "  " +
                st_dev2.toStringAsFixed(2) +
                "  " +
                cp2.toStringAsFixed(2) +
                "  " +
                cpk2.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT3 ----------------------------------> ' +
                max3.toString() +
                "  " +
                min3.toString() +
                "  " +
                avg3.toStringAsFixed(2) +
                "  " +
                st_dev3.toStringAsFixed(2) +
                "  " +
                cp3.toStringAsFixed(2) +
                "  " +
                cpk3.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT4 ----------------------------------> ' +
                max4.toString() +
                "  " +
                min4.toString() +
                "  " +
                avg4.toStringAsFixed(2) +
                "  " +
                st_dev4.toStringAsFixed(2) +
                "  " +
                cp4.toStringAsFixed(2) +
                "  " +
                cpk4.toStringAsFixed(2));
        print(
            'MAX MIN AVG STDEV Cp Cpk POINT5 ----------------------------------> ' +
                max5.toString() +
                "  " +
                min5.toString() +
                "  " +
                avg5.toStringAsFixed(2) +
                "  " +
                st_dev5.toStringAsFixed(2) +
                "  " +
                cp5.toStringAsFixed(2) +
                "  " +
                cpk5.toStringAsFixed(2));
      }

      // Save
      List<int>? fileBytes = await excel.encode();

      File outputFile = File((filepath));
      if (res.isGranted) {
        if (await outputFile.exists()) {
          //print("File exist");
          // await outputFile.delete().catchError((e) {
          //   print(e);
          // });
        }
      }

      // Saving the file
      if (fileBytes != null) {
        await outputFile.writeAsBytes(fileBytes, flush: true);

        print('Update Cell');
      }
    } catch (e) {
      print(e);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> excel_append_data(String filepath) async {
    try {
      var res = await Permission.storage.request();
      File InputFile = File((filepath));
      if (res.isGranted) {
        print(
            'Permission OK ----------------------------------------------------->>>> Append Mode');
      }

      //var filename = MyConstant.path_excel;
      List<int> bytes = await (InputFile).readAsBytes();
      var excel = FromExcel.Excel.decodeBytes(bytes);
      var sheet1 = excel['Sheet1'];

      int last_column = 0;
      int last_row = 0;
      for (var table in excel.tables.keys) {
        print(table); //sheet Name

        last_column = excel.tables[table]!.maxColumns;
        last_row = excel.tables[table]!.maxRows;
        print('Append Max Column: ' + last_column.toString());
        print('Append Max Rows: ' + last_row.toString());
      }

      // Append
      String result = '';
      if (judge == true) {
        result = "OK";
      } else {
        result = "NG";
      }

      if (read_point_selected == '1') {
        List<double> value = [double.parse(data_recived[0].trim()), 0, 0, 0, 0];
        AppendDataToExcel(sheet1, value, last_row, result);
      } else if (read_point_selected == '2') {
        List<double> value = [
          double.parse(data_recived[0].trim()),
          double.parse(data_recived[1].trim()),
          0,
          0,
          0
        ];
        AppendDataToExcel(sheet1, value, last_row, result);
      } else if (read_point_selected == '3') {
        List<double> value = [
          double.parse(data_recived[0].trim()),
          double.parse(data_recived[1].trim()),
          double.parse(data_recived[2].trim()),
          0,
          0
        ];
        AppendDataToExcel(sheet1, value, last_row, result);
      } else if (read_point_selected == '4') {
        List<double> value = [
          double.parse(data_recived[0].trim()),
          double.parse(data_recived[1].trim()),
          double.parse(data_recived[2].trim()),
          double.parse(data_recived[3].trim()),
          0
        ];
        AppendDataToExcel(sheet1, value, last_row, result);
      } else if (read_point_selected == '5') {
        List<double> value = [
          double.parse(data_recived[0].trim()),
          double.parse(data_recived[1].trim()),
          double.parse(data_recived[2].trim()),
          double.parse(data_recived[3].trim()),
          double.parse(data_recived[4].trim())
        ];
        AppendDataToExcel(sheet1, value, last_row, result);
      }

      bool isSet = excel.setDefaultSheet(sheet1.sheetName);
      // isSet is bool which tells that whether the setting of default sheet is successful or not.
      if (isSet) {
        print("${sheet1.sheetName} is set to default sheet.");
      } else {
        print("Unable to set ${sheet1.sheetName} to default sheet.");
      }

      List<int>? fileBytes = await excel.encode();

      File outputFile = File((filepath));
      if (res.isGranted) {
        if (await outputFile.exists()) {
          //print("File exist");
          // await outputFile.delete().catchError((e) {
          //   print(e);
          // });
        }
      }

      // Saving the file
      if (fileBytes != null) {
        await outputFile.writeAsBytes(fileBytes, flush: true);

        print('Appended');
      } else {
        print('------------------------------->>> Null');
      }
    } catch (e) {
      print(e);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void AppendDataToExcel(
      FromExcel.Sheet sheet1, List<double> value, int last_row, String result) {
    //https://github.com/justkawal/excel/issues/293

    var cell0 = sheet1.cell(FromExcel.CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: last_row));
    cell0.value = FromExcel.TextCellValue(timenow);
    cell0.cellStyle = FromExcel.CellStyle(
        numberFormat: FromExcel.NumFormat.defaultNumeric); // Text

    var cell1 = sheet1.cell(FromExcel.CellIndex.indexByColumnRow(
        columnIndex: 1, rowIndex: last_row));
    cell1.value = FromExcel.DoubleCellValue(value[0]);
    cell1.cellStyle = FromExcel.CellStyle(
        numberFormat: FromExcel.NumFormat.standard_2); // Double

    var cell2 = sheet1.cell(FromExcel.CellIndex.indexByColumnRow(
        columnIndex: 2, rowIndex: last_row));
    cell2.value = FromExcel.DoubleCellValue(value[1]);
    cell2.cellStyle = FromExcel.CellStyle(
        numberFormat: FromExcel.NumFormat.standard_2); // Double

    var cell3 = sheet1.cell(FromExcel.CellIndex.indexByColumnRow(
        columnIndex: 3, rowIndex: last_row));
    cell3.value = FromExcel.DoubleCellValue(value[2]);
    cell3.cellStyle = FromExcel.CellStyle(
        numberFormat: FromExcel.NumFormat.standard_2); // Double

    var cell4 = sheet1.cell(FromExcel.CellIndex.indexByColumnRow(
        columnIndex: 4, rowIndex: last_row));
    cell4.value = FromExcel.DoubleCellValue(value[3]);
    cell4.cellStyle = FromExcel.CellStyle(
        numberFormat: FromExcel.NumFormat.standard_2); // Double

    var cell5 = sheet1.cell(FromExcel.CellIndex.indexByColumnRow(
        columnIndex: 5, rowIndex: last_row));
    cell5.value = FromExcel.DoubleCellValue(value[4]);
    cell5.cellStyle = FromExcel.CellStyle(
        numberFormat: FromExcel.NumFormat.standard_2); // Double

    var cell6 = sheet1.cell(FromExcel.CellIndex.indexByColumnRow(
        columnIndex: 6, rowIndex: last_row));
    cell6.value = FromExcel.TextCellValue(result);
    cell6.cellStyle = FromExcel.CellStyle(
        numberFormat: FromExcel.NumFormat.defaultNumeric); // Text
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> excel_write_header(String filepath) async {
    try {
      var excel = FromExcel.Excel.createExcel();
      var sheet1 = excel['Sheet1'];

      List<FromExcel.CellValue> dataList_row0 = [
        FromExcel.TextCellValue("List"),
        FromExcel.TextCellValue("Point1"),
        FromExcel.TextCellValue("Point2"),
        FromExcel.TextCellValue("Point3"),
        FromExcel.TextCellValue("Point4"),
        FromExcel.TextCellValue("Point5"),
        FromExcel.TextCellValue("")
      ];

      List<FromExcel.CellValue> dataList_row1 = [
        FromExcel.TextCellValue("ST MAX")
      ];
      List<FromExcel.CellValue> dataList_row2 = [
        FromExcel.TextCellValue("ST MIN")
      ];
      List<FromExcel.CellValue> dataList_row3 = [
        FromExcel.TextCellValue("MAX")
      ];
      List<FromExcel.CellValue> dataList_row4 = [
        FromExcel.TextCellValue("MIN")
      ];
      List<FromExcel.CellValue> dataList_row5 = [
        FromExcel.TextCellValue("AVERAGE")
      ];
      List<FromExcel.CellValue> dataList_row6 = [
        FromExcel.TextCellValue("ST DEV")
      ];
      List<FromExcel.CellValue> dataList_row7 = [FromExcel.TextCellValue("Cp")];
      List<FromExcel.CellValue> dataList_row8 = [
        FromExcel.TextCellValue("Cpk")
      ];

      List<FromExcel.CellValue> dataList_row9 = [
        FromExcel.TextCellValue(""),
        FromExcel.TextCellValue(""),
        FromExcel.TextCellValue(""),
        FromExcel.TextCellValue(""),
        FromExcel.TextCellValue(""),
        FromExcel.TextCellValue(""),
        FromExcel.TextCellValue("")
      ];

      List<FromExcel.CellValue> dataList_row10 = [
        FromExcel.TextCellValue("Timestamp"),
        FromExcel.TextCellValue("Point1"),
        FromExcel.TextCellValue("Point2"),
        FromExcel.TextCellValue("Point3"),
        FromExcel.TextCellValue("Point4"),
        FromExcel.TextCellValue("Point5"),
        FromExcel.TextCellValue("Judge")
      ];

      sheet1.insertRowIterables(dataList_row0, 0);
      sheet1.insertRowIterables(dataList_row1, 1);
      sheet1.insertRowIterables(dataList_row2, 2);
      sheet1.insertRowIterables(dataList_row3, 3);
      sheet1.insertRowIterables(dataList_row4, 4);
      sheet1.insertRowIterables(dataList_row5, 5);
      sheet1.insertRowIterables(dataList_row6, 6);
      sheet1.insertRowIterables(dataList_row7, 7);
      sheet1.insertRowIterables(dataList_row8, 8);
      sheet1.insertRowIterables(dataList_row9, 9);
      sheet1.insertRowIterables(dataList_row10, 10);

      List<int>? fileBytes = await excel.encode();

      var res = await Permission.storage.request();
      File outputFile = File((filepath));
      if (res.isGranted) {
        if (await outputFile.exists()) {
          print("File exist");
          //await outputFile.delete().catchError((e) {
          //print(e);
          //});
        }
      }

      // Saving the file
      if (fileBytes != null) {
        await outputFile.writeAsBytes(fileBytes, flush: true);
      }
    } catch (e) {
      print(e);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void WriteLogFile() {
    String res;

    if (judge == true) {
      res = "OK";
    } else {
      res = "NG";
    }
    print('Index Recieved: $index_recive');
    if (index_recive >= int.parse(read_point_selected))
      FileStorage.writeCounter(
          timenow +
              ',' +
              data_recived[0].trim() +
              ',' +
              data_recived[1].trim() +
              ',' +
              data_recived[2].trim() +
              ',' +
              data_recived[3].trim() +
              ',' +
              data_recived[4].trim() +
              ',' +
              res +
              '\r',
          "log.csv");
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Container icon_ng() {
    return Container(
      width: 30,
      //color: Colors.pink,
      child: ShowImage(path: MyConstant.image_ng),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Container icon_ok() {
    return Container(
      width: 30,
      //color: Colors.pink,
      child: ShowImage(path: MyConstant.image_ok),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget show_timenow() {
    return Text(
      timenow,
      style: TextStyle(fontSize: 25, color: Colors.teal),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget show_counter() {
    return Text(
      'Counter',
      style: TextStyle(
          fontSize: 30, fontWeight: FontWeight.bold, color: Colors.teal),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget reset_button() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: () {
          confirm_popup();
        },
        icon: Icon(Icons.arrow_drop_down_circle_rounded, size: 50),
        label: Text(
          'Reset',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(60),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget build_save_button() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
          //color: Colors.red,
          width: 200,
          height: 80,
          child: isSaving
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colors.teal,
                ))
              : ElevatedButton.icon(
                  onPressed: () async {
                    //isSaving = true;  // for test --> don't show CircularProgress
                    if (index_recive >= int.parse(read_point_selected)) {
                      await write_to_excel().then((value) {
                        setState(() {
                          //_processIndex = (_processIndex + 1) % _processes.length;
                          //WriteLogFile();
                          check_save_counter();
                          index_recive = 0;
                          buffer.clear();
      
                          index_image = 1;
                          FileImagePath = imagePathDownloadFolder +
                              read_preset_selected +
                              '/' +
                              index_image.toString() +
                              '.jpg';
      
                          if (read_point_selected == '1') {
                            status_result[0] = true;
      
                            data_recived[0] = 'Waiting';
                            unit[0] = '';
                          } else if (read_point_selected == '2') {
                            status_result[0] = true;
                            status_result[1] = true;
      
                            data_recived[0] = 'Waiting';
                            data_recived[1] = 'Waiting';
      
                            unit[0] = '';
                            unit[1] = '';
                          } else if (read_point_selected == '3') {
                            status_result[0] = true;
                            status_result[1] = true;
                            status_result[2] = true;
      
                            data_recived[0] = 'Waiting';
                            data_recived[1] = 'Waiting';
                            data_recived[2] = 'Waiting';
      
                            unit[0] = '';
                            unit[1] = '';
                            unit[2] = '';
                          } else if (read_point_selected == '4') {
                            status_result[0] = true;
                            status_result[1] = true;
                            status_result[2] = true;
                            status_result[3] = true;
      
                            data_recived[0] = 'Waiting';
                            data_recived[1] = 'Waiting';
                            data_recived[2] = 'Waiting';
                            data_recived[3] = 'Waiting';
      
                            unit[0] = '';
                            unit[1] = '';
                            unit[2] = '';
                            unit[3] = '';
                          } else if (read_point_selected == '5') {
                            status_result[0] = true;
                            status_result[1] = true;
                            status_result[2] = true;
                            status_result[3] = true;
                            status_result[4] = true;
      
                            data_recived[0] = 'Waiting';
                            data_recived[1] = 'Waiting';
                            data_recived[2] = 'Waiting';
                            data_recived[3] = 'Waiting';
                            data_recived[4] = 'Waiting';
      
                            unit[0] = '';
                            unit[1] = '';
                            unit[2] = '';
                            unit[3] = '';
                            unit[4] = '';
                          }
                        });
                        return isSaving = false;
                      });
                    }
                  },
                  icon: Icon(Icons.save, size: 50),
                  label: Text(
                    'Save',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(60),
                    ),
                  ),
                )),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget retry_button_1_points() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            index_recive--;
            buffer.clear();

            // Index Image
            if (index_recive <= 0) {
              index_image = 1;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 1) {
              index_image = 2;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 2) {
              index_image = 3;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 3) {
              index_image = 4;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 4) {
              index_image = 5;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive >= 5) {
              index_recive = 5;
            }

            if (index_recive == 0) {
              index_recive = 0;
              buffer.clear();

              status_result[0] = true;

              data_recived[0] = 'Waiting';
              unit[0] = '';
            }

            if (index_recive <= 0) {
              index_recive = 0;
            }
          });
        },
        icon: Icon(Icons.replay_circle_filled_rounded, size: 50),
        label: Text(
          'Retry',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(60),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget retry_button_2_points() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            index_recive--;
            buffer.clear();

            // Index Image
            if (index_recive <= 0) {
              index_image = 1;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 1) {
              index_image = 2;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 2) {
              index_image = 3;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 3) {
              index_image = 4;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 4) {
              index_image = 5;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive >= 5) {
              index_recive = 5;
            }

            if (index_recive == 0) {
              index_recive = 0;
              buffer.clear();

              status_result[0] = true;
              status_result[1] = true;

              data_recived[0] = 'Waiting';
              data_recived[1] = 'Waiting';

              unit[0] = '';
              unit[1] = '';
            } else if (index_recive == 1) {
              status_result[1] = true;

              data_recived[1] = 'Waiting';
              unit[1] = '';
            }

            if (index_recive <= 0) {
              index_recive = 0;
            }
          });
        },
        icon: Icon(Icons.replay_circle_filled_rounded, size: 50),
        label: Text(
          'Retry',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(60),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget retry_button_3_points() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            index_recive--;
            buffer.clear();

            // Index Image
            if (index_recive <= 0) {
              index_image = 1;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 1) {
              index_image = 2;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 2) {
              index_image = 3;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 3) {
              index_image = 4;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 4) {
              index_image = 5;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive >= 5) {
              index_recive = 5;
            }

            if (index_recive == 0) {
              index_recive = 0;
              buffer.clear();

              status_result[0] = true;
              status_result[1] = true;
              status_result[2] = true;

              data_recived[0] = 'Waiting';
              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';

              unit[0] = '';
              unit[1] = '';
              unit[2] = '';
            } else if (index_recive == 1) {
              status_result[1] = true;
              status_result[2] = true;

              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';

              unit[1] = '';
              unit[2] = '';
            } else if (index_recive == 2) {
              status_result[2] = true;

              data_recived[2] = 'Waiting';
              unit[2] = '';
            }

            if (index_recive <= 0) {
              index_recive = 0;
            }
          });
        },
        icon: Icon(Icons.replay_circle_filled_rounded, size: 50),
        label: Text(
          'Retry',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(60),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget retry_button_4_points() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            index_recive--;
            buffer.clear();

            // Index Image
            if (index_recive <= 0) {
              index_image = 1;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 1) {
              index_image = 2;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 2) {
              index_image = 3;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 3) {
              index_image = 4;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 4) {
              index_image = 5;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive >= 5) {
              index_recive = 5;
            }

            if (index_recive == 0) {
              index_recive = 0;
              buffer.clear();

              status_result[0] = true;
              status_result[1] = true;
              status_result[2] = true;
              status_result[3] = true;

              data_recived[0] = 'Waiting';
              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';

              unit[0] = '';
              unit[1] = '';
              unit[2] = '';
              unit[3] = '';
            } else if (index_recive == 1) {
              status_result[1] = true;
              status_result[2] = true;
              status_result[3] = true;

              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';

              unit[1] = '';
              unit[2] = '';
              unit[3] = '';
            } else if (index_recive == 2) {
              status_result[2] = true;
              status_result[3] = true;

              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';

              unit[2] = '';
              unit[3] = '';
            } else if (index_recive == 3) {
              status_result[3] = true;
              status_result[4] = true;

              data_recived[3] = 'Waiting';
              unit[3] = '';
            }

            if (index_recive <= 0) {
              index_recive = 0;
            }
          });
        },
        icon: Icon(Icons.replay_circle_filled_rounded, size: 50),
        label: Text(
          'Retry',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(60),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget retry_button_5_points() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            //_processIndex = (_processIndex - 1) % _processes.length;
            index_recive--;
            buffer.clear();

            // Index Image
            if (index_recive <= 0) {
              index_image = 1;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 1) {
              index_image = 2;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 2) {
              index_image = 3;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 3) {
              index_image = 4;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive == 4) {
              index_image = 5;
              FileImagePath = imagePathDownloadFolder +
                  read_preset_selected +
                  '/' +
                  index_image.toString() +
                  '.jpg';
            } else if (index_recive >= 5) {
              index_recive = 5;
            }

            if (index_recive == 0) {
              index_recive = 0;
              buffer.clear();

              status_result[0] = true;
              status_result[1] = true;
              status_result[2] = true;
              status_result[3] = true;
              status_result[4] = true;

              data_recived[0] = 'Waiting';
              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';
              data_recived[4] = 'Waiting';

              unit[0] = '';
              unit[1] = '';
              unit[2] = '';
              unit[3] = '';
              unit[4] = '';
            } else if (index_recive == 1) {
              status_result[1] = true;
              status_result[2] = true;
              status_result[3] = true;
              status_result[4] = true;

              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';
              data_recived[4] = 'Waiting';

              unit[1] = '';
              unit[2] = '';
              unit[3] = '';
              unit[4] = '';
            } else if (index_recive == 2) {
              status_result[2] = true;
              status_result[3] = true;
              status_result[4] = true;

              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';
              data_recived[4] = 'Waiting';

              unit[2] = '';
              unit[3] = '';
              unit[4] = '';
            } else if (index_recive == 3) {
              status_result[3] = true;
              status_result[4] = true;

              data_recived[3] = 'Waiting';
              data_recived[4] = 'Waiting';

              unit[3] = '';
              unit[4] = '';
            } else if (index_recive == 4) {
              status_result[4] = true;

              data_recived[4] = 'Waiting';
              unit[4] = '';
            }

            if (index_recive <= 0) {
              index_recive = 0;
            }
          });
        },
        icon: Icon(Icons.replay_circle_filled_rounded, size: 50),
        label: Text(
          'Retry',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(60),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Card build_ok_counter(int value) {
    return Card(
      color: Colors.green,
      child: Container(
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: icon_ok(),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                NumberFormat("#,###").format(value),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Qty',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Card build_ng_counter(int value) {
    return Card(
      color: Colors.red,
      child: Container(
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: icon_ng(),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                NumberFormat("#,###").format(value),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Qty',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Card build_total_counter(int value) {
    return Card(
      color: Colors.blue,
      child: Container(
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Total',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                NumberFormat("#,###").format(value),
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Qty',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> confirm_popup() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ListTile(
          leading: ShowImage(path: MyConstant.confirm),
          title: Text(
            'Are you sure to reset the counter?',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          //subtitle: Text('Are you sure?', style: TextStyle(color: Colors.teal),),
        ),
        actions: [
          TextButton(
            onPressed: () {
              cnt_ok = 0;
              cnt_ng = -0;
              cnt_total = 0;
              save_count();
              read_counter();
              Navigator.pop(context);
            },
            child: Text(
              'Yes',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'No',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  TableRow buildRow(List<String> cells,
          {bool isHeader = false, bool isOK = false}) =>
      TableRow(
        decoration: isHeader
            ? BoxDecoration(color: Colors.teal)
            : BoxDecoration(color: isOK ? Colors.white : Colors.red),
        children: cells.map((cell) {
          final style = TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            color: isHeader ? Colors.white : Colors.black,
          );
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
                child: Text(
              cell,
              style: style,
            )),
          );
        }).toList(),
      );

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
