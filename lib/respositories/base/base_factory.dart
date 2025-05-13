abstract class BaseFactory{
  Future<Map<dynamic, dynamic>> index({dynamic params = const {"page" : "1"}});
  Future<dynamic> create({dynamic params = const {"page" : "1"}});
}