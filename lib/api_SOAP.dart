
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:opc_app_main/object_SOAP.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'dart:collection';
import 'package:flutter_typeahead/flutter_typeahead.dart';
class APISoap extends StatefulWidget {
  @override
  APISoapState createState() => APISoapState();
}

class APISoapState extends State<APISoap> {
  // Future<String>? _futureResponse;
  List<Map<String, String>> _medicines = [];
    String currentSearchTextCustomer = '';
  TextEditingController searchProducts = TextEditingController();
List<String> selectedItems = [];
 bool _isDoneSelectedvt =
      false;
String _selectedMedicine = '';
  @override
  Future<String> fetchSalesPriceList() async {
    final String url =
        'https://my431086.businessbydesign.cloud.sap/sap/bc/srt/scs/sap/ManageSalesPriceListIn';
    final username = "_opc1";
    final password = "Opc@2022#";
    final credentials = base64Encode(utf8.encode('$username:$password'));

    String requestBody = '''
      <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <SOAP-ENV:Body>
          <n0:SalesPriceListFindByIDQuery_sync xmlns:n0="http://sap.com/xi/A1S/Global">
            <SalesPriceList>
              <!-- Identifier of Price / Discount List -->
              <ID>BGBAN</ID>
            </SalesPriceList>
          </n0:SalesPriceListFindByIDQuery_sync>
        </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>
    ''';

    Map<String, String> headers = {
      'Content-Type': 'text/xml;charset=UTF-8',
      'Authorization': 'Basic $credentials',
      'SOAPAction': 'SalesPriceListFindByIDQuery_sync',
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: requestBody);

    if (response.statusCode == 200) {
      print(response.statusCode);
      return response.body;
    } else {
      throw Exception(
          'Failed to load sales price list: ${response.statusCode}');
    }
  }
  Future<void> _showCustomerList(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Danh sách khách hàng'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _medicines.length,
              itemBuilder: (BuildContext context,  suggestion) {
                 final medicine = suggestion as Map<String, String>;
                return ListTile(
                  title: Text(medicine['name']!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: ${medicine['price']}'),
                      Text('ID: ${medicine['id']}'),
                    ],
                  ),
                  
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchMedicines() async {
    final xmlData = await fetchSalesPriceList();
    final medicines = await parseXML(xmlData);
    setState(() {
      _medicines = medicines;
    });
  }


  Future<List<Map<String, String>>> parseXML(String xml) async {
  final document = XmlDocument.parse(xml);
  final descriptions = document.findAllElements('Description');
  final prices = document.findAllElements('PriceSpecification');
  final medicines = <String, Map<String, String>>{};
  
  for (var i = 0; i < descriptions.length; i++) {
    final description = descriptions.elementAt(i);
    final name = description.text.trim();
    final price = prices.length > i ? prices.elementAt(i).findElements('Amount').first?.text?.trim() ?? "" : "";
    String id = "";
    if (prices.length > i) {
      final priceElement = prices.elementAt(i); // lấy phần tử ở vị trí i
      final idElement = priceElement.findElements('PropertyValuation').firstOrNull?.findElements('PriceSpecificationElementPropertyValuation').firstOrNull?.findElements('PriceSpecificationElementPropertyValue').firstOrNull?.findElements('ID').firstOrNull;
      if (idElement != null) {
        id = idElement.text.trim();
      }
    }
    if (id.isNotEmpty && price.isNotEmpty) {
      if (!medicines.containsKey(name)) {
        medicines[name] = {'name': name, 'price': price, 'id': id};
      }
    }
  }

  return medicines.values.toList();
}


  @override
  void initState() {
    super.initState();
    fetchMedicines();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API SOAP'),
      ),
      body: Row(
        children: [
          // TypeAheadField
         Expanded(child:  Container(
            child: TypeAheadField(
  textFieldConfiguration: TextFieldConfiguration(
    decoration: InputDecoration(
      labelText: 'Tìm kiếm sản phẩm',
    ),
    controller: TextEditingController(text: _selectedMedicine), // Đặt giá trị cho controller
  ),
suggestionsCallback: (pattern) async {
  // Hàm callback để lấy danh sách gợi ý dựa trên giá trị nhập (pattern)
  return _medicines
      .where((medicine) =>
          medicine['name']!.toLowerCase().contains(pattern.toLowerCase()) ||
          medicine['id']!.toLowerCase().contains(pattern.toLowerCase()) ||
          medicine['price']!.toLowerCase().contains(pattern.toLowerCase()))
      .toList();
},


  itemBuilder: (context, suggestion) {
    // Builder để xây dựng giao diện của gợi ý
    final medicine = suggestion as Map<String, String>;
    return ListTile(
      title: Text(medicine['name']!),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price: ${medicine['price']}'),
          Text('ID: ${medicine['id']}'),
        ],
      ),
    );
  },
  onSuggestionSelected: (suggestion) {
    // Callback được gọi khi người dùng chọn một gợi ý
    setState(() {
      _selectedMedicine = (suggestion as Map<String, String>)['name']!;
    });
  },
),

          ),),
//           Visibility(
//             visible: !_isDoneSelectedvt,
//             child: Container(
//               width: 70,
//               child: Expanded(
//                 child: Container(
//                   child: GestureDetector(
//                     onTap: () async {
//                   // Hiển thị hộp thoại cảnh báo
//                   await showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text('Danh sách sản phẩm'),
//                         content: Container(
//                           width: double.maxFinite,
//                           child: ListView.builder(
//                             itemCount: _medicines.length, // Số lượng sản phẩm
//                             itemBuilder: (context, suggestion) {
                             
//                               return ListTile(
//                                 title: Text((suggestion as Map<String, String>)['name']!), // Tên sản phẩm
//                                 subtitle: Text((suggestion as Map<String, String>)['price']!), // Giá sản phẩm
//                                 onTap: () {
//                                 // setState(() {
//                                 //   final product = _medicines[suggestion];
//                                 //   selectedItems = medicine['name'];
//                                 //   searchProducts.text = product['name'];
//                                 //   currentSearchTextCustomer = product['name'].toLowerCase();
//                                 //   _medicines = data.where((customer) {
//                                 //     return (customer['name']?.toLowerCase() ?? '').contains(currentSearchTextCustomer) ||
//                                 //         (customer['id']?.toLowerCase() ?? '').contains(currentSearchTextCustomer);
//                                 //   }).toList();
//                                 //   _isDoneSelectedvt = true;
//                                 // });
//                                 Navigator.of(context).pop((suggestion as Map<String, String>));
//                               },


//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Đóng'),
//             onPressed: () {
//               Navigator.of(context).pop(); // Đóng hộp thoại cảnh báo
//             },
//           ),
//         ],
//       );
//     },
//   );
// },

//                     child: Row(children: [
//                       Container(
//                         margin: EdgeInsets.only(left: 10),
//                         width: 50,
//                         child: Row(children: [
//                           Icon(Icons.arrow_drop_down),
//                            if (selectedItems != null)
//                                             GestureDetector(
//                                               // onTap: () {
//                                               //   setState(() {
//                                               //     selectedItems = null;
//                                               //     searchProducts
//                                               //         .text = '';
//                                               //     currentSearchTextCustomer =
//                                               //         '';
//                                               //     filteredData = data;
//                                               //     _isDoneSelectedvt = false;
//                                               //   });
//                                               // },
//                                               child: Icon(Icons.close),
//                       )]),
//                       )
//                     ]),
//                   )
//                 ),
//               )
//             )
//           )
          // Danh sách dữ liệu
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: _medicines.length,
          //     itemBuilder: (context, index) {
          //       final medicine = _medicines[index];
          //                       // Kiểm tra nếu medicine được chọn trùng với _selectedMedicine
          //       // thì hiển thị ListTile với màu nền khác để đánh dấu là đã chọn
          //       return ListTile(
          //         title: Text(medicine['name']!),
          //         subtitle: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text('Price: ${medicine['price']}'),
          //             Text('ID: ${medicine['id']}'),
          //           ],
          //         ),
          //         tileColor: medicine['id'] == _selectedMedicine
          //             ? Colors.grey.withOpacity(0.2)
          //             : null,
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

  
   

