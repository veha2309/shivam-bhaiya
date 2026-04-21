import 'package:flutter/material.dart';
import 'package:school_app/circular/Model/circular_model.dart';
import 'package:school_app/circular/ViewModel/circular_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'dart:async';

class CircularScreen extends StatefulWidget {
  static const String routeName = '/circular';
  final String? title;
  const CircularScreen({super.key, this.title});

  @override
  State<CircularScreen> createState() => _CircularScreenState();
}

class _CircularScreenState extends State<CircularScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();
  int page = 0;
  bool isLoading = false;
  bool hasMore = true;
  List<CircularModel> circularList = [];
  DateTime selectedDate = DateTime.now();
  int month = 0;
  double height = 0;
  double width = 0;
  bool showPinnedOnly = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchCirculars();
    _scrollController.addListener(_onScroll);
    month = selectedDate.month;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCirculars() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final response = await CircularViewModel.instance
        .getCircularListForStudent(page, searchQuery);

    if (response.success) {
      final newCirculars = response.data ?? [];
      setState(() {
        if (page == 0) circularList.clear();
        if (newCirculars.isEmpty) {
          hasMore = false;
        } else {
          circularList.addAll(newCirculars);
          page++;
        }
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading) {
      _fetchCirculars();
    }
  }

  @override
  Widget build(BuildContext context) {
    height = getHeightOfScreen(context) * 0.5;
    width = getWidthOfScreen(context) * 0.8;
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Circular",
        body: circularBody(context),
      ),
    );
  }

  Widget circularBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search circulars...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = '';
                                  page = 0;
                                  hasMore = true;
                                });
                                _fetchCirculars();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      setState(() {
                        searchQuery = value;
                        page = 0;
                        hasMore = true;
                      });
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        _fetchCirculars();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showPinnedOnly = !showPinnedOnly;
                  });
                  _fetchCirculars();
                },
                child: Icon(
                  showPinnedOnly ? Icons.push_pin : Icons.push_pin_outlined,
                  color:
                      showPinnedOnly ? ColorConstant.primaryColor : Colors.grey,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Builder(
              builder: (context) {
                if (isLoading && circularList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (circularList.isEmpty) {
                  return const NoDataWidget();
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 16.0,
                    children: [
                      DataTableWidget(
                        headingRowHeight: 35,
                        headingTextStyle: const TextStyle(
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                        ),
                        headingRowColor: ColorConstant.primaryColor,
                        dataTextStyle: const TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                        ),
                        headers: [
                          TableColumnConfiguration(text: "S.No", width: 30),
                          TableColumnConfiguration(text: "Date", width: 75),
                          TableColumnConfiguration(text: "Subject", width: 150),
                        ],
                        data: (() {
                          final filteredList = showPinnedOnly
                              ? circularList
                                  .where((circular) =>
                                      circular.isPinned?.toLowerCase() == 'y')
                                  .toList()
                              : circularList;
                          return filteredList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final circular = entry.value;
                            return TableRowConfiguration(
                              rowHeight: 45,
                              onTap: (_) {
                                showDialog(
                                  context: context,
                                  useRootNavigator: true,
                                  useSafeArea: true,
                                  builder: (context) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12.0),
                                        constraints: BoxConstraints(
                                            maxHeight:
                                                getHeightOfScreen(context) -
                                                    100),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        width: width,
                                        child: SingleChildScrollView(
                                            child: Column(
                                          children: <Widget>[
                                            Text(
                                              circular.remarks ?? "",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: fontFamily,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              circular.creationDate.toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: fontFamily,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Html(
                                              data: circular.message,
                                              style: {
                                                "*": Style(
                                                  fontSize: FontSize(15),
                                                  fontFamily: fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              },
                                              extensions: const [
                                                TableHtmlExtension(),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                launchURLString(
                                                    circular.attachments ?? "");
                                              },
                                              child: Text(
                                                circular.fileName ?? "",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: ColorConstant
                                                      .primaryColor,
                                                  fontFamily: fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: AppButton(
                                                      text: "Close",
                                                      onPressed: (p0) {
                                                        Navigator.pop(context);
                                                      }),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: AppButton(
                                                    text: circular.isPinned
                                                                ?.toLowerCase() ==
                                                            'y'
                                                        ? "Unpin"
                                                        : "Pin",
                                                    onPressed: (p0) async {
                                                      await CircularViewModel
                                                          .instance
                                                          .updateCircularPinnedStatus(
                                                              [
                                                            circular.noticeId ??
                                                                ""
                                                          ],
                                                              circular.isPinned
                                                                          ?.toLowerCase() ==
                                                                      'y'
                                                                  ? "N"
                                                                  : "Y").then(
                                                              (response) {
                                                        if (response.success) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          showSnackBarOnScreen(
                                                              context,
                                                              "Pinned/Unpinned successfully");
                                                          searchQuery = '';
                                                          page = 0;
                                                          hasMore = true;
                                                          _fetchCirculars();
                                                        } else {
                                                          Navigator.of(context)
                                                              .pop();
                                                          showSnackBarOnScreen(
                                                              context,
                                                              "An error occurred");
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )),
                                      ),
                                    ],
                                  ),
                                );
                                CircularViewModel.instance
                                    .updateCircularReadStatus(
                                        circular.noticeId ?? "");
                              },
                              cells: [
                                TableCellConfiguration(
                                  text: (index + 1).toString(),
                                  width: 30,
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontFamily: fontFamily,
                                    color: circular.isRead?.toLowerCase() == 'y'
                                        ? Colors.black54
                                        : Colors.black,
                                  ),
                                ),
                                TableCellConfiguration(
                                    text: formatAnyDateToDDMMYY(
                                        circular.creationDate ?? ""),
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontFamily: fontFamily,
                                      color:
                                          circular.isRead?.toLowerCase() == 'y'
                                              ? Colors.black54
                                              : Colors.black,
                                    ),
                                    width: 75),
                                TableCellConfiguration(
                                  onTap: (_) {
                                    launchURLString(circular.fileName ?? "");
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          circular.remarks ?? "",
                                          textAlign: TextAlign.center,
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: fontFamily,
                                            color: circular.isRead
                                                        ?.toLowerCase() ==
                                                    'y'
                                                ? Colors.black54
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        if (circular.isPinned?.toLowerCase() ==
                                            'y')
                                          const Icon(
                                            Icons.push_pin,
                                            size: 14,
                                            color: ColorConstant.primaryColor,
                                          ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  width: 200,
                                ),
                              ],
                            );
                          }).toList();
                        })(),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
