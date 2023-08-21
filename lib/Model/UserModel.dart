import 'dart:convert';

class User{
  String email;
  String uniquePseudo;
  String pseudo;
  String? Avatar;

  User(this.email, this.uniquePseudo, this.pseudo, this.Avatar);

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