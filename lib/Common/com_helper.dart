import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

//Creer des textes d'erreur par rapport au entrée
alertDialog(String msg) {
  Toast.show(msg, duration: Toast.lengthLong, gravity: Toast.bottom);
}

//verifier si l'email est ecrit sur la bonne forme
validateEmail(String email) {
  final RegExp emailReg = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  return emailReg.hasMatch(email);
}

validatePassword(String pass1, String pass2) {
  if (pass1 != pass2) {
    return false;
  } else {
    return true;
  }
}
