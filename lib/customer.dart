import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:opc_app_main/call_api.dart';
import 'package:opc_app_main/login_screen.dart';


import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late final DateTime _currentDate;
  var filter, skip, top, format, expand, maCbNV;

  final String url2 = "http://118.69.225.144/api/user";
  List<Customer> data = [];
  List<Customer> filteredData = [];

  TextEditingController _businessPartnerNameController = TextEditingController();
  TextEditingController _internalIDController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String currentSearchText = '';


  void fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String maCbNv = prefs.getString('maCbNv')!;
    maCbNV = maCbNv;
    print(maCbNv);
    final String url =
        "https://my431086.businessbydesign.cloud.sap/sap/byd/odata/cust/v1/khcustomertest/CustomerCurrentEmployeeResponsibleCollection?\$format=json&\$expand=Customer&\$filter=EmployeeID eq " +
            "'" +
            maCbNV +
            "'";
    final username = "OPCIT";
    final password = "Welcome1";
    final credentials = base64Encode(utf8.encode('$username:$password'));
    final headers = {
      'Authorization': 'Basic $credentials',
      'User-Agent': 'MyApp/1.0'
    };
    final response = await http.get(Uri.parse(Uri.encodeFull(url)),
        headers: headers); 
    setState(() {
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        var results = decodedJson['d']['results'];
        for (int i = 0; i < results.length; i++) {
          var customerJson = results[i]['Customer'];
          data.add(Customer.fromJson(customerJson));
          filteredData.add(Customer.fromJson(customerJson));
        }
      } else {
        throw Exception('Failed to load data');
      }
    });
  }



  @override
  void initState() {
    super.initState();
    fetchData();
    _currentDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 54, 168, 89),
        title: Text("Khách hàng",),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(hintText: "Tìm kiếm"),
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  currentSearchText = value.toLowerCase();
                  filteredData = data.where((customer) {
                    return (customer.businessPartnerName?.toLowerCase() ?? '')
                            .contains(currentSearchText) ||
                        (customer.internalID?.toLowerCase() ?? '')
                            .contains(currentSearchText);
                  }).toList();
                  print(data);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      filteredData[index].businessPartnerName.toString() ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  subtitle:
                      Text(filteredData[index].internalID.toString() ?? ""),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
