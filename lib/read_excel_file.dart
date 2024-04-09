import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';



//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class ReadExcelPage extends StatefulWidget {
  final filename;
  const ReadExcelPage({super.key, this.filename});

  @override
  State<ReadExcelPage> createState() => _ReadExcelPageState();
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class _ReadExcelPageState extends State<ReadExcelPage> {
  List<MyExcelTable> excelList = <MyExcelTable>[];
  late ExcelDataSource excelDataSource;
  bool isReady=false;

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
    var sheet1 = excel['Sheet1'];
    

    

    

    for (var table in excel.tables.keys) {
      print('Max Column: ' + excel.tables[table]!.maxColumns.toString());
      print('Max Rows: ' + excel.tables[table]!.maxRows.toString());
      for (int rowIndex = 11; rowIndex < excel.tables[table]!.maxRows; rowIndex++) {
        
        var excelfileDetails = new MyExcelTable();
        

        excelfileDetails.Timestamp = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value.toString();
        //print('Timestamp: ${excelfileDetails.Timestamp}');

        excelfileDetails.Point1 = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value.toString();
        //print('Point1: ${excelfileDetails.Point1}');

        excelfileDetails.Point2 = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value.toString();
        //print('Point2: ${excelfileDetails.Point2}');

        excelfileDetails.Point3 = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value.toString();
        //print('Point3: ${excelfileDetails.Point3}');

        excelfileDetails.Point4 = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value.toString();
        //print('Point4: ${excelfileDetails.Point4}');

        excelfileDetails.Point5 = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value.toString();
        //print('Point5: ${excelfileDetails.Point5}');

        excelfileDetails.Judge = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value.toString();
        //print('Judge: ${excelfileDetails.Judge}');


        excelList.add(excelfileDetails);

        
      }
    }

    print('Excel: ${excelList.toString()}');


    setState(() {
      excelDataSource = ExcelDataSource(excelData: excelList);
      isReady = true;
    });
   

    
    
  }

  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  @override
  void initState() {
 
    super.initState();

    String filepath = '/storage/emulated/0/Download/' + widget.filename.toString();
    //String filepath = '/storage/emulated/0/Download/Presset5Product5_2024-03-31.xlsx';
    excel_read(filepath);

    
    excelDataSource = ExcelDataSource(excelData: excelList);

    
  }

  @override
  Widget build(BuildContext context) {
    //double size = MediaQuery.of(context).size.width;
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
      body: Center(
        child: SafeArea(
          child: isReady? build_datagridview(): CircularProgressIndicator(color: Colors.teal,),
        ),
      ),
    );
  }

  SfDataGrid build_datagridview() {
    return SfDataGrid(
          allowSorting: true,          
          source: excelDataSource,
          loadMoreViewBuilder: _buildLoadMoreView,
          selectionMode: SelectionMode.single,
          columnWidthMode: ColumnWidthMode.fill,
          columns: <GridColumn>[
            GridColumn(
                columnName: 'Timestamp',
                label: Container(
                    padding: EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Timestamp',
                    ))),
            GridColumn(
                columnName: 'Point1',
                label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Point1'))),
            GridColumn(
                columnName: 'Point2',
                label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Point2',
                      overflow: TextOverflow.ellipsis,
                    ))),
            GridColumn(
                columnName: 'Point3',
                label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Point3'))),
            GridColumn(
                columnName: 'Point4',
                label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Point4'))),
            GridColumn(
                columnName: 'Point5',
                label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Point5'))),
            GridColumn(
                columnName: 'Judge',
                label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Judge'))),
          ],
        );
  }
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Widget _buildProgressIndicator() {
    return Container(
        height: 60.0,
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
            border: BorderDirectional(
                top: BorderSide(
          width: 1.0,
        ))),
        child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Container(
                child: CircularProgressIndicator(
              backgroundColor: Colors.transparent,
            ))));
  }
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Widget _buildLoadMoreView(BuildContext context, LoadMoreRows loadMoreRows) {
    Future<String> loadRows() async {
      // Call the loadMoreRows function to call the
      // DataGridSource.handleLoadMoreRows method. So, additional
      // rows can be added from handleLoadMoreRows method.
      await loadMoreRows();
      return Future<String>.value('Completed');
    }
 
    return FutureBuilder<String>(
      initialData: 'Loading',
      future: loadRows(),
      builder: (context, snapShot) {
        return snapShot.data == 'Loading'
            ? _buildProgressIndicator()
            : SizedBox.fromSize(size: Size.zero);
      },
    );
  }
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class ExcelDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  ExcelDataSource({required List<MyExcelTable> excelData}) {
    _excelData = excelData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'Timestamp', value: e.Timestamp),
              DataGridCell<String>(columnName: 'Point1', value: e.Point1),
              DataGridCell<String>(columnName: 'Point2', value: e.Point2),
              DataGridCell<String>(columnName: 'Point3', value: e.Point3),
              DataGridCell<String>(columnName: 'Point4', value: e.Point4),
              DataGridCell<String>(columnName: 'Point5', value: e.Point5),
              DataGridCell<String>(columnName: 'Judge', value: e.Judge),

            ]))
        .toList();
  }

  List<DataGridRow> _excelData = [];

  @override
  List<DataGridRow> get rows => _excelData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}

class MyExcelTable {
  var Timestamp;
  var Point1;
  var Point2;
  var Point3;
  var Point4;
  var Point5;
  var Judge;

  MyExcelTable(
      {this.Timestamp,
      this.Point1,
      this.Point2,
      this.Point3,
      this.Point4,
      this.Point5,
      this.Judge});

      @override
  String toString() {
    return '\r\nMyExcelTable: {Timestamp: ${Timestamp}, Point1: ${Point1}, Point2: ${Point2}, Point3: ${Point3}, Point4: ${Point4}, Point5: ${Point5}, Judge: ${Judge}}';
  }
}
