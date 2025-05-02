import 'package:pouic/Model/FileModel.dart';
import 'package:pouic/Model/ReactionModel.dart';
import 'package:pouic/Model/UserModel.dart';

class MessageParentModel{
  int id;
  User user;
  String message;
  DateTime date;
  List<FileModel> files;
  MessageParentModel(this.id, this.user, this.message, this.date,this.files);
}