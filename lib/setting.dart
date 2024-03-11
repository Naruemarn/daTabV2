//import 'dart:js';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:databv2/utility/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        title: Text('Setting'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        elevation: 50,
        leading: IconButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              save_register().then(
                (value) {
                Navigator.pop(context, [
                min1.text,
                max1.text,

                min2.text,
                max2.text,

                min3.text,
                max3.text,

                min4.text,
                max4.text,

                min5.text,
                max5.text,]);
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
              buildTitle('STEP 1'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min1),
                  build_max(size, 'Max', max1),
                ],
              ),
              buildTitle('STEP 2'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min2),
                  build_max(size, 'Max', max2),
                ],
              ),
              buildTitle('STEP 3'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min3),
                  build_max(size, 'Max', max3),
                ],
              ),
              buildTitle('STEP 4'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  build_min(size, 'Min', min4),
                  build_max(size, 'Max', max4),
                ],
              ),
              buildTitle('STEP 5'),
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
  Widget buildTitle(String msg) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        msg,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
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
                labelStyle: TextStyle(fontSize: 20),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(30)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(30)),
              ),
              style: TextStyle(fontSize: 20),
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
                labelStyle: TextStyle(fontSize: 20),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(30)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(30)),
              ),
              style: TextStyle(fontSize: 20),
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
