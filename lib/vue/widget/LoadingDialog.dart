import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(), // Indicateur de chargement
          SizedBox(width: 20), // Espacement entre l'indicateur et le texte
          Text("Chargement..."), // Texte indiquant le chargement
        ],
      ),
    );
  }
}