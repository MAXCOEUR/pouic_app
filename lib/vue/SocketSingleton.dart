import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketSingleton {
  late IO.Socket socket;
  final LoginModel lm = Constant.loginModel!;

  // Constructeur privé
  SocketSingleton._privateConstructor() {
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
  }
  void disconnect(){
    socket.emit('leaveConversations', {'uniquePseudo': lm.user.uniquePseudo});
  }
}
