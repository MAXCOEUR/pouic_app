import 'dart:isolate';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/Model/MessageParentModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class IsolateMessage {
  final String action;
  final dynamic payload;

  IsolateMessage(this.action, this.payload);
}

class NotificationCustom {
  late Isolate _isolate;
  final ReceivePort _receiveSecondeThreadPort = ReceivePort();
  int? idConversation;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationCustom._privateConstructor(){
    initNotif();
  }
  static final NotificationCustom _instance = NotificationCustom._privateConstructor();
  static NotificationCustom get instance => _instance;

  void initNotif() async{
    WidgetsFlutterBinding.ensureInitialized();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void start() async {
    final serverUrl = 'http://46.227.18.31:3000';
    final loginModel = LoginModelProvider.getInstance(() {}).loginModel!;

    // Créez l'isolat et envoyez le premier message pour démarrer
    _isolate = await Isolate.spawn(_socketListenerIsolate, [_receiveSecondeThreadPort.sendPort,serverUrl,loginModel.user.uniquePseudo]);

    _receiveSecondeThreadPort.listen((message) {
      if (message is IsolateMessage) {
        final action = message.action;
        final payload = message.payload;

        if (action == "recevoirMessage"&& payload is Set<dynamic>) {
          Map<String,dynamic> messageMap = payload.first;

          MessageParentModel? parent;
          if(messageMap["id_parent"]!=null){
            User userParent= User("", messageMap['parent_uniquePseudo'], messageMap['parent_pseudo'],messageMap["parent_bio"],messageMap["parent_extension"]);
            parent = MessageParentModel(messageMap["id_parent"], userParent, messageMap["parent_Message"], DateTime.parse(messageMap["parent_date"]),[]);
          }

          User user = User(messageMap["email"], messageMap["uniquePseudo"], messageMap["pseudo"],messageMap["bio"],messageMap["extension"]);
          MessageModel message = MessageModel(messageMap["id"], user, messageMap["Message"], DateTime.parse(messageMap["date"]), messageMap["id_conversation"],true,[],parent);

          if(loginModel.user!=message.user && idConversation != message.id_conversation){
            showNotification(message);
          }

        }
        else if (action == "SandPort" && payload is Set<SendPort>){
        }
      }
    });
  }

  static void _socketListenerIsolate(List<dynamic> data) {

    IO.Socket socket;
    socket = IO.io(data[1], <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to server');
      socket.emit('joinConversations', {'uniquePseudo': data[2]});
    });
    socket.on("recevoirMessage", (value){
      Map<String,dynamic> messageMap = value["message"];
      final isolateMessage = IsolateMessage('recevoirMessage', {
        messageMap
      });
      data[0].send(isolateMessage);
    });

    print("Connected to server for notification");
  }

  void setConversation(Conversation? conversation) {
    if (conversation == null) {
      idConversation=null;
    } else {
      idConversation=conversation.id;
    }
  }

  void stop() {
    _receiveSecondeThreadPort.close();
    _isolate.kill();
  }

  Future<void> showNotification(MessageModel message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'b1717167dd1920d2ef95d8ae8de426a0adc0d8dca3551437862a2c3310b9e53a',
      'Channel Name',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.id, // ID de la notification (doit être unique)
      'Message de ${message.user.pseudo}',
      message.message,
      platformChannelSpecifics,
    );
  }

}
