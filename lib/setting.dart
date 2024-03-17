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

  final List<String> items1 = [
    'Preset 1',
    'Preset 2',
    'Preset 3',
    'Preset 4',
    'Preset 5',
    'Preset 6',
    'Preset 7',
    'Preset 8',
    'Preset 9',
    'Preset 10',
  ];

  String selected_preset = 'Preset 1';


  String read_preset_selected = 'Preset 1';
  String read_preset_name = 'Preset 1';

  String read_min1='0';
  String read_min2='0';
  String read_min3='0';
  String read_min4='0';
  String read_min5='0';

  String read_max1='0';
  String read_max2='0';
  String read_max3='0';
  String read_max4='0';
  String read_max5='0';

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
              buildTitle('Preset'),

              build_dropdown_preset(size),

              buildTitle('Name'),
              build_name(size, 'Name', preset_name),
              //Divider(),
              buildTitle('POINT 1'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min1),
                  build_max(size, 'Max', max1),
                ],
              ),
              buildTitle('POINT 2'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min2),
                  build_max(size, 'Max', max2),
                ],
              ),
              buildTitle('POINT 3'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min3),
                  build_max(size, 'Max', max3),
                ],
              ),
              buildTitle('POINT 4'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min4),
                  build_max(size, 'Max', max4),
                ],
              ),
              buildTitle('POINT 5'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min5),
                  build_max(size, 'Max', max5),
                ],
              ),
            ],
          ),
        ),
      )),
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
              hint: 'Select Preset',
              value: selected_preset,
              dropdownItems: items1,
              onChanged: ((value) {
                setState(() {
                  selected_preset = value!;
                  preset_name.text = value;
                  print(selected_preset);
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

    prefs.setString('key_preset_selected', selected_preset!);
    prefs.setString('key_preset_name', preset_name.text);

    prefs.setString('key_min1', min1.text);
    prefs.setString('key_max1', max1.text);

    prefs.setString('key_min2', min2.text);
    prefs.setString('key_max2', max2.text);

    prefs.setString('key_min3', min3.text);
    prefs.setString('key_max3', max3.text);

    prefs.setString('key_min4', min4.text);
    prefs.setString('key_max4', max4.text);

    prefs.setString('key_min5', min5.text);
    prefs.setString('key_max5', max5.text);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Future<Null> read_register() async {
    prefs = await SharedPreferences.getInstance();

    read_preset_selected = prefs.getString('key_preset_selected')!;
    read_preset_name = prefs.getString('key_preset_name')!;

    read_min1 = prefs.getString('key_min1')!;
    read_max1 = prefs.getString('key_max1')!;

    read_min2 = prefs.getString('key_min2')!;
    read_max2 = prefs.getString('key_max2')!;

    read_min3 = prefs.getString('key_min3')!;
    read_max3 = prefs.getString('key_max3')!;

    read_min4 = prefs.getString('key_min4')!;
    read_max4 = prefs.getString('key_max4')!;

    read_min5 = prefs.getString('key_min5')!;
    read_max5 = prefs.getString('key_max5')!;

    setState(() {
      selected_preset = read_preset_selected.toString();
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
}
