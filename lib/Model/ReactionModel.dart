import 'package:discution_app/Model/UserModel.dart';

class Reaction{
  User user;
  String reaction;
  Reaction(this.user,this.reaction);


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reaction && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}