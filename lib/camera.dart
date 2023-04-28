import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:opc_app_main/api_SOAP.dart';
import 'package:opc_app_main/api_save.dart';
import 'package:opc_app_main/call_api.dart';
import 'package:opc_app_main/camera.dart';
import 'package:opc_app_main/customer.dart';
import 'package:opc_app_main/login_screen.dart';
import 'package:opc_app_main/orderList_screen.dart';
import 'package:opc_app_main/order_screen.dart';
import 'package:opc_app_main/post_api.dart';
import 'package:opc_app_main/statistical_screen.dart';
import 'package:opc_app_main/visit_customer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewMain extends StatefulWidget {
  final bool isLoggedIn;
  NewMain({required this.isLoggedIn});
  @override
  State<StatefulWidget> createState() {
    return Body();
  }
}

class Body extends State<NewMain> {
  bool isUserGD = false; // initialize with false
  String? userRole = null; // fetch user's role using getChucDanh()
  String? hoten;
  String? chuc_Danh;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showBottomSheet = false;
  bool _isLoggedIn = false;
  Color _backgroundColor = Colors.white;
  int index = 0;
  TextEditingController _searchController = TextEditingController();

  int selectedIndex = 0;
  Future<void> getHoten() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hoten = prefs.getString('hoten') ?? '';
    setState(() {});
  }

  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    login('username', 'password', 'GD').catchError((e) {
      print('Login error: $e');
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    prefs = await SharedPreferences.getInstance();
    final chucDanh = prefs.getString('chucdanh');
    if (chucDanh != null && chucDanh.toUpperCase() == 'GD') {
      setState(() {
        this.chuc_Danh = 'GD';
        isUserGD = true;
      });
    } else {
      setState(() {
        this.chuc_Danh = 'Unknown';
        isUserGD = false;
      });
    }
  }

  Future<void> login(String username, String password, String chucDanh) async {
    final url = "http://118.69.225.144/api/User";
    final response = await http.post(Uri.parse(url),
        body: {'tendangnhap': username, 'matkhau': password});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('API response: $jsonResponse');
      if (jsonResponse.containsKey('chuc_Danh')) {
        final chucDanhFromApi = jsonResponse['chuc_Danh'];
        prefs.setString('chucdanh', chucDanhFromApi);

        if (chucDanhFromApi.toUpperCase() == 'GD') {
          setState(() {
            this.chuc_Danh = 'GD';
            isUserGD = true;
          });
        } else {
          setState(() {
            this.chuc_Danh = 'Unknown';
            isUserGD = false;
          });
        }
      } else {
        print('Error getting chuc_Danh: key not found');
        setState(() {
          this.chuc_Danh = 'Unknown';
          isUserGD = false;
        });
      }
    } else {
      throw Exception('Failed to get chuc_Danh from API');
    }

    // Perform any necessary action using the value of chucDanh parameter here
    print('chuc_Danh parameter: $chucDanh');
  }

  @override
  Widget build(BuildContext context) {
    getHoten();
    // It will provie us total height  and width of our screen
    Size size = MediaQuery.of(context).size;
    // it enable scrolling on small device
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: Drawer(
          child: Container(
            color: Color.fromARGB(255, 214, 212,
                212), // Thiết lập màu nền trắng cho toàn bộ Drawer
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Container(
                      //  padding: EdgeInsets.only(top:10),
                      height: 100,
                      color: Color.fromARGB(255, 158, 136, 121),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage('images/user.png'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt,
                                      color: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      showBottomSheet = true;
                                    });
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                                0.8), // opacity giữa 0 và 1
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0),
                                              bottomLeft: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.white,
                                                  onPrimary: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.camera_alt),
                                                    SizedBox(
                                                        width:
                                                            8.0), // thêm khoảng cách giữa icon và text
                                                    Text(
                                                      'Chụp ảnh',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () {},
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.white,
                                                  onPrimary: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.photo_library),
                                                    SizedBox(width: 10.0),
                                                    Text('Chọn ảnh từ thư viện',
                                                        style: TextStyle(
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                                onPressed: () {},
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.blueGrey[
                                                      800], // sử dụng màu xanh dương
                                                  onPrimary: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0), // chỉ định bán kính bo tròn
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.cancel),
                                                    SizedBox(width: 10),
                                                    Text('Hủy',
                                                        style: TextStyle(
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ).then((value) {
                                      setState(() {
                                        showBottomSheet = false;
                                      });
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Text(hoten ?? '',
                              style: TextStyle(fontFamily: 'Labrada')),
                        ],
                      )),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.account_circle_rounded, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Thông tin cá nhân',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'Labrada')),
                    ],
                  ),
                  onTap: () {
                    // Do something
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.group_add_outlined, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Thêm User',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'Labrada')),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PostApi()));
                  },
                ),
                if (isUserGD) // Only show if user is GD
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.check, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'Phê duyệt tài khoản',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Labrada',
                          ),
                        ),
                      ],
                    ),
                  ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Cài đặt',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'Labrada')),
                    ],
                  ),
                  onTap: () {
                    // Do something
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Đăng xuất',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'Labrada')),
                    ],
                  ),
                  onTap: () async {
                    setState(() {
                      _isLoggedIn = false;
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(
                                Icons.logout, // Icon logout
                                color: Colors.red,
                                size: 24,
                              ),
                              SizedBox(
                                  width: 8), // Khoảng cách giữa Icon và Text
                              Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 16),
                              Text(
                                'Bạn có chắc chắn muốn đăng xuất?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    child: Text(
                                      'Có',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.clear();
                                      Navigator.of(context).pop();
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                LoginScreen()),
                                        ModalRoute.withName('/'),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    child: Text(
                                      'Không',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      // Xử lý khi người dùng chọn không đăng xuất ở đây
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(10, 141, 94, 1),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded),
            onPressed: () {
              if (_scaffoldKey.currentState != null) {
                _scaffoldKey.currentState!.openDrawer();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  color: Colors.white,
                  height: size.height * 0.2,
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.draw_rounded,
                            color: Colors.black,
                          )
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(left: 20, right: 10, bottom: 40),
                        height: size.height * 0.2 - 27,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(10, 141, 94, 1),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(36),
                                bottomRight: Radius.circular(
                                  36,
                                ))),
                        child: Row(
                          children: [
                            Text(
                              'OPC-APP',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Labrada'),
                            ),
                            Spacer(),
                            Image.asset(
                              'images/logo.png',
                              width: 100,
                              height: 80,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            height: 54,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 10),
                                    blurRadius: 50,
                                    color: Colors.black.withOpacity(0.30),
                                  )
                                ]),
                            child: TextField(
                              style: TextStyle(
                                  color: Colors.black, fontFamily: 'Labrada'),
                              decoration: InputDecoration(
                                  hintText: "Tìm kiếm",
                                  hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontFamily: 'NotoSerif'),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 20.0, bottom: 10.0, top: 10.0),
                                  suffixIcon: Icon(
                                    Icons.search,
                                    color: Colors.black54,
                                  )),
                            ),
                          ))
                    ],
                  )),
              SizedBox(
                height: 40,
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Column(children: [
                          PopupMenuButton(
                            color: _backgroundColor,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text(
                                  "1. Danh mục khách hàng",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                                value: 1,
                              ),
                              PopupMenuItem(
                                child: Text(
                                  "2. Danh mục bảng giá",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                                value: 2,
                              ),
                              PopupMenuItem(
                                child: Text(
                                  "3. Danh mục đối tác",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                                value: 3,
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 1:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CustomerPage()),
                                  );
                                  break;
                                case 2:
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => PriceListCategoryPage()),
                                  // );
                                  break;
                                case 3:
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => PartnerCategoryPage()),
                                  // );
                                  break;
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'DANH MỤC',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        child: Column(
                          children: [
                            PopupMenuButton(
                              color: _backgroundColor,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Text(
                                    "1. Viếng thăm khách hàng",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: 1,
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    "2. Danh sách đơn hàng",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: 2,
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    "3. Đơn đặt hàng TDV",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: 3,
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    "4. Bảng kê nộp tiền mặt",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: 4,
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    "5. Bảng kê nộp tiền GH",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: 5,
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    "6. Thu nợ khách hàng",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: 6,
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    "7. Thêm sản phẩm",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: 7,
                                ),
                              ],
                              onSelected: (value) {
                                switch (value) {
                                  case 1:
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VisitCustomerPage()),
                                    );
                                    break;
                                  case 2:
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => PriceListCategoryPage()),
                                    // );
                                    break;
                                  case 3:
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => PartnerCategoryPage()),
                                    // );
                                    break;
                                  case 4:
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => PartnerCategoryPage()),
                                    // );
                                    break;
                                  case 5:
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => PartnerCategoryPage()),
                                    // );
                                    break;
                                  case 6:
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => PartnerCategoryPage()),
                                    // );
                                    break;
                                  case 7:
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => PartnerCategoryPage()),
                                    // );
                                    break;
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'BÁN HÀNG',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // color: Colors.red,
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewScreen()),
                              );
                            },
                            child: Text(
                              'BÁO CÁO',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            style: OutlinedButton.styleFrom(
                                minimumSize: Size(100, 50),
                                side: BorderSide(color: Colors.transparent))),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                height: 30,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            'TRANG CHỦ',
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Labrada',
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: EdgeInsets.only(right: 20),
                            height: 7,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      color: Color.fromARGB(255, 255, 255, 255),
                      margin: EdgeInsets.only(left: 20, top: 30, bottom: 20),
                      width: size.width * 0.4,
                      child: GestureDetector(
                        onTap: () {
                          // Xử lý sự kiện khi người dùng nhấp vào Column ở đây
                          // Ví dụ: chuyển sang một trang khác
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ApiSave()),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset('images/viengtham.png'),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(10, 141, 94, 1),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 10),
                                      blurRadius: 40,
                                      color: Colors.black.withOpacity(0.4),
                                    )
                                  ]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Viếng thăm',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Labrada')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Container(
                      color: Color.fromARGB(255, 255, 255, 255),
                      margin: EdgeInsets.only(
                          left: 20, top: 30, bottom: 20, right: 20),
                      width: size.width * 0.4,
                      child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện khi người dùng nhấp vào Column ở đây
                            // Ví dụ: chuyển sang một trang khác
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderListScreen()),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('images/notebook.png'),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(10, 141, 94, 1),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 10),
                                        blurRadius: 40,
                                        color: Colors.black.withOpacity(0.4),
                                      )
                                    ]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('DS Đơn hàng',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Labrada')),
                                  ],
                                ),
                              ),
                            ],
                          ))),
                ],
              ),
              Row(
                children: [
                  Container(
                      color: Color.fromARGB(255, 255, 255, 255),
                      margin: EdgeInsets.only(
                          left: 20, top: 30, bottom: 20, right: 20),
                      width: size.width * 0.4,
                      child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện khi người dùng nhấp vào Column ở đây
                            // Ví dụ: chuyển sang một trang khác
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderPage()),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('images/document.png'),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(10, 141, 94, 1),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 10),
                                        blurRadius: 40,
                                        color: Colors.black.withOpacity(0.4),
                                      )
                                    ]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Đơn hàng',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Labrada')),
                                  ],
                                ),
                              )
                            ],
                          ))),
                  Container(
                      color: Color.fromARGB(255, 255, 255, 255),
                      margin: EdgeInsets.only(left: 20, top: 30, bottom: 20),
                      width: size.width * 0.4,
                      child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện khi người dùng nhấp vào Column ở đây
                            // Ví dụ: chuyển sang một trang khác
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => APISoap()),
                            );
                          },
                          child: Column(
                            children: [
                              Image.asset('images/doipass.png'),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(10, 141, 94, 1),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 10),
                                        blurRadius: 40,
                                        color: Colors.black.withOpacity(0.4),
                                      )
                                    ]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Đổi pass',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Labrada')),
                                  ],
                                ),
                              )
                            ],
                          ))),
                ],
              ),
              Container(
                  color: Color.fromARGB(255, 255, 255, 255),
                  margin: EdgeInsets.only(left: 20, top: 30, bottom: 20),
                  width: size.width * 0.4,
                  child: GestureDetector(
                      onTap: () {
                        // Xử lý sự kiện khi người dùng nhấp vào Column ở đây
                        // Ví dụ: chuyển sang một trang khác
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => ApiSave()),
                        // );
                      },
                      child: Column(
                        children: [
                          Image.asset('images/KH_onl.png'),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(10, 141, 94, 1),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 10),
                                    blurRadius: 40,
                                    color: Colors.black.withOpacity(0.4),
                                  )
                                ]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('KH online',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Labrada')),
                              ],
                            ),
                          )
                        ],
                      ))),
            ],
          ),
        ));
  }
}
