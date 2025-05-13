import 'package:tez_mobile/helpers/network_V2.dart';
import 'package:tez_mobile/helpers/response.dart';
import 'package:tez_mobile/models/transaction.dart';
import 'package:tez_mobile/respositories/base/base_factory.dart';

class BaseRepository implements BaseFactory{

  final String endPoint;

  BaseRepository({required this.endPoint });

  @override
  Future<Map> index({params = const {"page" : "1"}}) async {
    
     Map<dynamic, dynamic> data = await NetworkV2(
      endPoint: endPoint,
      params: params
    ).get();

    data = HttpResponseUtil.responseListData(data);
    dynamic listJson = data["list"];
    dynamic cntJson = data["total"];
    List<Transaction> list = List<Transaction>.from(listJson.map((model)=> Transaction.fromJson(model)));
    int cnt = int.parse(cntJson.toString());
    return {
      "list" : list,
      "total" : cnt
    };
  }

  @override
  Future<dynamic> create({params = const {"page" : "1"}}) async {
    Map<dynamic, dynamic> response = await NetworkV2(
      endPoint: endPoint,
      params: params
    ).post();
    return response;
  }

  
  

}