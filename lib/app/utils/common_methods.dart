import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/app/presentation/screens/startup/startup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  static resetToStartUp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const StartupScreen(),
      ),
    );
  }

  static Future<bool> checkAlreadyExist(
      String collection, String document) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      final docRef = db.collection(collection).doc(document);
      final snapshot = await docRef.get();
      return snapshot.exists;
    } catch (e) {
      rethrow;
    }
  }

  static String getLookupMessage(
      DateTime startTime, String prefix, String suffix) {
    final diffTime = DateTime.now().subtract(Duration(
        minutes: startTime.minute,
        days: startTime.day,
        hours: startTime.hour,
        microseconds: startTime.microsecond,
        milliseconds: startTime.millisecond,
        seconds: startTime.second));

    String lookup = timeago.format(diffTime, locale: 'en_short');
    return "$prefix $lookup $suffix";
  }
}
