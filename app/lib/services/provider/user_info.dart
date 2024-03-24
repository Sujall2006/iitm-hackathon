import 'package:flutter/cupertino.dart';

class UserInfo {
  const UserInfo({required this.username, required this.mailId, required this.name, required this.phoneNumber});
  final String username;
  final String name;
  final String phoneNumber;
  final String mailId;
}

class UserInfoProvider extends ChangeNotifier {
  UserInfo? _userInfo;

  void setUserInfo(UserInfo userInfo) {
    _userInfo = userInfo;
    notifyListeners();
  }

  UserInfo? getUserInfo() => _userInfo;
}