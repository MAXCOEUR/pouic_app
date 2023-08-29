import 'dart:convert';
import 'dart:typed_data';

class Conversation{
  int id;
  String name;
  String uniquePseudo_admin;
  int unRead;

  Conversation(this.id, this.name, this.uniquePseudo_admin,this.unRead);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uniquePseudo_admin': uniquePseudo_admin,
      "unRead":unRead,
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
}