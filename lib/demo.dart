import 'package:flutter/material.dart';
import 'package:opc_app_main/api_call_statistics.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

enum LoadState { loading, success, error }

LoadState loadState = LoadState.loading;

class ViewScreen12 extends StatefulWidget {
  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen12> {
  bool isDataFullyLoaded = false;
  double progressValue = 0.0;
  LoadState loadState = LoadState.loading;
  double progress = 0.0;
  List<Results> data = [];
  List<Results> filteredData = [];
  List<BieuDo> dataBD = [];
  List<BieuDo> filteredDataBD = [];
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '');
  double totalRevenue = 0.0;
  double totalPlan = 0.0;
  String TDV = '';
  List<_SalesData> data1 = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40)
  ];
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
        "https://my427593.businessbydesign.cloud.sap/sap/byd/odata/ana_businessanalytics_analytics.svc/RPCRMCIVIB_Q0001QueryResults?\$select=CDOC_YEAR,CDOC_CREATED_DT,CIP_SAL_EMP,TIP_SAL_EMP,CDOC_UUID,CDOC_PROC_TYPE,CDPY_BUYER_UUID,TDPY_BUYER_UUID,CDOC_INV_DATE,CDOC_YEAR_MONTH,KCNT_REVENUE,KCNT_VAL_INV,KKITM_GROSS_AMT&\$format=json&\$filter=PARA_CAL_DAY gt datetime'2023-02-01T00:00:00' and PARA_CAL_DAY lt datetime'2023-02-28T00:00:00' &\$filter=CIP_SAL_EMP eq" +
            "'" +
            maCbNV +
            "'" +
            "and CDOC_PROC_TYPE eq 'CI' &(CDOC_INV_DATE ge datetime'2023-02-01T00:00:00'and CDOC_INV_DATE le datetime'2023-02-28T00:00:00')&\$top=200&\$skip=0";
    final username = "OPCIT";
    final password = "Welcome2";
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

  Future<void> fetchData1() async {
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
    // Thực hiện tải dữ liệu từ API
    final String url = "https://my427593.businessbydesign.cloud.sap/sap/byd/odata/ana_businessanalytics_analytics.svc/RPCRMCIVIB_Q0001QueryResults?$select=CDOC_YEAR,CDOC_CREATED_DT,KCINV_QTY,CIPR_REFO_CATCP,CIPR_PROD_UUID,TIPR_PROD_UUID,KKITM_NET_AM_RC,TIPR_REFO_CATCP,CIPR_REFO_PRDTY,TIPR_REFO_PRDTY,CIP_SAL_EMP,TIP_SAL_EMP,CDOC_UUID,CDOC_PROC_TYPE,CDPY_BUYER_UUID,TDPY_BUYER_UUID,CDOC_INV_DATE,CDOC_YEAR_MONTH,KCNT_REVENUE,KCNT_VAL_INV,KKITM_GROSS_AMT&$format=json&$filter=PARA_CAL_DAY gt datetime'2023-02-01T00:00:00'  &$filter=PARA_CAL_DAY lt datetime'2023-02-28T00:00:00'  and CIP_SAL_EMP eq"+
    "'" +
    maCbNV +
    "'" +
     "and CDOC_PROC_TYPE eq'CI' and (CDOC_INV_DATE  ge datetime'2023-02-01T00:00:00' and CDOC_INV_DATE  le datetime'2023-02-28T00:00:00')&$top=200&$skip=0";
    final username = "OPCIT";
    final password = "Welcome2";
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
          dataBD.add(BieuDo.fromJson(customerJson));
        }
        filteredDataBD = removeDuplicatesBD(dataBD);
        loadState = LoadState.success; // cập nhật trạng thái thành công
      } else {
        throw Exception('Failed to load data');
      }
      progress = 100.0;
      loaded = true;
    });
  }

  void calculateTotal() {
    totalRevenue = 0;
    totalPlan = 0;
    for (var i = 0; i < filteredData.length; i++) {
      totalRevenue += double.parse(filteredData[i].kCNTREVENUE.toString());
      totalPlan += double.parse(filteredData[i].kKITMGROSSAMT.toString());
      TDV = filteredData[i].tIPSALEMP.toString();
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
  }

  @override
  Widget build(BuildContext context) {
    calculateTotal();
    return Scaffold(
      appBar: AppBar(
        title: Text('Doanh thu TDV'),
      ),
      body: Column(
        children: [
          if (loadState == LoadState.loading)
            LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          SizedBox(
            height: 200,
            child: Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Text(
                        "Trình dược viên",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                    TableCell(
                      child: Text(
                        "Doanh thu",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                    TableCell(
                      child: Text(
                        "Kế hoạch",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                    TableCell(
                      child: Text(
                        "Tỷ lệ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                TableRow(children: [
                  TableCell(
                    child: Text(TDV.toString()),
                  ),
                  TableCell(
                    child: Text(
                        NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: '₫',
                        ).format(totalPlan),
                        style: TextStyle(fontFamily: 'SourceSerifPro')),
                    // child: Text(
                    //   totalPlan.toString(),
                    // ),
                  ),
                  TableCell(
                    child: Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: '₫',
                      ).format(totalRevenue),
                      style: TextStyle(fontFamily: 'SourceSerifPro'),
                    ),
                    // child: Text(
                    //   totalRevenue.toString(),
                    // ),
                  ),
                  TableCell(
                    child: Text(
                        (totalPlan / totalRevenue * 100).toStringAsFixed(2) +
                            "%",
                        style: TextStyle(fontFamily: 'SourceSerifPro')),
                  ),
//             TableCell(
//   child: Text((double.parse(filteredData[i].kCNTREVENUE) / double.parse(filteredData[i].kKITMGROSSAMT) * 100).toStringAsFixed(2)),
                ]),
                for (int i = 0; i < filteredDataBD.length; i++)
                  TableRow(children: [
                    TableCell(
                      child: Text(filteredDataBD[i].tIPSALEMP.toString()),
                    ),
                    TableCell(
                      child: Text(filteredDataBD[i].cIPRREFOCATCP.toString()),
                      // child: Text(
                      //   totalPlan.toString(),
                      // ),
                    ),
                    TableCell(
                      child: Text(filteredDataBD[i].tIPRPRODUUID.toString()),
                      // child: Text(
                      //   totalRevenue.toString(),
                      // ),
                    ),
                    TableCell(
                      child: Text(filteredDataBD[i].tIPRREFOPRDTY.toString()),
                    ),
//             TableCell(
//   child: Text((double.parse(filteredData[i].kCNTREVENUE) / double.parse(filteredData[i].kKITMGROSSAMT) * 100).toStringAsFixed(2)),
                  ]),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
