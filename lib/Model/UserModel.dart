import 'dart:convert';
import 'dart:typed_data';

class User{
  String email;
  String uniquePseudo;
  String pseudo;
  bool? sont_amis;
  String? bio;
  String? extension;

  User({required this.email,required this.uniquePseudo,required this.pseudo,required this.bio,required this.extension,this.sont_amis});

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
    if(extension!=null){
      return uniquePseudo+"."+extension!;
    }
    return null;
  }
}