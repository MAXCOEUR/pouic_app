import 'dart:typed_data';

import 'package:discution_app/Model/UserModel.dart';
import 'package:flutter/material.dart';

class Constant{
  static LoginModel? loginModel;

  static showAlertDialog(BuildContext context,String titre,String erreur) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(titre),
      content: Text(erreur),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}