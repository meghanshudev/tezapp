
import 'package:tez_mobile/respositories/base/base_factory.dart';

abstract class SearchFactory extends BaseFactory {
  Future<Map<String, dynamic>> search({params = const {"page" : "1"}});
}