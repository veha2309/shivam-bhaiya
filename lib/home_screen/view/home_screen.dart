import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/daily_message.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/model/home_screen_utils.dart';
import 'package:school_app/home_screen/view/notification_list_widget.dart';
import 'package:school_app/home_screen/view_model/home_viewmodel.dart';
import 'package:school_app/homework_screen/model/homeBanner_model.dart';

import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/components.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  User? loggedInUser;
  Future<ApiResponse<HomeModel>>? homeDetail;
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  HomeModel? homeModel;
  Map<String, List<MenuDetail>> menuDetailMap = {};
  List<HomebannerModel> banner = [];
  int currentPage = 0;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndShowPopup(context);
    }
  }

  Future<void> _checkAndShowPopup(BuildContext context) async {
    if (await shouldShowPopup()) {
      var response = await HomeViewmodel.instance.getDailyMessage();
      if (response.success && (response.data?.isNotEmpty ?? false)) {
        // Get today's message by matching the date
        DailyMessage? todayMessage;
        try {
          todayMessage = response.data?.firstWhere(
            (message) =>
                message.messageDate == getDDMMYYYYInNum(DateTime.now()),
          );
        } catch (_) {}

        if (todayMessage != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text(
                "Thought of the day",
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(1.0),
                style: TextStyle(
                  color: ColorConstant.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                todayMessage!.message ?? "",
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  color: ColorConstant.primaryTextColor,
                ),
              ),
              contentPadding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16.0, bottom: 16.0),
              actionsAlignment: MainAxisAlignment.end,
              actionsPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16.0,
              ),
              actions: [
                Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        width: 100,
                        decoration: BoxDecoration(
                          color: ColorConstant.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: ColorConstant.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.thumb_up,
                          color: ColorConstant.onPrimary,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // First time check jab app launch ho
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPopup(context);
    });
    try {
      loggedInUser = AuthViewModel.instance.getLoggedInUser();
      callGetHomeDetailFuture();
    } catch (_) {}
  }

  void callGetBannerService() async {
    var response = await HomeViewmodel.instance.getHomeBanner();
    if (response.success) {
      banner = response.data ?? [];
      setState(() {});
    }
  }

  void callGetHomeDetailFuture() {
    homeModel = null;
    menuDetailMap = {};
    homeDetail = HomeViewmodel.instance.fetchHomeDetail().then((response) {
      if (response.success) {
        homeModel = response.data;
        if (homeModel != null) AuthViewModel.instance.setHomeModel(homeModel!);

        homeModel?.menuDetails?.forEach((menuDetail) {
          if (menuDetail.categoryId == "2") {
            if (menuDetailMap[menuDetail.categoryId] != null) {
              menuDetailMap[menuDetail.categoryId]!.add(menuDetail);
            } else {
              menuDetailMap[menuDetail.categoryId ?? ""] = [menuDetail];
            }
          } else {
            if (menuDetailMap["1"] != null) {
              menuDetailMap["1"]!.add(menuDetail);
            } else {
              menuDetailMap["1"] = [menuDetail];
            }
          }

          menuDetailMap.map((key, value) {
            value.sort((a, b) {
              int getPositionOfA =
                  fromMobileMenuId(a.mobileMenuId ?? "")?.position ?? 9999;

              int getPositionOfB =
                  fromMobileMenuId(b.mobileMenuId ?? "")?.position ?? 9999;

              return (getPositionOfA) - (getPositionOfB);
            });
            return MapEntry(key, value);
          });
        });

        SchoolDetailsViewModel.instance.registerDeviceForNotifications();
        SchoolDetailsViewModel.instance.subscribeTopicId();
      }

      return response;
    });
    callGetBannerService();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    try {
      loggedInUser = AuthViewModel.instance.getLoggedInUser();
      setState(() {
        callGetHomeDetailFuture();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Exit the app when back button is pressed on the home screen
        SystemNavigator.pop();
        return true;
      },
      child: AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        showBackButton: false,
        background: ImageConstants.homeScreenBackground,
        body: RefreshIndicator(
          onRefresh: () {
            setState(() {
              callGetHomeDetailFuture();
            });
            return Future(() => null);
          },
          child: AppFutureBuilder(
            future: homeDetail,
            builder: (context, snapshot) {
              if (homeModel?.menuDetails?.isEmpty ?? true) {
                return const NoDataWidget();
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16,
                  children: [
                    UserHeaderWidget(user: loggedInUser, homeModel: homeModel),
                    Expanded(
                        child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: getHomeScreen(),
                    ))
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getHomeScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const NotificationListWidget(),
        const SizedBox(height: 16),
        getQuickActionsWidget(),
        const SizedBox(height: 16),
        if (banner.isNotEmpty) ...[
          getBannerWidget(),
          const SizedBox(height: 16),
        ],
        ...menuDetailMap["1"]?.asMap().entries.map(
              (entry) {
                int index = entry.key;

                int backgroundIndex = 0;

                if (index % 4 == 0) {
                  backgroundIndex = 0;
                } else if (index % 4 == 1) {
                  backgroundIndex = 1;
                } else if (index % 4 == 2) {
                  backgroundIndex = 2;
                } else if (index % 4 == 3) {
                  backgroundIndex = 3;
                }

                var menuDetail = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: RectangleTileComponent(
                      backgroundImagePath: getBackgroundPath[backgroundIndex],
                      title: menuDetail.menuName ?? "",
                      icon: getMenuIcon(menuDetail),
                      onTap: () {
                        Widget? destinationWidget = navigateToMenuDestination(
                          menuDetail,
                          title: menuDetail.menuName,
                        );

                        if (destinationWidget != null) {
                          navigateToScreen(
                            context,
                            destinationWidget,
                          );
                        }
                      }),
                );
              },
            ) ??
            [],
        const SizedBox(
          height: 66,
        )
      ],
    );
  }

  Widget getBannerWidget() {
    int currentPage = 0;
    double size = getWidthOfScreen(context) - 32;
    return StatefulBuilder(
      builder: (context, setStateful) {
        return Container(
          height: (size / 2) + 20,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage(ImageConstants.homeScreenYellow),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: banner.length,
                  onPageChanged: (index) {
                    setStateful(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = banner[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: (item.attachment?.isNotEmpty ?? false)
                            ? DecorationImage(
                                image: NetworkImage(item.attachment ?? ""),
                                fit: BoxFit.contain,
                                onError: (exception, stackTrace) {
                                  // Handle image loading error
                                },
                              )
                            : const DecorationImage(
                                image:
                                    AssetImage(ImageConstants.homeScreenYellow),
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banner.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget getQuickActionsWidget() {
    bool isTeacher =
        AuthViewModel.instance.getLoggedInUser()?.userType.toUpperCase() ==
            "TEACHER";

    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: (menuDetailMap["2"]?.length ?? 2) == 1 ? 1 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: (menuDetailMap["2"]?.length ?? 2) == 1 ? 2.5 : 1,
          children: menuDetailMap["2"]?.asMap().entries.map(
                (entry) {
                  int index = entry.key;
                  var menuDetail = entry.value;

                  String icon;

                  if (isTeacher) {
                    icon = index % 2 != 0
                        ? IconConstants.studentSearch
                        : IconConstants.attendance;
                  } else {
                    icon = index % 2 != 0
                        ? IconConstants.noticeBoard
                        : IconConstants.homework;
                  }

                  return SquareGridComponent(
                    backgroundImage: index % 2 == 0
                        ? ImageConstants.homeScreenOrangeSquare
                        : ImageConstants.homeScreenPinkSquare,
                    title: menuDetail.menuName ?? "",
                    icon: icon,
                    onTap: () {
                      Widget? destinationWidget = navigateToMenuDestination(
                        menuDetail,
                        title: menuDetail.menuName,
                      );
                      if (destinationWidget != null) {
                        navigateToScreen(context, destinationWidget);
                      }
                    },
                  );
                },
              ).toList() ??
              [],
        ),
      ],
    );
  }
}

List<String> getBackgroundPath = [
  ImageConstants.homeScreenPurple,
  ImageConstants.homeScreenGreen,
  ImageConstants.homeScreenYellow,
  ImageConstants.homeScreenOrange,
];
