import 'dart:convert';
import 'dart:typed_data';

class User{
  String email;
  String uniquePseudo;
  String pseudo;
  Uint8List? Avatar;

  User(this.email, this.uniquePseudo, this.pseudo, [this.Avatar]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uniquePseudo == uniquePseudo;
  }

  @override
  int get hashCode => uniquePseudo.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'uniquePseudo': uniquePseudo,
      'pseudo': pseudo,
      'Avatar': Avatar,
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class LoginModel{
  User user;
  String token;

  LoginModel(this.user,this.token);

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'token': token,
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
}