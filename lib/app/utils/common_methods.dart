import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceInfo {
  int deviceType = 0;
  String deviceToken = '';

  DeviceInfo({required this.deviceType, required this.deviceToken});
}

class CommonMethods {
  CommonMethods._();

  // To dismiss keyboard
  static hideKeyBoard() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  // To go back
  static onBackPress() async {
    SystemNavigator.pop();
  }

  static showToast(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
    ));
  }

  static DateTime stringToDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      throw Exception("Invalid date format.");
    }
  }
}
