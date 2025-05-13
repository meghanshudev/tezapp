
import 'package:tez_mobile/respositories/base/base_repository.dart';
import 'package:tez_mobile/respositories/transactions/transaction_factory.dart';

class TransactionRepository extends BaseRepository implements TransactionFactory{
  final String endPoint;
  TransactionRepository({this.endPoint =  "me/transaction"}) : super(endPoint: endPoint);

  
}