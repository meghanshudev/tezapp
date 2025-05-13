// To parse this JSON data, do
//
//     final parent = parentFromJson(jsonString);

import 'dart:convert';

Parent parentFromJson(String str) => Parent.fromJson(json.decode(str));

String parentToJson(Parent data) => json.encode(data.toJson());

class Parent {
  final String id;
  final String name;
  final String image;

  Parent({
      this.id = "",
      this.name = "",
      this.image = "",
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
      id: json["id"].toString(),
      name: json["name"],
      image: json["image"],
  );

  Map<String, dynamic> toJson() => {
      "id": id,
      "name": name,
      "image": image,
  };
}
