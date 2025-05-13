// To parse this JSON data, do
//
//     final attribute = attributeFromJson(jsonString);

import 'dart:convert';

Attribute attributeFromJson(String str) => Attribute.fromJson(json.decode(str));

String attributeToJson(Attribute data) => json.encode(data.toJson());

class Attribute {
  final String id;
  final String name;
  final String value;

  Attribute({
      this.id = "",
      this.name = "",
      this.value = "",
  });

  factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
      id: json["id"].toString(),
      name: json["name"],
      value: json["value"],
  );

  Map<String, dynamic> toJson() => {
      "id": id,
      "name": name,
      "value": value,
  };
}
