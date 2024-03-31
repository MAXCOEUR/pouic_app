import 'package:intl/intl.dart';

import 'ReactionModel.dart';
import 'UserModel.dart';

class PouirealModel {
  int id;
  User user;
  String? description;
  DateTime date;
  String? picture1;
  String? picture2;
  List<Reaction> reactions = [];

  PouirealModel(this.id, this.user, this.description, this.date, this.picture1,
      this.picture2);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PouirealModel && other.id == id;
  }
  factory PouirealModel.fromJson(Map<String, dynamic> json) {

    User user = User(email: json['email'], uniquePseudo: json['uniquePseudo'], pseudo: json['pseudo'], bio: json['bio'], extension: json['extension']);
    DateTime date = DateTime.parse(json["date"]).toLocal();

    return PouirealModel(
        json['id'],
        user,
        json['description'],
        date,
        json['linkPicture1'],
        json['linkPicture2']
    );
  }
  @override
  String toString() {
    return "$id $description $date";
  }
}
class PouirealPostModel {
  User user;
  String? description;
  DateTime date;

  PouirealPostModel(this.user, this.description, this.date);


  Map<String, dynamic> toPostJson(){
    return {"description": this.description,"date":DateFormat('yyyy-MM-dd HH:mm:ss').format(this.date)};
  }
}