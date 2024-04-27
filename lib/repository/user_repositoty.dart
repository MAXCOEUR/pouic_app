import '../data_source/api_data_source.dart';

class UserRepositoty{
  ApiDataSource _apiDataSource = ApiDataSource();

  Future<bool> resetPassWord(String emailOrUniquePsodo) async{
    try{
      await _apiDataSource.postapi(["user","reset_mot_de_passe"], bodyParameters:{'emailOrPseudo': emailOrUniquePsodo});
      return true;
    }catch(ex){
      return false;
    }

  }
}