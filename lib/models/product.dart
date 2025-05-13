// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

import '../helpers/utils.dart';
import 'attribute.dart';
import 'category.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
  final String id;
  final String name;
  final String image;
  final double unitPrice;
  final double percentOff;
  final double salePrice;
  final String saleUom;
  final Category? category;
  final List<Attribute>? attributes;
  final Product? product;

    Product({
        this.id = "",
        this.name = "",
        this.image  = "",
        this.unitPrice  = 0.0,
        this.percentOff = 0.0,
        this.salePrice = 0.0,
        this.saleUom = "",
        this.category,
        this.attributes,
        this.product,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"].toString(),
        name: json["name"],
        image: json["image"],
        unitPrice: convertDouble(json["unit_price"]),
        percentOff: convertDouble(json["percent_off"]),
        salePrice: convertDouble(json["sale_price"]),
        saleUom: json["sale_uom"],
        category: json["category"] == null ? null : Category.fromJson(json["category"]),
        attributes: List<Attribute>.from(json["attributes"].map((x) => Attribute.fromJson(x))),
        product: json["product"] == null ? null : Product.fromJson(json["product"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "unit_price": unitPrice,
        "percent_off": percentOff,
        "sale_price": salePrice,
        "sale_uom": saleUom,
        "category": category == null ? null : category!.toJson(),
        "attributes": List<dynamic>.from(attributes!.map((x) => x.toJson())),
        "product": product == null ? null : product!.toJson(),
    };
}