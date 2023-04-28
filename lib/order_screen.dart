
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:opc_app_main/call_api.dart';
import 'package:opc_app_main/provider_products.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'dart:collection';
class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController productIDController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController decimalValueController = TextEditingController();
  final TextEditingController partyIDController = TextEditingController();
    List<Map<String, String>> _medicines = [];
    dynamic donGia;
    dynamic thanhTien;
    String currentSearchTextCustomer = '';
    String selectedProductPrice = '';
  double giaGocTemp = 0.0; // Biến tạm để lưu giá trị giá gốc của sản phẩm
    final TextEditingController searchProduct = TextEditingController();
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


  Future<String> fetchDataUp() async {
    String productID = productIDController.text;
    String quantity = quantityController.text;
    String decimalValue = decimalValueController.text;
    String partyID = partyIDController.text;

    final String url =
        'https://my431086.businessbydesign.cloud.sap/sap/bc/srt/scs/sap/managesalesorderin5';
    final username = '_opc1';
    final password = 'Opc@2022#';
    final credentials = base64Encode(utf8.encode('$username:$password'));
    String requestBody = ''' 
  <SOAP-ENV:Envelope   xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	<SOAP-ENV:Body>
		<n0:SalesOrderBundleMaintainRequest_sync xmlns:n0="http://sap.com/xi/SAPGlobal20/Global" xmlns:ypj="http://0005837950-one-off.sap.com/YPJHSCV4Y_">
			<BasicMessageHeader/>
			<SalesOrder>
				<DATETIME>2023-03-29T12:00:00.1234567Z</DATETIME>
				<Name languageCode="EN">APP_OPC</Name>
				<Item>
					<ItemProduct>
						<ProductID>$productID</ProductID>
					</ItemProduct>
					<ItemScheduleLine>
						<Quantity>$quantity</Quantity>
					</ItemScheduleLine>
					<ypj:PromotionID></ypj:PromotionID>
					<ypj:OrgPrice currencyCode="VND">0.00</ypj:OrgPrice>
					<ypj:GiftItem>false</ypj:GiftItem>
					<ypj:PurchProductID></ypj:PurchProductID>
					<ypj:OrgPrice currencyCode="VND">0</ypj:OrgPrice>
					<ypj:TotalDiscAllocation currencyCode="VND">0</ypj:TotalDiscAllocation>
					<PriceAndTaxCalculationItem>
						<ItemMainDiscount>
							<Rate>                         
								<DecimalValue>$decimalValue</DecimalValue>           
							</Rate>
						</ItemMainDiscount>
					</PriceAndTaxCalculationItem>
				</Item>
				<AccountParty>
					<PartyID>$partyID</PartyID>
				</AccountParty>
			</SalesOrder>
		</n0:SalesOrderBundleMaintainRequest_sync>
	</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
   ''';

    Map<String, String> headers = {
      'Content-Type': 'text/xml;charset=UTF-8',
      'Authorization': 'Basic $credentials',
      'SOAPAction': 'SalesOrderBundleMaintainRequest_sync',
    };
    final response =
        await http.post(Uri.parse(url), headers: headers, body: requestBody);
    if (response.statusCode == 200) {
      var jsonResponse = json.encode(response.body);
      print(response.statusCode);
      print(response.body);
      return "success";
    } else {
      print('Request failed with status: ${response.statusCode}.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm thất bại')),
      );
      return "failed";
    }
  }

  final TextEditingController _MaSanPhamController = TextEditingController();
  TextEditingController _dateTimeController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  List<String> textList = [];
  var filter, skip, top, format, expand, maCbNV;

  bool _isChecked = false;
  String _text = '';

  final String url2 = "http://118.69.225.144/api/user";
  final _searchControllerCustomer = TextEditingController();
  List<Customer> data = [];
  List<Customer> filteredData = []; // Danh sách khách hàng gốc
  List<Customer> _products = [];
  List<Customer> _allCustomers = []; // Danh sách khách hàng đã lọc
  Customer? _selectedCustomer;
  bool _isDoneSelected =
      false; //isDoneSelected sẽ kiểm tra xem nút kết thúc đã được bấm hay chưa
  String selectedTextCustomer =
      ''; // Tạo biến state để lưu giá trị của _searchController
  int? selectedIndexCustomer;
  bool _isItemSelected = false;
  bool _isResultSelected =
      false; // khởi tạo biến kiểm tra kết quả đã chọn hay chưa
  TextEditingController _itemController = TextEditingController();
  String currentSearchTextProducts = '';
  bool dataChanged = false;
TextEditingController searchProducts = TextEditingController();
  List<String> selectedCustomer = [];
  int? selectedCustomerIndex;
  void selectCustomer(int index) {
    setState(() {
      if (selectedCustomerIndex == index) {
        selectedCustomerIndex = null;
      } else {
        selectedCustomerIndex = index;
      }
    });
  }

  Products? _selectedProductsvt;
  bool dataChangedvt = false;
  // List<String> textListvt = [];
  final _searchControllervt = TextEditingController();
  String currentSearchTextvt = '';
  List<Products> datavt = [];
  List<Products> filteredDatavt = []; // Danh sản phẩm
  bool _isItemSelectedvt = false;
  bool _isDoneSelectedvt =
      false; //isDoneSelected sẽ kiểm tra xem nút kết thúc đã được bấm hay chưa
  bool _isResultSelectedvt =
      false; // khởi tạo biến kiểm tra kết quả đã chọn hay chưa
  List<String> selectedProducts = [];
  String currentSearchTextProduct = '';
  List<String> selectedItems = [];
  String _selectedMedicine = '';
  String _soLuongValue =
      ''; // khởi tạo biến tạm để lưu trữ giá trị nhập vào TextField
  //int? selectedProductsIndex;
  int? _selectedProductIndex;
  void _handleTap(int index) {
    if (_selectedProductIndex == index) {
      // If the item is already selected, unselect it
      setState(() {
        _selectedProductIndex = null;
        _isItemSelected = false;
      });
    } else {
      // If a new item is selected, highlight the edit button
      setState(() {
        _selectedProductIndex = index;
        _isItemSelected = true;
      });
    }
  }

  // void _calculateTotal() {
  //   tongTienHang = 0;
  //   tongThue = 0;
  //   for (final product in selectedProducts) {
  //     final pattern = RegExp(
  //         r'Số lượng: (\d+).*Đơn giá: (\d+).*Thuế: (\d+)%.*Chiết khấu: (\d+)%');
  //     final match = pattern.firstMatch(product);
  //     if (match != null) {
  //       final sl = int.tryParse(match.group(1)!) ?? 0;
  //       final donGia = int.tryParse(match.group(2)!) ?? 0;
  //       final thue = int.tryParse(match.group(3)!) ?? 0;
  //       final chietKhau = int.tryParse(match.group(4)!) ?? 0;
  //       final thanhTien = (sl * donGia * (100 - chietKhau) / 100).round();
  //       print(
  //           'Số lượng: $sl, Đơn giá: $donGia, Thuế: $thue%, Chiết khấu: $chietKhau%, Thành tiền: $thanhTien');
  //       tongTienHang += thanhTien;
  //       tongThue += (thanhTien * thue / 100).round();
  //     }
  //   }
  //   print('Tổng tiền hàng: $tongTienHang');
  //   print('Tổng thuế: $tongThue');
  //   tongCong = tongTienHang + tongThue;
  //   print('Tổng cộng: $tongCong');
  // }

  void _handleEditButton() {
    if (_selectedProductIndex == null) {
      return;
    }

    final selectedProduct = selectedProducts[_selectedProductIndex!];
    final patternSL = RegExp(r'Số lượng: (\d+)');
    final patternCK = RegExp(r'Chiết khấu: (\d+)');
    final matchSL = patternSL.firstMatch(selectedProduct);
    final matchCK = patternCK.firstMatch(selectedProduct);
    final slController = TextEditingController(text: matchSL?.group(1));
    final ckController = TextEditingController(text: matchCK?.group(1));
    final sl = int.tryParse(slController.text) ?? 0;
    final ck = int.tryParse(ckController.text) ?? 0;
    print('Số lượng: $sl, Chiết khấu: $ck');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chỉnh sửa sản phẩm'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  enabled: false,
                  initialValue: selectedProduct
                      .replaceAll(patternSL, '')
                      .replaceAll(patternCK, '')
                      .trim(),
                  decoration: InputDecoration(
                    hintText: 'Tên sản phẩm',
                  ),
                ),
                TextFormField(
                  controller: slController,
                  decoration: InputDecoration(
                    hintText: 'Số lượng',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: ckController,
                  decoration: InputDecoration(
                    hintText: 'Chiết khấu',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final sl = int.tryParse(slController.text) ?? 0;
                final ck = int.tryParse(ckController.text) ?? 0;

                // tính giá trị tiền hàng và thuế của sản phẩm
                final patternDG = RegExp(r'Đơn giá: ([\d\.]+)');
                 final patternGG = RegExp(r'Giá gốc: ([\d\.]+)');
                final patternTT = RegExp(r'Thành tiền: ([\d\.]+)');
                final matchDG = patternDG.firstMatch(selectedProduct);
                final matchTT = patternTT.firstMatch(selectedProduct);
                final matchGG = patternGG.firstMatch(selectedProduct);
                final donGia = double.tryParse(matchGG?.group(1) ?? '0') ?? 0;
                final thanhTien =
                    double.tryParse(matchTT?.group(1) ?? '0') ?? 0;
                    // dynamic dongia =giaText;
                var tienHang = (donGia * sl * ((100 - ck) / 100));
                print('Tiền hàng là: $tienHang');
                // var dongia = giaGoc *(100-ck)/100;
                final thue = sl * (tienHang * 0.05);
                print('Thuế nhập dữ liệu và nhấn lưu: $thue');
                final newThanhTien = tienHang;
                final newDonGia = donGia;
                final newProductWithTT = selectedProduct
                    .replaceAll(patternSL, 'Số lượng: $sl')
                    .replaceAll(patternCK, 'Chiết khấu: $ck')
                    .replaceAll(patternDG, 'Đơn giá: ${newDonGia}')
                    .replaceAll(patternTT,
                        'Thành tiền: ${newThanhTien.toStringAsFixed(0)}');

                // cập nhật danh sách sản phẩm và giá trị tổng tiền hàng và thuế
                // cập nhật danh sách sản phẩm và giá trị tổng tiền hàng và thuế
                final newSelectedProducts =
                    selectedProducts.cast<String>().toList();
                newSelectedProducts[_selectedProductIndex!] = newProductWithTT;
                double newTotal = 0;
                double newThue = 0;
                for (final product in newSelectedProducts) {
                  final matchTG = patternDG.firstMatch(product);
                  final matchTT = patternTT.firstMatch(product);
                  final sl = int.tryParse(
                          patternSL.firstMatch(product)?.group(1) ?? '0') ??
                      0;
                  final ck = int.tryParse(
                          patternCK.firstMatch(product)?.group(1) ?? '0') ??
                      0;
                  final giaGoc = double.tryParse(matchTG?.group(1) ?? '0') ?? 0;
                  final thanhTien =
                      double.tryParse(matchTT?.group(1) ?? '0') ?? 0;
                  final tienHang = (donGia * sl * ((100 - ck) / 100));
                  newTotal += thanhTien;
                  newThue += tienHang * 0.05;
                  print('Tong tien mới là: $newTotal');
                  print('Tong thue moi la: $newThue');
                }

                setState(() {
                  selectedProducts = newSelectedProducts;
                  tongTienHang = newTotal;
                  tongThue = newThue;
                  tongCong = tongTienHang + tongThue;
                });
                Navigator.pop(context);
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void selectProducts(int index) {
    setState(() {
      _selectedProductIndex = index;
      _selectedProductsvt = null;
      currentSearchTextProducts = '';
      filteredDatavt = datavt;
      _isDoneSelectedvt = false;
      // Thêm các thông tin về sản phẩm đã chọn vào danh sách
      // selectedProducts[index] = '${selectedProducts[index]} - Đơn giá: $_dongia - Số lượng: $_soluong - Thành tiền: $_thanhTien';
    });
  }

  String giaText = '';

  dynamic _thanhTien = 0;
  dynamic chietKhau = 0;
  dynamic giaGoc = 0;
  dynamic soLuong = 0;
  TextEditingController _soluong = TextEditingController();
  TextEditingController _chietkhau = TextEditingController();
  TextEditingController _giagoc = TextEditingController();
  TextEditingController _TT = TextEditingController();
  TextEditingController _DG = TextEditingController();

  double _dongia = 0.0; // khai báo biến _dongia
  double tongTienHang = 0.0;
  double tongCong = 0.0;
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '');
  double Thue = 0;
  double tongThue = 0.0;
  int? _editingProductIndex;
  final buttonStyle = OutlinedButton.styleFrom(
    backgroundColor: Colors.grey,
  );

  double tinhThue(double soLuong, double giaGoc) {
    return (soLuong * giaGoc * 0.05).toDouble();
  }
  double tinhThanhTien(double soLuong, double donGia, double chietKhau) {
  return donGia * soLuong * (100 - chietKhau) / 100;
}

void _handleTextFieldChanged(String value) {
  setState(() {
    final soLuong = _soluong.text;
    double giaGoc = double.tryParse(value) ?? 0.0;
    // giaGocTemp = giaGoc;
    giaGocTemp = double.parse(giaText);
      try {
      chietKhau = _chietkhau.text?.isEmpty ?? true ? 0 : int.parse(_chietkhau.text);

      } catch (e) {
        print("Giá trị chiết khấu không hợp lệ");
        // hoặc thực hiện các hành động khác phù hợp
      }
  print("Giagoc $giaGocTemp");
  print("ChietKhau $chietKhau");
    double donGia = giaGocTemp * ((100 - chietKhau) / 100);
    _DG.text = donGia.toStringAsFixed(0); // Cập nhật giá trị đơn giá
double thanhTien = (double.tryParse(soLuong) ?? 0) * (double.tryParse(_DG.text) ?? 0);
//  Thue = thanhTien * 0.05 * (double.tryParse(soLuong) ?? 0);
Thue = thanhTien * 0.05;
_TT.text = thanhTien.toStringAsFixed(0); // Cập nhật giá trị thành tiền

  });
}



// Xử lý sự kiện khi người dùng nhập vào TextField _soluong
  void _handleSoLuongChanged(String value) {
    setState(() {
      _soLuongValue = value;
    });
  }

Future<Customer?> _showProductList(BuildContext context) async {
    return showDialog<Customer>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Danh sách sản phẩm'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(filteredData[index].businessPartnerName ?? ''),
                  subtitle: Text(filteredData[index].internalID ?? ''),
                  onTap: () {
                    Navigator.of(context).pop(filteredData[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<Customer?> _showCustomerList(BuildContext context) async {
    return showDialog<Customer>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Danh sách khách hàng'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(filteredData[index].businessPartnerName ?? ''),
                  subtitle: Text(filteredData[index].internalID ?? ''),
                  onTap: () {
                    Navigator.of(context).pop(filteredData[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<Products?> _showProductsList(BuildContext context) async {
    List<dynamic> data = await ConnectJsonObject.getAllContacts();
    List<Products> filteredDatavt = [];
    for (var item in data) {
      if (item is Products) {
        filteredDatavt.add(item);
      }
    }
    String currentSearchTextProducts = '';
    return showDialog<Products>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Danh sách sản phẩm'),
          content: Container(
            width: double.maxFinite,
            child: Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredDatavt.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(filteredDatavt[index].tenVtDmVt ?? ''),
                    trailing:
                        Text('Giá ' + filteredDatavt[index].gia.toString()),
                    onTap: () {
                      Navigator.of(context).pop(filteredDatavt[index]);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xoá'),
          content: Text('Bạn có chắc muốn xoá dòng này?'),
          actions: [
            TextButton(
              child: Text('Huỷ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Đồng ý'),
              onPressed: () {
                setState(() {
                  textList.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTextToList() {
    final newText = _selectedMedicine;
    final SoLuong = _soluong.text;
    final giaBan = _DG.text;
    final giagoc = giaText;
    final CK = _chietkhau.text;
    dynamic ThanhTien = _TT.text;
    // final tt = ck != 0.0 ? gia * sl * (100 - ck) / 100 : gia * sl;
    // final thue = (tt * 0.05).toInt();

    if (_selectedMedicine.isNotEmpty) {
         final newProduct =
        '$newText - Số lượng: $SoLuong - Giá gốc: $giagoc Thành tiền: $ThanhTien - Chiết khấu: $CK ';
     print("Chuoi $newProduct");
      setState(() {
        selectedProducts.add(newProduct);
        _soluong.text = '';
        _selectedProductIndex = null;
        // tongTienHang += tt;
        // tongThue += thue;
      });
    

      // setState(() {
      //   tongCong = tongTienHang + tongThue;
      // });
    }
  }

  Future<bool> _onWillPop() async {
    if (dataChanged) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Các thông tin vừa nhập chưa được lưu'),
              content: Text('Bạn có chắc chắn muốn thoát không?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Không'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Có'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

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
    final response =
        await http.get(Uri.parse(Uri.encodeFull(url)), headers: headers);

    setState(() {
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        var results = decodedJson['d']['results'];
        for (int i = 0; i < results.length; i++) {
          var customerJson = results[i]['Customer'];
          data.add(Customer.fromJson(customerJson));
          filteredData.add(Customer.fromJson(customerJson));
          _allCustomers.add(Customer.fromJson(customerJson));
        }
      } else {
        throw Exception('Failed to load data');
      }
    });
  }

  void _handleCbTextFieldChanged(String text) {
    setState(() {
      _text = text;
    });
  }

  void _updateDateTimeText() {
    _dateTimeController.text =
        DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime);
  }

  void _updateDateTime(DateTime newDateTime) {
    setState(() {
      _selectedDateTime = newDateTime;
      _updateDateTimeText();
    });
  }

  void resetFields() {
    setState(() {
      _selectedMedicine = '';
      _searchControllervt.text = '';
      _selectedProductsvt = null;
      _isDoneSelectedvt = false;
      giaText = '';
      soLuong = 0; // set the quantity back to 0
      chietKhau = 0; // set the discount back to 0
      giaGoc = 0.0; // set the unit price back to 0
      _thanhTien = 0.0;
      _soluong.text = '';
      _DG.text = '';
      _chietkhau.text = '';
      _dongia = 0.0;
      _TT.text = '';
    });
  }

  @override
  void initState() {
    super.initState();
    // tongTienHang = 0.0;
    // tongThue = 0.0;
    // tongCong = 0.0;
    fetchData();
    fetchMedicines();
  }// bây giờ tôi muốn khi chọn 1 sản phẩm từ typeadhead thì sẽ lấy ra giá tiền và đem hiện thị vào textfield giá gốc. Sau đó, khi click vào nút thêm sẽ đem các giá trị đó hiện thị lên constrainedbox 


  @override
  Widget build(BuildContext context) {
    DateTime _selectedDateTime = DateTime.now();
    String _formattedDateTime =
        DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime);
    final dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_selectedDateTime));
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 54, 168, 89),
                title: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Đơn đặt hàng OPC',
                            style: TextStyle(fontSize: 15)),
                      ]),
                )),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top:10,left:20,right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dateTimeController,
                            readOnly: true,
                            decoration:
                                InputDecoration(hintText: 'Hãy nhập ngày giờ'),
                            onTap: () async {
                              final selectedDateTime = await showDatePicker(
                                context: context,
                                initialDate: _selectedDateTime,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );

                              if (selectedDateTime != null) {
                                final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      TimeOfDay.fromDateTime(_selectedDateTime),
                                );

                                if (selectedTime != null) {
                                  final newDateTime = DateTime(
                                    selectedDateTime.year,
                                    selectedDateTime.month,
                                    selectedDateTime.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );

                                  _updateDateTime(newDateTime);
                                }
                              }
                            },
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 10)),
                        Expanded(
                          child: Container(
                            // color: Colors.red,
                            //margin: EdgeInsets.all(10),
                            child: TypeAheadField(
                              textFieldConfiguration: TextFieldConfiguration(
                                onChanged: _handleTextFieldChanged,
                                decoration: InputDecoration(
                                    hintText: 'Chọn mã đối tượng'),
                                controller: _searchControllerCustomer,
                              ),
                              suggestionsCallback: (pattern) async {
                                // Lấy danh sách các gợi ý dựa trên từ khóa tìm kiếm
                                return data.where((customer) {
                                  return (customer.businessPartnerName
                                                  ?.toLowerCase() ??
                                              '')
                                          .contains(pattern.toLowerCase()) ||
                                      (customer.internalID?.toLowerCase() ?? '')
                                          .contains(pattern.toLowerCase());
                                }).toList();
                              },
                              itemBuilder: (context, suggestion) {
                                // Hiển thị gợi ý trong danh sách
                                return ListTile(
                                  title: Text(
                                      suggestion.businessPartnerName ?? ''),
                                  subtitle: Text(suggestion.internalID ?? ''),
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                // Xử lý sự kiện khi người dùng chọn một gợi ý
                                setState(() {
                                  _selectedCustomer = suggestion;
                                  _searchControllerCustomer.text =
                                      _selectedCustomer?.businessPartnerName ??
                                          '';
                                  currentSearchTextCustomer = _selectedCustomer
                                          ?.businessPartnerName
                                          ?.toLowerCase() ??
                                      '';
                                  filteredData = data.where((customer) {
                                    return (customer.businessPartnerName
                                                    ?.toLowerCase() ??
                                                '')
                                            .contains(
                                                currentSearchTextCustomer) ||
                                        (customer.internalID?.toLowerCase() ??
                                                '')
                                            .contains(
                                                currentSearchTextCustomer);
                                  }).toList();
                                  _isItemSelected = false;
                                  _isResultSelected =
                                      true; // đánh dấu là đã chọn kết quả
                                });
                              },
                            ),
                          ),
                        ),
                        //SizedBox(width: 10),
                        Visibility(
                          visible: !_isDoneSelected,
                          child: Container(
                            width: 70,
                            child: Expanded(
                              child: Container(
                                // margin: EdgeInsets.only(left: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    _showCustomerList(context).then((value) {
                                      setState(() {
                                        _selectedCustomer = value;
                                        _searchControllerCustomer.text =
                                            _selectedCustomer
                                                    ?.businessPartnerName ??
                                                '';
                                        currentSearchTextCustomer =
                                            _selectedCustomer
                                                    ?.businessPartnerName
                                                    ?.toLowerCase() ??
                                                '';
                                        filteredData = data.where((customer) {
                                          return (customer.businessPartnerName
                                                          ?.toLowerCase() ??
                                                      '')
                                                  .contains(
                                                      currentSearchTextCustomer) ||
                                              (customer.internalID
                                                          ?.toLowerCase() ??
                                                      '')
                                                  .contains(
                                                      currentSearchTextCustomer);
                                        }).toList();
                                      });
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        // color: Colors.black,
                                        margin: EdgeInsets.only(left: 10),
                                        width: 50,
                                        child: Row(children: [
                                          Icon(Icons.arrow_drop_down),
                                          //SizedBox(width: 10),
                                          if (_selectedCustomer != null)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedCustomer = null;
                                                  _searchControllerCustomer
                                                      .text = '';
                                                  currentSearchTextCustomer =
                                                      '';
                                                  filteredData = data;
                                                  _isDoneSelected = false;
                                                });
                                              },
                                              child: Icon(Icons.close),
                                            ),
                                        ]),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 340,
                        child: TextField(
                          onChanged: _handleTextFieldChanged,
                          decoration: InputDecoration(
                              hintText: 'Địa chỉ',
                              border: UnderlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 200,
                        child: TextField(
                          onChanged: _handleTextFieldChanged,
                          decoration: InputDecoration(
                              hintText: 'Nội dung',
                              border: UnderlineInputBorder()),
                        ),
                      ),
                      Container(
                        width: 140,
                        child: TextField(
                          onChanged: _handleTextFieldChanged,
                          decoration: InputDecoration(
                              hintText: 'Diễn giải',
                              border: UnderlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        width: 340,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 340,
                        margin: EdgeInsets.only(left: 20),
                        child: TextField(
                          controller: _MaSanPhamController,
                          onChanged: _handleTextFieldChanged,
                          decoration: InputDecoration(
                              hintText: 'Mã Sản Phẩm',
                              border: UnderlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child:  Container(
                        margin:EdgeInsets.only(left:20,right:10),
            child: TypeAheadField(
  textFieldConfiguration: TextFieldConfiguration(
    decoration: InputDecoration(
      labelText: 'Chọn sản phẩm',
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
          Text('Giá: ${medicine['price']}'),
          Text('ID: ${medicine['id']}'),
        ],
      ),
    );
  },
  onSuggestionSelected: (suggestion) {
    // Callback được gọi khi người dùng chọn một gợi ý
    setState(() {
  _selectedMedicine = (suggestion as Map<String, String>)['name']!;
  String giaTextValue = (suggestion as Map<String, String>)['price'] ?? '';
  double giaGoc = double.tryParse(giaTextValue) ?? 0.0; // Chuyển đổi giá trị 'giaTextValue' từ chuỗi sang số thực
  giaText = giaGoc.toStringAsFixed(0); // Sử dụng 'toStringAsFixed()' để định dạng số thực
});

     print('Sản phẩm được chọn: $_selectedMedicine');
  },
  
),

          ),),
                        //SizedBox(width: 10),
                        // Visibility(
                        //   visible: !_isDoneSelected,
                        //   child: Container(
                        //     width: 70,
                        //     child: Expanded(
                        //       child: Container(
                        //         // margin: EdgeInsets.only(left: 10),
                        //         child: GestureDetector(
                        //           onTap: () {
                        //             _showCustomerList(context).then((value) {
                        //               setState(() {
                        //                 _selectedCustomer = value;
                        //                 _searchControllerCustomer.text =
                        //                     _selectedCustomer
                        //                             ?.businessPartnerName ??
                        //                         '';
                        //                 currentSearchTextCustomer =
                        //                     _selectedCustomer
                        //                             ?.businessPartnerName
                        //                             ?.toLowerCase() ??
                        //                         '';
                        //                 filteredData = data.where((customer) {
                        //                   return (customer.businessPartnerName
                        //                                   ?.toLowerCase() ??
                        //                               '')
                        //                           .contains(
                        //                               currentSearchTextCustomer) ||
                        //                       (customer.internalID
                        //                                   ?.toLowerCase() ??
                        //                               '')
                        //                           .contains(
                        //                               currentSearchTextCustomer);
                        //                 }).toList();
                        //               });
                        //             });
                        //           },
                        //           child: Row(
                        //             children: [
                        //               Container(
                        //                 // color: Colors.black,
                        //                 margin: EdgeInsets.only(left: 10),
                        //                 width: 50,
                        //                 child: Row(children: [
                        //                   Icon(Icons.arrow_drop_down),
                        //                   //SizedBox(width: 10),
                        //                   if (_selectedCustomer != null)
                        //                     GestureDetector(
                        //                       onTap: () {
                        //                         setState(() {
                        //                           _selectedCustomer = null;
                        //                           _searchControllerCustomer
                        //                               .text = '';
                        //                           currentSearchTextCustomer =
                        //                               '';
                        //                           filteredData = data;
                        //                           _isDoneSelected = false;
                        //                         });
                        //                       },
                        //                       child: Icon(Icons.close),
                        //                     ),
                        //                 ]),
                        //               )
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left:20),
                        width: 150,
                        child: TextField(
                          onChanged: _handleCbTextFieldChanged,
                          enabled: _isChecked,
                          decoration:
                              InputDecoration(border: UnderlineInputBorder()),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isChecked = value!;
                                });
                              },
                            ),
                            Text('KM',
                                style: TextStyle(
                                  fontSize: 10,
                                )),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                        width: 110,
                      ),
                    ],
                  ),
                  Container(
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Số lượng',
                                    style: TextStyle(fontSize: 13)),
                                TextField(
                                  controller: _soluong,
                                   onChanged: _handleTextFieldChanged,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'SL',
                                    hintStyle: TextStyle(fontSize: 15),
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ],
                          ),
                          ),
                          Container(
                            width: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Giá gốc', style: TextStyle(fontSize: 13)),
                                TextField(
                                  controller: _giagoc,
                                  enabled: false,
                                  onChanged: _handleTextFieldChanged,
                                  decoration: InputDecoration(
                                    hintText: giaText,
                                    hintStyle: TextStyle(fontSize: 15),
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Chiết khấu',
                                    style: TextStyle(fontSize: 13)),
                                TextField(
                                  controller: _chietkhau,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(),
                                  onChanged: _handleTextFieldChanged,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Đơn giá', style: TextStyle(fontSize: 13)),
                                TextField(
                                controller: _DG,
                                // onChanged: (value) => _handleTextFieldChanged(value), // Gọi hàm _handleTextFieldChanged khi giá trị thay đổi
                                enabled: false, 
                                decoration: InputDecoration(
                                  hintText: donGia,
                                  hintStyle: TextStyle(fontSize: 15),
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                              ],
                            ),
                          ),
                          Container(
                            width: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thành tiền',
                                  style: TextStyle(fontSize: 13),
                                ),
                                TextField(
                                  controller: _TT,
                                  enabled: false,
                                onChanged: _handleTextFieldChanged,
                                  decoration: InputDecoration(
                                    hintText: _thanhTien.toString(),
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      
                      //thêm tính năng scroll bọc LimitedBox bên trong một SingleChildScrollView
                      ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 150, // chiều cao cố định ban đầu của ConstrainedBox
                          ),
                          child: ListView.builder(
                            itemCount: selectedProducts.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = selectedProducts[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [                                                                                                                                                                                                                                              
                                  GestureDetector(
                                    onTap: () => _handleTap(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedProductIndex == index
                                          ? Colors.grey
                                          : Colors.transparent,
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(item),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ],
                              );
                            
                            },
                          ),
                        ),
                      Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(padding: EdgeInsets.only(left: 10)),
                              OutlinedButton(
                                onPressed: () {
                                  int index =
                                      0; // Define the index variable here int index = 0; // Define the index variable here
                                  if (_selectedMedicine == null) {
                                    // Nếu giá trị không được chọn, hiển thị thông báo lỗi
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Thông báo'),
                                        content:
                                            Text('Bạn chưa chọn sản phẩm.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    final newText = _selectedMedicine;
                                    dynamic SoLuong = _soluong.text;
                                    dynamic giaBan = _DG.text;
                                    final CK = _chietkhau.text;
                                    dynamic ThanhTien = _TT.text;
                                    // dynamic Thue = SoLuong * giaBan * 5/100;
                                    print('Thanh tien: $ThanhTien');
                                    // final newProduct =
                                    //     '$newText - Số lượng: $SoLuong - Đơn giá: $giaBan Thành tiền: $ThanhTien - Chiết khấu: $CK ';
                                    //     print("Chuoi trong Thêm: $newProduct");
                                    // print(
                                    //     'Subtitle: ${filteredData[index].internalID ?? ''}');
                                    _addTextToList();
                                        
                                    setState(() {
                                
                                    //  _thanhTien = tinhThanhTien(soLuong, donGia, chietKhau);
                                      // Thue = SoLuong* giaGoc *0.05;
                                      print("SoLuong la: $soLuong");
                                      print("giaGoc la: $giaGoc");
                                      tongTienHang += double.parse(ThanhTien);
                                      tongThue += Thue;
                                      print('Thue la: $tongThue');
                                      print(
                                          'Tong tiên hàng ở nút thêm: $tongTienHang');
                                          resetFields();
                                    });
                                   
                                  }
                                },
                                child: Text('Thêm',
                                    style: TextStyle(color: Colors.black)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 10)),
                              GestureDetector(
                                onTap: () {
                                  if (_selectedProductIndex != null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Xác nhận xóa'),
                                          content: Text(
                                              'Bạn có chắc chắn muốn xóa sản phẩm này không?'),
                                          actions: <Widget>[
                                            OutlinedButton(
                                              child: Text('Hủy'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            OutlinedButton(
                                              child: Text('Xóa'),
                                              onPressed: () {
                                                if (_selectedProductIndex !=
                                                    null) {
                                                  final selectedProduct =
                                                      selectedProducts[
                                                          _selectedProductIndex!];
                                                  final pattern = RegExp(
                                                      r'Thành tiền: (\d+)');
                                                  final patternSL = RegExp(
                                                      r'Số lượng: (\d+)');
                                                  final patternCK = RegExp(
                                                      r'Chiết khấu: (\d+)');
                                                  final patternGG =
                                                      RegExp(r'Đơn giá: (\d+)');
                                                   final patternDG =
                                                      RegExp(r'Giá gốc: (\d+)');
                                                  final matchSL =
                                                      patternSL.firstMatch(
                                                          selectedProduct);
                                                 final matchDG =
                                                      patternDG.firstMatch(
                                                          selectedProduct);
                                                  final match =
                                                      pattern.firstMatch(
                                                          selectedProduct);
                                                  final matchCK =
                                                      patternCK.firstMatch(
                                                          selectedProduct);
                                                  final matchGG =
                                                      patternGG.firstMatch(
                                                          selectedProduct);
                                                  if (match != null &&
                                                      matchSL != null &&
                                                      matchCK != null &&
                                                    
                                                      matchDG != null) {
                                                    final soLuongString =
                                                        matchSL.group(1);
                                                    final thanhTienString =
                                                        match.group(1);
                                                    final chietKhauString =
                                                        matchCK.group(1);
                                                    final giagocString =
                                                        matchDG.group(1);
                                                    final GG = int.parse(
                                                        giagocString!);
                                                    final SL = int.parse(
                                                        soLuongString!);
                                                    final thanhTienCanXoa =
                                                        int.parse(
                                                            thanhTienString!); //Thuế = SL *DG      TT = GiaGoc *CK *SL   Total = Thue + TT
                                                    final _CK = int.parse(
                                                        chietKhauString!);
                                                    final _DG =
                                                        thanhTienCanXoa / SL;
                                                    final _thue =
                                                        SL * _DG * 0.05;
                                                    tongTienHang -=
                                                        thanhTienCanXoa;
                                                        print('tong thue truoc khi xoa: $tongThue');
                                                    tongThue -= _thue;
                                                    print('thanhTienCanXoa $thanhTienCanXoa');
                                                    print('thue can xoa $_thue');
                                                    print('tong thue sau khi xoa: $tongThue');
                                                  }
                                                  selectedProducts.removeAt(
                                                      _selectedProductIndex!);
                                                  _selectedProductIndex = null;
                                                  setState(() {});
                                                }
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectedProductIndex != null
                                        ? Colors.red
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      'Xoá',
                                      style: TextStyle(
                                          color: _selectedProductIndex != null
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 10)),
                              OutlinedButton(
                                onPressed:
                                    _isItemSelected ? _handleEditButton : null,
                                child: Text(
                                  'Sửa',
                                  style: TextStyle(
                                      color: _selectedProductIndex != null
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16),
                                ),
                                style: buttonStyle.copyWith(
                                  backgroundColor: _isItemSelected
                                      ? MaterialStateProperty.all(Colors.blue)
                                      : MaterialStateProperty.all(Colors.grey),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(left: 10)),
                              OutlinedButton(
                                  onPressed: () async {
                                    String message = await fetchDataUp();
                                    if (message == 'success') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              backgroundColor: Colors.blue,
                                              content: Text(
                                                'Thêm thành công',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )));
                                      productIDController.clear();
                                      quantityController.clear();
                                      decimalValueController.clear();
                                      partyIDController.clear();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text('Thêm thất bại ')));
                                    }
                                  },
                                  child: Text('Lưu',
                                      style: TextStyle(color: Colors.white)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ))
                            ]),
                      )
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    height: 100,
                    // color: Color.fromARGB(255, 214, 212, 212),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tiền hàng'),
                              Text('Thuế'),
                              Text('Tổng cộng'),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                  // padding: EdgeInsets.all(10),
                                  height: 70,
                                  width: 200,
                                  // color: Colors.white,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          currencyFormatter
                                                  .format(tongTienHang) +
                                              'VNĐ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          currencyFormatter.format(tongThue) +
                                              'VNĐ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          currencyFormatter.format(
                                                  tongTienHang + tongThue) +
                                              'VNĐ',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ]))
                            ],
                          ),
                        ]),
                  )
                ],
              ),
            )));
  }
}
