import 'package:flutter/material.dart';
import 'package:school_app/academic_card/model/academic_card.dart';
import 'package:school_app/academic_card/model/card_no_array_response.dart';
import 'package:school_app/academic_card/model/save_update_student_discipline_data.dart';
import 'package:school_app/academic_card/view_model/academic_card_view_model.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/search_student_profile/Model/search_student_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class AcademicCardEntryScreen extends StatefulWidget {
  static const String routeName = '/academic-card-entry';
  final List<SearchStudentModel> students;
  final String classCode;
  final String sectionCode;

  const AcademicCardEntryScreen({
    super.key,
    required this.students,
    required this.classCode,
    required this.sectionCode,
  });

  @override
  State<AcademicCardEntryScreen> createState() =>
      _AcademicCardEntryScreenState();
}

class _AcademicCardEntryScreenState extends State<AcademicCardEntryScreen> {
  Future<ApiResponse<List<AcademicCard>>>? getDisciplineCategoryListFuture;
  Future<ApiResponse<CardNoArrayResponse>>? getCardNoArrayFuture;
  List<AcademicCard> categories = [];
  CardNoArrayResponse? cardNoArrayResponse;

  int totalStudents = 0;
  int prevCardNo = -1;
  List<SearchStudentModel> students = [];

  @override
  void initState() {
    super.initState();
    callGetDisciplineCategoryListFuture();
  }

  void callGetCardNoArray() {
    User? user = AuthViewModel.instance.getLoggedInUser();
    String affiliationCode = user?.affiliationCode ?? "";

    getCardNoArrayFuture = AcademicCardViewModel.instance
        .getCardNoArray(affiliationCode)
        .then((response) {
      if (response.success) {
        setState(() {
          cardNoArrayResponse = response.data;
          // Populate card numbers for all students
          populateCardNumbersForStudents();
          // Populate remarks for all students based on selected categories
          updateRemarksForAllStudents();
        });
      }
      return response;
    });
  }

  void callGetDisciplineCategoryListFuture() {
    User? user = AuthViewModel.instance.getLoggedInUser();
    String affiliationCode = user?.affiliationCode ?? "";

    getDisciplineCategoryListFuture = AcademicCardViewModel.instance
        .getDisciplineCategoryList(affiliationCode)
        .then((ApiResponse<List<AcademicCard>> response) {
      if (response.success) {
        setState(() {
          categories = response.data ?? [];
          totalStudents = widget.students.length;
          int index = 1;
          students = widget.students.map((student) {
            student.sNo = index++;
            student.remarkController = TextEditingController();
            student.cardNoController = TextEditingController();
            student.fromDate = TextEditingController();
            student.toDate = TextEditingController();
            student.cardCategoryCode =
                <String>{}; // Initialize as empty modifiable set
            return student;
          }).toList();

          callGetCardNoArray();
        });
      }
      return response;
    });
  }

  /// Updates remarks for all students based on selected categories and their norms
  void updateRemarksForAllStudents() {
    if (cardNoArrayResponse?.normArray == null) return;

    for (SearchStudentModel student in students) {
      updateRemarksForStudent(student);
    }
  }

  /// Updates remarks for a specific student based on selected categories and their norms
  void updateRemarksForStudent(SearchStudentModel student) {
    if (cardNoArrayResponse?.normArray == null) return;

    List<String> selectedNorms = [];

    // If no categories are selected, clear the remarks
    if (student.cardCategoryCode == null || student.cardCategoryCode!.isEmpty) {
      student.remarkController ??= TextEditingController();
      student.remarkController!.text = '';
      return;
    }

    // For each selected category code, find its norm
    for (String categoryCode in student.cardCategoryCode!) {
      try {
        // Find the norm for this category code
        NormArrayItem? normItem = cardNoArrayResponse!.normArray!.firstWhere(
          (item) => item.categoryCode == categoryCode,
          orElse: () => NormArrayItem(),
        );

        if (normItem.norm != null && normItem.norm!.isNotEmpty) {
          selectedNorms.add(normItem.norm!);
        }
      } catch (e) {
        // Handle any errors in finding the norm
        print('Error finding norm for category code: $categoryCode');
      }
    }

    // Join all norms with comma and set to remark controller
    String remarks = selectedNorms.join('#');

    // Ensure remarkController is initialized
    student.remarkController ??= TextEditingController();

    student.remarkController!.text = remarks;
  }

  /// Opens date picker and updates the controller with selected date
  Future<String?> openDatePicker(BuildContext context,
      {DateTime? initialDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      // Format date as YYYY-MM-DD
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      return formattedDate;
    }
    return null;
  }

  /// Opens date picker and updates the controller with selected date
  Future<void> openDatePickerForController(BuildContext context,
      TextEditingController controller, SearchStudentModel currentStudent,
      {bool isFromDate = false}) async {
    // Parse existing date if available, otherwise use current date
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        List<String> dateParts = controller.text.split('-');
        if (dateParts.length == 3) {
          initialDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
        }
      } catch (e) {
        // If parsing fails, use current date
        initialDate = DateTime.now();
      }
    }

    String? selectedDate = await openDatePicker(
      context,
      initialDate: initialDate,
    );

    if (selectedDate != null) {
      // Validate date range if this is fromDate
      if (isFromDate) {
        // Check if fromDate is after toDate
        if (currentStudent.toDate?.text.isNotEmpty == true) {
          try {
            List<String> toDateParts = currentStudent.toDate!.text.split('-');
            if (toDateParts.length == 3) {
              DateTime toDate = DateTime(
                int.parse(toDateParts[0]),
                int.parse(toDateParts[1]),
                int.parse(toDateParts[2]),
              );

              List<String> fromDateParts = selectedDate.split('-');
              DateTime fromDate = DateTime(
                int.parse(fromDateParts[0]),
                int.parse(fromDateParts[1]),
                int.parse(fromDateParts[2]),
              );

              if (fromDate.isAfter(toDate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('From date cannot be after to date'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            }
          } catch (e) {
            // If parsing fails, continue without validation
          }
        }
      } else {
        // This is toDate, check if toDate is before fromDate
        if (currentStudent.fromDate?.text.isNotEmpty == true) {
          try {
            List<String> fromDateParts =
                currentStudent.fromDate!.text.split('-');
            if (fromDateParts.length == 3) {
              DateTime fromDate = DateTime(
                int.parse(fromDateParts[0]),
                int.parse(fromDateParts[1]),
                int.parse(fromDateParts[2]),
              );

              List<String> toDateParts = selectedDate.split('-');
              DateTime toDate = DateTime(
                int.parse(toDateParts[0]),
                int.parse(toDateParts[1]),
                int.parse(toDateParts[2]),
              );

              if (toDate.isBefore(fromDate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('To date cannot be before from date'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            }
          } catch (e) {
            // If parsing fails, continue without validation
          }
        }
      }

      controller.text = selectedDate;
      setState(() {}); // Trigger UI update
    }
  }

  Future<void> onSave() async {
    User? user = AuthViewModel.instance.getLoggedInUser();
    String username = user?.username ?? "";
    String affiliationCode = user?.affiliationCode ?? "";

    // Create list of SaveUpdateStudentDisciplineData from students
    List<SaveUpdateStudentDisciplineData> disciplineDataList = [];

    for (SearchStudentModel student in students) {
      // Skip if no categories are selected
      if (student.cardCategoryCode == null ||
          student.cardCategoryCode!.isEmpty) {
        continue;
      }

      String? sessionCode = AuthViewModel.instance.homeModel?.sessionCode;

      // Create discipline data for each selected category
      for (SearchStudentModel student in widget.students) {
        SaveUpdateStudentDisciplineData disciplineData =
            SaveUpdateStudentDisciplineData(
                disciplineCardId: '', // Blank for insert
                studentId: student.studentId,
                categoryCode: student.cardCategoryCode?.join("~"),
                sessionCode:
                    sessionCode, // You may need to get this from context
                classCode:
                    widget.classCode, // You may need to get this from context
                sectionCode:
                    widget.sectionCode, // You may need to get this from context
                disciplineDate: DateTime.now()
                    .toString()
                    .split(' ')[0], // Current date in YYYY-MM-DD format
                actionTaken: student.remarkController?.text ?? '',
                suspensionStr: student.suspension ? 'Y' : 'N',
                fromDate: student.fromDate?.text ?? '',
                toDate: student.toDate?.text ?? '',
                createdBy: username,
                cardNo: student.cardNoController?.text);

        disciplineDataList.add(disciplineData);
      }
    }

    // Call the API to save the discipline data
    if (disciplineDataList.isNotEmpty) {
      await AcademicCardViewModel.instance
          .saveUpdateStudentDisciplineData(affiliationCode, disciplineDataList)
          .then((response) {
        if (response.success) {
          showSnackBarOnScreen(context, 'Discipline data saved successfully');
          // Show success message

          Navigator.of(context).pop();
        } else {
          // Show error message
          showSnackBarOnScreen(context, 'Error: ${response.errorMessage}');
        }
      });
    } else {
      // Show message if no data to save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No discipline data to save'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Finds the next available card number that doesn't exist in the cardNoArray
  int findNextAvailableCardNo() {
    if (cardNoArrayResponse?.cardNoArray == null ||
        cardNoArrayResponse?.nextCardNo == null) {
      return 1; // Default fallback
    }

    List<int> existingCardNos = cardNoArrayResponse!.cardNoArray!;
    int nextCardNo = cardNoArrayResponse!.nextCardNo!;

    // Check if nextCardNo already exists in the array
    while (existingCardNos.contains(nextCardNo)) {
      nextCardNo++;
    }

    return nextCardNo;
  }

  /// Populates card numbers for all students in the list
  void populateCardNumbersForStudents() {
    if (students.isEmpty || cardNoArrayResponse == null) return;

    int currentCardNo = findNextAvailableCardNo();
    List<int> existingCardNos =
        List<int>.from(cardNoArrayResponse!.cardNoArray ?? []);

    for (int i = 0; i < students.length; i++) {
      // Find the next available card number for this student
      while (existingCardNos.contains(currentCardNo)) {
        currentCardNo++;
      }

      // Ensure cardNoController is initialized
      if (students[i].cardNoController == null) {
        students[i].cardNoController = TextEditingController();
      }

      // Populate the card number for this student
      students[i].cardNoController!.text = currentCardNo.toString();

      // Add this card number to the existing list to avoid duplicates
      existingCardNos.add(currentCardNo);
      currentCardNo++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: "Academic Card Entry",
        body: AppFutureBuilder(
            future: getDisciplineCategoryListFuture,
            builder: (context, snapshot) {
              return getAcademicCardEntryBody();
            }),
      ),
    );
  }

  Widget getAcademicCardEntryBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16.0,
          children: [
            if (students.isNotEmpty) ...[
              ...students.map((student) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "${student.sNo} / $totalStudents",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(1.0),
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: fontFamily,
                            color: ColorConstant.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TableWidget(rows: [
                        TableRowConfiguration(
                          cells: [
                            TableCellConfiguration(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8.0,
                                  children: [
                                    const Text(
                                      "Student Name",
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w700,
                                        color: ColorConstant.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      student.studentName,
                                      textScaler: const TextScaler.linear(1.0),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: fontFamily,
                                        color: ColorConstant.inactiveColor,
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        ),
                        TableRowConfiguration(
                          cells: [
                            TableCellConfiguration(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8.0,
                                children: categories
                                    .map((category) => Row(
                                          children: [
                                            Text(
                                              category.categoryName ?? "--",
                                              textScaler:
                                                  const TextScaler.linear(1.0),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: fontFamily,
                                                color: ColorConstant
                                                    .primaryTextColor,
                                              ),
                                            ),
                                            const Spacer(),
                                            Checkbox(
                                              value: student.cardCategoryCode
                                                      ?.contains(category
                                                          .categoryCode) ??
                                                  false,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              semanticLabel:
                                                  category.categoryCode,
                                              side: const BorderSide(
                                                color:
                                                    ColorConstant.inactiveColor,
                                                width: 1,
                                              ),
                                              onChanged: (value) {
                                                // Ensure cardCategoryCode is initialized
                                                student.cardCategoryCode ??=
                                                    <String>{};

                                                if (value == true) {
                                                  // Add category code if checked
                                                  student.cardCategoryCode!.add(
                                                      category.categoryCode ??
                                                          "");
                                                } else {
                                                  // Remove category code if unchecked
                                                  student.cardCategoryCode!
                                                      .remove(category
                                                              .categoryCode ??
                                                          "");
                                                }

                                                updateRemarksForAllStudents();
                                                setState(
                                                    () {}); // Trigger UI update
                                              },
                                              activeColor:
                                                  ColorConstant.primaryColor,
                                              checkColor:
                                                  ColorConstant.onPrimary,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        TableRowConfiguration(
                          rowHeight: 80,
                          cells: [
                            TableCellConfiguration(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2.0,
                                  children: [
                                    const Text(
                                      "Card No",
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w700,
                                        color: ColorConstant.primaryColor,
                                      ),
                                    ),
                                    AppTextfield(
                                      controller: student.cardNoController,
                                      hintText: "Enter card no",
                                      height: null,
                                      showIcon: false,
                                      enabled: false,
                                    )
                                  ],
                                )),
                          ],
                        ),
                        TableRowConfiguration(
                          cells: [
                            TableCellConfiguration(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2.0,
                                  children: [
                                    const Text(
                                      "Area of Concern",
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w700,
                                        color: ColorConstant.primaryColor,
                                      ),
                                    ),
                                    AppTextfield(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 8),
                                      controller: student.remarkController,
                                      hintText: "Enter area of concern",
                                      height: null,
                                      showIcon: false,
                                      enabled: true,
                                      onSubmit: (_) {},
                                    )
                                  ],
                                )),
                          ],
                        ),
                        TableRowConfiguration(
                          rowHeight: 40,
                          cells: [
                            TableCellConfiguration(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  spacing: 2.0,
                                  children: [
                                    const Text(
                                      "Suspension",
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w700,
                                        color: ColorConstant.primaryColor,
                                      ),
                                    ),
                                    Checkbox(
                                      value: student.suspension,
                                      onChanged: (value) {
                                        student.suspension =
                                            !student.suspension;
                                        setState(() {});
                                      },
                                    )
                                  ],
                                )),
                          ],
                        ),
                        TableRowConfiguration(
                          rowHeight: 80,
                          cells: [
                            TableCellConfiguration(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2.0,
                                  children: [
                                    const Text(
                                      "From Date",
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w700,
                                        color: ColorConstant.primaryColor,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (student.suspension) {
                                          openDatePickerForController(context,
                                              student.fromDate!, student,
                                              isFromDate: true);
                                        }
                                      },
                                      child: AppTextfield(
                                        controller: student.fromDate,
                                        hintText: "Enter from date",
                                        height: null,
                                        showIcon: false,
                                        enabled: false,
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        ),
                        TableRowConfiguration(
                          rowHeight: 80,
                          cells: [
                            TableCellConfiguration(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2.0,
                                  children: [
                                    const Text(
                                      "To Date",
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w700,
                                        color: ColorConstant.primaryColor,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (student.suspension) {
                                          openDatePickerForController(
                                              context, student.toDate!, student,
                                              isFromDate: false);
                                        }
                                      },
                                      child: AppTextfield(
                                        controller: student.toDate,
                                        hintText: "Enter to date",
                                        height: null,
                                        showIcon: false,
                                        enabled: false,
                                      ),
                                    )
                                  ],
                                )),
                          ],
                        ),
                      ]),
                    ],
                  ),
                );
              }),
              AppButton(
                text: "Save",
                onPressed: (isLoading) async {
                  isLoading.value = true;
                  await onSave();
                  isLoading.value = false;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
