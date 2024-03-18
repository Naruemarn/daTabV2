//import 'dart:js';

//import 'dart:js_util';
import 'dart:math';

import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:databv2/utility/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final formKey = GlobalKey<FormState>();

  late SharedPreferences prefs;

  TextEditingController preset_name = TextEditingController();

  TextEditingController min1 = TextEditingController();
  TextEditingController max1 = TextEditingController();

  TextEditingController min2 = TextEditingController();

  TextEditingController max2 = TextEditingController();

  TextEditingController min3 = TextEditingController();
  TextEditingController max3 = TextEditingController();

  TextEditingController min4 = TextEditingController();
  TextEditingController max4 = TextEditingController();

  TextEditingController min5 = TextEditingController();
  TextEditingController max5 = TextEditingController();

  List<String> items1 = [
    'Preset1',
    'Preset2',
    'Preset3',
    'Preset4',
    'Preset5',
    'Preset6',
    'Preset7',
    'Preset8',
    'Preset9',
    'Preset10',
  ];

  List<String> items2 = [
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  String selected_point = '1';
  String selected_preset = 'Preset1';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    read_register();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         //if (formKey.currentState!.validate()) {
        //         read_register();
        //         //}
        //       },
        //       icon: Icon(
        //         Icons.save,
        //         size: 40,
        //       ))
        // ],
        title: Text(
          'Preset',
          style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        elevation: 50,
        leading: IconButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              save_register().then((value) {
                Navigator.pop(context, [
                  selected_point,
                  selected_preset,
                  preset_name.text,
                  min1.text,
                  max1.text,
                  min2.text,
                  max2.text,
                  min3.text,
                  max3.text,
                  min4.text,
                  max4.text,
                  min5.text,
                  max5.text,
                ]);
              });
            }
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
          child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(
          FocusNode(),
        ),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              build_dropdown_point_preset(size),
              buildTitle('Name'),
              build_name(size, 'Name', preset_name),
              if (selected_point == '1') ...[
                buildTitle('POINT 1'),
                build_minmax1(size),
              ],
              if (selected_point == '2') ...[
                buildTitle('POINT 1'),
                build_minmax1(size),
                buildTitle('POINT 2'),
                build_minmax2(size),
              ],
              if (selected_point == '3') ...[
                buildTitle('POINT 1'),
                build_minmax1(size),
                buildTitle('POINT 2'),
                build_minmax2(size),
                buildTitle('POINT 3'),
                build_minmax3(size),
              ],
              if (selected_point == '4') ...[
                buildTitle('POINT 1'),
                build_minmax1(size),
                buildTitle('POINT 2'),
                build_minmax2(size),
                buildTitle('POINT 3'),
                build_minmax3(size),
                buildTitle('POINT 4'),
                build_minmax4(size),
              ],
              if (selected_point == '5') ...[
                buildTitle('POINT 1'),
                build_minmax1(size),
                buildTitle('POINT 2'),
                build_minmax2(size),
                buildTitle('POINT 3'),
                build_minmax3(size),
                buildTitle('POINT 4'),
                build_minmax4(size),
                buildTitle('POINT 5'),
                build_minmax5(size),
              ],
            ],
          ),
        ),
      )),
    );
  }

  Row build_minmax5(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        build_min(size, 'Min', min5),
        build_max(size, 'Max', max5),
      ],
    );
  }

  Row build_minmax4(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        build_min(size, 'Min', min4),
        build_max(size, 'Max', max4),
      ],
    );
  }

  Row build_minmax3(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        build_min(size, 'Min', min3),
        build_max(size, 'Max', max3),
      ],
    );
  }

  Row build_minmax2(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        build_min(size, 'Min', min2),
        build_max(size, 'Max', max2),
      ],
    );
  }

  Row build_minmax1(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        build_min(size, 'Min', min1),
        build_max(size, 'Max', max1),
      ],
    );
  }

  Padding build_dropdown_point_preset(double size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Column(
            children: [
              buildTitle('Select Point 1-5'),
              build_dropdown_point(size),
            ],
          ),
          Column(
            children: [
              buildTitle('Select Preset 1-10'),
              build_dropdown_preset(size),
            ],
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget build_dropdown_point(double size) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        child: Row(
          children: [
            CustomDropdownButton2(
              hint: 'Select point 1-5',
              value: selected_point,
              dropdownItems: items2,
              onChanged: ((value) {
                setState(() {
                  selected_point = value!;
                  print(selected_point);
                  read_register_select_dropdown();
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget build_dropdown_preset(double size) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        child: Row(
          children: [
            CustomDropdownButton2(
              hint: 'Select Preset 1-10',
              value: selected_preset,
              dropdownItems: items1,
              onChanged: ((value) {
                setState(() {
                  selected_preset = value!;
                  print(selected_preset);
                  read_register_select_dropdown();
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget buildTitle(String msg) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        msg,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget build_name(double size, String txt, TextEditingController inputbox) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            //margin: EdgeInsets.only(top: 8),
            width: size * 0.513,
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please fill preset name';
                } else {
                  return null;
                }
              },
              //keyboardType: TextInputType.text,
              controller: inputbox,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: txt,
                labelStyle: TextStyle(fontSize: 15),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(15)),
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget build_min(double size, String txt, TextEditingController inputbox) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //margin: EdgeInsets.only(top: 8),
            width: size * 0.25,
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please fill min value';
                } else {
                  return null;
                }
              },
              keyboardType: TextInputType.number,
              controller: inputbox,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: txt,
                labelStyle: TextStyle(fontSize: 15),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(15)),
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget build_max(double size, String txt, TextEditingController inputbox) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //margin: EdgeInsets.only(top: 8),
            width: size * 0.25,
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please fill max value';
                } else {
                  return null;
                }
              },
              keyboardType: TextInputType.number,
              controller: inputbox,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: txt,
                labelStyle: TextStyle(fontSize: 15),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(15)),
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<Null> save_register() async {
    prefs = await SharedPreferences.getInstance();

    prefs.setString('key_point_selected', selected_point);
    prefs.setString('key_preset_selected', selected_preset);

    prefs.setString('key_preset_name_' + selected_preset, preset_name.text);

    prefs.setString('key_min1_' + selected_preset, min1.text);
    prefs.setString('key_max1_' + selected_preset, max1.text);

    prefs.setString('key_min2_' + selected_preset, min2.text);
    prefs.setString('key_max2_' + selected_preset, max2.text);

    prefs.setString('key_min3_' + selected_preset, min3.text);
    prefs.setString('key_max3_' + selected_preset, max3.text);

    prefs.setString('key_min4_' + selected_preset, min4.text);
    prefs.setString('key_max4_' + selected_preset, max4.text);

    prefs.setString('key_min5_' + selected_preset, min5.text);
    prefs.setString('key_max5_' + selected_preset, max5.text);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<Null> read_register() async {
    prefs = await SharedPreferences.getInstance();

    read_point_selected = prefs.getString('key_point_selected')!;
    print(
        '---------------- Dropdown Point Selected is ------------------------>   $read_preset_selected');

    read_preset_selected = prefs.getString('key_preset_selected')!;
    print(
        '---------------- Dropdown Preset Selected is ------------------------>   $read_preset_selected');

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

    setState(() {
      selected_point = read_point_selected.toString();

      if (read_preset_selected.toString() == '0') {
        selected_preset = 'Preset1';
      } else {
        selected_preset = read_preset_selected.toString();
      }

      preset_name.text = read_preset_name.toString();

      min1.text = read_min1.toString();
      max1.text = read_max1.toString();

      min2.text = read_min2.toString();
      max2.text = read_max2.toString();

      min3.text = read_min3.toString();
      max3.text = read_max3.toString();

      min4.text = read_min4.toString();
      max4.text = read_max4.toString();

      min5.text = read_min5.toString();
      max5.text = read_max5.toString();
    });

    print('Setting Preset Page');
    print('Point selected = $read_point_selected');
    print('Pset selected = $read_preset_selected');
    print('Pset name = $read_preset_name');

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
  Future<Null> read_register_select_dropdown() async {
    prefs = await SharedPreferences.getInstance();

    read_preset_name =
        prefs.getString('key_preset_name_' + selected_preset.toString())!;

    read_min1 = prefs.getString('key_min1_' + selected_preset.toString())!;
    read_max1 = prefs.getString('key_max1_' + selected_preset.toString())!;

    read_min2 = prefs.getString('key_min2_' + selected_preset.toString())!;
    read_max2 = prefs.getString('key_max2_' + selected_preset.toString())!;

    read_min3 = prefs.getString('key_min3_' + selected_preset.toString())!;
    read_max3 = prefs.getString('key_max3_' + selected_preset.toString())!;

    read_min4 = prefs.getString('key_min4_' + selected_preset.toString())!;
    read_max4 = prefs.getString('key_max4_' + selected_preset.toString())!;

    read_min5 = prefs.getString('key_min5_' + selected_preset.toString())!;
    read_max5 = prefs.getString('key_max5_' + selected_preset.toString())!;

    setState(() {
      preset_name.text = read_preset_name.toString();

      min1.text = read_min1.toString();
      max1.text = read_max1.toString();

      min2.text = read_min2.toString();
      max2.text = read_max2.toString();

      min3.text = read_min3.toString();
      max3.text = read_max3.toString();

      min4.text = read_min4.toString();
      max4.text = read_max4.toString();

      min5.text = read_min5.toString();
      max5.text = read_max5.toString();
    });

    print('Product name = $read_preset_name');

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
}
