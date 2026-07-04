import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projet_blockchain/Model/user.dart';
import '../Common/com_helper.dart';
import '../Common/gen_login_signup_header.dart';
import '../Common/gen_text_form_field.dart';
import '../DatabaseHandler/db_helper.dart';
import 'sign_up.dart';
import 'package:toast/toast.dart';
import 'home_page.dart';

class LoginForm extends StatefulWidget {
  final Socket socket;
  const LoginForm(this.socket, {super.key});

  @override
  _LoginFormState createState() => _LoginFormState(socket);
}

class _LoginFormState extends State<LoginForm> {
  final _conUserName = TextEditingController();
  final _conPassword = TextEditingController();
  final DbHelper _dbHelper = DbHelper.instance;
  final Socket socket;

  _LoginFormState(this.socket);

  @override
  void initState() {
    super.initState();
  }

  login() async {
    String uname = _conUserName.text;
    String password = _conPassword.text;

    print("pseudo : $uname");

    if (uname.isEmpty) {
      alertDialog("Veuillez entrer votre email");
    } else if (password.isEmpty) {
      alertDialog("Veuillez entrer votre mot de passe");
    } else {
      await _dbHelper.getUser(uname, password).then((userData) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => MainPage(
                    userData, socket)), // changer par la page de blockchain
            (Route<dynamic> route) => false);
      }).catchError((error) {
        alertDialog("Erreur : Connection refusée");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '', //TODO j'ai enlevé le texte
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GenLoginSignupHeader("Se connecter"),
              const SizedBox(height: 10.0),
              GetTextFormField(
                  controller: _conUserName,
                  hintName: 'Pseudo',
                  inputType: TextInputType.name,
                  icon: Icons.person),
              const SizedBox(height: 10.0),
              GetTextFormField(
                  controller: _conPassword,
                  hintName: 'Mot de passe',
                  icon: Icons.lock,
                  isObscureText: true),
              Container(
                margin: const EdgeInsets.all(30.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: TextButton(
                  onPressed: login,
                  child: const Text('Se connecter',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pas encore de compte ?'),
                    TextButton(
                      onPressed: () {
                        // Naviguer vers la page signup
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SignUpForm(socket)));
                      },
                      child: const Text("S'inscrire"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
