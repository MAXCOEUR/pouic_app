import 'dart:convert';
import 'dart:typed_data';

import 'package:discution_app/Model/MessageListeModel.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/vue/SocketSingleton.dart';
import 'package:socket_io_client/src/socket.dart';

class MessagesController {
  MessageListe messages;
  Conversation conversation;
  final Socket _socket = SocketSingleton.instance.socket;
  LoginModel lm = Constant.loginModel!;
  Function callBack;

  MessagesController(this.messages, this.conversation,this.callBack) {
    _socket.on("recevoirMessage", _handleReceivedMessage);
  }
  void dispose() {
    _socket.off("recevoirMessage", _handleReceivedMessage);
   // _socket.emit('leaveConversation', {'conversationId': conversation.id});
  }
  void _handleReceivedMessage(data) {
    User user = User(data["email"], data["uniquePseudo"], data["pseudo"], data["Avatar"]);
    messages.newMessage(MessageModel(data["id"], user, data["file"], data["Message"], DateTime.parse(data["date"]), data["id_conversation"],true));
    print(data);
    //luMessage(data["id"]);
    callBack();
  }

  void sendMessageToSocket(String messageText) {
    _socket.emit('envoyerMessage', {
      'token': lm.token,
      'messageText': messageText,
      'conversationId': conversation.id,
    });
  }

  int getLastId(){
    int index= messages.messages.length-1;
    return messages.messages[(index<0)?0:index].id;
  }

  void addOldMessage_inListe(int id_conversation,int id_lastMessage,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+lm.token;
    Api.getData(
        "message", {'id_conversation': id_conversation, 'id_lastMessage': id_lastMessage}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = jsonDecode(response.data);
          
          List<MessageModel> messagesTmp=[];
          for(Map<String, dynamic> data in jsonData){
            Uint8List? avatarData;
            if (data['Avatar'] != null) {
              List<dynamic> avatarBytes = data['Avatar']['data'];
              avatarData = Uint8List.fromList(avatarBytes.cast<int>());
              User user= User(data['email'], data['uniquePseudo'], data['pseudo'], avatarData);
              messagesTmp.add(MessageModel(data["id"], user, data["file"], data["Message"], DateTime.parse(data["date"]), data["id_conversation"],(data["is_read"]==1)?true:false));
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
  void initListe(int id_conversation,Function callBack,Function callBackError){
    addOldMessage_inListe(id_conversation,0,callBack,callBackError);
  }
  int firstMessageNotOpen(){
    List<int> tmpListe=[0];
    for(int i=0;i<messages.messages.length;i++){
      if(!messages.messages[i].isread){
        tmpListe.add(i);
      }
    }
    return tmpListe.last;
  }

  void luAllMessage(int id_conversation){
    _socket.emit('luAllMessage', {
      'token': lm.token,
      'conversationId': id_conversation,
    });
  }
  void luMessage(int id_message){
    _socket.emit('luMessage', {
      'token': lm.token,
      'messageId': id_message,
    });
  }
}
