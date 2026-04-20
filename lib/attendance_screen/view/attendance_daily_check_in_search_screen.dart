import 'package:flutter/material.dart';
import 'package:school_app/attendance_daily_check_in/view/attendance_daily_check_in_screen.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/utils.dart';

class AttendanceDailyCheckInSearchScreen extends StatefulWidget {
  static const String routeName = '/attendance-daily-check-in-search';
  const AttendanceDailyCheckInSearchScreen({super.key});

  @override
  State<AttendanceDailyCheckInSearchScreen> createState() =>
      _AttendanceDailyCheckInSearchScreenState();
}

class _AttendanceDailyCheckInSearchScreenState
    extends State<AttendanceDailyCheckInSearchScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    loggedInUser = AuthViewModel.instance.getLoggedInUser();
    selectedDate = DateTime.now();
    callGetClassesFuture();
  }

  void callGetClassesFuture() {
    getClassListFuture = SchoolDetailsViewModel.instance
        .getClassList()
        .then((ApiResponse<List<ClassModel>> response) {
      if (response.success) {
        classes = response.data ?? [];
        // If user has classCode, find and set the selected class
        if (loggedInUser?.classCode != null) {
          selectedClass = classes.firstWhere(
            (classModel) => classModel.classCode == loggedInUser?.classCode,
            orElse: () => classes.first,
          );
          // If class is found, get sections
          if (selectedClass != null) {
            callGetSectionsFuture(selectedClass!);
          }
        }
      }
      return response;
    });
  }

  void callGetSectionsFuture(ClassModel value) {
    isLoadingNotifier.value = true;
    setState(() {
      selectedClass = value;
      selectedSection = null;
      getSectionListFuture = SchoolDetailsViewModel.instance
          .getSectionList(value.classCode)
          .then((ApiResponse<List<Section>> response) {
        isLoadingNotifier.value = false;
        if (response.success) {
          sections = response.data ?? [];
          // If user has sectionCode, find and set the selected section
          if (loggedInUser?.sectionCode != null) {
            selectedSection = sections.firstWhere(
              (section) => section.sectionCode == loggedInUser?.sectionCode,
              orElse: () => sections.first,
            );
            setState(() {});
          }
        }
        return response;
      });
    });
  }

  ClassModel? selectedClass;
  Section? selectedSection;
  DateTime? selectedDate;

  List<ClassModel> classes = [];
  List<Section> sections = [];

  Future<void> openDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: "Mark Attendance",
        body: AppFutureBuilder(
          future: getClassListFuture,
          builder: (context, snapshot) {
            if (classes.isEmpty) {
              return const NoDataWidget();
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.8, // 80% of screen height
              width: MediaQuery.of(context).size.width *
                  0.9, // 90% of screen width
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextfield(
                      onTap: () =>
                          openClassBottomSheet(context, classes, (value) {
                        callGetSectionsFuture(value);
                      }),
                      hintText: selectedClass?.className ?? 'Select Class',
                    ),
                    const SizedBox(height: 16),
                    AppTextfield(
                      onTap: () =>
                          openSectionBottomSheet(context, sections, (value) {
                        setState(() {
                          selectedSection = value;
                        });
                      }),
                      hintText:
                          selectedSection?.sectionName ?? 'Select Section',
                    ),
                    const SizedBox(height: 16),
                    AppTextfield(
                      onTap: () => openDatePicker(context),
                      hintText: selectedDate == null
                          ? 'Choose Attendance Date'
                          : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}',
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      onPressed: (_) async {
                        // Handle the search button functionality
                        debugPrint('Selected Class: $selectedClass');
                        debugPrint('Selected Section: $selectedSection');
                        debugPrint('Selected Date: $selectedDate');

                        if (selectedClass == null ||
                            selectedSection == null ||
                            selectedDate == null) {
                          showSnackBarOnScreen(
                              context, "Please select all fields");
                          return;
                        }
                        navigateToScreen(
                            context,
                            AttendanceDailyCheckInScreen(
                                classModel: selectedClass!,
                                section: selectedSection!,
                                date: selectedDate!));
                      },
                      text: 'SEARCH',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
