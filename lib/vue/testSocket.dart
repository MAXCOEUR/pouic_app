

import 'package:discution_app/vue/SocketManager.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class testSocket extends StatefulWidget {
  @override
  _testSocketState createState() => _testSocketState();
}

class _testSocketState extends State<testSocket> {
  IO.Socket socket = SocketManager.getInstance().socket;
  String message = '';
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    socket.on('message', (data) {
      setState(() {
        message=data;
      });
    });
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      socket.emit('message', _controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket.IO Flutter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Message reçu:'),
            Text(
              message,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Envoyer un message'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: sendMessage,
              child: Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}