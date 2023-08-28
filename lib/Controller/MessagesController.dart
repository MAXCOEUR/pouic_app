import 'dart:convert';
import 'dart:typed_data';

import 'package:discution_app/Model/MessageListeModel.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/SocketManager.dart';

class MessagesController {
  MessageListe messages;
  Conversation conversation;
  SocketManager _socketManager = SocketManager();
  LoginModel lm = Constant.loginModel!;
  Function callBack;

  MessagesController(this.messages, this.conversation,this.callBack) {
    _socketManager.socket.emit('joinConversation', {'conversationId': conversation.id});
    _socketManager.socket.on("recevoirMessage", _handleReceivedMessage);
  }
  void dispose() {
    _socketManager.socket.off("recevoirMessage", _handleReceivedMessage);
    _socketManager.socket.emit('leaveConversation', {'conversationId': conversation.id});
  }
  void _handleReceivedMessage(data) {
    User user = User(data["email"], data["uniquePseudo"], data["pseudo"], data["Avatar"]);
    messages.newMessage(Message(data["id"], user, data["file"], data["Message"], DateTime.parse(data["date"]), data["id_conversation"]));
    print(data);
    callBack();
  }

  void sendMessageToSocket(String messageText) {
    _socketManager.socket.emit('envoyerMessage', {
      'token': lm.token,
      'messageText': messageText,
      'conversationId': conversation.id,
    });
  }

  int getLastId(){
    int index= messages.messages.length-1;
    return messages.messages[index].id;
  }

  void addOldMessage_inListe(int id_conversation,int id_lastMessage,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+lm.token;
    Api.getData(
        "message", {'id_conversation': id_conversation, 'id_lastMessage': id_lastMessage}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = jsonDecode(response.data);
          
          List<Message> messagesTmp=[];
          for(Map<String, dynamic> data in jsonData){
            Uint8List? avatarData;
            if (data['Avatar'] != null) {
              List<dynamic> avatarBytes = data['Avatar']['data'];
              avatarData = Uint8List.fromList(avatarBytes.cast<int>());
              User user= User(data['email'], data['uniquePseudo'], data['pseudo'], avatarData);
              messagesTmp.add(Message(data["id"], user, data["file"], data["Message"], DateTime.parse(data["date"]), data["id_conversation"]));
            }
          }
          messages.addOldMessages(messagesTmp);

          callBack();
        },
        onError: (error) {
          callBackError(error);
        }
    );
  }
}
