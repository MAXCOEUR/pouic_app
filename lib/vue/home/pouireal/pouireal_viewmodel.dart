import 'dart:async';

import 'package:pouic/Model/FileCustom.dart';
import 'package:pouic/Model/ReactionModel.dart';
import 'package:pouic/Model/pouireal_model.dart';
import 'package:pouic/repository/pouireal_repository.dart';
import 'package:camera/camera.dart';

class PouirealViewModel{
  PouirealRepository pouirealRepository = PouirealRepository();

  void _getPouirealAsync(StreamController<List<PouirealModel>> streamController,int id_lastPouireal)async{
    List<PouirealModel> list = await pouirealRepository.getPouireal(id_lastPouireal);
    streamController.add(list);
  }
  Stream<List<PouirealModel>> getPouireal(int id_lastPouireal){
    StreamController<List<PouirealModel>> streamController = StreamController<List<PouirealModel>>();

    _getPouirealAsync(streamController,id_lastPouireal);

    return streamController.stream;
  }

  void _deletePouirealAsync(StreamController<int> streamController,int id_pouireal)async{
    int list = await pouirealRepository.deletePouireal(id_pouireal);
    streamController.add(list);
  }
  Stream<int> deletePouireal(int id_pouireal){
    StreamController<int> streamController = StreamController<int>();

    _deletePouirealAsync(streamController,id_pouireal);

    return streamController.stream;
  }

  void _isPosted(StreamController<bool> streamController)async{
    bool isPosted = await pouirealRepository.isPosted();
    streamController.add(isPosted);
  }
  Stream<bool> isPosted(){
    StreamController<bool> streamController = StreamController<bool>();

    _isPosted(streamController);

    return streamController.stream;
  }
  void _postPouireal(StreamController<PouirealModel> streamController,PouirealPostModel pouirealpost)async{
    PouirealModel pouireal = await pouirealRepository.postPouireal(pouirealpost);
    streamController.add(pouireal);
  }
  Stream<PouirealModel> postPouireal(PouirealPostModel pouireal){
    StreamController<PouirealModel> streamController = StreamController<PouirealModel>();

    _postPouireal(streamController,pouireal);

    return streamController.stream;
  }
  void _postPouirealReaction(StreamController<Reaction> streamController,PouirealModel pouirealpost,String emoji)async{
    Reaction pouireal = await pouirealRepository.postPouirealReaction(pouirealpost,emoji);
    streamController.add(pouireal);
  }
  Stream<Reaction> postPouirealReaction(PouirealModel pouireal,String emoji){
    StreamController<Reaction> streamController = StreamController<Reaction>();

    _postPouirealReaction(streamController,pouireal,emoji);

    return streamController.stream;
  }
  void _postPouirealFile(StreamController<PouirealModel> streamController,int idPouireal, int nbImage, FileCustom image)async{
    PouirealModel pouireal = await pouirealRepository.postPouirealFile(idPouireal,nbImage,image);
    streamController.add(pouireal);
  }
  Stream<PouirealModel> postPouirealFile(int idPouireal, int nbImage, FileCustom image){
    StreamController<PouirealModel> streamController = StreamController<PouirealModel>();

    _postPouirealFile(streamController,idPouireal,nbImage,image);

    return streamController.stream;
  }
}