import 'dart:convert';

class Conversation{
  int id;
  String name;
  String uniquePseudo_admin;
  String? image;

  Conversation(this.id, this.name, this.uniquePseudo_admin, this.image);

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
      'image': image,
    };
  }
  String toJsonString() {
    return jsonEncode(toJson());
  }
}