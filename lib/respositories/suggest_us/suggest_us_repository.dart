
import 'package:tez_mobile/respositories/base/base_repository.dart';
import 'package:tez_mobile/respositories/suggest_us/suggest_us_factory.dart';

class SuggestUsRepository extends BaseRepository implements SuggestUsFactory{
  final String endPoint;
  SuggestUsRepository({this.endPoint =  "suggestion"}) : super(endPoint: endPoint);
}