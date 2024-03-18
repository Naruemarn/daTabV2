import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'dart:typed_data';
import 'dart:developer';

import 'package:databv2/FileStorage.dart';

import 'package:databv2/setting.dart';
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

import 'package:excel/excel.dart';
//import 'package:path/path.dart';

import 'package:timelines/timelines.dart';

import 'package:async/async.dart';

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
  int index_recive = 0;

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

    setState(() {
      data_recived[index_recive] = dataString;
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
    read_preset_name = prefs.getString('key_preset_name_' + read_preset_selected.toString())!;

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

    setState(() {
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
          // IconButton(
          //   onPressed: () async {
          //     OpenFile.open(MyConstant.path_excel);
          //   },
          //   icon: const Icon(
          //     Icons.file_copy_sharp,
          //   ),
          // ),
          build_setting_icon(context)
        ],
      ),
      body: Column(
        children: [
          build_timeline(context, int.parse(read_point_selected)),
          //Divider(color: Colors.grey, height: 40,),
          Container(
            //color: Colors.yellow,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    //color: Colors.blue,
                    child: Column(
                      children: [
                        show_counter(),
                        build_ok_counter(cnt_ok!),
                        build_ng_counter(cnt_ng!),
                        build_total_counter(cnt_total!),
                        reset_button(),
                      ],
                    ),
                  ),
                ),
                build_judge(size),
                build_table(size)
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: build_retry_save_button(),
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
  Row build_retry_save_button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (read_point_selected == '1') retry_button_1_points(),
        if (read_point_selected == '2') retry_button_2_points(),
        if (read_point_selected == '3') retry_button_3_points(),
        if (read_point_selected == '4') retry_button_4_points(),
        if (read_point_selected == '5') retry_button_5_points(),
        SizedBox(width: 20),
        if (index_recive >= int.parse(read_point_selected)) save_button(),
      ],
    );
  }

  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Expanded build_table(double size) {
    return Expanded(
      child: Container(
        width: size * 0.1,
        //color: Colors.purple,
        child: Column(
          children: [
            Container(
                child: Text(
              read_preset_name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Colors.teal),
            )),
            SizedBox(
              height: 5,
            ),
            if (read_point_selected == '1') build_table_row1(),
            if (read_point_selected == '2') build_table_row2(),
            if (read_point_selected == '3') build_table_row3(),
            if (read_point_selected == '4') build_table_row4(),
            if (read_point_selected == '5') build_table_row5(),
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
  Column build_judge(double size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (index_recive >= int.parse(read_point_selected))
          judge
              ? Container(
                  width: size * 0.25,
                  child: ShowImage(path: MyConstant.image_ok),
                )
              : Container(
                  width: size * 0.25,
                  child: ShowImage(path: MyConstant.image_ng),
                ),
        if (index_recive < int.parse(read_point_selected))
          Container(
            width: size * 0.25,
            child: ShowImage(path: MyConstant.image_wait),
          ),
        Container(
          child: Text(
            'Judge',
            style: TextStyle(
                fontSize: 30, color: Colors.teal, fontWeight: FontWeight.bold),
          ),
        ),
        //show_timenow(),
      ],
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
        data_recived[index],
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
        data_recived[index],
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
        data_recived[index],
        style: TextStyle(
            fontWeight: FontWeight.normal, fontSize: 35, color: Colors.green),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> write_to_excel() async {
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
        await excel_append_data(filename);
      } else {
        await excel_write_header(filename);
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> excel_append_data(String filepath) async {
    var res = await Permission.storage.request();
    File InputFile = File((filepath));
    if (res.isGranted) {
      print('Permission OK Append Mode');
    }

    //var filename = MyConstant.path_excel;
    List<int> bytes = await (InputFile).readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    var sheet1 = excel['Sheet1'];

    String result = '';
    if (judge == true) {
      result = "OK";
    } else {
      result = "NG";
    }

    if (read_point_selected == '1') {
      sheet1.appendRow([
        TextCellValue(timenow),
        TextCellValue(data_recived[0].trim()),
        TextCellValue('Not use'),
        TextCellValue('Not use'),
        TextCellValue('Not use'),
        TextCellValue('Not use'),
        TextCellValue(result)
      ]);
    } else if (read_point_selected == '2') {
      sheet1.appendRow([
        TextCellValue(timenow),
        TextCellValue(data_recived[0].trim()),
        TextCellValue(data_recived[1].trim()),
        TextCellValue('Not use'),
        TextCellValue('Not use'),
        TextCellValue('Not use'),
        TextCellValue(result)
      ]);
    } else if (read_point_selected == '3') {
      sheet1.appendRow([
        TextCellValue(timenow),
        TextCellValue(data_recived[0].trim()),
        TextCellValue(data_recived[1].trim()),
        TextCellValue(data_recived[2].trim()),
        TextCellValue('Not use'),
        TextCellValue('Not use'),
        TextCellValue(result)
      ]);
    } else if (read_point_selected == '4') {
      sheet1.appendRow([
        TextCellValue(timenow),
        TextCellValue(data_recived[0].trim()),
        TextCellValue(data_recived[1].trim()),
        TextCellValue(data_recived[2].trim()),
        TextCellValue(data_recived[3].trim()),
        TextCellValue('Not use'),
        TextCellValue(result)
      ]);
    } else if (read_point_selected == '5') {
      sheet1.appendRow([
        TextCellValue(timenow),
        TextCellValue(data_recived[0].trim()),
        TextCellValue(data_recived[1].trim()),
        TextCellValue(data_recived[2].trim()),
        TextCellValue(data_recived[3].trim()),
        TextCellValue(data_recived[4].trim()),
        TextCellValue(result)
      ]);
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
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<void> excel_write_header(String filepath) async {
    var excel = Excel.createExcel();
    var sheet1 = excel['Sheet1'];

    List<CellValue> dataList = [
      TextCellValue("Timestamp"),
      TextCellValue("Point1"),
      TextCellValue("Point2"),
      TextCellValue("Point3"),
      TextCellValue("Point4"),
      TextCellValue("Point5"),
      TextCellValue("Judge")
    ];

    sheet1.insertRowIterables(dataList, 0);

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
      width: 60,
      //color: Colors.pink,
      child: ShowImage(path: MyConstant.image_ng),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Container icon_ok() {
    return Container(
      width: 60,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        //color: Colors.red,
        width: 150,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            confirm_popup();
          },
          icon: Icon(Icons.arrow_drop_down_circle_rounded),
          label: Text('Reset'),
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.black,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget save_button() {
    return Container(
        //color: Colors.red,
        width: 200,
        height: 70,
        child: isSaving
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.teal,
              ))
            : ElevatedButton.icon(
                onPressed: () async {
                  isSaving = true;

                  await write_to_excel().then((value) => isSaving = false);

                  setState(() {
                    //_processIndex = (_processIndex + 1) % _processes.length;

                    //WriteLogFile();

                    check_save_counter();
                    index_recive = 0;
                    buffer.clear();

                    if (read_point_selected == '1') {
                      status_result[0] = true;

                      data_recived[0] = 'Waiting';
                    } else if (read_point_selected == '2') {
                      status_result[0] = true;
                      status_result[1] = true;

                      data_recived[0] = 'Waiting';
                      data_recived[1] = 'Waiting';
                    } else if (read_point_selected == '3') {
                      status_result[0] = true;
                      status_result[1] = true;
                      status_result[2] = true;

                      data_recived[0] = 'Waiting';
                      data_recived[1] = 'Waiting';
                      data_recived[2] = 'Waiting';
                    } else if (read_point_selected == '4') {
                      status_result[0] = true;
                      status_result[1] = true;
                      status_result[2] = true;
                      status_result[3] = true;

                      data_recived[0] = 'Waiting';
                      data_recived[1] = 'Waiting';
                      data_recived[2] = 'Waiting';
                      data_recived[3] = 'Waiting';
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
                    }
                  });
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
                    borderRadius: new BorderRadius.circular(30),
                  ),
                ),
              ));
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget retry_button_1_points() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            index_recive--;
            buffer.clear();

            if (index_recive == 0) {
              index_recive = 0;
              buffer.clear();

              status_result[0] = true;

              data_recived[0] = 'Waiting';
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
            borderRadius: new BorderRadius.circular(30),
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
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            index_recive--;
            buffer.clear();

            if (index_recive == 0) {
              index_recive = 0;
              buffer.clear();

              status_result[0] = true;
              status_result[1] = true;

              data_recived[0] = 'Waiting';
              data_recived[1] = 'Waiting';
            } else if (index_recive == 1) {
              status_result[1] = true;

              data_recived[1] = 'Waiting';
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
            borderRadius: new BorderRadius.circular(30),
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
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            index_recive--;
            buffer.clear();

            if (index_recive == 0) {
              index_recive = 0;
              buffer.clear();

              status_result[0] = true;
              status_result[1] = true;
              status_result[2] = true;

              data_recived[0] = 'Waiting';
              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';
            } else if (index_recive == 1) {
              status_result[1] = true;
              status_result[2] = true;

              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';
            } else if (index_recive == 2) {
              status_result[2] = true;

              data_recived[2] = 'Waiting';
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
            borderRadius: new BorderRadius.circular(30),
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
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            index_recive--;
            buffer.clear();

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
            } else if (index_recive == 1) {
              status_result[1] = true;
              status_result[2] = true;
              status_result[3] = true;

              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';
            } else if (index_recive == 2) {
              status_result[2] = true;
              status_result[3] = true;

              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';
            } else if (index_recive == 3) {
              status_result[3] = true;
              status_result[4] = true;

              data_recived[3] = 'Waiting';
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
            borderRadius: new BorderRadius.circular(30),
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
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            //_processIndex = (_processIndex - 1) % _processes.length;
            index_recive--;
            buffer.clear();

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
            } else if (index_recive == 1) {
              status_result[1] = true;
              status_result[2] = true;
              status_result[3] = true;
              status_result[4] = true;

              data_recived[1] = 'Waiting';
              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';
              data_recived[4] = 'Waiting';
            } else if (index_recive == 2) {
              status_result[2] = true;
              status_result[3] = true;
              status_result[4] = true;

              data_recived[2] = 'Waiting';
              data_recived[3] = 'Waiting';
              data_recived[4] = 'Waiting';
            } else if (index_recive == 3) {
              status_result[3] = true;
              status_result[4] = true;

              data_recived[3] = 'Waiting';
              data_recived[4] = 'Waiting';
            } else if (index_recive == 4) {
              status_result[4] = true;

              data_recived[4] = 'Waiting';
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
            borderRadius: new BorderRadius.circular(30),
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
        width: 400,
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
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Qty',
                style: TextStyle(color: Colors.white, fontSize: 25),
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
        width: 400,
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
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Qty',
                style: TextStyle(color: Colors.white, fontSize: 25),
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
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
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
              padding: const EdgeInsets.all(20.0),
              child: Text(
                NumberFormat("#,###").format(value),
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Qty',
                style: TextStyle(color: Colors.white, fontSize: 25),
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
