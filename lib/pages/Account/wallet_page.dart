import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart' as rfa;
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/models/transaction.dart';
import 'package:tezchal/pages/Transaction/components/transaction_item.dart';
import 'package:tezchal/pages/Transaction/components/transaction_loading.dart';
import 'package:tezchal/pages/Transaction/transaction_page.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/respositories/transactions/transaction_repository.dart';
import 'package:tezchal/ui_elements/border_button.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/custom_footer.dart';
import 'package:tezchal/ui_elements/custom_footer_buttons.dart';
import 'package:tezchal/ui_elements/custom_sub_header.dart';
import 'package:tezchal/ui_elements/icon_box.dart';
import 'package:tezchal/ui_elements/custom_textfield.dart';
import 'package:easebuzz_flutter/easebuzz_flutter.dart';
 class WalletPage extends StatefulWidget {
   const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<Transaction> transactions = [];
  bool isLoading = false;
  String balance = "0";
  final TextEditingController _amountController = TextEditingController();
 
   var zipCode = '';
   var deliverTo = '';
  String phone = '';

  bool isLoadingButton = false;

  @override
  void initState() {
    initialize();
    super.initState();
    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode =
        !checkIsNullValue(userSession['zip_code'])
            ? userSession['zip_code']
            : "";
    phone = !checkIsNullValue(userSession) ? userSession['phone_number'] : "";
  }

  initialize() {
    fetchUserProfile();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBar(
          isWidget: true,
          title: "tez_cash".tr(),
          subtitle: "$deliverTo • $phone",
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: getFooter()
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 23),
          getBalanceCard(),
          // SizedBox(
          //   height: 10,
          // ),
          // getOptionButtons(),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Expanded(
                  child:
                      Text("recent_activity", style: normalBoldBlackTitle).tr(),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 70,
                    height: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("see_all", style: meduimGreyText).tr(),
                        // SizedBox(
                        //   width: 6,
                        // ),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          getTransactions(),
          checkIsNullValue(transactions.length)
              ? SizedBox()
              : Padding(
                padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: BorderButton(
                    width: double.infinity,
                    height: 55,
                    title: "view_all_activities".tr(),
                    suffixIcon: Icon(Icons.arrow_forward_ios, color: primary),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget getTransactions() {
    if (isLoading) return transactionLoading();
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionItem(item: transactions[index]);
      },
    );
  }

  Widget transactionLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return TransactionLoading();
      },
    );
  }

  Widget getOptionButtons() {
    return Row(
      children: [
        Spacer(),
        Column(
          children: [
            IconBox(
              child: Icon(Icons.add, color: Colors.white, size: 30),
              padding: 30,
            ),
            SizedBox(height: 10),
            Text(
              "add tez chal \ncash",
              textAlign: TextAlign.center,
              style: smallMediumGreyText,
            ),
          ],
        ),
        SizedBox(width: 40),
        Column(
          children: [
            IconBox(
              child: Icon(Icons.star, color: Colors.white, size: 30),
              padding: 30,
            ),
            SizedBox(height: 10),
            Text(
              "redeem \nvoucher",
              textAlign: TextAlign.center,
              style: smallMediumGreyText,
            ),
          ],
        ),
        Spacer(),
      ],
    );
  }

  Widget getBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      margin: EdgeInsets.fromLTRB(15, 0, 15, 20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 1,
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("your_balance", style: normalBoldWhiteTitle).tr(),
              // Image.asset("assets/images/logo-bg.png"),
            ],
          ),
          Text("₹$balance", style: titleBoldWhiteTitle),
        ],
      ),
    );
  }

  Widget getFooter() {
    return CustomFooterButtons(
      isLoading: isLoadingButton,
      proceedTitle: "Add amount".tr(),
      onTapProceed: () {
        _showAddAmountDialog();
      },
      onTapBack: () {
        Navigator.pop(context);
      },
    );
  }
  fetchUserProfile() async {
    var data = await getProfileData(context);
    setState(() {
      balance = data["balance"].toString();
    });
  }

  fetchData() async {
    if (isLoading) return;
    if (mounted)
      setState(() {
        isLoading = true;
      });

    Map<dynamic, dynamic> data = await TransactionRepository().index(
      params: {"page": "1", "row": "5"},
    );
    List<Transaction> items = data["list"] as List<Transaction>;

    if (mounted)
      setState(() {
        transactions = items;
        isLoading = false;
      });
    return true;
  }

  _showAddAmountDialog() {
    rfa.Alert(
      context: context,
      style: alertStyle,
      title: "Add Amount",
      content: Column(
        children: <Widget>[
          SizedBox(height: 20),
          CustomTextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            hintText: 'Enter Amount',
          ),
        ],
      ),
      buttons: [
        rfa.DialogButton(
          height: 60,
          width: 120,
          child: Text(
            "Cancel",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.grey,
          radius: BorderRadius.circular(10.0),
        ),
        rfa.DialogButton(
          height: 60,
          width: 120,
          child: Text(
            "Add",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            addAmount();
          },
          color: primary,
          radius: BorderRadius.circular(10.0),
        ),
      ],
    ).show();
  }

  addAmount() async {
    if (_amountController.text.isEmpty) {
      showToast("Please enter amount", context);
      return;
    }
    Navigator.pop(context);
    setState(() {
      isLoadingButton = true;
    });
    int? amount = int.tryParse(_amountController.text);
    var response = await netPost(
      isUserToken: true,
      endPoint: 'me/wallet/add',
      params: {'amount': amount},
    );
    log("WALLET - ${response}");
    if (response['resp_code'] == "200") {
      var respData = response['resp_data'];
      if (respData != null && respData['success'] == true && respData['data'] != null) {
        var paymentUrl = respData['data']['payment_url'];
        var accessKey = respData['data']['access_key'];
        var method = respData['data']['method'];
        var transactionId = respData['data']['transaction_id'].toString();
        if (paymentUrl != null && accessKey != null && method != null) {
          // Trigger EaseBuzz payment flow
          await _startEaseBuzzPayment(accessKey, paymentUrl, transactionId);
        } else {
          showToast("Amount added successfully", context);
          initialize();
        }
      } else {
        showToast(respData['message'] ?? "Failed to add amount", context);
      }
    } else {
      showToast(response['resp_data']['message'], context);
    }
    setState(() {
      isLoadingButton = false;
    });
  }

  final EasebuzzFlutter _easebuzzFlutterPlugin = EasebuzzFlutter();
  String? _pendingTransactionId;

  Future<void> _startEaseBuzzPayment(String accessKey, String paymentUrl, String transactionId) async {
    setState(() {
      _pendingTransactionId = transactionId;
    });
    try {
      // The EasebuzzFlutter plugin expects the accessKey and environment (e.g., "test" or "prod")
      final paymentResponse = await _easebuzzFlutterPlugin.payWithEasebuzz(
        accessKey,
        "test", // Assuming test environment; change if needed
      );
      // After payment flow, check payment status from backend
      if (_pendingTransactionId != null) {
        await _checkPaymentStatus(_pendingTransactionId!);
      } else {
        _showPaymentStatusDialog(
          "Payment Error",
          "Could not verify payment status. Transaction ID not found.",
        );
      }
    } catch (e) {
      showToast("Payment failed: ${e.toString()}", context);
    }
  }

  Future<void> _checkPaymentStatus(String transactionId) async {
    var response = await netGet(
      endPoint: "payment/status/$transactionId",
      isUserToken: true,
    );
    if (mounted) {
      setState(() {
        _pendingTransactionId = null;
      });
    }
    if (response['resp_code'] == "200" && response['resp_data'] != null) {
      var status = response['resp_data']['data']['status'];
      if (status == 'success') {
        _showPaymentStatusDialog("Payment Successful", "Your payment was successful.");
        initialize();
      } else if (status == 'failed') {
        _showPaymentStatusDialog("Payment Failed", "Your payment has failed. Please try again.");
      }
    }
  }

  void _showPaymentStatusDialog(String title, String message) {
    rfa.Alert(
      context: context,
      style: alertStyle,
      title: title,
      content: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Text(
          message,
          style: alertStyle.descStyle,
          textAlign: alertStyle.descTextAlign,
        ),
      ),
      buttons: [
        rfa.DialogButton(
          height: 60,
          width: 150,
          child: Text(
            "OK",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: primary,
          radius: BorderRadius.circular(10.0),
        ),
      ],
    ).show();
  }
}
