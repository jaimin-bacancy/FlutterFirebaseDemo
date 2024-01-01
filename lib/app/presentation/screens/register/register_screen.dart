import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
import 'package:firebase_demo/app/utils/common_methods.dart';
import 'package:firebase_demo/app/utils/validation.dart';
import 'package:firebase_demo/app/widgets/form_button.dart';
import 'package:firebase_demo/app/widgets/form_input.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(StringConfig.registerText)),
        body: const RegisterForm());
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String _name = "";
  String _email = "";
  String _password = "";

  void onSubmitPress(context) {
    if (_email.isEmpty || _password.isEmpty || _name.isEmpty) {
      CommonMethods.showToast(
          context, StringConfig.nameEmailPasswordCannotBeEmpty);
    } else if (Validation.validateEmail(_email) != null) {
      CommonMethods.showToast(context, Validation.validateEmail(_email) ?? "");
    } else if (Validation.validatePassword(_password) != null) {
      CommonMethods.showToast(
          context, Validation.validatePassword(_password) ?? "");
    } else {
      AuthService(context).registerUser(_name, _email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FormInput(
            initialValue: _name,
            label: StringConfig.nameText,
            placeholderText: StringConfig.enterNameText,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.emailAddress,
            onChanged: (text) {
              _name = text;
            },
          ),
          const SizedBox(height: 12),
          FormInput(
            initialValue: _email,
            label: StringConfig.emailIdText,
            placeholderText: StringConfig.enterEmailText,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.emailAddress,
            onChanged: (text) {
              _email = text;
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
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Center(
                  child: FormButton(
                label: StringConfig.submit,
                onButtonPress: () {
                  onSubmitPress(context);
                },
              )),
              const SizedBox(height: 12),
              const RegisterView()
            ],
          ),
        ]),
      ),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  void onLoginPress(context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          StringConfig.alreadyUserText,
          style: TextStyle(fontSize: 14),
        ),
        InkWell(
            onTap: () {
              onLoginPress(context);
            },
            child: const Text(StringConfig.loginText,
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.bold))),
      ],
    );
  }
}
