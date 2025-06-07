import 'package:intl/intl.dart';

class User{
  int? id;
  String? userName;
  String? password;
  String? fullName;
  bool? status;
  String? email;
  String? phone;
  String? role;
  String? avatar;

  User({this.id, this.userName, this.password, this.fullName, this.status,
     this.email, this.phone, this.role, this.avatar});

  Map<String, dynamic> toMap(){
    var dateFormat = DateFormat("dd/MM/yyyy");
    return <String, dynamic>{
      "userName": userName,
      "password": password,
      "id": id,
      "email": email,
      "fullName": fullName,
      "status": status,
      "phone": phone,
      "role" : role,
      "avatar": avatar
    };
  }

  User.fromMap(Map<String, dynamic> map) {
    var dateFormat = DateFormat("dd/MM/yyyy");
    id = map["id"];
    userName = map["userName"] ?? '';
    password = map["password"] ?? '';
    email = map["email"] ?? '';
    fullName = map["fullName"] ?? '';
    status = map["status"] ?? 'false';
    phone = map["phone"] ?? '';
    role = map["role"];
    avatar = map["avatar"];
  }

  @override
  String toString() {
    return 'User{id: $id, userName: $userName, password: $password, fullName: $fullName, status: $status, email: $email, phone: $phone, role: $role}';
  }
}