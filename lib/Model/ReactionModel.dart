import 'package:pouic/Model/UserModel.dart';

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
  factory Reaction.fromJson(Map<String, dynamic> json) {

    User user = User(email: json['email'], uniquePseudo: json['uniquePseudo'], pseudo: json['pseudo'], bio: json['bio'], extension: json['extension']);

    return Reaction(
        user,
        json['emoji']
    );
  }
}