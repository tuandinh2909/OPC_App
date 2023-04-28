
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:opc_app_main/api_call_statistics.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

enum LoadState { loading, success, error }

LoadState _loadState = LoadState.loading;
Widget _child = Text('Xem', style: TextStyle(color: Colors.white));

class ViewScreen extends StatefulWidget {
  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  double totalGrossAmt = 0; // thêm biến tổng
  double totalPhien = 0;
  double totalHD2 = 0;
  double totalHH04 = 0;
  double total = 0.0;
  double KeHoach = 0.0;
  bool isDataFullyLoaded = false;
  double progressValue = 0.0;
  LoadState loadState = LoadState.loading;
  double progress = 0.0;
  List<Results> data = [];
  List<Results> filteredData = [];
  List<BieuDo> dataBD = [];
  List<BieuDo> filteredDataBD = [];
  List<Kehoach> filteredData3 = [];
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  int startDay = 0, startMonth = 0, startYear = 0;
  int endDay = 0, endYear = 0, endMonth = 0;

  List<Kehoach> data3 = [];
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '');
  double totalRevenue = 0.0;
  double totalPlan = 0.0;
  String TDV = '';
  late List<_SalesData> data1 = [];
  var maCbNV;
  var filter, skip, top, format, expand, select;

  List<Results> removeDuplicates(List<Results> list) {
    Map<String, Results> map = {};

    for (Results item in list) {
      map[item.cDOCUUID!] = item;
    }
    return map.values.toList();
  }

  List<BieuDo> removeDuplicatesBD(List<BieuDo> list) {
    Map<String, BieuDo> map = {};

    for (BieuDo item in list) {
      map[item.cDOCUUID12!] = item;
    }
    return map.values.toList();
  }

  void handleDateRange() {
    DateTime startDate = DateTime.parse(_startDateController.text);
    DateTime endDate = DateTime.parse(_endDateController.text);

    int startDay = startDate.day;
    int startMonth = startDate.month;
    int startYear = startDate.year;

    int endDay = endDate.day;
    int endMonth = endDate.month;
    int endYear = endDate.year;

    print(
        'Ngày bắt đầu: $startDay, Tháng bắt đầu: $startMonth, Năm bắt đầu: $startYear');
    print(
        'Ngày kết thúc: $endDay, Tháng kết thúc: $endMonth, Năm kết thúc: $endYear');
  }



//Doanh thu
  Future<void> fetchData() async {
    // Khởi tạo biến progress và loaded
    bool loaded = false;
    double progress = 0.0;

    // Lấy SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      progress = 0.01;
    });
    String maCbNv = prefs.getString('maCbNv')!;
    maCbNV = maCbNv;
    var _ci = 'CI';
    print("Mã được in ra của API 1 là: " + maCbNv);

    // Thực hiện tải dữ liệu từ API

    final String url =
        "https://my431086.businessbydesign.cloud.sap/sap/byd/odata/ana_businessanalytics_analytics.svc/RPCRMCIVIB_Q0001QueryResults?\$select=CDOC_YEAR,CDOC_CREATED_DT,KCINV_QTY,CIPR_REFO_CATCP,CIPR_PROD_UUID,TIPR_PROD_UUID,KKITM_NET_AM_RC,TIPR_REFO_CATCP,CIPR_REFO_PRDTY,TIPR_REFO_PRDTY,CIP_SAL_EMP,TIP_SAL_EMP,CDOC_UUID,CDOC_PROC_TYPE,CDPY_BUYER_UUID,TDPY_BUYER_UUID,CDOC_INV_DATE,CDOC_YEAR_MONTH,KCNT_REVENUE,KCNT_VAL_INV,KKITM_GROSS_AMT&\$format=json&\$filter=PARA_CAL_DAY gt datetime'2023-02-01T00:00:00'  &\$filter=PARA_CAL_DAY lt datetime'2023-02-28T00:00:00'  and CIP_SAL_EMP eq " +
            "'" +
            maCbNV +
            "'" +
            " and CDOC_PROC_TYPE eq'CI' and (CDOC_INV_DATE ge datetime'2023-02-01T00:00:00' and CDOC_INV_DATE le datetime'2023-02-28T00:00:00')&\$top=200&\$skip=0";
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

    print(response.body);
    setState(() {
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        var results = decodedJson['d']['results'];

        for (int i = 0; i < results.length; i++) {
          var customerJson = results[i];
          data.add(Results.fromJson(customerJson));
        }
        filteredData = removeDuplicates(data);
        loadState = LoadState.success; // cập nhật trạng thái thành công
      } else {
        throw Exception('Failed to load data');
      }
      progress = 100.0;
      loaded = true;
    });
  }

//Biểu đồ
  Future<void> fetchData1() async {
    bool loaded = false;
    double progress = 0.0;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      progress = 0.01;
    });

    String? maCbNv = prefs.getString('maCbNv');
    if (maCbNv != null) {
      maCbNV = maCbNv;
      print("Mã được in ra của API 2 là: " + maCbNv);
    } else {
      print('Không tìm thấy mã cán bộ nhân viên!');
    }
    var _ci = 'CI';

    DateTime startDate = DateTime.parse(_startDateController.text);
    DateTime endDate = DateTime.parse(_endDateController.text);

    int startDay = startDate.day;
    String startDayString = startDay.toString().padLeft(2, '0');
    int startMonth = startDate.month;
    String startMonthString = startMonth.toString().padLeft(2, '0');
    int startYear = startDate.year;

    int endDay = endDate.day;
    String endDayString = endDay.toString().padLeft(2, '0');
    int endMonth = endDate.month;
    String endMonthString = endMonth.toString().padLeft(2, '0');
    int endYear = endDate.year;
    final String url =
        "https://my431086.businessbydesign.cloud.sap/sap/byd/odata/ana_businessanalytics_analytics.svc/RPCRMCIVIB_Q0001QueryResults?\$select=CDOC_YEAR,CDOC_CREATED_DT,KCINV_QTY,CIPR_REFO_CATCP,CIPR_PROD_UUID,TIPR_PROD_UUID,KKITM_NET_AM_RC,TIPR_REFO_CATCP,CIPR_REFO_PRDTY,TIPR_REFO_PRDTY,CIP_SAL_EMP,TIP_SAL_EMP,CDOC_UUID,CDOC_PROC_TYPE,CDPY_BUYER_UUID,TDPY_BUYER_UUID,CDOC_INV_DATE,CDOC_YEAR_MONTH,KCNT_REVENUE,KCNT_VAL_INV,KKITM_GROSS_AMT&\$format=json&\$filter=PARA_CAL_DAY gt datetime'$startYear-$startMonthString-$startDayString" +
            "T00:00:00'  &\$filter=PARA_CAL_DAY lt datetime'$endYear-$endMonthString-$endDayString" +
            "T00:00:00'  and CIP_SAL_EMP eq " +
            "'" +
            maCbNV +
            "'" +
            " and CDOC_PROC_TYPE eq'CI' and (CDOC_INV_DATE ge datetime'$startYear-$startMonthString-$startDayString" +
            "T00:00:00' and CDOC_INV_DATE le datetime'$endYear-$endMonthString-$endDayString" +
            "T00:00:00')&\$top=200&\$skip=0";

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

      for (int i = 0; i < results.length; i++) {
        var customerJson = results[i];
        newData.add(BieuDo.fromJson(customerJson));
        totalPlan += double.parse(newData[i].kKITMGROSSAMT.toString());

        if (customerJson['CIPR_REFO_CATCP'].startsWith('TP02') ||
            customerJson['CIPR_REFO_CATCP'].startsWith('TP05') ||
            customerJson['CIPR_REFO_CATCP'].startsWith('TP07')) {
          totalGrossAmt += double.parse(customerJson['KKITM_GROSS_AMT']);
        }
        if (customerJson['CIPR_REFO_CATCP'].startsWith('HH04')) {
          totalHH04 += double.parse(customerJson['KKITM_GROSS_AMT']);
        }
        if (customerJson['CIPR_REFO_CATCP'].startsWith('HD2')) {
          totalHD2 += double.parse(customerJson['KKITM_GROSS_AMT']);
        }
        if (customerJson['CIPR_REFO_CATCP'].startsWith('TP08') &&
            customerJson['CIPR_REFO_CATCP'].startsWith('TP09')) {
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

      print('Total OPC: $totalGrossAmt');
      print('Total OPC_BD: $totalHH04');
      print('Total HD2: $totalHD2');
      print('Total Phien: $totalPhien');
      print('Total plan: $totalPlan');

      List<BieuDo> oldData = dataBD;
      List<BieuDo> mergedData = [...oldData, ...newData];

      List<BieuDo> filteredDataBD = mergedData.toList().toSet().toList();

      setState(() {
        dataBD = filteredDataBD;
        loadState = LoadState.success; // cập nhật trạng thái thành công

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
//Ke hoach
  Future<void> fetchData2() async {
    // Khởi tạo biến progress và loaded
    bool loaded = false;
    double progress = 0.0;

    // Lấy SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      progress = 0.01;
    });
    String maCbNv = prefs.getString('maCbNv')!;
    maCbNV = maCbNv;
    var _ci = 'CI';
    print("Mã được in ra của API 3 là: " + maCbNv);

    // Thực hiện tải dữ liệu từ API

    final String url =
        "https://my431086.businessbydesign.cloud.sap/sap/byd/odata/ana_businessanalytics_analytics.svc/RPCRMSTPP_Q0001QueryResults?\$select=CEMPLOYEE,TEMPLOYEE,CPLAN_ID,KCTARGET_VALUE&\$format=json&\$filter=PLAN_ID eq 'OPC_TP_0101:2023/03-2023/07'";
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

    print(response.body);
    setState(() {
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        var results = decodedJson['d']['results'];

        for (int i = 0; i < results.length; i++) {
          var customerJson = results[i];
          data3.add(Kehoach.fromJson(customerJson));
          if (maCbNV == data3[i].cEMPLOYEE.toString())
            KeHoach = double.parse(data3[i].kCTARGETVALUE.toString());
          else
            KeHoach == 0;
        }

        loadState = LoadState.success; // cập nhật trạng thái thành công
      } else {
        throw Exception('Failed to load data');
      }
      progress = 100.0;
      loaded = true;
    });
    print("KeHoach là: " + KeHoach.toString());  
  }

  void calculateTotal() {
    totalRevenue = 0;

    for (var i = 0; i < filteredData.length; i++) {
      totalRevenue += double.parse(filteredData[i].kCNTREVENUE.toString());
      // totalPlan += double.parse(filteredData[i].kKITMGROSSAMT.toString());
      TDV = filteredData[i].tIPSALEMP.toString();
      print("TDV là $TDV");
    }
  }

  @override
  void initState() {
    super.initState();

    fetchData().catchError((error) {
      setState(() {
        loadState = LoadState.error; // cập nhật trạng thái lỗi
      });
    });
    fetchData1().catchError((error) {
      setState(() {
        loadState = LoadState.error; // cập nhật trạng thái lỗi
      });
    });
    fetchData2().catchError((error) {
      setState(() {
        loadState = LoadState.error; // cập nhật trạng thái lỗi
      });
    });

    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    calculateTotal();

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Doanh thu TDV',
            style:
                TextStyle(fontFamily: 'Labrada', fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (loadState == LoadState.loading)
                LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
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
                      width: 16,
                    ),
                    Expanded(
                      child: Container(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: Size(60, 50),
                          ),
                          child: _loadState == LoadState.loading
                              ? _child
                              : Icon(
                                  _loadState == LoadState.success
                                      ? Icons.check
                                      : Icons.error,
                                  color: _loadState == LoadState.success
                                      ? Colors.black
                                      : Colors.red,
                                ),
                          onPressed: () {
                            setState(() {
                              _loadState = LoadState.loading;
                              _child = CircularProgressIndicator(
                                backgroundColor: Colors.grey,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              );
                            });
                            handleDateRange();

                            fetchData1().then((value) {
                              setState(() {
                                _loadState = LoadState.success;
                              });
                            }).catchError((error) {
                              setState(() {
                                _loadState = LoadState.error;
                              });
                            }).whenComplete(() {
                              Future.delayed(Duration(seconds: 2), () {
                                setState(() {
                                  _loadState = LoadState.loading;
                                  _child = Text('Xem',
                                      style: TextStyle(color: Colors.white));
                                });
                              });
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (loadState == LoadState.loading)
                        SizedBox(height: 10.0),
                      if (loadState == LoadState.error)
                        Center(
                          child: Text("Error: Failed to load data"),
                        ),
                      if (loadState == LoadState.success)
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'BẢNG THỐNG KÊ DOANH THU',
                                style: TextStyle(
                                    fontFamily: 'Anton', fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        height: 300,
                        width: double.infinity,
                        child: SfCircularChart(
                          // Chart title
                          // Enable legend
                          legend: Legend(
                              isVisible: true, toggleSeriesVisibility: false),
                          series: <CircularSeries<_SalesData, String>>[
                            DoughnutSeries<_SalesData, String>(
                                dataSource: data1,
                                xValueMapper: (_SalesData sales, _) =>
                                    sales.year,
                                yValueMapper: (_SalesData sales, _) =>
                                    sales.sales,
                                // Enable data label
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                ),
                                // Set custom colors for data points
                                pointColorMapper: (_SalesData data, _) {
                                  if (data.year == 'OPC') {
                                    return Color.fromRGBO(234, 136, 99, 1);
                                  } else if (data.year == 'Cồn') {
                                    return Color.fromRGBO(109, 168, 176, 1);
                                  } else if (data.year == 'HD2') {
                                    return Color.fromARGB(255, 243, 232, 81);
                                  } else if (data.year ==
                                      'Phiến tỉ trọng theo loại sản phẩm') {
                                    return Color.fromARGB(255, 81, 212, 131);
                                  } else {
                                    return Colors.grey;
                                  }
                                })
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                  height: 210,
                  child: SingleChildScrollView(
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
                          )
                        ]),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
