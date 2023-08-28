import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:discution_app/Model/ConversationListeModel.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/SocketSingleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ConversationController{
  ConversationListe conversations;
  LoginModel loginModel = Constant.loginModel!;
  final Socket _socket = SocketSingleton.instance.socket;
  Function callBack;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  ConversationController(this.conversations,this.callBack){
    _socket.on("recevoirMessage", _handleReceivedMessage);

    if(Platform.isAndroid || Platform.isIOS||Platform.isLinux || Platform.isMacOS){
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      initNotif();
    }
  }
  Future<void> initNotif () async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialiser les notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('mipmap/ic_launcher'); // Remplacez 'app_icon' par le nom de votre icône de l'application
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }
  void dispose() {
    _socket.off("recevoirMessage", _handleReceivedMessage);
    _socket.emit('leaveConversation', {'uniquePseudo': loginModel.user.uniquePseudo});
  }
  void _handleReceivedMessage(data) {
    int idConv = data["id_conversation"];
    for(Conversation conv in conversations.conversations){
      if(conv.id==idConv){
        conv.unRead++;
        if(flutterLocalNotificationsPlugin!=null){
          User user = User(data["email"], data["uniquePseudo"], data["pseudo"], data["Avatar"]);
          MessageModel message = MessageModel(data["id"], user, data["file"], data["Message"], DateTime.parse(data["date"]), data["id_conversation"],true);
          showCustomNotification(message,conv);
        }
        callBack();
      }
    }
  }


  void addConversation_inListe(int page,String search,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.getData(
        "conv", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = jsonDecode(response.data);

          for(Map<String, dynamic> user in jsonData){
            Uint8List? avatarData;
            if (user['image'] != null) {
              List<dynamic> avatarBytes = user['image']['data'];
              avatarData = Uint8List.fromList(avatarBytes.cast<int>());
            }
            conversations.addConv(Conversation(user["id"], user["name"], user["uniquePseudo_admin"], avatarData,user["unRead"]));
          }

          callBack();
        },
        onError: (error) {
          callBackError(error);
        }
    );
  }
  void removeAllConversation_inListe(){
    conversations.reset();
  }


  Future<void> showCustomNotification(MessageModel message,Conversation conv) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'b1717167dd1920d2ef95d8ae8de426a0adc0d8dca3551437862a2c3310b9e53a',
      'Custom Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin!.show(
      message.id, // Id de la notification
      conv.name, // Titre de la notification
      message.user.pseudo+" : "+ message.message, // Corps de la notification
      platformChannelSpecifics,
    );
  }

}