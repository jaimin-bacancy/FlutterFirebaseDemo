abstract class StringConfig {
  StringConfig._();

  //Login Screen
  static const String loginText = 'Login';
  static const String emailIdText = 'Email ID';
  static const String enterEmailText = 'Enter email ID';
  static const String passwordText = 'Password';
  static const String enterPasswordText = 'Enter Password';
  static const String submit = 'Submit';
  static const String registerAccountText = "New to Awesome App? ";
  static const String registerText = 'Register';

  //Register Screen
  static const String nameText = 'Name';
  static const String enterNameText = 'Enter name';
  static const String alreadyUserText = "Already a user? ";

  // Field validations
  static const String fieldCannotBeEmpty = 'This field cann\'t be empty';
  static const String pleaseEnterPassword = 'Please enter password';
  static const String pleaseEnterName = 'Please enter name';
  static const String passwordLengthError =
      'The password must be at least 8 characters';
  static const String specialCharValidation =
      'Password must contain at least one number and both uppercase and lowercase letters.';
  static const String pleaseProvideValidEmail = 'Please provide valid Email ID';
  static const String pleaseEnterEmail = 'Please enter Email ID';
  static const String emailPasswordCannotBeEmpty =
      "Email/Password cannot be empty";
  static const String nameEmailPasswordCannotBeEmpty =
      "Name/Email/Password cannot be empty";
  static const String invalidCredentials = "Invalid Credentials";
  static const String theAccountAlreadyExistsForThatEmail =
      "The account already exists for that email.";
  static const String invalidEmail = "Invalid Email";
  static const String somethingWantWrong = "Something want wrong";
  static const String userNotFound = "User not found";
  static const String userDisabled = "User disabled";

  // Common
  static const String ORText = 'OR';
}
