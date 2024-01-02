// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/presentation/screens/home/home_screen.dart';
import 'package:firebase_demo/app/services/user_service.dart';
import 'package:firebase_demo/app/utils/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  BuildContext context;

  AuthService(this.context);

  Stream<User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  Future<String?> getCurrentUID() async {
    return _firebaseAuth.currentUser?.uid;
  }

  void signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        UserService(context).checkAlreadyExist(user.uid).then((ifExist) {
          if (ifExist) {
            CommonMethods.resetToStartUp(context);
          } else {
            UserService(context)
                .createUser(user.uid, user.displayName ?? "", user.email!)
                .then((isCreated) {
              if (isCreated) {
                CommonMethods.resetToStartUp(context);
              } else {
                CommonMethods.showToast(
                    context, StringConfig.somethingWantWrong);
              }
            });
          }
        });
      } else {
        CommonMethods.showToast(context, StringConfig.somethingWantWrong);
      }
    } catch (e) {
      CommonMethods.showToast(context, StringConfig.somethingWantWrong);
    }
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
            CommonMethods.resetToStartUp(context);
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
      CommonMethods.resetToStartUp(context);
    }).catchError((e) {
      CommonMethods.showToast(context, StringConfig.somethingWantWrong);
    });
  }
}
