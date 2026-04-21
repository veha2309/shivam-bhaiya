import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/academic_card/model/academic_card.dart';
import 'package:school_app/academic_card/model/card_no_array_response.dart';
import 'package:school_app/academic_card/model/save_update_student_discipline_data.dart';
import 'package:school_app/academic_card/view_model/academic_card_view_model.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/search_student_profile/Model/search_student_model.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
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
          populateCardNumbersForStudents();
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
            student.cardCategoryCode = <String>{};
            return student;
          }).toList();

          callGetCardNoArray();
        });
      }
      return response;
    });
  }

  void updateRemarksForAllStudents() {
    if (cardNoArrayResponse?.normArray == null) return;
    for (SearchStudentModel student in students) {
      updateRemarksForStudent(student);
    }
  }

  void updateRemarksForStudent(SearchStudentModel student) {
    if (cardNoArrayResponse?.normArray == null) return;
    List<String> selectedNorms = [];
    if (student.cardCategoryCode == null || student.cardCategoryCode!.isEmpty) {
      student.remarkController?.text = '';
      return;
    }
    for (String categoryCode in student.cardCategoryCode!) {
      try {
        NormArrayItem? normItem = cardNoArrayResponse!.normArray!.firstWhere(
          (item) => item.categoryCode == categoryCode,
          orElse: () => NormArrayItem(),
        );
        if (normItem.norm != null && normItem.norm!.isNotEmpty) {
          selectedNorms.add(normItem.norm!);
        }
      } catch (e) {}
    }
    student.remarkController?.text = selectedNorms.join('#');
  }

  void populateCardNumbersForStudents() {
    if (students.isEmpty || cardNoArrayResponse == null) return;
    int currentCardNo = cardNoArrayResponse!.nextCardNo ?? 1;
    List<int> existingCardNos = List<int>.from(cardNoArrayResponse!.cardNoArray ?? []);

    for (int i = 0; i < students.length; i++) {
      while (existingCardNos.contains(currentCardNo)) {
        currentCardNo++;
      }
      students[i].cardNoController ??= TextEditingController();
      students[i].cardNoController!.text = currentCardNo.toString();
      existingCardNos.add(currentCardNo);
      currentCardNo++;
    }
  }

  Future<void> onSave() async {
    User? user = AuthViewModel.instance.getLoggedInUser();
    String username = user?.username ?? "";
    String affiliationCode = user?.affiliationCode ?? "";
    List<SaveUpdateStudentDisciplineData> disciplineDataList = [];
    String? sessionCode = AuthViewModel.instance.homeModel?.sessionCode;

    for (SearchStudentModel student in students) {
      if (student.cardCategoryCode == null || student.cardCategoryCode!.isEmpty) continue;
      SaveUpdateStudentDisciplineData disciplineData = SaveUpdateStudentDisciplineData(
        disciplineCardId: '',
        studentId: student.studentId,
        categoryCode: student.cardCategoryCode?.join("~"),
        sessionCode: sessionCode,
        classCode: widget.classCode,
        sectionCode: widget.sectionCode,
        disciplineDate: DateTime.now().toString().split(' ')[0],
        actionTaken: student.remarkController?.text ?? '',
        suspensionStr: student.suspension ? 'Y' : 'N',
        fromDate: student.fromDate?.text ?? '',
        toDate: student.toDate?.text ?? '',
        createdBy: username,
        cardNo: student.cardNoController?.text,
      );
      disciplineDataList.add(disciplineData);
    }

    if (disciplineDataList.isNotEmpty) {
      final response = await AcademicCardViewModel.instance.saveUpdateStudentDisciplineData(affiliationCode, disciplineDataList);
      if (response.success) {
        showSnackBarOnScreen(context, 'Academic cards saved successfully');
        Navigator.of(context).pop();
      } else {
        showSnackBarOnScreen(context, 'Error: ${response.errorMessage}');
      }
    } else {
      showSnackBarOnScreen(context, 'No data to save');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: "Academic Card Entry",
        body: AppFutureBuilder(
          future: getDisciplineCategoryListFuture,
          builder: (context, snapshot) => _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              physics: const BouncingScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) => _buildStudentCard(students[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: AppButton(
              text: "Save Academic Cards",
              onPressed: (isLoading) async {
                isLoading.value = true;
                await onSave();
                isLoading.value = false;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(SearchStudentModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Student ${student.sNo} of $totalStudents",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    "CARD #${student.cardNoController?.text ?? '--'}",
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.studentName, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                const SizedBox(height: 16),
                
                Text("Select Violation Categories", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = student.cardCategoryCode?.contains(cat.categoryCode) ?? false;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(cat.categoryName ?? ""),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.onSurface,
                      ),
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      onSelected: (val) {
                        setState(() {
                          student.cardCategoryCode ??= <String>{};
                          if (val) student.cardCategoryCode!.add(cat.categoryCode!);
                          else student.cardCategoryCode!.remove(cat.categoryCode!);
                          updateRemarksForStudent(student);
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                Text("Area of Concern", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                AppTextfield(
                  controller: student.remarkController,
                  hintText: "Enter remarks...",
                  height: null,
                  maxlines: 2,
                  showIcon: false,
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Suspension", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                          Switch(
                            value: student.suspension,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => student.suspension = val),
                          ),
                        ],
                      ),
                    ),
                    if (student.suspension) ...[
                      Expanded(
                        child: _buildDatePicker(
                          label: "From",
                          controller: student.fromDate!,
                          onTap: () => _pickDate(student.fromDate!, student, isFrom: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker(
                          label: "To",
                          controller: student.toDate!,
                          onTap: () => _pickDate(student.toDate!, student, isFrom: false),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({required String label, required TextEditingController controller, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.mdRadius,
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? "Select" : controller.text,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(TextEditingController controller, SearchStudentModel student, {required bool isFrom}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() => controller.text = formatted);
    }
  }
}
