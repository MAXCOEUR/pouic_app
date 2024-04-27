
import 'package:Pouic/vue/ResetPassword_viewModel.dart';
import 'package:Pouic/vue/widget/LoadingDialog.dart';
import 'package:dio/dio.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/vue/CreateUserVue.dart';
import 'package:flutter/material.dart';
import 'package:Pouic/vue/home/HomeView.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/LoginController.dart';

import '../HomeTmp.dart';
import '../outil/Constant.dart';



class ResetPassword extends StatefulWidget {
  ResetPassword({super.key});
  final String title="Reset Mot de passe";

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  ResetpasswordViewmodel viewModel = ResetpasswordViewmodel();
  final userName_Email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  bool _isLoading = false;

  void resetMDP(){
    setState(() {
      _isLoading=true;
    });
    Stream<bool> stream = viewModel.restPassword(userName_Email.text);
    stream.listen((good) {
      setState(() {
        _isLoading=false;
      });
      if(good){
        _showAlertDialogSucces(context, "Succes", "le mot de passe a été Réinitialiser et le mail a été encoyé");

      }
      else{
        Constant.showAlertDialog(context, "Erreur", "Une erreur s'est produite le email ou Psodo n'existe pas");
      }

    }, onError: (error) {
      setState(() {
        _isLoading=false;
      });
      Constant.showAlertDialog(context, "Erreur", "Une erreur s'est produite");
      print("Erreur : $error");
    });
  }
  static _showAlertDialogSucces(BuildContext context, String titre, String erreur) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
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

  @override
  void dispose() {
    userName_Email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(widget.title),
      ),
      body: (_isLoading)?LoadingDialog(): SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: userName_Email,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Entrez votre username ou mail',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est obligatoire.';
                    }
                    return null; // Retourne null s'il n'y a pas d'erreur
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeMarginPading.h3),
                child: ElevatedButton(
                  onPressed: () {
                    // Valide le formulaire avant d'exécuter le code
                    if (_formKey.currentState!.validate()) {
                      // Code à exécuter lorsque le bouton est pressé
                      print('le username ou email est : ' +
                          userName_Email.text);
                      resetMDP();
                    }
                  },
                  child: Text('Réinitialiser Mot de passe'),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}


