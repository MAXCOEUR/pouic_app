import 'dart:convert';
import 'dart:typed_data';

class User{
  String email;
  String uniquePseudo;
  String pseudo;
  bool? sont_amis =false;
  String? bio;
  String? extansion;

  User(this.email, this.uniquePseudo, this.pseudo,this.bio,this.extansion,[this.sont_amis]);

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
    if(extansion!=null){
      return uniquePseudo+"."+extansion!;
    }
    return null;
  }
}