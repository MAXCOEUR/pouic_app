import 'package:discution_app/Controller/Notification.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketSingleton {
  late IO.Socket socket;
  //late NotificationCustom _notificationCustom;
  final LoginModel lm = LoginModelProvider.getInstance((){}).loginModel!;

  // Constructeur privé
  SocketSingleton._privateConstructor() {
    //_notificationCustom= NotificationCustom.instance;
    _connect();
  }

  // Instance unique de SocketManager
  static final SocketSingleton _instance = SocketSingleton._privateConstructor();

  // Méthode pour obtenir l'instance unique
  static SocketSingleton get instance => _instance;

  void _connect() {
    socket = IO.io('http://46.227.18.31:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to server');
      socket.emit('joinConversations', {'uniquePseudo': lm.user.uniquePseudo});
    });
    // Ajoutez d'autres écouteurs d'événements socket et des méthodes au besoin
  }
  void reconnect(){
    socket.emit('joinConversations', {'uniquePseudo': lm.user.uniquePseudo});
    //_notificationCustom.start();
  }
  void disconnect(){
    socket.emit('leaveConversations', {'uniquePseudo': lm.user.uniquePseudo});
    //_notificationCustom.stop();
  }
}
