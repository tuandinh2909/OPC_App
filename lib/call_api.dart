class Autogenerated {
  D? d;

  Autogenerated({this.d});

  Autogenerated.fromJson(Map<String, dynamic> json) {
    d = json['d'] != null ? new D.fromJson(json['d']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.d != null) {
      data['d'] = this.d!.toJson();
    }
    return data;
  }
}

class D {
  List<Results>? results;

  D({this.results});

  D.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  Metadata? mMetadata;
  String? objectID;
  String? parentObjectID;
  String? internalID;
  String? employeeUUID;
  String? partyRoleCode;
  String? uUID;
  String? employeeID;
  Customer? customer;

  Results(
      {this.mMetadata,
      this.objectID,
      this.parentObjectID,
      this.internalID,
      this.employeeUUID,
      this.partyRoleCode,
      this.uUID,
      this.employeeID,
      this.customer});

  Results.fromJson(Map<String, dynamic> json) {
    mMetadata = json['__metadata'] != null
        ? new Metadata.fromJson(json['__metadata'])
        : null;
    objectID = json['ObjectID'];
    parentObjectID = json['ParentObjectID'];
    internalID = json['InternalID'];
    employeeUUID = json['EmployeeUUID'];
    partyRoleCode = json['PartyRoleCode'];
    uUID = json['UUID'];
    employeeID = json['EmployeeID'];
    customer = json['Customer'] != null
        ? new Customer.fromJson(json['Customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mMetadata != null) {
      data['__metadata'] = this.mMetadata!.toJson();
    }
    data['ObjectID'] = this.objectID;
    data['ParentObjectID'] = this.parentObjectID;
    data['InternalID'] = this.internalID;
    data['EmployeeUUID'] = this.employeeUUID;
    data['PartyRoleCode'] = this.partyRoleCode;
    data['UUID'] = this.uUID;
    data['EmployeeID'] = this.employeeID;
    if (this.customer != null) {
      data['Customer'] = this.customer!.toJson();
    }
    return data;
  }
}

class Metadata {
  String? uri;
  String? type;

  Metadata({this.uri, this.type});

  Metadata.fromJson(Map<String, dynamic> json) {
    uri = json['uri'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uri'] = this.uri;
    data['type'] = this.type;
    return data;
  }
}

class Customer {
  Metadata? mMetadata;
  String? objectID;
  String? internalID;
  String? categoryCode;
  String? businessPartnerName;
  String? businessPartnerFormattedName;
  String? industrialSectorCode;
  String? customerABCClassificationCode;
  SalesArrangementSalesArrangement? salesArrangementSalesArrangement;
  SalesArrangementSalesArrangement? customerCurrentEmployeeResponsible;
  SalesArrangementSalesArrangement? customerFormattedAddressV1;

  Customer(
      {this.mMetadata,
      this.objectID,
      this.internalID,
      this.categoryCode,
      this.businessPartnerName,
      this.businessPartnerFormattedName,
      this.industrialSectorCode,
      this.customerABCClassificationCode,
      this.salesArrangementSalesArrangement,
      this.customerCurrentEmployeeResponsible,
      this.customerFormattedAddressV1});

  Customer.fromJson(Map<String, dynamic> json) {
    mMetadata = json['__metadata'] != null
        ? new Metadata.fromJson(json['__metadata'])
        : null;
    objectID = json['ObjectID'];
    internalID = json['InternalID'];
    categoryCode = json['CategoryCode'];
    businessPartnerName = json['BusinessPartnerName'];
    businessPartnerFormattedName = json['BusinessPartnerFormattedName'];
    industrialSectorCode = json['IndustrialSectorCode'];
    customerABCClassificationCode = json['CustomerABCClassificationCode'];
    salesArrangementSalesArrangement =
        json['SalesArrangementSalesArrangement'] != null
            ? new SalesArrangementSalesArrangement.fromJson(
                json['SalesArrangementSalesArrangement'])
            : null;
    customerCurrentEmployeeResponsible =
        json['CustomerCurrentEmployeeResponsible'] != null
            ? new SalesArrangementSalesArrangement.fromJson(
                json['CustomerCurrentEmployeeResponsible'])
            : null;
    customerFormattedAddressV1 = json['CustomerFormattedAddressV1'] != null
        ? new SalesArrangementSalesArrangement.fromJson(
            json['CustomerFormattedAddressV1'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mMetadata != null) {
      data['__metadata'] = this.mMetadata!.toJson();
    }
    data['ObjectID'] = this.objectID;
    data['InternalID'] = this.internalID;
    data['CategoryCode'] = this.categoryCode;
    data['BusinessPartnerName'] = this.businessPartnerName;
    data['BusinessPartnerFormattedName'] = this.businessPartnerFormattedName;
    data['IndustrialSectorCode'] = this.industrialSectorCode;
    data['CustomerABCClassificationCode'] = this.customerABCClassificationCode;
    if (this.salesArrangementSalesArrangement != null) {
      data['SalesArrangementSalesArrangement'] =
          this.salesArrangementSalesArrangement!.toJson();
    }
    if (this.customerCurrentEmployeeResponsible != null) {
      data['CustomerCurrentEmployeeResponsible'] =
          this.customerCurrentEmployeeResponsible!.toJson();
    }
    if (this.customerFormattedAddressV1 != null) {
      data['CustomerFormattedAddressV1'] =
          this.customerFormattedAddressV1!.toJson();
    }
    return data;
  }
}

class SalesArrangementSalesArrangement {
  Deferred? dDeferred;

  SalesArrangementSalesArrangement({this.dDeferred});

  SalesArrangementSalesArrangement.fromJson(Map<String, dynamic> json) {
    dDeferred = json['__deferred'] != null
        ? new Deferred.fromJson(json['__deferred'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dDeferred != null) {
      data['__deferred'] = this.dDeferred!.toJson();
    }
    return data;
  }
}

class Deferred {
  String? uri;

  Deferred({this.uri});

  Deferred.fromJson(Map<String, dynamic> json) {
    uri = json['uri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uri'] = this.uri;
    return data;
  }
}

class User {
  String? tendangnhap;
  String? matkhau;
  String? hoten;
  int? id;
  String? maDvcs;
  String? maCbNv;
  String? chucDanh;
  String? maTDVExtra;
  String? maKho;

  User(
      {this.tendangnhap,
      this.matkhau,
      this.hoten,
      this.id,
      this.maDvcs,
      this.maCbNv,
      this.chucDanh,
      this.maTDVExtra,
      this.maKho});

  User.fromJson(Map<String, dynamic> json) {
    tendangnhap = json['tendangnhap'];
    matkhau = json['matkhau'];
    hoten = json['hoten'];
    id = json['id'];
    maDvcs = json['ma_Dvcs'];
    maCbNv = json['ma_CbNv'];
    chucDanh = json['chuc_Danh'];
    maTDVExtra = json['ma_TDV_Extra'];
    maKho = json['ma_Kho'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tendangnhap'] = this.tendangnhap;
    data['matkhau'] = this.matkhau;
    data['hoten'] = this.hoten;
    data['id'] = this.id;
    data['ma_Dvcs'] = this.maDvcs;
    data['ma_CbNv'] = this.maCbNv;
    data['chuc_Danh'] = this.chucDanh;
    data['ma_TDV_Extra'] = this.maTDVExtra;
    data['ma_Kho'] = this.maKho;
    return data;
  }
}

class Products {
  final String maVt;
  late final String tenVtDmVt;
  late final double gia;
  late final double thueGtgt;

  Products({
    required this.maVt,
    required this.tenVtDmVt,
    required this.gia,
    required this.thueGtgt,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      maVt: json['ma_vt'],
      tenVtDmVt: json['Ten_Vt_DmVt'],
      gia: json['gia'],
      thueGtgt: (json['Thue_Gtgt']),
    );
  }
}
