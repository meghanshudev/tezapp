
import 'package:tez_mobile/models/product.dart';
import 'package:tez_mobile/respositories/base/base_repository.dart';
import 'package:tez_mobile/respositories/search/search_factory.dart';

import '../../helpers/network_V2.dart';
import '../../helpers/response.dart';

class SearchRepository extends BaseRepository implements SearchFactory{
  final String endPoint;
  SearchRepository({this.endPoint =  "product"}) : super(endPoint: endPoint);

  @override
  Future<Map<String, dynamic>> search({params = const {"page" : "1"}}) async {
     Map<dynamic, dynamic> data = await NetworkV2(
      endPoint: endPoint,
      params: params
    ).get();

    // print("#############DATA###############");
    // print(data);
    data = HttpResponseUtil.responseListData(data);
    dynamic listJson = data["list"];
    List<Product> list = List<Product>.from(listJson.map((model)=> Product.fromJson(model)));
    return {
      "list" : list,
    };
  }
}