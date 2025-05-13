import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/helpers/utils.dart';
import 'package:tez_mobile/models/transaction.dart';
import 'package:tez_mobile/pages/Transaction/components/transaction_item.dart';
import 'package:tez_mobile/provider/account_info_provider.dart';
import 'package:tez_mobile/respositories/transactions/transaction_repository.dart';
import 'package:tez_mobile/ui_elements/custom_appbar.dart';
import 'package:tez_mobile/ui_elements/loading_widget.dart';
import 'package:tez_mobile/ui_elements/pagination_widget.dart';
import 'package:tez_mobile/ui_elements/custom_footer.dart' as footer;

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  RefreshController refreshController = RefreshController();

  bool isLoading = false;
  bool isPulling = false;

  int page = 1;
  int total = 0;
  String search = "";
  List<Transaction> list = [];
  var zipCode = '';
  var deliverTo = '';

  @override
  void initState() {
    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code']
        : "";
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initialize() {
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: CustomAppBar(
            subtitle:
                zipCode + " - " + context.watch<AccountInfoProvider>().name,
            subtitleIcon: Entypo.location_pin,
          ),
        ),
        body: getBody(),
        bottomNavigationBar: footer.CustomFooter(
          onTapBack: () {
            Navigator.of(context).pop();
          },
        ));
  }

  Widget getBody() {
    if (isLoading && page == 1 && !isPulling) return LoadingData();
    return PaginationWidget(
      isLoading: isLoading,
      totalRow: total,
      currentTotalRow: list.length,
      currentPage: page,
      refreshController: refreshController,
      items: getList(),
      onLoading: () {
        onLoading();
      },
      onRefresh: () {
        onRefresh();
      },
      loadMore: () {
        loadMore();
      },
    );
  }

  List<Widget> getList() {
    return List.generate(
        list.length,
        (index) => TransactionItem(
              item: list[index],
            ));
  }

  Future<void> loadMore() async {
    await fetchData();
  }

  void onLoading() async {
    refreshController.loadComplete();
  }

  void onRefresh() async {
    setState(() {
      page = 1;
      isPulling = true;
    });
    fetchData().then((isSuccess) {
      if (isSuccess) {
        refreshController.refreshCompleted();
      } else {
        refreshController.refreshFailed();
      }
    });
  }

  fetchData() async {
    if (isLoading) return;
    if (mounted)
      setState(() {
        isLoading = true;
      });

    Map<dynamic, dynamic> data = await TransactionRepository().index(params: {
      "page": page.toString(),
      "row": "10",
    });
    List<Transaction> items = data["list"] as List<Transaction>;
    int cnt = data["total"];

    if (mounted)
      setState(() {
        if (page == 1)
          list = items;
        else
          list.addAll(items);

        total = cnt;
        isLoading = false;
        isPulling = false;
        page++;
      });
    return true;
  }
}
