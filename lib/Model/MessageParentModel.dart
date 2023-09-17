import 'package:Pouic/Model/FileModel.dart';
import 'package:Pouic/Model/ReactionModel.dart';
import 'package:Pouic/Model/UserModel.dart';

class MessageParentModel{
  int id;
  User user;
  String message;
  DateTime date;
  List<FileModel> files;
  MessageParentModel(this.id, this.user, this.message, this.date,this.files);
}