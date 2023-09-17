import 'package:Pouic/outil/Api.dart';
import 'package:Pouic/outil/LoginSingleton.dart';
import 'package:Pouic/outil/SocketSingleton.dart';
import 'package:socket_io_client/socket_io_client.dart';

class HomeController{
  int? nbrMessageNonLu;
  int? nbrDemande;
  Socket _socket = SocketSingleton.instance.socket;
  LoginModel loginModel = LoginModelProvider.getInstance((){}).loginModel!;
  Function callBack;

  HomeController(this.callBack){
    _socket.on("recevoirMessage", _handleReceivedMessage);
    _socket.on("demandeAmis", _handledemandeAmis);
    _socket.on("newAmis", _handlenewAmis);
    _socket.on("deleteAmis", _handledeleteAmis);
    _socket.on("updateMessageNonLu", _handleupdateMessageNonLu);
    askApiNbrMessageNonLu();
    askApiNbrDemande();
  }
  void dispose() {
    _socket.off("recevoirMessage", _handleReceivedMessage);
    _socket.off("demandeAmis", _handledemandeAmis);
    _socket.off("newAmis", _handlenewAmis);
    _socket.off("deleteAmis", _handledeleteAmis);
    _socket.off("updateMessageNonLu", _handleupdateMessageNonLu);
  }

  void askApiNbrMessageNonLu() async {
    String AuthorizationToken='Bearer '+loginModel.token;
    final response = await Api.instance.getData(
      'user/unread',
      null,
      {'Authorization': AuthorizationToken},
    );

    if (response.statusCode == 200) {
      String unreadAsString = response.data["unread"];
      nbrMessageNonLu = int.parse(unreadAsString);
      callBack();
    } else {
      throw Exception();
    }
  }
  void askApiNbrDemande() async {
    String AuthorizationToken='Bearer '+loginModel.token;
    final response = await Api.instance.getData(
      'amis/demande/nbr',
      null,
      {'Authorization': AuthorizationToken},
    );

    if (response.statusCode == 200) {
      nbrDemande = response.data["nbrDemande"];
      callBack();
    } else {
      throw Exception();
    }
  }

  void _handleReceivedMessage(data){
    if(nbrMessageNonLu!=null){
      nbrMessageNonLu=nbrMessageNonLu!+1;
      callBack();
    }
  }
  void _handledemandeAmis(data){

    if(nbrDemande!=null){
      if(data["user"]!=null){
        nbrDemande=nbrDemande!+1;
      }
      callBack();
    }
  }
  void _handlenewAmis(data){
    if(nbrDemande!=null) {
      nbrDemande = nbrDemande! - 1;
      callBack();
    }
  }
  void _handledeleteAmis(data){
    if(nbrDemande!=null) {
      nbrDemande = nbrDemande! - 1;
      callBack();
    }
  }
  void _handleupdateMessageNonLu(data){
    if(nbrMessageNonLu!=null){
      nbrMessageNonLu=data["unread"];
      callBack();
    }
  }
}