import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tez_mobile/ui_elements/loading_widget.dart';

class PaginationWidget extends StatefulWidget {
  final RefreshController refreshController;
  final int totalRow;
  final int currentPage;
  final int currentTotalRow;
  final bool isLoading;
  final Function loadMore;
  final Function()? onRefresh;
  final Function()? onLoading;
  final List<Widget> items;

  const PaginationWidget({
    this.currentPage = 1,
    this.totalRow = 0,
    this.currentTotalRow = 0,
    this.isLoading = false,
    required this.loadMore,
    required this.refreshController,
    this.onLoading,
    this.onRefresh,
    this.items = const [],
    Key? key,
  }) : super(key: key);

  @override
  _PaginationWidgetState createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= (scrollInfo.metrics.maxScrollExtent)) {
          if (!widget.isLoading && (widget.currentTotalRow < widget.totalRow)) {
            widget.loadMore();
            return true;
          }
        }
        return false;
      },
      child: SmartRefresher(
        enablePullDown: true,
        controller: widget.refreshController,
        onRefresh: widget.onRefresh,
        onLoading: widget.onLoading,
        header: WaterDropHeader(),
        child: SingleChildScrollView(
          // padding: EdgeInsets.all(15),
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (widget.totalRow <= 0)
                  ? Center(
                      child: Text(
                      "No Data Found!",
                      style: TextStyle(fontSize: 14),
                    ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.items),
              Container(
                  child: (widget.isLoading && widget.currentPage > 1)
                      ? LoadingData()
                      : Container())
            ],
          ),
        ),
      ),
    );
  }
}
