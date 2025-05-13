
import 'package:tez_mobile/models/cart.dart';

abstract class CartFactory{
  Future<List<Cart>> list();
  Future<int> addOrUpdate({ required Cart cart , String type = "add"});
  Future<void> removeAll();
}