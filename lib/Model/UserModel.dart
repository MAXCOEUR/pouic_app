import 'dart:convert';
import 'dart:typed_data';

class User{
  String email;
  String uniquePseudo;
  String pseudo;
  bool? sont_amis =false;
  String? bio;
  String? extantion;

  User(this.email, this.uniquePseudo, this.pseudo,this.bio,this.extantion,[this.sont_amis]);

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
      'sont_amis':sont_amis,
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
  String? getNameImage(){
    if(extantion!=null){
      return uniquePseudo+"."+extantion!;
    }
    return null;
  }
}