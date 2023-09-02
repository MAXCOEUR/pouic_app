import 'package:discution_app/Model/UserModel.dart';

class MessageParentModel{
  int id;
  User user;
  String message;
  DateTime date;
  MessageParentModel(this.id, this.user, this.message, this.date);
}