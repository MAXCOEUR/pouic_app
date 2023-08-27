import 'dart:convert';
import 'dart:typed_data';

import 'package:discution_app/Model/ConversationListeModel.dart';
import 'package:discution_app/Model/ConversationModel.dart';
import 'package:discution_app/Model/UserModel.dart';
import 'package:discution_app/outil/Api.dart';
import 'package:discution_app/outil/Constant.dart';

class ConversationController{
  ConversationListe conversations;
  ConversationController(this.conversations);
  LoginModel loginModel = Constant.loginModel!;

  void addConversation_inListe(int page,String search,Function callBack,Function callBackError){
    String AuthorizationToken='Bearer '+loginModel.token;
    Api.getData(
        "conv", {'search': search, 'page': page}, {'Authorization': AuthorizationToken})
        .then(
            (response) {

          List<dynamic> jsonData = jsonDecode(response.data);

          for(Map<String, dynamic> user in jsonData){
            Uint8List? avatarData;
            if (user['image'] != null) {
              List<dynamic> avatarBytes = user['image']['data'];
              avatarData = Uint8List.fromList(avatarBytes.cast<int>());
            }
            conversations.addConv(Conversation(user["id"], user["name"], user["uniquePseudo_admin"], avatarData,user["unRead"]));
          }

          callBack();
        },
        onError: (error) {
          callBackError(error);
        }
    );
  }
  void removeAllConversation_inListe(){
    conversations.reset();
  }
}