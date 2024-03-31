import 'package:Pouic/Model/ReactionModel.dart';
import 'package:Pouic/Model/pouireal_model.dart';
import 'package:Pouic/data_source/api_data_source.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

class PouirealRepository{
  ApiDataSource _apiDataSource = ApiDataSource();

  Future<List<PouirealModel>> getPouireal(int id_lastPouireal) async{
    final Map<String, dynamic> jsonData = await _apiDataSource.getapi(["pouireal"], queryParameters:{'id_lastPouireal': id_lastPouireal.toString()});
    final List<dynamic> result = jsonData['result'];
    final List<PouirealModel> listPouirealModel=[];

    for (var res in result){
      PouirealModel tmp = PouirealModel.fromJson(res);
      tmp.reactions = await getPouirealReaction(tmp.id);
      listPouirealModel.add(tmp);
    }

    return listPouirealModel;
  }
  Future<List<Reaction>> getPouirealReaction(int pouireal_id) async{
    final Map<String, dynamic> jsonData = await _apiDataSource.getapi(["pouireal","reaction"], queryParameters:{'pouireal_id': pouireal_id.toString()});
    final List<dynamic> result = jsonData['result'];
    final List<Reaction> listReaction=[];

    for (var res in result){
      listReaction.add(Reaction.fromJson(res));
    }

    return listReaction;
  }
  Future<int> deletePouireal(int id_pouireal) async{
    final Map<String, dynamic> jsonData = await _apiDataSource.deleteapi(["pouireal"], queryParameters:{'id_pouireal': id_pouireal.toString()});
    final int result = int.parse(jsonData['id_pouireal']);

    return result;
  }
  Future<bool> isPosted() async{
    try{
      await _apiDataSource.getapi(["pouireal","isPosted"]);
      return true;
    }catch(Exception){
      return false;
    }
  }
  Future<PouirealModel> postPouireal(PouirealPostModel pouireal) async{
    final Map<String, dynamic> jsonData = await _apiDataSource.postapi(["pouireal"],bodyParameters: pouireal.toPostJson());
    PouirealModel pouirealModel = PouirealModel.fromJson(jsonData['result']);
    return pouirealModel;
  }
  Future<Reaction> postPouirealReaction(PouirealModel pouireal,String emoji) async{
    final Map<String, dynamic> jsonData = await _apiDataSource.postapi(["pouireal","reaction"],bodyParameters: {"pouireal_id":pouireal.id,"emoji":emoji});

    Reaction reaction = Reaction.fromJson(jsonData["result"][0]);
    return reaction;
  }
  Future<PouirealModel> postPouirealFile(int idPouireal, int nbImage, XFile image) async {
    try {
      // Appel de la fonction postapiDataMultipart pour envoyer l'image
      final Map<String, dynamic> jsonData = await _apiDataSource.postapiDataMultipart(
        ["pouireal", "upload"],
        {
          "file": MultipartFile.fromBytes(
            await image.readAsBytes(),
            filename: image.name,
          ),
          "nbr_picture": nbImage,
          "id_pouireal": idPouireal,
        },
      );

      // Créer une instance de PouirealModel à partir des données JSON renvoyées
      PouirealModel pouirealModel = PouirealModel.fromJson(jsonData['result']);

      // Retourner le modèle PouirealModel
      return pouirealModel;
    } catch (error) {
      // Gérer les erreurs ici
      throw error;
    }
  }

}