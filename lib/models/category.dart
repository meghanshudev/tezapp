// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
  final String id;
  final String name;
  final dynamic description;
  final String image;
  final bool isSubCategory;
  
  Category({
      this.id = "",
      this.name = "",
      this.description,
      this.image = "",
      this.isSubCategory = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
      id: json["id"].toString(),
      name: json["name"],
      description: json["description"],
      image: json["image"],
      isSubCategory: json["is_sub_category"],
  );

  Map<String, dynamic> toJson() => {
      "id": id,
      "name": name,
      "description": description,
      "image": image,
      "is_sub_category": isSubCategory,
  };
}
