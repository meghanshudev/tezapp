import 'package:tezapp/helpers/utils.dart';

class Cart{

  final String productId;
  int qty;
  
  Cart({
    this.productId = "",
    this.qty = 0
  });

  Cart.fromJson(json)
      : 
        productId = json["product_id"].toString(),
        qty = convertInt(json["qty"]);

  Map<String, dynamic> toJson() => {
    'product_id' : productId,
    'qty' : qty
  };
}