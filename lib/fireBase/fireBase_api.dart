import 'dart:typed_data';

import 'package:Pouic/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message)async{
  print('Title: ${message.notification?.title}');
  print('body: ${message.notification?.body}');
  print('Payload: ${message.data}');
  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id', // ID de votre canal de notification
    'Nom de votre canal', // Nom de votre canal de notification
    importance: Importance.max, // Importance de la notification
    priority: Priority.high, // Priorité de la notification
    playSound: true, // Activer le son
  );

  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin?.show(
    0, // ID de la notification
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
  );
}

class FireBaseApi{
  final _firebaseMessaging= FirebaseMessaging.instance;

  Future<String?> initNotification()async{
    await _firebaseMessaging.requestPermission(criticalAlert: true);
    final fCMToken = await _firebaseMessaging.getToken();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    return fCMToken;
  }
}