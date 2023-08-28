import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageItemListeView extends StatelessWidget {
  final Message message;
  final LoginModel lm = Constant.loginModel!;

  MessageItemListeView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: message.user.Avatar != null
                  ? Image.memory(
                      message.user.Avatar!,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.account_circle),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Ajoutez ici la logique à exécuter lorsque le pseudo est cliqué
                      },
                      child: Text(
                        message.user.pseudo,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 5), // Espacement entre le pseudo et la date
                    Text(
                      DateFormat('MM/dd/yyyy HH:mm')
                          .format(message.date.toLocal()),
                      style: TextStyle(
                        fontSize: 12, // Taille de police plus petite
                        color: Colors.grey, // Couleur plus discrète
                      ),
                    ),
                  ],
                ),
                Text(
                  message.message,
                  style: TextStyle(fontSize: 16),
                  softWrap: true, // Permettre le wrapping automatique du texte
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
