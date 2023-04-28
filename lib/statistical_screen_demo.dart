import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:opc_app_main/api_call_statistics.dart';
import 'package:opc_app_main/main_screen.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

enum LoadState { loading, success, error }

LoadState loadState = LoadState.loading;
class ViewScreen extends StatefulWidget{
  @override 
  _ViewScreenState createState()=> _ViewScreenState();
}
class _ViewScreenState extends State<ViewScreen>{
    double totalGrossAmt = 0; // thêm biến tổng
  double totalPhien = 0;
  double totalHD2 = 0;
  double totalHH04 = 0;
  double total = 0.0;
  double KeHoach = 0.0;
    double totalRevenue = 0.0;
  double totalPlan = 0.0;
   String TDV = '';
    List<BieuDo> dataBD = [];
   late List<_SalesData> data1 = [];
    late TextEditingController _startDateController;
    late TextEditingController _endDateController;
     List<Results> data = [];
    List<Results> filteredData = [];
        var maCbNV;
          List<Results> removeDuplicates(List<Results> list) {
    Map<String, Results> map = {};

    for (Results item in list) {
      map[item.cDOCUUID!] = item;
    }
    return map.values.toList();
  }

  void handleDateRange() {
  DateTime startDate = DateTime.parse(_startDateController.text);
  DateTime endDate = DateTime.parse(_endDateController.text);
  
  int startDay = startDate.day; // lấy giá trị ngày bắt đầu
  int startMonth = startDate.month; // lấy giá trị tháng bắt đầu
  int startYear = startDate.year; // lấy giá trị năm bắt đầu
  
  int endDay = endDate.day; // lấy giá trị ngày kết thúc
  int endMonth = endDate.month; // lấy giá trị tháng kết thúc
  int endYear = endDate.year; // lấy giá trị năm kết thúc
  
  print('Ngày bắt đầu: $startDay, Tháng bắt đầu: $startMonth, Năm bắt đầu: $startYear');
  print('Ngày kết thúc: $endDay, Tháng kết thúc: $endMonth, Năm kết thúc: $endYear');
}

//Doanh thu
  Future<void> fetchData1(int startDay, int startMonth, int startYear, int endDay, int endMonth, int endYear) async {
      String startDateString = '$startYear-${startMonth.toString().padLeft(2, '0')}-${startDay.toString().padLeft(2, '0')}T00:00:00';
  String endDateString = '$endYear-${endMonth.toString().padLeft(2, '0')}-${endDay.toString().padLeft(2, '0')}T00:00:00';

    // Khởi tạo biến progress và loaded
    bool loaded = false;
    double progress = 0.0;

    // Lấy SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      progress = 0.01;
    });
    // Lấy mã cán bộ nhân viên từ SharedPreferences
    String? maCbNv = prefs.getString('maCbNv');
    if (maCbNv != null) {
      maCbNV = maCbNv;
      print("Mã được in ra của API 2 là: " + maCbNv);
      // Tiếp tục xử lý dữ liệu
    } else {
      // Xử lý lỗi
      print('Không tìm thấy mã cán bộ nhân viên!');
    }
    var _ci = 'CI';
    // Thực hiện tải dữ liệu từ API

    final String url =
      "https://my431086.businessbydesign.cloud.sap/sap/byd/odata/ana_businessanalytics_analytics.svc/RPCRMCIVIB_Q0001QueryResults?\$select=CDOC_YEAR,CDOC_CREATED_DT,KCINV_QTY,CIPR_REFO_CATCP,CIPR_PROD_UUID,TIPR_PROD_UUID,KKITM_NET_AM_RC,TIPR_REFO_CATCP,CIPR_REFO_PRDTY,TIPR_REFO_PRDTY,CIP_SAL_EMP,TIP_SAL_EMP,CDOC_UUID,CDOC_PROC_TYPE,CDPY_BUYER_UUID,TDPY_BUYER_UUID,CDOC_INV_DATE,CDOC_YEAR_MONTH,KCNT_REVENUE,KCNT_VAL_INV,KKITM_GROSS_AMT&\$format=json&\$filter=PARA_CAL_DAY gt datetime'$startDateString'  &\$filter=PARA_CAL_DAY lt datetime'$endDateString'  and CIP_SAL_EMP eq "+"'"+maCbNV+"'"+" and CDOC_PROC_TYPE eq'CI' and (CDOC_INV_DATE ge datetime'$startDateString' and CDOC_INV_DATE le datetime'$endDateString')&\$top=200&\$skip=0";
    //print("Mã được in ra của API 2 là: " + maCbNv!);
    final username = "OPCIT";
    final password = "Welcome1";
    final credentials = base64Encode(utf8.encode('$username:$password'));
    final headers = {
      'Authorization': 'Basic $credentials',
      'User-Agent': 'MyApp/1.0',
      'Accept': 'application/json'
    };
    final response =
        await http.get(Uri.parse(Uri.encodeFull(url)), headers: headers);

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      var results = decodedJson['d']['results'];

      List<BieuDo> newData = [];

      for (int i = 0; i <= results.length; i++) {
        var customerJson = results[i];
        newData.add(BieuDo.fromJson(customerJson));
        TDV = newData[i].tIPSALEMP.toString();
   totalPlan += double.parse(newData[i].kKITMGROSSAMT.toString());
        // tính tổng giá trị KKITM_GROSS_AMT nếu mã bắt đầu bằng TP02 hoặc TP05
        if (customerJson['CIPR_REFO_CATCP'].startsWith('TP02') ||
            customerJson['CIPR_REFO_CATCP'].startsWith('TP05') ||
            customerJson['CIPR_REFO_CATCP'].startsWith('TP07')) {
          totalGrossAmt += double.parse(customerJson['KKITM_GROSS_AMT']);
        }
        if (customerJson['CIPR_REFO_CATCP'].startsWith('HH04')) {
          // nếu mã bắt đầu bằng HH04
          totalHH04 += double.parse(
              customerJson['KKITM_GROSS_AMT']); // tính tổng riêng cho HH04
        }
        if (customerJson['CIPR_REFO_CATCP'].startsWith('HD2')) {
          // nếu mã bắt đầu bằng HD2
          totalHD2 += double.parse(
              customerJson['KKITM_GROSS_AMT']); // tính tổng riêng cho HD2
        }
        if (customerJson['CIPR_REFO_CATCP'].startsWith('TP08') &&
            customerJson['CIPR_REFO_CATCP'].startsWith('TP09')) {
          // nếu mã bắt đầu bằng TP08 hoặc TP09
          totalPhien += double.parse(
              customerJson['KKITM_GROSS_AMT']); // tính tổng riêng cho Phien
        }
      }

      data1 = [
        _SalesData('OPC', totalGrossAmt),
        _SalesData('Cồn', totalHH04),
        _SalesData('HD2', totalHD2),
        _SalesData('Phiến tỷ trọng theo loại sản phẩm', totalPhien),
      ];
// in giá trị tổng ra để kiểm tra
      print('Total OPC: $totalGrossAmt');
      print('Total OPC_BD: $totalHH04');
      print('Total HD2: $totalHD2');
      print('Total Phien: $totalPhien');

      List<BieuDo> oldData = dataBD;
      List<BieuDo> mergedData = [...oldData, ...newData];

// Loại bỏ các phần tử trùng lặp bằng cách sử dụng index của các phần tử
      List<BieuDo> filteredDataBD = mergedData.toList().toSet().toList();

      setState(() {
        dataBD = filteredDataBD;
        // loadState = LoadState.success; // cập nhật trạng thái thành công

        for (var data in dataBD) {
          if (data.cIPRREFOCATCP!.startsWith('TP02') ||
              data.cIPRREFOCATCP!.startsWith('TP05')) {
            total += double.parse(data.kKITMGROSSAMT ?? '0');
          }
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

 @override
  void initState() {
    super.initState();
    // fetchData().catchError((error) {
    //   setState(() {
    //     loadState = LoadState.error; // cập nhật trạng thái lỗi
    //   });
    // });
    // fetchData1().catchError((error) {
    //   setState(() {
    //     // loadState = LoadState.error; // cập nhật trạng thái lỗi
    //   });
    // });
    // fetchData2().catchError((error) {
    //   setState(() {
    //     loadState = LoadState.error; // cập nhật trạng thái lỗi
    //   });
    // });
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

@override 
Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(onPressed: (){
            Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePageMain(isLoggedIn: true,)),
                    );
          },
          icon: Icon(Icons.arrow_back),), 
          Text('Doanh thu TDV',)
        ],
      )
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime(1900, 1, 1),
                        maxTime: DateTime.now(),
                        onConfirm: (date) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(date);
                          _startDateController.text = formattedDate;
                        },
                        locale: LocaleType.vi,
                      );
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: TextStyle(fontSize: 10),
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Ngày bắt đầu',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime(1900, 1, 1),
                        maxTime: DateTime.now(),
                        onConfirm: (date) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(date);
                          _endDateController.text = formattedDate;
                        },
                        locale: LocaleType.vi,
                      );
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: TextStyle(fontSize: 10),
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: 'Ngày kết thúc',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width:16,
                ),
                Expanded(child:
                 Container(
                  child: OutlinedButton(
                   style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(60, 50), //<-- SEE HERE
                  ),
                    child: Text('Xem',style: TextStyle(color: Colors.white)),
                    onPressed: (){
                        handleDateRange();
                        
                          
                    },
                  ),
                ))
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Text(
                            "Trình dược viên",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontFamily: 'Labrada'),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            "Doanh thu",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontFamily: 'Labrada'),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            "Kế hoạch",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontFamily: 'Labrada'),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            "Tỷ lệ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontFamily: 'Labrada'),
                          ),
                        ),
                      ],
                    ),
                    TableRow(children: [
                      TableCell(
                        child: Text(TDV.toString(),
                            style: TextStyle(fontFamily: 'Amiri')),
                      ),
                      TableCell(
                        child: Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '₫',
                            ).format(totalPlan),
                            style: TextStyle(fontFamily: 'Amiri')),
                        // child: Text(
                        //   totalPlan.toString(),
                        // ),
                      ),
                      TableCell(
                        child: Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '₫',
                            ).format(KeHoach),
                            style: TextStyle(fontFamily: 'Amiri')),
                        // child: Text(
                        //   totalRevenue.toString(),
                        // ),
                      ),
                      TableCell(
                        child: Text(
                            (totalPlan / KeHoach * 100).toStringAsFixed(2) +
                                "%",
                            style: TextStyle(fontFamily: 'Amiri')),
//             TableCell(
//   child: Text((double.parse(filteredData[i].kCNTREVENUE) / double.parse(filteredData[i].kKITMGROSSAMT) * 100).toStringAsFixed(2)),
                      )
                    ]),

//                 for (int i = 0; i < dataBD.length; i++)
//                   TableRow(children: [
//                     TableCell(
//                       child: Text('Total Cồn:' + NumberFormat.currency(
//                           locale: 'vi_VN',
//                           symbol: '₫',
//                         ).format(totalHH04),),
//                     ),
//                     TableCell(
//                       child: Text('Total HD2:' + NumberFormat.currency(
//                           locale: 'vi_VN',
//                           symbol: '₫',
//                         ).format(totalHD2),),
//                       // child: Text(
//                       //   totalPlan.toString(),
//                       // ),
//                     ),
//                     TableCell(
//                       child: Text('TotalPhien:' + NumberFormat.currency(
//                           locale: 'vi_VN',
//                           symbol: '₫',
//                         ).format(totalPhien),),
//                       // child: Text(
//                       //   totalRevenue.toString(),
//                       // ),
//                     ),
//                     TableCell(
//                       child:Text('Total:' + NumberFormat.currency(
//                           locale: 'vi_VN',
//                           symbol: '₫',
//                         ).format(totalGrossAmt),)

//                     ),
// //             TableCell(
// //   child: Text((double.parse(filteredData[i].kCNTREVENUE) / double.parse(filteredData[i].kKITMGROSSAMT) * 100).toStringAsFixed(2)),
//                   ]),
                  ],
                ),
              )
              ],
            ),
          ),
        ],
      ),
    )
  );
}
}
class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
