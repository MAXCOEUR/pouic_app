import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/Model/ReactionModel.dart';
import 'package:discution_app/Model/UserModel.dart';

class MessageParentModel{
  int id;
  User user;
  String message;
  DateTime date;
  List<FileModel> files;
  MessageParentModel(this.id, this.user, this.message, this.date,this.files);
}