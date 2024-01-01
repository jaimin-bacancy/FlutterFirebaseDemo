// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/presentation/screens/home/home_screen.dart';
import 'package:firebase_demo/app/presentation/screens/startup/startup_screen.dart';
import 'package:firebase_demo/app/services/user_service.dart';
import 'package:firebase_demo/app/utils/common_methods.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  BuildContext context;

  AuthService(this.context);

  Stream<User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  Future<String?> getCurrentUID() async {
    return _firebaseAuth.currentUser?.uid;
  }

  void signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "INVALID_LOGIN_CREDENTIALS" || e.code == "wrong-password") {
        CommonMethods.showToast(context, StringConfig.invalidCredentials);
      } else if (e.code == "user-disabled") {
        CommonMethods.showToast(context, StringConfig.userDisabled);
      } else if (e.code == "user-not-found") {
        CommonMethods.showToast(context, StringConfig.userNotFound);
      } else {
        CommonMethods.showToast(context, StringConfig.somethingWantWrong);
      }
    } catch (e) {
      CommonMethods.showToast(context, StringConfig.somethingWantWrong);
    }
  }

  void registerUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        UserService(context)
            .createUser(user.uid, name, user.email!)
            .then((isCreated) {
          if (isCreated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const StartupScreen(),
              ),
            );
          } else {
            CommonMethods.showToast(context, StringConfig.somethingWantWrong);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        CommonMethods.showToast(
            context, StringConfig.theAccountAlreadyExistsForThatEmail);
      } else if (e.code == 'invalid-email') {
        CommonMethods.showToast(context, StringConfig.invalidEmail);
      } else {
        CommonMethods.showToast(context, StringConfig.somethingWantWrong);
      }
    } catch (e) {
      CommonMethods.showToast(context, StringConfig.somethingWantWrong);
    }
  }

  void logout() {
    _firebaseAuth.signOut().then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StartupScreen(),
        ),
      );
    }).catchError((e) {
      CommonMethods.showToast(context, StringConfig.somethingWantWrong);
    });
  }
}
