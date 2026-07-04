import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projet_blockchain/Model/user.dart';
import '../Common/com_helper.dart';
import '../Common/gen_login_signup_header.dart';
import '../DatabaseHandler/db_helper.dart';
import 'login.dart';
import 'package:toast/toast.dart';

import '../Common/gen_text_form_field.dart';

class SignUpForm extends StatefulWidget {
  final Socket socket;
  const SignUpForm(this.socket, {super.key});

  @override
  _SignUpState createState() => _SignUpState(socket);
}

class _SignUpState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>(); // recuperer l'etat de chaque champ

  final _conUserName = TextEditingController();
  final _conPassword = TextEditingController();
  final _conCPassword = TextEditingController();
  final DbHelper _dbHelper = DbHelper.instance;
  final Socket socket;

  _SignUpState(this.socket);

  @override
  void initState() {
    super.initState();
  }

  signUp() async {
    String uname = _conUserName.text;
    String password = _conPassword.text;
    String cpassword = _conCPassword.text;

    if (_formKey.currentState!.validate()) {
      if (password != cpassword) {
        print('Password Mismatch');
        alertDialog('Les mots de passe de ne correspondent pas');
        //Toast.show('Password Mismatch', duration: Toast.lengthLong,gravity: Toast.bottom);
      } else {
        _formKey.currentState!
            .save(); // assurer au compilateur que "_formKey.currentState n'est pas null

        User user = User(pseudo: uname, password: password);
        await _dbHelper.insert(user).then((userData) {
          //then to catch error of database
          alertDialog('Profil enregistré');
          print(userData);
        }).catchError((error) {
          print(error);
          alertDialog('Erreur: Le profil non enregsitré');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GenLoginSignupHeader("S'inscrire"),
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
                const SizedBox(height: 10.0),
                GetTextFormField(
                    controller: _conCPassword,
                    hintName: 'Confirmer mot de passe',
                    icon: Icons.lock,
                    isObscureText: true),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: TextButton(
                    onPressed: signUp,
                    child: const Text("S'inscrire",
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
                          // Naviguer vers la page Login
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LoginForm(socket)),
                              (Route<dynamic> route) => false);
                        },
                        child: const Text('Se connecter'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
