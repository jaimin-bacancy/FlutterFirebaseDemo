import 'package:firebase_demo/app/base_config/configs/images_config.dart';
import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/presentation/screens/register/register_screen.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
import 'package:firebase_demo/app/utils/common_methods.dart';
import 'package:firebase_demo/app/utils/validation.dart';
import 'package:firebase_demo/app/widgets/form_button.dart';
import 'package:firebase_demo/app/widgets/form_input.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConfig.loginText)),
      body: const LoginForm(),
    );
  }
}

void onSubmitPress(BuildContext context, String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    CommonMethods.showToast(context, StringConfig.emailPasswordCannotBeEmpty);
  } else if (Validation.validateEmail(email) != null) {
    CommonMethods.showToast(context, Validation.validateEmail(email) ?? "");
  } else if (Validation.validatePassword(password) != null) {
    CommonMethods.showToast(
        context, Validation.validatePassword(password) ?? "");
  } else {
    AuthService(context).signInWithEmail(email, password);
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FormInput(
            initialValue: _email,
            label: StringConfig.emailIdText,
            placeholderText: StringConfig.enterEmailText,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.emailAddress,
            onChanged: (text) {
              _email = text;
            },
            validator: (value) {
              return Validation.validateEmail(value!);
            },
          ),
          const SizedBox(height: 12),
          FormInput(
            initialValue: _password,
            label: StringConfig.passwordText,
            placeholderText: StringConfig.enterPasswordText,
            obscureText: true,
            textInputAction: TextInputAction.done,
            textInputType: TextInputType.visiblePassword,
            onChanged: (text) {
              _password = text;
            },
            validator: (value) {
              return Validation.validatePassword(value!);
            },
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Center(
                  child: FormButton(
                label: StringConfig.submit,
                onButtonPress: () {
                  onSubmitPress(context, _email, _password);
                },
              )),
              const SizedBox(height: 12),
            ],
          ),
          const Separator(),
          const SocialAuth(),
          const SizedBox(height: 12),
          const RegisterView(),
        ]),
      ),
    );
  }
}

class SocialAuth extends StatelessWidget {
  const SocialAuth({super.key});

  void onGooglePress(BuildContext context) async {}

  void onFacebookPress(BuildContext context) {
    print("Facebook");
  }

  void onApplePress(BuildContext context) {
    print("Apple");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialAuthItem(
            icon: ImagesConfig.googleSignIn,
            onPress: () {
              onGooglePress(context);
            }),
      ],
    );
  }
}

class SocialAuthItem extends StatelessWidget {
  const SocialAuthItem({super.key, required this.icon, required this.onPress});

  final Function onPress;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          onPress();
        },
        child: Image.asset(
          icon,
          width: 28,
          height: 28,
        ),
      ),
    );
  }
}

class Separator extends StatelessWidget {
  const Separator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(children: <Widget>[
      Expanded(
          child: Divider(
        endIndent: 10,
        indent: 10,
        color: Colors.black38,
      )),
      Text(StringConfig.ORText),
      Expanded(
          child: Divider(
        indent: 10,
        endIndent: 10,
        color: Colors.black38,
      )),
    ]);
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  void onRegisterPress(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const RegisterScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          StringConfig.registerAccountText,
          style: TextStyle(fontSize: 14),
        ),
        InkWell(
            onTap: () => {onRegisterPress(context)},
            child: const Text(StringConfig.registerText,
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)))
      ],
    );
  }
}
