import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/MessageListeModel.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/MessageParentModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/Model/MessageModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LoginSingleton.dart';
import 'package:discution_app/outil/SocketSingleton.dart';
import 'package:socket_io_client/src/socket.dart';
import 'package:path/path.dart' as path;

class MessagesController {
  MessageListe messages;
  Conversation conversation;
  final Socket _socket = SocketSingleton.instance.socket;
  LoginModel lm = LoginModelProvider.getInstance((){}).loginModel!;
  Function callBack;

  MessagesController(this.messages, this.conversation,this.callBack) {
    _socket.on("recevoirMessage", _handleReceivedMessage);
    _socket.on("deleteMessage", _handleDeleteMessage);
    _socket.on("editMessage", _handleEditMessage);
    _socket.on("EndFile", _handleEndFile);
  }
  void dispose() {
    _socket.off("recevoirMessage", _handleReceivedMessage);
    _socket.off("deleteMessage", _handleDeleteMessage);
    _socket.off("editMessage", _handleEditMessage);
    _socket.off("EndFile", _handleEndFile);
  }
  void _handleEditMessage(data){
    int id_message=int.parse(data["id_message"]);
    int id_conversation=data["id_conversation"];
    String message=data["message"];
    if(id_conversation!=conversation.id){
      return ;
    }
    messages.editMessage(id_message,message);
    callBack();
  }
  void _handleDeleteMessage(data){
    int id_message=int.parse(data["id_message"]);
    int id_conversation=data["id_conversation"];
    if(id_conversation!=conversation.id){
      return ;
    }
    messages.removeId(id_message);
    callBack();
  }
  void _handleEndFile(data) {
    int id_message = data["id_message"];
    FileModel file = FileModel(data["fieldname"], data["name"]);
    messages.addFile(id_message,file);
    callBack();
  }
  void _handleReceivedMessage(data) {
    Map<String,dynamic> messageMap = data["message"];

    if(messageMap["id_conversation"]!=conversation.id){
      return ;
    }


    User user = User(messageMap["email"], messageMap["uniquePseudo"], messageMap["pseudo"]);
    List<String> listeLinkFile= [];
    List<String> listenameFile= [];
    if(messageMap["linkfile"]!=null && messageMap["name"]!=null){
      listeLinkFile=messageMap["linkfile"].split(',');
      listenameFile=messageMap["name"].split(',');
    }else{
      listeLinkFile=[];
      listenameFile=[];
    }
    List<FileModel> listeFile= [];
    for(int i=0;i<listeLinkFile.length;i++){
      listeFile.add(FileModel(listeLinkFile[i], listenameFile[i]));
    }
    MessageParentModel? parent;
    if(messageMap["id_parent"]!=null){
      User userParent= User("", messageMap['parent_uniquePseudo'], messageMap['parent_pseudo']);
      parent = MessageParentModel(messageMap["id_parent"], userParent, messageMap["parent_Message"], DateTime.parse(messageMap["parent_date"]));
    }


    MessageModel message =MessageModel(messageMap["id"], user, messageMap["Message"], DateTime.parse(messageMap["date"]), messageMap["id_conversation"],true,listeFile,parent);
    messages.newMessage(message);
    print(data);
    List<dynamic> listeFileTmp =data["file"];
    List<String> listeString = listeFileTmp.map((item) => item.toString()).toList();
    if(listeString.length>0){
      sendFile(listeString,message);
    }
    if(user!=lm.user){
      luMessage(message.id);
    }

    callBack();
  }

  void sendMessageToSocket(String messageText,List<String> listeFile,MessageParentModel? parent) {
    listeFile;
    if(listeFile.length>0 || messageText.isNotEmpty){
      _socket.emit('envoyerMessage', {
        'token': lm.token,
        'messageText': messageText,
        'conversationId': conversation.id,
        'file':listeFile,
        'id_parent':(parent==null)?null:parent.id,
      });
    }
  }

  Future<void> sendFile(List<String> listeFile,MessageModel message) async {
    for(String s in listeFile){
      try {
        File file = File(s);
        final response = await Api.instance.postDataMultipart(
          'message/upload',
          {'file': await MultipartFile.fromFile(file.path),'id_message':message.id,'name':path.basename(s),'id_conversation':message.id_conversation},
          null,
          {'contentType':'application/json; charset=utf-8'},
        );

        if (response.statusCode == 200) {
          //callBack();
        } else {
          throw Exception();
        }
      }catch(error){

      }
    }
    listeFile.clear();
  }

  int getLastId(){
    int index= messages.messages.length-1;
    return messages.messages[(index<0)?0:index].id;
  }

  void addOldMessage_inListe(int id_conversation,int id_lastMessage,Function callBack,Function callBackError){
    print("getMessage Api");
    String AuthorizationToken='Bearer '+lm.token;
    Api.instance.getData(
        "message", {'id_conversation': id_conversation, 'id_lastMessage': id_lastMessage}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = response.data;
          
          List<MessageModel> messagesTmp=[];
          for(Map<String, dynamic> data in jsonData){
            List<String> listeLinkFile= [];
            List<String> listenameFile= [];
            if(data["linkfile"]!=null && data["name"]!=null){
              listeLinkFile=data["linkfile"].split(',');
              listenameFile=data["name"].split(',');
            }else{
              listeLinkFile=[];
              listenameFile=[];
            }
            List<FileModel> listeFile= [];
            for(int i=0;i<listeLinkFile.length;i++){
              listeFile.add(FileModel(listeLinkFile[i], listenameFile[i]));
            }
            MessageParentModel? parent;
            if(data["id_parent"]!=null){
              User userParent= User("", data['parent_uniquePseudo'], data['parent_pseudo']);
              parent = MessageParentModel(data["id_parent"], userParent, data["parent_Message"], DateTime.parse(data["parent_date"]));
            }


            User user= User(data['email'], data['uniquePseudo'], data['pseudo']);
            messagesTmp.add(MessageModel(data["id"], user, data["Message"], DateTime.parse(data["date"]), data["id_conversation"],(data["is_read"]==1)?true:false,listeFile,parent));
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

  static void delete(MessageModel message,Function callBack,Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    try{
      final response = await Api.instance.deleteData("message", null, {'id_message': message.id}, {'Authorization': AuthorizationToken});
      if(response.statusCode==201){
        callBack();
      }else{
        throw Exception();
      }
    }catch(error){
      callBackError(error);
    }
  }
  static void edit(MessageModel message,String edit,Function callBack,Function callBackError) async {
    LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
    String AuthorizationToken='Bearer ${loginModel.token}';
    try{
      final response = await Api.instance.putData("message", {'message':edit}, {'id_message': message.id}, {'Authorization': AuthorizationToken});
      if(response.statusCode==201){
        callBack();
      }else{
        throw Exception();
      }
    }catch(error){
      callBackError(error);
    }
  }
}
