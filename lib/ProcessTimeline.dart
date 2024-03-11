import 'dart:async';
import 'dart:math';

import 'package:databv2/setting.dart';
import 'package:databv2/utility/my_constant.dart';
import 'package:databv2/widgets/show_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines/timelines.dart';

late SharedPreferences prefs;

late String? read_min1;
late String? read_min2;
late String? read_min3;
late String? read_min4;
late String? read_min5;

late String? read_max1;
late String? read_max2;
late String? read_max3;
late String? read_max4;
late String? read_max5;

const kTileHeight = 50.0;

// const completeColor = Color(0xff5e6172);
// const inProgressColor = Color(0xff5ec792);
// const todoColor = Color(0xffd1d2d7);

const inProgressColor = Colors.orange;
const completeColor = Colors.green;
const todoColor = Colors.grey;

int? cnt_ok;
int? cnt_ng;
int? cnt_total;

String timenow = '';

class ProcessTimelinePage extends StatefulWidget {
  @override
  _ProcessTimelinePageState createState() => _ProcessTimelinePageState();
}

class _ProcessTimelinePageState extends State<ProcessTimelinePage> {
  int _processIndex = 0;

  final status_result = [true, false, true, false, true];
  final _processes = [
    '100.1234',
    '200.1234',
    '300.1234',
    '400.1234',
    '500.1234',
  ];
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void gettime() {
    final DateTime now = DateTime.now();

    setState(() {
      timenow = DateFormat('yyyy-mm-dd HH:mm:ss ').format(now);
    });
  }
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Future<Null> read_setting() async {
    prefs = await SharedPreferences.getInstance();

    read_min1 = prefs.getString('key_min1');
    read_max1 = prefs.getString('key_max1');

    read_min2 = prefs.getString('key_min2');
    read_max2 = prefs.getString('key_max2');

    read_min3 = prefs.getString('key_min3');
    read_max3 = prefs.getString('key_max3');

    read_min4 = prefs.getString('key_min4');
    read_max4 = prefs.getString('key_max4');

    read_min5 = prefs.getString('key_min5');
    read_max5 = prefs.getString('key_max5');

    setState(() {
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
    // TODO: implement initState
    super.initState();

    read_setting();
    read_counter();
    
    DateTime now = new DateTime.now();
    timenow = DateFormat('yyyy-mm-dd HH:mm:ss ').format(now);
    Timer.periodic(Duration(seconds: 1), (Timer t) => gettime());
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        //leading: Image.asset('asset/images/logo.png', fit: BoxFit.cover),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              MyConstant.logo_appbar,
              scale: 3,
            ),
            const SizedBox(
              width: 10,
            ),
            // (Text(
            //   MyConstant.appName,
            //   style: const TextStyle(
            //       fontSize: 50,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.white),
            // )),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () async {
                //Navigator.pushNamed(context, MyConstant.routeSetting);
                final List<String> get_setting =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SettingPage(),
                  ),
                );

                setState(() {
                  read_min1 = get_setting[0];
                  read_max1 = get_setting[1];

                  read_min2 = get_setting[2];
                  read_max2 = get_setting[3];

                  read_min3 = get_setting[4];
                  read_max3 = get_setting[5];

                  read_min4 = get_setting[6];
                  read_max4 = get_setting[7];

                  read_min5 = get_setting[8];
                  read_max5 = get_setting[9];

                  print(
                      'Return Setting ==> $read_min1  $read_max1  $read_min2  $read_max2  $read_min3  $read_max3  $read_min4  $read_max4  $read_min5  $read_max5');
                });

                //read_register();
              },
              icon: const Icon(
                Icons.settings,
                size: 35,
              ))
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            //color: Colors.grey[200],
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
                    MediaQuery.of(context).size.width / _processes.length,
                oppositeContentsBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Image.asset(
                      'assets/images/process_timeline/step${index + 1}.png',
                      width: 50.0,
                      color: getColor(index),
                    ),
                  );
                },
                contentsBuilder: (context, index) {
                  if (status_result[index]) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        _processes[index],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.green),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        _processes[index],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.red),
                      ),
                    );
                  }
                },
                indicatorBuilder: (_, index) {
                  var color;
                  var child;

                  if (index == _processIndex) {
                    color = inProgressColor;
                    child = Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    );
                  } else if (index < _processIndex) {
                    color = completeColor;
                    child = Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15.0,
                    );
                  } else {
                    color = todoColor;
                  }

                  if (index <= _processIndex) {
                    return Stack(
                      children: [
                        // CustomPaint(
                        //   size: Size(30.0, 30.0),
                        //   painter: _BezierPainter(
                        //     color: color,
                        //     drawStart: index > 0,
                        //     drawEnd: index < _processIndex,
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
                            drawEnd: index < _processes.length - 1,
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
                    if (index == _processIndex) {
                      final prevColor = getColor(index - 1);
                      final color = getColor(index);
                      List<Color> gradientColors;
                      if (type == ConnectorType.start) {
                        gradientColors = [
                          Color.lerp(prevColor, color, 0.5)!,
                          color
                        ];
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
                itemCount: _processes.length,
              ),
            ),
          ),
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
                        show_timenow(),
                        build_ok_counter(cnt_ok!),
                        build_ng_counter(cnt_ng!),
                        build_total_counter(cnt_total!),
                        reset_button(),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      //padding: EdgeInsets.symmetric(vertical: 16),
                      width: size * 0.25,
                      //color: Colors.yellow,
                      child: ShowImage(path: MyConstant.image_wait),
                    ),
                    Container(
                      //color: Colors.amber,
                      child: Text(
                        'Result',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      width: size * 0.1,
                      //color: Colors.purple,
                      child: Table(
                        border: TableBorder.all(),
                        columnWidths: {
                          0: FractionColumnWidth(0.15),
                          1: FractionColumnWidth(0.25),
                          2: FractionColumnWidth(0.25),
                          3: FractionColumnWidth(0.25),
                        },
                        children: [
                          buildRow(['Step', 'Min', 'Result', 'Max'],
                              isHeader: true),
                          buildRow(['1', read_min1.toString(), 'x', read_max1.toString()]),
                          buildRow(['2', read_min2.toString(), 'xx', read_max2.toString()]),
                          buildRow(['3', read_min3.toString(), 'xxx', read_max3.toString()]),
                          buildRow(['4', read_min4.toString(), 'xxxx', read_max4.toString()]),
                          buildRow(['5', read_min5.toString(), 'xxxxx', read_max5.toString()]),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          retry_button(),
          SizedBox(width: 20),
          save_button(),
        ],
      ),
    );
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
  Text show_timenow() {
    return Text(
      timenow,
      style: TextStyle(fontSize: 20, color: Colors.teal),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget reset_button() {
    return Container(
      //color: Colors.red,
      width: 150,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          confirm_popup();
        },
        icon: Icon(Icons.clear_outlined),
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
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget save_button() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            //_processIndex = (_processIndex + 1) % _processes.length;
            cnt_ok=1234;
            cnt_ng=5678;
            cnt_total=9999;
            save_count();
          });
        },
        icon: Icon(Icons.save_as_outlined, size: 50),
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
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget retry_button() {
    return Container(
      //color: Colors.red,
      width: 200,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _processIndex = (_processIndex - 1) % _processes.length;
          });
        },
        icon: Icon(Icons.refresh, size: 50),
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
                NumberFormat("#,###").format(value) + ' Qty',
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
                NumberFormat("#,###").format(value) + ' Qty',
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
      color: Colors.grey,
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
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                NumberFormat("#,###").format(value) + ' Qty',
                style: TextStyle(color: Colors.white, fontSize: 30),
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

  TableRow buildRow(List<String> cells, {bool isHeader = false}) => TableRow(
        decoration: isHeader
            ? BoxDecoration(color: Colors.teal)
            : BoxDecoration(color: Colors.white),
        children: cells.map((cell) {
          final style = TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 18,
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
