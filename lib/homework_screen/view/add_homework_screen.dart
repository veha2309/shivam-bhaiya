import 'dart:io';

import 'package:calendar_view/calendar_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_app/document/viewmodel/upload_document_viewmodel.dart';
import 'package:school_app/homework_screen/model/add_homework_model.dart';
import 'package:school_app/homework_screen/model/pendingTest_model.dart';
import 'package:school_app/homework_screen/model/subjectBook_model.dart';
import 'package:school_app/homework_screen/model/subject_model.dart';
import 'package:school_app/homework_screen/model/homework_model.dart';
import 'package:school_app/homework_screen/view_model/add_homework_view_model.dart';
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
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/homework_screen/model/examSchedule_model.dart';
import 'package:school_app/homework_screen/view_model/homework_view_model.dart';

class AddHomeWorkScreen extends StatefulWidget {
  static const String routeName = '/add-homework';
  final String? title;
  const AddHomeWorkScreen({super.key, this.title});

  @override
  State<AddHomeWorkScreen> createState() => _AddHomeWorkScreenState();
}

class _AddHomeWorkScreenState extends State<AddHomeWorkScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();

  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<HomeworkModel>>>? getTeacherHomeworkFuture;
  Future<ApiResponse<ExamScheduleModel>>? getExamSchedule;

  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ClassModel? selectedClass;
  Section? selectedSection;
  SubjectModel? selectedSubject;

  List<ClassModel> classes = [];
  List<Section> sections = [];

  // Homework related variables
  List<HomeworkModel>? currentMonthHomework;
  Map<String, List<HomeworkData>> currentMonthHomeworkMap = {};
  List<HomeworkData>? selectedDayHomeworkItems = [];
  List<PendingtestModel> pendingTestModels = [];
  List<SubjectbookModel> subjectComboModels = [];
  List<SubjectbookModel> selectedDateSubjectModel = [];
  ExamScheduleModel? examSchedule;
  Set<DateTime> underLineDates = {};
  Set<DateTime> testDates = {};
  final Map<String, PlatformFile?> _subjectAttachments = {};
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getClassListFuture = SchoolDetailsViewModel.instance
        .getClassList()
        .then((ApiResponse<List<ClassModel>> response) {
      if (response.success) {
        classes = response.data ?? [];
      }
      return response;
    });
  }

  void clearAllData() {
    currentMonthHomework = null;
    currentMonthHomeworkMap = {};
    selectedDayHomeworkItems = [];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void callGetPendingTestListService() async {
    if (selectedSection?.sectionCode == null) {
      return;
    }
    var response = await AddHomeworkViewModel.instance.getPendingTestList();

    if (response.success) {
      pendingTestModels = response.data ?? [];
      pendingTestModels.removeWhere((pendingtestModel) {
        return pendingtestModel.testStatus?.toUpperCase() == "Y";
      });
      setState(() {});
    }
  }

  void callGetExamScheduleFuture() {
    getExamSchedule = HomeworkViewModel.instance
        .getExamSchedule(selectedSection?.sectionCode ?? "")
        .then((response) {
      if (response.success) {
        examSchedule = response.data;

        try {
          underLineDates = examSchedule?.scheduleByDate?.keys
                  .map((key) => formatAnyDateIntoDateTime(key))
                  .toSet() ??
              {};
          setState(() {});
        } catch (_) {}
      }
      return response;
    });
  }

  void updateData(DateTime selectedMonthData) {
    clearAllData();
    selectedDate.value = selectedMonthData;

    if (selectedClass != null && selectedSection != null) {
      String teacherId =
          AuthViewModel.instance.getLoggedInUser()?.username ?? "";
      getTeacherHomeworkFuture = AddHomeworkViewModel.instance
          .getTeacherHomeworkData(selectedClass!.classCode,
              selectedSection!.sectionCode, selectedMonthData)
          .then((response) {
        if (response.success) {
          currentMonthHomework = response.data;
          currentMonthHomework?.forEach((item) {
            if (currentMonthHomeworkMap[item.homeworkDate] == null) {
              currentMonthHomeworkMap[item.homeworkDate ?? ""] =
                  item.homeworkData ?? [];
            } else {
              currentMonthHomeworkMap[item.homeworkDate]
                  ?.addAll(item.homeworkData ?? []);
            }
          });
          selectedDayHomeworkItems =
              currentMonthHomeworkMap[getDDMMYYYYInNum(selectedDate.value)];

          // Populate homework text for subjects
          selectedDateSubjectModel = getSubjectsToShow();

          currentMonthHomework?.forEach((item) {
            item.homeworkData?.forEach((item) {
              if (item.testDate != null) {
                try {
                  DateTime testDate =
                      formatAnyDateIntoDateTime(item.testDate ?? "");
                  testDates.add(testDate);
                } catch (_) {}
              }
            });
          });

          setState(() {});
        }
        return response;
      });

      callGetPendingTestListService();
      callGetExamScheduleFuture();
    }
  }

  void callGetHomeWorkListFuture() async {
    isLoadingNotifier.value = true;

    // for (String section in selectedSection) {
    ApiResponse response = await AddHomeworkViewModel.instance
        .getSubjectBook(selectedClass!.classCode, selectedSection!.sectionCode);

    if (response.success) {
      subjectComboModels = response.data;

      for (var item in subjectComboModels) {
        item.homeworkText = TextEditingController();
      }
    } else {
      showSnackBarOnScreen(
          context, response.errorMessage ?? "Something went wrong");
      isLoadingNotifier.value = false;
      return;
    }
    // }
    isLoadingNotifier.value = false;
    updateData(selectedDate.value);
    setState(() {});
  }

  String getSectionNameForDropDown() {
    if (selectedSection != null) {
      return selectedSection!.sectionName;
    } else {
      return "Select Section";
    }
  }

  bool checkSelectedDay(DateTime date) {
    return date.day == selectedDate.value.day &&
        date.month == selectedDate.value.month &&
        date.year == selectedDate.value.year;
  }

  bool shouldEnableTextField(SubjectbookModel subject) {
    DateTime date = selectedDate.value;
    DateTime now = DateTime.now();

    DateTime nowDDMMYYY = DateTime(now.year, now.month, now.day);

    if (date.isBefore(nowDDMMYYY)) {
      return false;
    }

    // If date is today
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      // Enable only if time is before 4 PM
      if (subject.homeworkText?.text != null &&
          subject.homeworkText!.text.isNotEmpty &&
          subject.doesHomeworkAlreadyExist &&
          now.hour > 16) {
        return false;
      }
    }

    return true;
  }

  bool isPastDate(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  bool shouldShowHomeworkTable() {
    // For past dates, show if there's homework data
    if (isPastDate(selectedDate.value) &&
        selectedDayHomeworkItems?.isNotEmpty == true) {
      return true;
    }

    DateTime date = selectedDate.value;
    DateTime now = DateTime.now();

    // For today and future dates, show if there are subjects
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day &&
        subjectComboModels.isNotEmpty) {
      return true;
    }

    return false;
  }

  PlatformFile? _getAttachmentForSubject(String subjectCode) {
    return _subjectAttachments[subjectCode];
  }

  bool _hasSubjectUpdated(SubjectbookModel subject) {
    final String subjectCode = subject.subjectCode ?? "";
    HomeworkData? serverData;
    try {
      serverData = selectedDayHomeworkItems?.firstWhere(
        (homework) => homework.subject == subject.subject,
      );
    } catch (_) {}

    final String localHomework = subject.homeworkText?.text.trim() ?? "";
    final String localDue =
        subject.dueDate != null ? getDDMMYYYYInNum(subject.dueDate!) : "";
    final String localTest = subject.testSchedule != null
        ? getDDMMYYYYInNum(subject.testSchedule!)
        : "";

    final PlatformFile? localAttachment = _getAttachmentForSubject(subjectCode);
    final String localDocumentName = subject.documentName ?? "";

    if (serverData == null) {
      return localHomework.isNotEmpty ||
          localDue.isNotEmpty ||
          localTest.isNotEmpty ||
          localAttachment != null ||
          localDocumentName.isNotEmpty;
    }

    final String serverHomework = serverData.homework?.trim() ?? "";
    final String serverDue = serverData.dueDate?.trim() ?? "";
    final String serverTest = serverData.testDate?.trim() ?? "";
    final String serverDocument = serverData.documentName ?? "";

    final bool homeworkChanged = localHomework != serverHomework;
    final bool dueChanged = localDue != serverDue;
    final bool testChanged = localTest != serverTest;
    final bool attachmentDeleted = serverData.isDeleted;
    final bool attachmentAddedOrReplaced = localAttachment != null;
    final bool attachmentNameChanged =
        localDocumentName.isNotEmpty && localDocumentName != serverDocument;
    final bool attachmentRemoved =
        serverDocument.isNotEmpty && localDocumentName.isEmpty;

    return homeworkChanged ||
        dueChanged ||
        testChanged ||
        attachmentDeleted ||
        attachmentAddedOrReplaced ||
        attachmentNameChanged ||
        attachmentRemoved;
  }

  void _markServerFileDeleted(String subjectName) {
    if (subjectName.isEmpty || selectedDayHomeworkItems == null) {
      return;
    }

    final int localIndex = selectedDayHomeworkItems!
        .indexWhere((item) => item.subject == subjectName);
    if (localIndex == -1) {
      return;
    }

    final HomeworkData existing = selectedDayHomeworkItems![localIndex];
    if (existing.isDeleted) {
      return;
    }

    final HomeworkData updated = HomeworkData(
      homework: existing.homework,
      subject: existing.subject,
      dueDate: existing.dueDate,
      testDate: existing.testDate,
      checkStatus: existing.checkStatus,
      checkDate: existing.checkDate,
      book: existing.book,
      notebook: existing.notebook,
      documentName: existing.documentName,
      fileName: existing.fileName,
      isDeleted: true,
    );

    selectedDayHomeworkItems![localIndex] = updated;

    final String dateKey = getDDMMYYYYInNum(selectedDate.value);
    final List<HomeworkData>? mappedList = currentMonthHomeworkMap[dateKey];
    if (mappedList != null) {
      final int mappedIndex =
          mappedList.indexWhere((item) => item.subject == subjectName);
      if (mappedIndex != -1) {
        mappedList[mappedIndex] = updated;
      }
    }
  }

  Future<void> _pickAttachmentForSubject(SubjectbookModel subject) async {
    final key = subject.subjectCode ?? "";
    if (key.isEmpty) {
      showSnackBarOnScreen(context, "Unable to attach file for this subject");
      return;
    }

    final selection = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () => Navigator.pop(context, "gallery"),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () => Navigator.pop(context, "camera"),
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Files"),
                onTap: () => Navigator.pop(context, "files"),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selection == null) {
      return;
    }

    if (selection == "files") {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (!mounted || result == null || result.files.isEmpty) {
        return;
      }

      setState(() {
        _subjectAttachments[key] = result.files.first;
      });
      return;
    }

    final imageSource =
        selection == "camera" ? ImageSource.camera : ImageSource.gallery;
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: imageSource,
    );

    if (!mounted || pickedImage == null) {
      return;
    }

    final platformFile = PlatformFile(
      name: pickedImage.name,
      path: pickedImage.path,
      size: await pickedImage.length(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _subjectAttachments[key] = platformFile;
    });
  }

  Future<bool> _uploadSubjectAttachments(
      List<AddHomeworkModel> subjectsWithHomework) async {
    Future<bool> uploadAttachment({
      required PlatformFile file,
      required AddHomeworkModel subjectModel,
    }) async {
      if (file.path == null || file.path!.isEmpty) {
        showSnackBarOnScreen(context, "Attachment is missing a valid path");
        return false;
      }

      final presignResponse =
          await AddHomeworkViewModel.instance.getPresignUrlForHomeworkDocument(
        subjectModel.subjectcode ?? "",
        file.name,
      );

      if (!presignResponse.success || presignResponse.data == null) {
        showSnackBarOnScreen(
          context,
          presignResponse.errorMessage ?? "Failed to get upload URL",
        );
        return false;
      }

      final uploadResponse =
          await UploadDocumentViewModel.instance.uploadDocument(
        File(file.path!),
        endpoint: presignResponse.data?.presignUrl ?? "",
        classCode: selectedClass?.classCode ?? "",
        sectionCode: selectedSection?.sectionCode ?? "",
        documentType: "",
        remark: "",
      );

      if (!uploadResponse.success) {
        showSnackBarOnScreen(
          context,
          uploadResponse.errorMessage ?? "Failed to upload document",
        );
        return false;
      }

      subjectModel.fileName = presignResponse.data?.fileName ?? "";
      subjectModel.documentName = presignResponse.data?.fileName ?? "";
      return true;
    }

    for (final subject in subjectsWithHomework) {
      final String subjectCode = subject.subjectcode ?? "";
      if (subjectCode.isEmpty) {
        showSnackBarOnScreen(context, "Missing subject code for attachment");
        return false;
      }

      final PlatformFile? attachment = _getAttachmentForSubject(subjectCode);

      HomeworkData? serverData;
      try {
        serverData = selectedDayHomeworkItems?.firstWhere((homework) {
          return homework.subject == subject.subjectName;
        });
      } catch (_) {}

      final bool serverHasFile = serverData?.fileName?.isNotEmpty == true;
      final bool serverHasDoc = serverData?.documentName?.isNotEmpty == true;
      final bool serverHasAny = serverHasFile || serverHasDoc;
      final bool serverMarkedDeleted = serverData?.isDeleted ?? false;

      final bool localHasFile = attachment != null;
      final bool localHasDoc = (subject.documentName?.isNotEmpty ?? false) ||
          (subject.fileName?.isNotEmpty ?? false);
      final bool localHasData = localHasFile || localHasDoc;

      // Case 2: Server has data & not deleted -> reuse server copy, skip upload
      if (serverHasAny && !serverMarkedDeleted) {
        subject.fileName = serverData?.fileName;
        subject.documentName = serverData?.documentName;
        continue;
      }

      // Case 3: Server has data & user deleted it -> delete then conditionally upload
      if (serverHasAny && serverMarkedDeleted) {
        if (serverData?.documentName?.isNotEmpty == true) {
          final deleteResponse =
              await UploadDocumentViewModel.instance.deleteDocument(
            serverData!.documentName!,
          );

          if (!deleteResponse.success) {
            showSnackBarOnScreen(
              context,
              deleteResponse.errorMessage ?? "Failed to delete old document",
            );
            return false;
          }
        }

        if (!localHasData) {
          subject.fileName = null;
          subject.documentName = null;
          continue;
        }

        if (!localHasFile) {
          showSnackBarOnScreen(context, "No attachment selected to upload");
          return false;
        }

        final bool didUpload = await uploadAttachment(
          file: attachment,
          subjectModel: subject,
        );
        if (!didUpload) {
          return false;
        }
        continue;
      }

      // Case 1: First-time upload -> upload new attachment, no delete
      if (!serverHasAny && localHasData) {
        if (!localHasFile) {
          showSnackBarOnScreen(context, "No attachment selected to upload");
          return false;
        }

        final bool didUpload = await uploadAttachment(
          file: attachment,
          subjectModel: subject,
        );
        if (!didUpload) {
          return false;
        }
        continue;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        body: AppBody(
          title: widget.title ?? "Add Homework",
          body: addHomeWorkBody(context),
        ),
      ),
    );
  }

  List<HomeworkData> getTodayDueHomeworks(DateTime selectedDate) {
    final todayStr = getDDMMYYYYInNum(selectedDate);
    final List<HomeworkData> todayDueHomeworks = [];

    if (currentMonthHomework != null) {
      for (final HomeworkModel model in currentMonthHomework!) {
        if (model.homeworkData != null) {
          for (final HomeworkData data in model.homeworkData!) {
            if (data.dueDate == todayStr &&
                !selectedDate.isBefore(DateTime.now())) {
              todayDueHomeworks.add(data);
            }
          }
        }
      }
    }
    return todayDueHomeworks;
  }

  Widget addHomeWorkBody(BuildContext context) {
    return AppFutureBuilder(
      future: getClassListFuture,
      builder: (context, snapshot) {
        if (classes.isEmpty) {
          return const NoDataWidget();
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 16,
                children: [
                  AppTextfield(
                    onTap: () =>
                        openClassBottomSheet(context, classes, (value) {
                      isLoadingNotifier.value = true;
                      setState(() {
                        selectedClass = value;
                        selectedSubject = null;
                        subjectComboModels.clear();
                        getSectionListFuture = SchoolDetailsViewModel.instance
                            .getSectionList(value.classCode)
                            .then((ApiResponse<List<Section>> response) {
                          isLoadingNotifier.value = false;
                          if (response.success) {
                            sections = response.data ?? [];
                          }
                          return response;
                        });
                      });
                    }),
                    enabled: false,
                    hintText: selectedClass?.className ?? 'Select Class',
                  ),
                  AppTextfield(
                    onTap: () =>
                        openSectionBottomSheet(context, sections, (section) {
                      selectedSection = section;
                      callGetHomeWorkListFuture();
                    }),
                    enabled: false,
                    hintText: selectedSection != null
                        ? getSectionNameForDropDown()
                        : 'Select Section',
                  ),
                  if (selectedClass != null && selectedSection != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        height: 350,
                        child: ValueListenableBuilder(
                          valueListenable: selectedDate,
                          builder: (context, _, __) {
                            return MonthView(
                              key: monthViewKey,
                              onPageChange: (date, page) {
                                if (date.isAfter(DateTime.now())) {
                                  return; // Prevent navigation to future dates
                                }
                                updateData(date.copyWith(day: 01));
                              },
                              useAvailableVerticalSpace: true,
                              hideDaysNotInMonth: true,
                              showBorder: false,
                              cellBuilder: (date, event, isToday, isInMonth,
                                  hideDaysNotInMonth) {
                                bool isSelected = checkSelectedDay(date);

                                bool isUnderline = underLineDates
                                    .any((d) => _isSameDay(d, date));

                                bool haveCheckDateAndStatus = false;
                                bool haveUncheckedTest = false;

                                List<HomeworkData> todayDueTest =
                                    getTodayDueTest(date);

                                for (HomeworkData homework
                                    in todayDueTest ?? []) {
                                  if (homework.checkDate != null ||
                                      homework.checkStatus?.toLowerCase() ==
                                          'y') {
                                    haveCheckDateAndStatus = true;
                                  } else {
                                    haveUncheckedTest = true;
                                  }
                                }

                                List<HomeworkData> todayDueHomeWork =
                                    getTodayDueHomeworks(date);

                                bool isPastDate = date.isBefore(DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day));

                                bool haveHomeWorkToday =
                                    currentMonthHomeworkMap[
                                            getDDMMYYYYInNum(date)] !=
                                        null;

                                bool isFutureDate =
                                    date.isAfter(DateTime.now());

                                return Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        padding: isSelected
                                            ? const EdgeInsets.all(8)
                                            : EdgeInsets.zero,
                                        decoration: BoxDecoration(
                                          shape: isSelected
                                              ? BoxShape.circle
                                              : BoxShape.rectangle,
                                          color: isSelected
                                              ? ColorConstant.primaryColor
                                              : null,
                                          border: isUnderline
                                              ? const Border(
                                                  bottom: BorderSide(
                                                    color: Colors.black,
                                                    width: 2,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Text(
                                          date.day.toString(),
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : isInMonth
                                                    ? isFutureDate
                                                        ? Colors.grey
                                                        : ColorConstant
                                                            .primaryTextColor
                                                    : ColorConstant
                                                        .secondaryTextColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (haveHomeWorkToday)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 5, right: 5),
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isPastDate
                                                ? Colors.grey
                                                : ColorConstant.primaryColor,
                                          ),
                                        ),
                                      ),
                                    if (haveCheckDateAndStatus)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 13, right: 10),
                                          height: 8,
                                          width: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    if (haveUncheckedTest)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 21, right: 10),
                                          height: 8,
                                          width: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: ColorConstant.errorColor,
                                          ),
                                        ),
                                      ),
                                    if (todayDueHomeWork.isNotEmpty)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 29, right: 10),
                                          height: 8,
                                          width: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                              headerBuilder: (date) {
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${monthIntToString(date.month)} ${date.year}",
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: ColorConstant.secondaryTextColor,
                                      thickness: 0.3,
                                    ),
                                  ],
                                );
                              },
                              weekDayBuilder: (day) {
                                return Container(
                                  decoration: const BoxDecoration(),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      intToWeekDay(day),
                                      textScaler: const TextScaler.linear(1.0),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: ColorConstant.secondaryTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              borderColor: ColorConstant.primaryColor,
                              onCellTap: (events, date) {
                                if (date.isAfter(DateTime.now())) {
                                  return; // Prevent selection of future dates
                                }
                                selectedDate.value = date;
                                selectedDayHomeworkItems =
                                    currentMonthHomeworkMap[
                                        getDDMMYYYYInNum(date)];
                                // Populate homework text for subjects

                                selectedDateSubjectModel = getSubjectsToShow();

                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  if (selectedClass != null && selectedSection != null)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, bottom: 10.0, left: 16.0, right: 16.0),
                      child: Column(
                        spacing: 6,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorConstant.primaryColor, // Blue
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('– Homework assigned today',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorConstant.errorColor, // Red
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('– Test scheduled',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 2,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('– Formal exam scheduled',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (pendingTestModels.isNotEmpty)
                    DataTableWidget(
                      headingRowHeight: 35,
                      headers: [
                        TableColumnConfiguration(
                          text: 'Class/Section',
                          width: 80,
                        ),
                        TableColumnConfiguration(
                          text: 'Subject',
                          width: 120,
                        ),
                        TableColumnConfiguration(
                          text: 'Test Date',
                          width: 100,
                        ),
                        TableColumnConfiguration(
                          text: 'Select',
                          width: 80,
                        ),
                      ],
                      data: pendingTestModels.asMap().entries.map((entry) {
                        final index = entry.key;
                        final test = entry.value;
                        return TableRowConfiguration(
                          rowHeight: 35,
                          cells: [
                            TableCellConfiguration(
                              text: test.className,
                              width: 80,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: ColorConstant.secondaryTextColor,
                                fontFamily: fontFamily,
                              ),
                            ),
                            TableCellConfiguration(
                              text: test.subjectName,
                              width: 120,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: ColorConstant.secondaryTextColor,
                                fontFamily: fontFamily,
                              ),
                            ),
                            TableCellConfiguration(
                              text: test.testDate,
                              width: 100,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: ColorConstant.secondaryTextColor,
                                fontFamily: fontFamily,
                              ),
                            ),
                            TableCellConfiguration(
                              width: 80,
                              child: Checkbox(
                                value: test.isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    test.isSelected = !test.isSelected;
                                  });
                                },
                                activeColor: ColorConstant.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  if (shouldShowHomeworkTable())
                    ...selectedDateSubjectModel.map((subject) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          TableWidget(
                            showBorder: true,
                            rows: [
                              TableRowConfiguration(
                                onTap: (_) async {
                                  if (!ifTeacherTeachSubjectWithCode(
                                      subject.subjectCode ?? "")) {
                                    return;
                                  }
                                  DateTime today = DateTime.now();
                                  DateTime lastDate = DateTime(today.year + 1);
                                  DateTime firstDate = today;
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        subject.dueDate ?? DateTime.now(),
                                    firstDate: firstDate,
                                    lastDate: lastDate,
                                  );
                                  if (selectedDate != null) {
                                    setState(() {
                                      subject.dueDate = selectedDate;
                                    });
                                  }
                                },
                                rowHeight: 35,
                                cells: [
                                  TableCellConfiguration(
                                    child: Row(
                                      spacing: 5,
                                      children: [
                                        const Icon(
                                          Icons.menu_book,
                                          color: ColorConstant.primaryColor,
                                        ),
                                        Text(
                                          subject.subject ?? "",
                                          style: const TextStyle(
                                            fontFamily: fontFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: ColorConstant.primaryColor,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          spacing: 4,
                                          children: [
                                            Text(
                                              subject.dueDate != null
                                                  ? getDDMMYYYYInNum(
                                                      subject.dueDate!)
                                                  : "Select Due Date",
                                              textScaler:
                                                  const TextScaler.linear(1.0),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: fontFamily,
                                                color:
                                                    ColorConstant.inactiveColor,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.calendar_month,
                                              color: ColorConstant.primaryColor,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                ],
                              ),
                              TableRowConfiguration(
                                cells: [
                                  TableCellConfiguration(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: TextFormField(
                                        enabled: ifTeacherTeachSubjectWithCode(
                                                subject.subjectCode ?? "") &&
                                            shouldEnableTextField(subject),
                                        controller: subject.homeworkText,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Enter homework"),
                                        style: const TextStyle(
                                          fontFamily: fontFamily,
                                          fontSize: 12,
                                        ),
                                        maxLines: null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRowConfiguration(
                                onTap: null,
                                rowHeight: 35,
                                cells: [
                                  TableCellConfiguration(
                                    child: Row(
                                      spacing: 5,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            if (!ifTeacherTeachSubjectWithCode(
                                                subject.subjectCode ?? "")) {
                                              return;
                                            }
                                            DateTime today = DateTime.now();
                                            DateTime lastDate =
                                                DateTime(today.year + 1);
                                            DateTime firstDate = today;

                                            showCustomCalendarPopup(
                                                context: context,
                                                underlineDates: {},
                                                dotDates: {},
                                                onDateSelected: (date) {
                                                  setState(() {
                                                    subject.testSchedule = date;
                                                  });
                                                });
                                            // DateTime? selectedDate =
                                            //     await showDatePicker(
                                            //   context: context,
                                            //   initialDate: subject.dueDate ??
                                            //       DateTime.now(),
                                            //   firstDate: firstDate,
                                            //   lastDate: lastDate,
                                            // );
                                            // if (selectedDate != null) {
                                            //   setState(() {
                                            //     subject.testSchedule =
                                            //         selectedDate;
                                            //   });
                                            // }
                                          },
                                          child: Text(
                                            subject.testSchedule != null
                                                ? getDDMMYYYYInNum(
                                                    subject.testSchedule!)
                                                : "Schedule Test",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    ColorConstant.primaryColor,
                                                color:
                                                    ColorConstant.primaryColor),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (!ifTeacherTeachSubjectWithCode(
                                                subject.subjectCode ?? "")) {
                                              return;
                                            }

                                            onSelectBooksTap(
                                                subject.subjectCode ?? "");
                                          },
                                          child: const Text(
                                            "Select Books/Notebooks",
                                            style: TextStyle(
                                                fontSize: 12,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    ColorConstant.primaryColor,
                                                color:
                                                    ColorConstant.primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                ],
                              ),
                              TableRowConfiguration(
                                onTap: null,
                                rowHeight: 35,
                                cells: [
                                  TableCellConfiguration(
                                    child: Row(
                                      spacing: 5,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Builder(builder: (context) {
                                            final attachment =
                                                _getAttachmentForSubject(
                                                    subject.subjectCode ?? "");

                                            final documentName =
                                                subject.documentName;

                                            final String message;
                                            if (attachment?.name != null &&
                                                attachment!.name.isNotEmpty) {
                                              message = attachment.name;
                                            } else if (documentName != null &&
                                                documentName.isNotEmpty) {
                                              message = documentName;
                                            } else {
                                              message = "Upload document +";
                                            }

                                            return Row(
                                              spacing: 6,
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if ((attachment ==
                                                              null) &&
                                                          (documentName ==
                                                                  null ||
                                                              documentName
                                                                  .isEmpty)) {
                                                        _pickAttachmentForSubject(
                                                            subject);
                                                      } else {
                                                        if (attachment !=
                                                                null &&
                                                            attachment.path !=
                                                                null) {
                                                          final ext = attachment
                                                              .name
                                                              .split('.')
                                                              .last
                                                              .toLowerCase();
                                                          const imageExtensions =
                                                              {
                                                            'png',
                                                            'jpg',
                                                            'jpeg',
                                                            'gif',
                                                            'bmp',
                                                            'wbmp',
                                                            'webp',
                                                            'heic',
                                                            'heif',
                                                          };
                                                          final isImage =
                                                              imageExtensions
                                                                  .contains(
                                                                      ext);

                                                          if (isImage) {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return Dialog(
                                                                  child:
                                                                      InteractiveViewer(
                                                                    child: Image
                                                                        .file(
                                                                      File(attachment
                                                                          .path!),
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          }
                                                        } else if (documentName !=
                                                                null &&
                                                            documentName
                                                                .isNotEmpty) {
                                                          final response =
                                                              await UploadDocumentViewModel
                                                                  .instance
                                                                  .viewUploadedHomework(
                                                            fileName:
                                                                documentName,
                                                          );
                                                          if (response
                                                              .success) {
                                                            launchURLString(
                                                                response.data ??
                                                                    "");
                                                          }
                                                        }
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (attachment != null &&
                                                            attachment.path != null)
                                                          Builder(builder: (context) {
                                                            final ext = attachment.name
                                                                .split('.')
                                                                .last
                                                                .toLowerCase();
                                                            const imageExtensions = {
                                                              'png', 'jpg', 'jpeg', 'gif', 'bmp', 'wbmp', 'webp', 'heic', 'heif',
                                                            };
                                                            if (imageExtensions.contains(ext)) {
                                                              return Padding(
                                                                padding: const EdgeInsets.only(right: 4.0),
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(4),
                                                                  child: Image.file(
                                                                    File(attachment.path!),
                                                                    height: 24,
                                                                    width: 24,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return const SizedBox.shrink();
                                                          }),
                                                        Flexible(
                                                          child: Text(
                                                            message,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                decoration: TextDecoration.underline,
                                                                decorationColor: ColorConstant.primaryColor,
                                                                color: ColorConstant.primaryColor),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (attachment != null ||
                                                    (documentName != null &&
                                                        documentName
                                                            .isNotEmpty))
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (attachment !=
                                                            null) {
                                                          _subjectAttachments
                                                              .remove(subject
                                                                      .subjectCode ??
                                                                  "");
                                                        } else if (documentName !=
                                                                null &&
                                                            documentName
                                                                .isNotEmpty) {
                                                          _markServerFileDeleted(
                                                              subject.subject ??
                                                                  "");
                                                          subject.documentName =
                                                              null;
                                                          subject.fileName =
                                                              null;
                                                        }
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.delete,
                                                      size: 14,
                                                      color: ColorConstant
                                                          .primaryColor,
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }),
                                        )
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    })
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "No homework found",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: fontFamily,
                          color: ColorConstant.secondaryTextColor,
                        ),
                      ),
                    ),
                  if (shouldShowHomeworkTable())
                    AppButton(
                      text: "Submit",
                      onPressed: (_) async {
                        String? sessionCode =
                            AuthViewModel.instance.homeModel?.sessionCode;

                        List<PendingtestModel> testToBeUpdated = [];

                        for (var test in pendingTestModels) {
                          if (test.isSelected) {
                            testToBeUpdated.add(test);
                          }
                        }

                        bool validationPass = true;

                        List<SubjectbookModel> subjectsWithHomework =
                            selectedDateSubjectModel.where((subject) {
                          if (subject.homeworkText != null &&
                              subject.homeworkText!.text.isNotEmpty) {
                            return true;
                          } else if ((subject.selectedBooks?.isNotEmpty ??
                                  false) ||
                              (subject.selectedNotebooks?.isNotEmpty ??
                                  false)) {
                            return true;
                          } else if (_getAttachmentForSubject(
                                  subject.subjectCode ?? "") !=
                              null) {
                            return true;
                          } else if (subject.documentName != null &&
                              subject.documentName!.isNotEmpty) {
                            return true;
                          }
                          return false;
                        }).toList();

                        if (subjectsWithHomework.isEmpty) {
                          showSnackBarOnScreen(
                              context, "Please add homework first");
                          return;
                        }

                        final bool hasAnythingUpdated =
                            subjectsWithHomework.any(_hasSubjectUpdated);

                        if (!hasAnythingUpdated) {
                          showSnackBarOnScreen(context, "No changes to submit");
                          return;
                        }

                        List<AddHomeworkModel>? addHomeworkModels =
                            subjectsWithHomework.map((item) {
                          String? sessionCode =
                              AuthViewModel.instance.homeModel?.sessionCode;
                          AddHomeworkModel addHomeworkModel = AddHomeworkModel(
                            homework: item.homeworkText?.text,
                            classcode: selectedClass?.classCode,
                            sectioncode: selectedSection?.sectionCode,
                            sessioncode: sessionCode,
                            subjectcode: item.subjectCode,
                            subjectName: item.subject,
                            testdate: item.testSchedule != null
                                ? getDDMMYYYYInNum(item.testSchedule!)
                                : null,
                            noteBook: item.selectedNotebooks
                                ?.map((nb) => nb.notebookid)
                                .join(','),
                            book: item.selectedBooks
                                ?.map((b) => b.bookid)
                                .join(','),
                            status: item.doesHomeworkAlreadyExist
                                ? "UPDATE"
                                : "ADD",
                            homeworkdate: getDDMMYYYYInNum(selectedDate.value),
                            duedate: item.dueDate != null
                                ? getDDMMYYYYInNum(item.dueDate!)
                                : null,
                          );

                          return addHomeworkModel;
                        }).toList();

                        if (pendingTestModels.isNotEmpty &&
                            addHomeworkModels.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "Please ensure that the homework is thoroughly checked for grammatical and spelling errors prior to submission.",
                                textScaler: TextScaler.linear(1.0),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      textScaler: TextScaler.linear(1.0),
                                    )),
                                TextButton(
                                  onPressed: () async {
                                    final uploadOk =
                                        await _uploadSubjectAttachments(
                                            addHomeworkModels);
                                    if (!uploadOk) {
                                      return;
                                    }

                                    await AddHomeworkViewModel.instance
                                        .saveHomeWork(addHomeworkModels);

                                    if (testToBeUpdated.isNotEmpty) {
                                      for (var test in testToBeUpdated) {
                                        await AddHomeworkViewModel.instance
                                            .updateTestCheckStatus(
                                                sessionCode ?? "",
                                                test.sectionCode ?? "",
                                                test.subjectCode ?? "",
                                                test.homeworkDate ?? "");
                                      }
                                    }

                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Confirm",
                                    textScaler: TextScaler.linear(1.0),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (addHomeworkModels.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "Please ensure that the homework is thoroughly checked for grammatical and spelling errors prior to submission.",
                                textScaler: TextScaler.linear(1.0),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      textScaler: TextScaler.linear(1.0),
                                    )),
                                TextButton(
                                  onPressed: () async {
                                    final uploadOk =
                                        await _uploadSubjectAttachments(
                                            addHomeworkModels);
                                    if (!uploadOk) {
                                      return;
                                    }

                                    await AddHomeworkViewModel.instance
                                        .saveHomeWork(addHomeworkModels);

                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Confirm",
                                    textScaler: TextScaler.linear(1.0),
                                  ),
                                ),
                              ],
                            ),
                          );
                          return;
                        } else {
                          if (testToBeUpdated.isNotEmpty) {
                            for (var test in testToBeUpdated) {
                              await AddHomeworkViewModel.instance
                                  .updateTestCheckStatus(
                                      sessionCode ?? "",
                                      test.sectionCode ?? "",
                                      test.subjectCode ?? "",
                                      test.homeworkDate ?? "");
                            }
                          }
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  // Legend for calendar symbols
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void onSelectBooksTap(String subjectCode) {
    SubjectbookModel subject;
    try {
      subject = selectedDateSubjectModel
          .firstWhere((item) => item.subjectCode == subjectCode);
    } catch (_) {
      return;
    }
    // Find the subject's books from subjectComboModels
    final subjectBooks = subject.books;
    final subjectNoteBooks = subject.noteBooks;
    // Create temporary lists to track selected items
    List<Book> tempSelectedBooks = List.from(subject.selectedBooks ?? []);
    List<Notebook> tempSelectedNotebooks =
        List.from(subject.selectedNotebooks ?? []);

    if (tempSelectedBooks.isEmpty && tempSelectedNotebooks.isEmpty) {
      // Add all books with isdefault == 'Y' to tempSelectedBooks
      tempSelectedBooks.addAll(
        subjectBooks?.where(
              (book) =>
                  book.isdefault == 'Y' && !tempSelectedBooks.contains(book),
            ) ??
            [],
      );

      tempSelectedNotebooks.addAll(
        subjectNoteBooks?.where(
              (notebook) =>
                  notebook.isdefault == 'Y' &&
                  !tempSelectedNotebooks.contains(notebook),
            ) ??
            [],
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Books & Notebooks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConstant.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Books Section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Books',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (subjectNoteBooks?.isEmpty ?? true)
                        const Text('No books available for this subject'),
                      ...subjectBooks?.map((book) {
                            return Row(
                              children: [
                                Checkbox(
                                  value: tempSelectedBooks.contains(book),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        tempSelectedBooks.add(book);
                                      } else {
                                        tempSelectedBooks.remove(book);
                                      }
                                    });
                                  },
                                  activeColor: ColorConstant.primaryColor,
                                ),
                                const Icon(
                                  Icons.menu_book,
                                  size: 16,
                                  color: ColorConstant.primaryColor,
                                ),
                                Text(
                                  book.bookname ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          }) ??
                          [],
                      const SizedBox(height: 16),
                      // Notebooks Section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Notebooks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (subjectNoteBooks?.isEmpty ?? true)
                        const Text('No notebooks available for this subject'),
                      ...subjectNoteBooks?.map((notebook) {
                            return Row(
                              children: [
                                Checkbox(
                                  value:
                                      tempSelectedNotebooks.contains(notebook),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        tempSelectedNotebooks.add(notebook);
                                      } else {
                                        tempSelectedNotebooks.remove(notebook);
                                      }
                                    });
                                  }, // Disable if no book is selected
                                  activeColor: ColorConstant.primaryColor,
                                ),
                                const Icon(
                                  Icons.book,
                                  size: 16,
                                  color: ColorConstant.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  notebook.notebookname ?? "",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            );
                          }) ??
                          [],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          int index = selectedDateSubjectModel.indexWhere(
                              (item) => item.subjectCode == subjectCode);

                          if (index != -1) {
                            selectedDateSubjectModel[index].selectedBooks =
                                tempSelectedBooks;
                            selectedDateSubjectModel[index].selectedNotebooks =
                                tempSelectedNotebooks;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool ifHomeWorkForSelectedDateExists() {
    DateTime selected = selectedDate.value;
    String selectedDateStringFormatted = getDDMMYYYYInNum(selected);

    if (currentMonthHomeworkMap[selectedDateStringFormatted] != null &&
        currentMonthHomeworkMap[selectedDateStringFormatted]!.isNotEmpty) {
      return true;
    }

    return false;
  }

  bool ifTeacherTeachSubjectWithCode(String subjectCode) {
    for (var subject in subjectComboModels) {
      if (subject.subjectCode == subjectCode) {
        return true;
      }
    }
    return false;
  }

  List<SubjectbookModel> getSubjectsToShow() {
    DateTime selected = selectedDate.value;
    String selectedDateStringFormatted = getDDMMYYYYInNum(selected);
    List<SubjectbookModel> subjectsToShow = [];

    // If homework exists for selected date
    if (ifHomeWorkForSelectedDateExists()) {
      // Get homework data for selected date
      List<HomeworkData>? homeworkData =
          currentMonthHomeworkMap[selectedDateStringFormatted];

      if (homeworkData != null) {
        // Create SubjectbookModel for each homework entry
        for (var homework in homeworkData) {
          // Check if this subject is already in the list
          bool subjectExists = subjectsToShow
              .any((subject) => subject.subject == homework.subject);

          if (!subjectExists) {
            // Find the subject in subjectComboModels to get books and other details
            SubjectbookModel? originalSubject = subjectComboModels.firstWhere(
              (subject) => subject.subject == homework.subject,
              orElse: () => SubjectbookModel(
                subject: homework.subject ?? '',
                subjectCode: homework.subject ?? '',
                books: [],
                noteBooks: [],
                fileName: homework.fileName,
                documentName: homework.documentName,
              ),
            );

            originalSubject.fileName = homework.fileName;
            originalSubject.documentName = homework.documentName;

            // Parse book and notebook IDs from homework data
            List<Book> selectedBooks = [];
            List<Notebook> selectedNotebooks = [];

            // Parse book IDs
            if (homework.book != null && homework.book!.isNotEmpty) {
              List<String> bookIds = homework.book!.split(',');
              for (String bookId in bookIds) {
                try {
                  int id = int.parse(bookId.trim());
                  Book? foundBook = originalSubject.books?.firstWhere(
                    (book) => book.bookid == id,
                  );
                  if (foundBook?.bookname?.isNotEmpty ?? false) {
                    selectedBooks.add(foundBook!);
                  }
                } catch (e) {
                  print('Error parsing book ID: $bookId');
                }
              }
            }

            // Parse notebook IDs
            if (homework.notebook != null && homework.notebook!.isNotEmpty) {
              List<String> notebookIds = homework.notebook!.split(',');

              // Search through all books to find the notebook
              for (String notebookId in notebookIds) {
                try {
                  int id = int.parse(notebookId.trim());
                  Notebook? foundNotebook = originalSubject.noteBooks
                      ?.firstWhere((notebook) => notebook.notebookid == id);
                  if (foundNotebook?.notebookname?.isNotEmpty ?? false) {
                    selectedNotebooks.add(foundNotebook!);
                  }
                } catch (_) {}
              }
            }

            // Create new SubjectbookModel with homework data
            SubjectbookModel subjectModel = SubjectbookModel(
              subject: originalSubject.subject,
              subjectCode: originalSubject.subjectCode,
              books: originalSubject.books,
              noteBooks: originalSubject.noteBooks,
              selectedBooks: selectedBooks,
              selectedNotebooks: selectedNotebooks,
              documentName: originalSubject.documentName,
              fileName: originalSubject.fileName,
              homeworkText: TextEditingController(text: homework.homework),
              testSchedule: homework.testDate != null
                  ? parseDDMMYYYY(homework.testDate!)
                  : null,
              dueDate: homework.dueDate != null
                  ? parseDDMMYYYY(homework.dueDate!)
                  : null,
              doesHomeworkAlreadyExist:
                  true, // Set to true for models from homework data
            );

            subjectsToShow.add(subjectModel);
          }
        }

        // Add any remaining subjects from subjectComboModels that weren't in homework
        for (var subject in subjectComboModels) {
          bool subjectExists =
              subjectsToShow.any((s) => s.subject == subject.subject);
          if (!subjectExists) {
            subjectsToShow.add(SubjectbookModel(
              subject: subject.subject,
              subjectCode: subject.subjectCode,
              books: subject.books,
              noteBooks: subject.noteBooks,
              homeworkText: TextEditingController(),
              doesHomeworkAlreadyExist:
                  false, // Set to false for models from subjectComboModels
            ));
          }
        }
      }
    } else {
      // If no homework exists, create list from subjectComboModels
      subjectsToShow = subjectComboModels.map((subject) {
        return SubjectbookModel(
          subject: subject.subject,
          subjectCode: subject.subjectCode,
          books: subject.books,
          noteBooks: subject.noteBooks,
          homeworkText: TextEditingController(),
          fileName: subject.fileName,
          documentName: subject.documentName,
          doesHomeworkAlreadyExist:
              false, // Set to false for models from subjectComboModels
        );
      }).toList();
    }

    return subjectsToShow;
  }

  // Helper method to parse date string to DateTime
  DateTime? parseDDMMYYYY(String dateStr) {
    try {
      List<String> parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  List<HomeworkData> getTodayDueTest(DateTime selectedDate) {
    final todayStr = getDDMMYYYYInNum(selectedDate);
    final List<HomeworkData> todayDueHomeworks = [];

    if (currentMonthHomework != null) {
      for (final HomeworkModel model in currentMonthHomework!) {
        if (model.homeworkData != null) {
          for (final HomeworkData data in model.homeworkData!) {
            if (data.testDate == todayStr) {
              todayDueHomeworks.add(data);
            }
          }
        }
      }
    }
    return todayDueHomeworks;
  }
}

class CalendarDateWidget extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime initialFocusedDay;
  final Set<DateTime> underlineDates;
  final Set<DateTime> dotDates;
  final void Function(DateTime selectedDate) onDateSelected;
  final DateTime? selectedDate;

  const CalendarDateWidget({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.initialFocusedDay,
    required this.underlineDates,
    required this.dotDates,
    required this.onDateSelected,
    this.selectedDate,
  });

  @override
  State<CalendarDateWidget> createState() => _CalendarDateWidgetState();
}

class _CalendarDateWidgetState extends State<CalendarDateWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay;
    _selectedDay = widget.selectedDate ?? _focusedDay;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        height: 400,
        width: 350,
        child: MonthView(
          key: monthViewKey,
          minMonth: DateTime(widget.firstDay.year, widget.firstDay.month),
          initialMonth: DateTime(_focusedDay.year, _focusedDay.month),
          useAvailableVerticalSpace: true,
          hideDaysNotInMonth: true,
          showBorder: false,
          cellBuilder: (date, event, isToday, isInMonth, hideDaysNotInMonth) {
            bool isSelected =
                _selectedDay != null && _isSameDay(date, _selectedDay!);
            bool isUnderline =
                widget.underlineDates.any((d) => _isSameDay(d, date));
            bool isDot = widget.dotDates.any((d) => _isSameDay(d, date));
            bool isPastDate = date.isBefore(DateTime.now());

            return GestureDetector(
              onTap: () {
                if (isPastDate) {
                  return;
                }
                setState(() {
                  _selectedDay = date;
                });
                widget.onDateSelected(date);
                Navigator.pop(context);
              },
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: isSelected
                          ? const EdgeInsets.all(8)
                          : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        shape:
                            isSelected ? BoxShape.circle : BoxShape.rectangle,
                        color: isSelected ? ColorConstant.primaryColor : null,
                        border: isUnderline
                            ? const Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              )
                            : null,
                      ),
                      child: Text(
                        date.day.toString(),
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isInMonth
                                  ? isPastDate
                                      ? Colors.grey
                                      : ColorConstant.primaryTextColor
                                  : ColorConstant.secondaryTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ),
                  if (isDot)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5, right: 5),
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConstant.errorColor,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          headerBuilder: (date) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        monthViewKey.currentState?.previousPage();
                      },
                      child: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      "${monthIntToString(date.month)} ${date.year}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: fontFamily,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        monthViewKey.currentState?.nextPage();
                      },
                      child: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const Divider(
                  color: ColorConstant.secondaryTextColor,
                  thickness: 0.3,
                ),
              ],
            );
          },
          weekDayBuilder: (day) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  intToWeekDay(day),
                  style: const TextStyle(
                    fontSize: 10,
                    color: ColorConstant.secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            );
          },
          borderColor: ColorConstant.primaryColor,
          onCellTap: (events, date) {
            bool isPastDate = date.isBefore(DateTime.now());
            if (isPastDate) return;
            setState(() {
              _selectedDay = date;
            });
            widget.onDateSelected(date);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

void showCustomCalendarPopup({
  required BuildContext context,
  required Set<DateTime> underlineDates,
  required Set<DateTime> dotDates,
  required void Function(DateTime selectedDate) onDateSelected,
}) {
  final DateTime now = DateTime.now();
  final int currentYear = now.month < 4 ? now.year - 1 : now.year;
  final DateTime firstDay = DateTime(currentYear, 4, 1);
  final DateTime lastDay = DateTime(currentYear + 1, 3, 31);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: CalendarDateWidget(
          firstDay: firstDay,
          lastDay: lastDay,
          initialFocusedDay: now,
          underlineDates: const {},
          // underlineDates,
          dotDates: const {},
          // dotDates,
          onDateSelected: onDateSelected,
        ),
      );
    },
  );
}
