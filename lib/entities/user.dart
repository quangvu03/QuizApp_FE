import 'package:intl/intl.dart';

class User{
  int? id;
  String? username;
  String? password;
  String? fullName;
  int? status;
  String? securityCode;
  String? email;
    DateTime? dob;
  String? phone;
  int? role;
  User({this.id, this.username, this.password, this.fullName, this.status,
    this.securityCode, this.email, this.phone, this.dob, this.role});

  Map<String, dynamic> toMap(){
    var dateFormat = DateFormat("dd/MM/yyyy");
    return <String, dynamic>{
      "username": username,
      "password": password,
      "id": id,
      "email": email,
      "fullName": fullName,
      "status": status,
      "securityCode": securityCode,
      "created": dob != null ? dateFormat.format(dob!) : null,
      "phone": phone,
      "role" : role
    };
  }

  User.fromMap(Map<String, dynamic> map) {
    var dateFormat = DateFormat("dd/MM/yyyy");
    id = map["id"];
    username = map["username"] ?? '';
    password = map["password"] ?? '';
    email = map["email"] ?? '';
    fullName = map["fullName"] ?? '';
    status = map["status"] is bool ? (map["status"] ? 1 : 0) : map["status"] as int?;
    securityCode = map["securityCode"] ?? '';
    dob = map["created"] != null ? dateFormat.parse(map["created"]) : null;
    phone = map["phone"] ?? '';
    role = map["role"];
  }
}