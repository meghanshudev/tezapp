import 'package:tezapp/helpers/utils.dart';

class Transaction{

  final String id;
  final double openBalance;
  final double amount;
  final double balance;
  final String stateType;
  final String trxType;
  final String remark;
  final String date;
  
  Transaction({
    this.id = "",
    this.openBalance = 0.0,
    this.amount= 0.0,
    this.balance = 0.0,
    this.stateType = "",
    this.trxType = "",
    this.remark = "",
    this.date = ""
  });

  Transaction.fromJson(json)
      : id = json["id"].toString(),
        openBalance = convertDouble(json["open_balance"]),
        amount = convertDouble(json["amount"]),
        balance = convertDouble(json["balance"]),
        stateType = json["state_type"].toString(),
        trxType = json["trx_type"].toString(),
        remark = json["remark"].toString(),
        date = myFormatDateTime(json["date"]);

  Map<String, dynamic> toJson() => {
    'id' : id,
    'open_balance' : openBalance,
    'amount' : amount,
    'balance' : balance,
    'state_type' : stateType,
    'trx_type' : trxType,
    'remark' : remark,
    'date' : date
  };
}