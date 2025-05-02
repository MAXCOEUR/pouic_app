import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:pouic/Model/FileCustom.dart';
import 'package:pouic/Model/FileModel.dart';
import 'package:pouic/Model/MessageListeModel.dart';
import 'package:pouic/Model/ConversationModel.dart';
import 'package:pouic/Model/MessageParentModel.dart';
import 'package:pouic/Model/ReactionModel.dart';
import 'package:pouic/Model/UserModel.dart';
import 'package:pouic/Model/MessageModel.dart';
import 'package:pouic/outil/Api.dart';
import 'package:pouic/outil/Constant.dart';
import 'package:pouic/outil/LoginSingleton.dart';
import 'package:pouic/outil/SocketSingleton.dart';
import 'package:socket_io_client/src/socket.dart';
import 'package:path/path.dart' as path;

class MessagesController {
  List<FileCustom> _listeFile=[];
  MessageListe messages;
  Conversation conversation;
  final Socket _socket = SocketSingleton.instance.socket;
  LoginModel lm = LoginModelProvider.getInstance((){}).loginModel!;
  Function callBack;

  MessagesController(this.messages, this.conversation,this.callBack) {
    _socket.on("recevoirMessage", _handleReceivedMessage);
    _socket.on("recevoirReaction", _handleRecevoirReaction);
    _socket.on("deleteMessage", _handleDeleteMessage);
    _socket.on("recevoirdeleteReaction", _handleRecevoirDeleteMessage);
    _socket.on("editMessage", _handleEditMessage);
    _socket.on("EndFile", _handleEndFile);
  }
  void dispose() {
    _socket.off("recevoirMessage", _handleReceivedMessage);
    _socket.off("recevoirReaction", _handleRecevoirReaction);
    _socket.off("deleteMessage", _handleDeleteMessage);
    _socket.off("recevoirdeleteReaction", _handleRecevoirDeleteMessage);
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
    int id_message=data["id_message"];
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
    User user = User( email:messageMap["email"], uniquePseudo:messageMap["uniquePseudo"], pseudo:messageMap["pseudo"],bio:messageMap["bio"],extension:messageMap["extension"]);
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
      User userParent= User(email: "", uniquePseudo:messageMap['parent_uniquePseudo'], pseudo:messageMap['parent_pseudo'],bio:messageMap["parent_bio"],extension:messageMap["parent_extension"]);
      List<FileModel> listeFileParent=splitGroupConcat(messageMap["parent_linkfile"],messageMap["parent_name"]);
      parent = MessageParentModel(messageMap["id_parent"], userParent, messageMap["parent_Message"], DateTime.parse(messageMap["parent_date"]),listeFileParent);
    }


    MessageModel message =MessageModel(messageMap["id"], user, messageMap["Message"], DateTime.parse(messageMap["date"]), messageMap["id_conversation"],true,listeFile,parent);
    messages.newMessage(message);
    print(data);

    if(_listeFile.length>0){
      sendFile(message);
    }
    if(user!=lm.user){
      luMessage(message.id);
    }

    callBack();
  }

  void _handleRecevoirReaction(data){
    Map<String,dynamic> messageMap = data["message"];
    int message_id=messageMap["message_id"];
    Reaction reaction = Reaction(User(email:messageMap["email"],uniquePseudo:messageMap["uniquePseudo"],pseudo:messageMap["pseudo"],bio:messageMap["bio"],extension:messageMap["extension"]), messageMap["emoji"]);
    messages.addReaction(message_id, reaction);
    callBack();
  }
  void _handleRecevoirDeleteMessage(data){
    messages.deleteReaction(data["messgaeId"],data["uniquePseudo"]);
    callBack();
  }

  void sendMessageToSocket(String messageText,List<FileCustom> listeFile,MessageParentModel? parent) {
    _listeFile.addAll(listeFile);
    if(listeFile.length>0 || messageText.isNotEmpty){
      _socket.emit('envoyerMessage', {
        'token': lm.token,
        'messageText': messageText,
        'conversationId': conversation.id,
        'id_parent':(parent==null)?null:parent.id,
      });
    }
  }
  void sendReactionToSocket(int id_conversation,int message_id,String reaction) {
    _socket.emit('setReaction', {
      'token': lm.token,
      'messgaeId': message_id,
      'reaction':reaction,
      'conversationId':id_conversation,
    });
  }
  void deleteReactionToSocket(int id_conversation,int message_id) {
    _socket.emit('deleteReaction', {
      'token': lm.token,
      'messgaeId': message_id,
      'conversationId':id_conversation,
    });
  }

  Future<void> sendFile(MessageModel message) async {
    for(FileCustom f in _listeFile){
      try {
        final response = await Api.instance.postDataMultipart(
          'message/upload',
          {'file':  MultipartFile.fromBytes(f.fileBytes!.toList(),filename:f.fileName),'id_message':message.id,'name':f.fileName,'id_conversation':message.id_conversation},
          null,
          null,
        );

        if (response.statusCode == 200) {
          //callBack();
        } else {
          throw Exception();
        }
      }catch(error){

      }
    }
    _listeFile.clear();
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

            int idMessage=data["id"];
            MessageModel? isEx=MessageListe.isExiste(idMessage,messagesTmp);

            if(isEx!=null){
              Reaction reaction = Reaction(User(email:data['reaction_email'], uniquePseudo:data['reaction_uniquePseudo'], pseudo:data['reaction_pseudo'],bio:data["reaction_bio"],extension:data["reaction_extension"]), data["reaction"]);
              isEx.addReaction(reaction);
            }else{
              MessageParentModel? parent;
              if(data["id_parent"]!=null){
                List<FileModel> listeFileParent=splitGroupConcat(data["parent_linkfile"],data["parent_name"]);
                User userParent= User(email:"", uniquePseudo:data['parent_uniquePseudo'], pseudo:data['parent_pseudo'],bio:data["parent_bio"],extension:data["parent_extension"]);
                parent = MessageParentModel(data["id_parent"], userParent, data["parent_Message"], DateTime.parse(data["parent_date"]),listeFileParent);
              }

              List<FileModel> listeFile=splitGroupConcat(data["linkfile"],data["name"]);
              User user= User(email:data['email'], uniquePseudo:data['uniquePseudo'], pseudo:data['pseudo'],bio:data["bio"],extension:data["extension"]);
              MessageModel message = MessageModel(data["id"], user, data["Message"], DateTime.parse(data["date"]), data["id_conversation"],(data["is_read"]==1)?true:false,listeFile,parent);
              if(data["reaction"]!=null){
                Reaction reaction = Reaction(User(email:data['reaction_email'], uniquePseudo:data['reaction_uniquePseudo'], pseudo:data['reaction_pseudo'],bio:data["reaction_bio"],extension:data["reaction_extension"]), data["reaction"]);
                message.addReaction(reaction);
              }

              messagesTmp.add(message);
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

  List<FileModel> splitGroupConcat(String? linkfile,String? name){
    List<FileModel> listeFile= [];
    List<String> listeLinkFile= [];
    List<String> listenameFile= [];
    if(linkfile!=null && name!=null){
      listeLinkFile=linkfile.split(',');
      listenameFile=name.split(',');
    }else{
      listeLinkFile=[];
      listenameFile=[];
    }
    for(int i=0;i<listeLinkFile.length;i++){
      listeFile.add(FileModel(listeLinkFile[i], listenameFile[i]));
    }

    return listeFile;
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
