import 'package:discution_app/Model/ConversationListeModel.dart';
import 'package:dio/dio.dart';


final Dio dio = Dio();

class ConversationController{
  ConversationListe conversationListe = ConversationListe();

  Future<bool> addConversationListe(int page) async {
    try{
      final response = await dio.get(
        'http://192.168.0.172:3000/api/conv',
      );
      print('GET Response data: ${response.data}');
    }catch(e){
      print(e);
      return false;
    }
    return true;
  }
}