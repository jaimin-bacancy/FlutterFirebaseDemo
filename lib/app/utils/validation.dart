import 'package:firebase_demo/app/base_config/configs/string_config.dart';

class Validation {
  Validation._();

  // Email validation
  static String? validateEmail(String value) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return StringConfig.pleaseEnterEmail;
    } else if (!regExp.hasMatch(value)) {
      return StringConfig.pleaseProvideValidEmail;
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regExp = RegExp(pattern);
    if (value.trim().isEmpty) {
      return StringConfig.pleaseEnterPassword;
    } else if (value.trim().length < 8) {
      return StringConfig.passwordLengthError;
    } else if (!regExp.hasMatch(value)) {
      return StringConfig.specialCharValidation;
    }
    return null;
  }

  // Empty string validation
  static String? validateEmptyField(
      {required String value,
      String errorMsg = StringConfig.fieldCannotBeEmpty}) {
    if (value.isEmpty) {
      return errorMsg;
    }
    return null;
  }
}
