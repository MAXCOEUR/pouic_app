import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static SocketManager? _instance;
  late IO.Socket socket;

  factory SocketManager.getInstance() {
    if (_instance == null) {
      _instance = SocketManager._internal();
    }
    return _instance!;
  }

  SocketManager._internal(){
    socket = IO.io('http://46.227.18.31:3001', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connecté au serveur');
    });
  }

  bool get isConnected => socket.connected;

  // Autres méthodes pour envoyer des messages, gérer les salons, etc.

  void dispose() {
    if (isConnected) {
      socket.disconnect();
    }
  }
}
