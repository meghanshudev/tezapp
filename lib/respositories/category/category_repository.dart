
import 'package:tez_mobile/models/category.dart';
import 'package:tez_mobile/respositories/base/base_repository.dart';

import '../../helpers/network_V2.dart';
import '../../helpers/response.dart';
import 'category_factory.dart';

class CategoryRepository extends BaseRepository implements CategoryFactory{
  final String endPoint;
  CategoryRepository({this.endPoint =  "category"}) : super(endPoint: endPoint);

  @override
  Future<Map> index({params = const {"page" : "1"}}) async {
    
    Map<dynamic, dynamic> data = await NetworkV2(
      endPoint: endPoint,
      params: params
    ).get();
    // print("#############DATA###############");
    // print(data);
    data = HttpResponseUtil.responseListData(data);
    dynamic listJson = data["list"];
    List<Category> list = List<Category>.from(listJson.map((model)=> Category.fromJson(model)));
    return {
      "list" : list,
    };
  }
}