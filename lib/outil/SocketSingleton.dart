import 'package:Pouic/Model/UserModel.dart';
import 'package:Pouic/outil/Constant.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
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
    socket = IO.io(Constant.ServeurApi, <String, dynamic>{
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
