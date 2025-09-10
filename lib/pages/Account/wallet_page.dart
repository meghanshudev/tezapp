import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/constant.dart';
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
import 'package:tezchal/ui_elements/custom_sub_header.dart';
import 'package:tezchal/ui_elements/icon_box.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<Transaction> transactions = [];
  bool isLoading = false;
  String balance = "0";

  var zipCode = '';
  var deliverTo = '';
  String phone = '';

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar(
          subtitle: zipCode + " - " + context.watch<AccountInfoProvider>().name,
          subtitleIcon: Entypo.location_pin,
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: CustomFooter(
        onTapBack: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSubHeader(
            title: "tez_cash".tr(),
            subtitle: "$deliverTo • $phone",
          ),
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
      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
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
              Image.asset("assets/images/logo-bg.png"),
            ],
          ),
          Text("₹$balance", style: titleBoldWhiteTitle),
        ],
      ),
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
}
