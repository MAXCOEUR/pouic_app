import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Pouic/Model/ConversationListeModel.dart';
import 'package:Pouic/Model/ConversationModel.dart';
import 'package:Pouic/Model/MessageModel.dart';
import 'package:Pouic/Model/MessageParentModel.dart';
import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Api.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/outil/SocketSingleton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ConversationController{
  ConversationListe conversations;
  LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
  final Socket _socket = SocketSingleton.instance.socket;
  Function callBack;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  int? idConvertationOpen;

  ConversationController(this.conversations,this.callBack){
    _socket.on("recevoirMessage", _handleReceivedMessage);
    _socket.on("newConversation", _handleNewConv);
    _socket.on("deleteConversation", _handleDeleteConv);
    if (!kIsWeb) {
      if(Platform.isAndroid || Platform.isIOS||Platform.isLinux || Platform.isMacOS){
        flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        initNotif();
      }
    }
  }
  void setIdConvertationOpen(int idConvertation){
    idConvertationOpen=idConvertation;
  }
  void setNullIdConvertationOpen(){
    idConvertationOpen=null;
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
    _socket.off("newConversation", _handleNewConv);
    _socket.off("deleteConversation", _handleDeleteConv);
    _socket.emit('leaveConversation', {'uniquePseudo': loginModel.user.uniquePseudo});
  }
  void _handleDeleteConv(data){
    int id_conversation = int.parse(data["id_conversation"]);

    conversations.removeConvId(id_conversation);
    SocketSingleton.instance.socket.emit('leaveConversation', {'idConversation': id_conversation});
    callBack();
  }
  void _handleNewConv(data){
    Map<String,dynamic> messageMap = data["conversation"];

    Conversation conversation = Conversation(messageMap["id"], messageMap["name"], messageMap["uniquePseudo_admin"],messageMap["extension"], 0);
    conversations.addTopConv(conversation);
    SocketSingleton.instance.socket.emit('joinConversation', {'idConversation': conversation.id});
    callBack();

  }
  void _handleReceivedMessage(data) {
    Map<String,dynamic> messageMap = data["message"];

    MessageParentModel? parent;
    if(messageMap["id_parent"]!=null){
      User userParent= User(email:"" ,uniquePseudo:messageMap['parent_uniquePseudo'], pseudo:messageMap['parent_pseudo'],bio:messageMap["parent_bio"],extension:messageMap["parent_extension"]);
      parent = MessageParentModel(messageMap["id_parent"], userParent, messageMap["parent_Message"], DateTime.parse(messageMap["parent_date"]),[]);
    }

    User user = User(email:messageMap["email"], uniquePseudo:messageMap["uniquePseudo"], pseudo:messageMap["pseudo"],bio:messageMap["bio"],extension:messageMap["extension"]);
    MessageModel message = MessageModel(messageMap["id"], user, messageMap["Message"], DateTime.parse(messageMap["date"]), messageMap["id_conversation"],true,[],parent);
    int idConv = messageMap["id_conversation"];
    Conversation? convtmp;
    for(Conversation conv in conversations.conversations){
      if(conv.id==idConv){
        convtmp=conv;
        conv.unRead++;
        if(message.user!=loginModel.user && idConvertationOpen!=idConv){
          if(flutterLocalNotificationsPlugin!=null){
            showCustomNotification(message,conv);
          }
        }
        callBack();
      }
    }
    if(convtmp!=null){
      conversations.removeConv(convtmp);
      conversations.addTopConv(convtmp);
    }
  }


  void addConversation_inListe(int page,String search,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.instance.getData(
        "conv", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = response.data;

          for(Map<String, dynamic> user in jsonData){
            conversations.addConv(Conversation(user["id"], user["name"], user["uniquePseudo_admin"],user["extension"],user["unRead"]));
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