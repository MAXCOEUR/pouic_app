import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  late IO.Socket socket;

  SocketManager(){
    connect();
  }

  void connect() {
    socket = IO.io('http://46.227.18.31:3001', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to server');
      //socket.emit('userJoined', userId);
    });

    // Add more socket event listeners and methods as needed
  }
}
