import 'dart:convert';

import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/models/cart.dart';
import 'package:tezchal/respositories/cart/cart_factory.dart';

class CartRepository implements CartFactory{
  
  final String storageName = "carts";

  @override
  Future<List<Cart>> list() async {
    dynamic listJson = await getStorage(storageName);
    listJson = jsonDecode(listJson ?? "[]") ;
    List<Cart> list = List<Cart>.from(listJson.map((model)=> Cart.fromJson(model)));
    return list;
  }

  @override
  Future<int> addOrUpdate({required Cart cart , String type = "add"}) async {

    int qty = 0;
    dynamic listJson = await getStorage(storageName);
    listJson = jsonDecode(listJson ?? "[]") ;
    List jsonList = [];
    dynamic jsonItem = {};
    if(listJson.length <= 0){
      jsonItem = cart.toJson();
      jsonList.add(jsonItem);
      qty = cart.qty;
    }else{
      List<Cart> list = List<Cart>.from(listJson.map((model)=> Cart.fromJson(model)));
      bool isRecordExist = false;
      for (Cart item in list) {
        //update if record is existed
        if(item.productId == cart.productId){
          if(type == "add") {
            if(item.qty < 0) item.qty = 0; 
            item.qty = item.qty + cart.qty;
          }
          else {
            if(item.qty >= 1) {
              item.qty = item.qty - cart.qty;
            }
            
          }
            
          jsonItem = item.toJson();
          isRecordExist = true;
          qty = item.qty;
        }
        //convert class object to json data
        else{
          jsonItem = item.toJson();
        }
        jsonList.add(jsonItem);
      }
      //add if record is not existed
      if(!isRecordExist) {
        qty = cart.qty;
        jsonItem = cart.toJson();
        jsonList.add(jsonItem);
      }
    }
    await setStorage(storageName, jsonList);
    return qty;
  }


  @override
  Future<void> removeAll() async {
     await removeStorage(storageName);
  }

  

}