import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Read Excel file
//List<String>? row0 = [];
List<String>? row1 = ['','','','','','','',''];
List<String>? row2 = ['','','','','','','',''];
List<String>? row3 = ['','','','','','','',''];
List<String>? row4 = ['','','','','','','',''];
List<String>? row5 = ['','','','','','','',''];

class ShowExcelPage extends StatefulWidget {
  final String? filename;

  const ShowExcelPage({
    Key? key,
    this.filename,
  }) : super(key: key);

  @override
  State<ShowExcelPage> createState() => _ShowExcelPageState();
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class _ShowExcelPageState extends State<ShowExcelPage> {
  @override
  void initState() {
    super.initState();

    String filepath ='/storage/emulated/0/Download/' + widget.filename.toString();
    excel_read(filepath);
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filename.toString(),
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: true,
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       String filepath ='/storage/emulated/0/Download/' + widget.filename.toString();
        //       excel_read(filepath);
        //     },
        //     icon: const Icon(
        //       Icons.file_copy_sharp,
        //     ),
        //   ),
        // ],
      ),
      body: Center(child: SafeArea(child:  row5!.isEmpty ?  CircularProgressIndicator() : build_table(size),),),
    );
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget build_table(double size) {
    return Container(
      width: size * 0.8,
      child: Table(
        border: TableBorder.all(),
        columnWidths: {
          0: FractionColumnWidth(0.25),
          1: FractionColumnWidth(0.15),
          2: FractionColumnWidth(0.15),
          3: FractionColumnWidth(0.15),
          4: FractionColumnWidth(0.15),
          5: FractionColumnWidth(0.15),
        },
        children: [
          buildRow(['List', 'Point1', 'Point2', 'Point3', 'Point4', 'Point5'],
              isHeader: true),
          buildRow(
              ['ST MAX', row1![0], row2![0], row3![0], row4![0], row5![0]]),
          buildRow(
              ['ST MIN', row1![1], row2![1], row3![1], row4![1], row5![1]]),
          buildRow(['MAX', row1![2], row2![2], row3![2], row4![2], row5![2]]),
          buildRow(['MIN', row1![3], row2![3], row3![3], row4![3], row5![3]]),
          buildRow(
              ['AVERAGE', row1![4], row2![4], row3![4], row4![4], row5![4]]),
          buildRow(
              ['ST DEV', row1![5], row2![5], row3![5], row4![5], row5![5]]),
          buildRow(['Cp', row1![6], row2![6], row3![6], row4![6], row5![6]]),
          buildRow(['Cpk', row1![7], row2![7], row3![7], row4![7], row5![7]]),
        ],
      ),
    );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  TableRow buildRow(List<String> cells, {bool isHeader = false}) => TableRow(
        decoration: isHeader
            ? BoxDecoration(color: Colors.teal)
            : BoxDecoration(color: Colors.white),
        children: cells.map((cell) {
          final style = TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 28,
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
  Future<void> excel_read(String filepath) async {
    var res = await Permission.storage.request();
    File InputFile = File((filepath));
    if (res.isGranted) {
      print('Permission OK Read Mode');
    }

    List<int> bytes = await (InputFile).readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    row1?.clear();
    row2?.clear();
    row3?.clear();
    row4?.clear();
    row5?.clear();

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        //row0.add(row[0]?.value.toString() ?? "");
        row1?.add(row[1]?.value.toString() ?? "");
        row2?.add(row[2]?.value.toString() ?? "");
        row3?.add(row[3]?.value.toString() ?? "");
        row4?.add(row[4]?.value.toString() ?? "");
        row5?.add(row[5]?.value.toString() ?? "");
      }
    }

    // Remove Header and Min max avg cp cpk ...
    row1?.removeAt(0);
    row2?.removeAt(0);
    row3?.removeAt(0);
    row4?.removeAt(0);
    row5?.removeAt(0);

    setState(() {
      row1 ?? "";
      row2 ?? "";
      row3 ?? "";
      row4 ?? "";
      row5 ?? "";
    });

    //print(' Row  1 --------------> ${row0}');
    print(
        ' Point1 --------------> ${row1?[0]}  ${row1?[0]}  ${row1?[1]}  ${row1?[2]}  ${row1?[3]}  ${row1?[4]}  ${row1?[5]}  ${row1?[6]}  ${row1?[7]}');
    print(
        ' Point2 --------------> ${row2?[0]}  ${row2?[0]}  ${row2?[1]}  ${row2?[2]}  ${row2?[3]}  ${row2?[4]}  ${row2?[5]}  ${row2?[6]}  ${row2?[7]}');
    print(
        ' Point3 --------------> ${row3?[0]}  ${row3?[0]}  ${row3?[1]}  ${row3?[2]}  ${row3?[3]}  ${row3?[4]}  ${row3?[5]}  ${row3?[6]}  ${row3?[7]}');
    print(
        ' Point4 --------------> ${row4?[0]}  ${row4?[0]}  ${row4?[1]}  ${row4?[2]}  ${row4?[3]}  ${row4?[4]}  ${row4?[5]}  ${row4?[6]}  ${row4?[7]}');
    print(
        ' Point5 --------------> ${row5?[0]}  ${row5?[0]}  ${row5?[1]}  ${row5?[2]}  ${row5?[3]}  ${row5?[4]}  ${row5?[5]}  ${row5?[6]}  ${row5?[7]}');
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
}
