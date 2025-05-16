
import 'package:tezapp/respositories/base/base_repository.dart';
import 'package:tezapp/respositories/suggest_us/suggest_us_factory.dart';

class SuggestUsRepository extends BaseRepository implements SuggestUsFactory{
  final String endPoint;
  SuggestUsRepository({this.endPoint =  "suggestion"}) : super(endPoint: endPoint);
}