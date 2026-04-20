import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/document/model/view_document.dart';
import 'package:school_app/document/viewmodel/view_document_viewmodel.dart';
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
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class ViewDocumentScreen extends StatefulWidget {
  static const String routeName = '/view-document';
  final String? title;

  const ViewDocumentScreen({
    super.key,
    this.title,
  });

  @override
  State<ViewDocumentScreen> createState() => _ViewDocumentScreenState();
}

class _ViewDocumentScreenState extends State<ViewDocumentScreen> {
  User? user;
  bool isTeacher = false;
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<Map<String, List<Document>>>>? getDocumentListFuture;

  Map<String, List<Document>> documents = {};

  @override
  void initState() {
    super.initState();
    user = AuthViewModel.instance.getLoggedInUser();
    if (user?.userType != "Teacher") {
      getDocumentListFuture = ViewDocumentViewModel.instance
          .getStudentViewDocumentData()
          .then((ApiResponse<Map<String, List<Document>>> response) {
        if (response.success) {
          setState(() {
            documents = response.data ?? {};
          });
        }
        return response;
      });
    } else {
      isTeacher = true;
      getClassListFuture = SchoolDetailsViewModel.instance
          .getClassList()
          .then((ApiResponse<List<ClassModel>> response) {
        if (response.success) {
          classes = response.data ?? [];
        }
        return response;
      });
    }
  }

  ClassModel? selectedClass;
  Section? selectedSection;

  List<ClassModel> classes = [];
  List<Section> sections = [];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: widget.title ?? "My Documents",
        body: getUploadDocumentsScreenBody(
          context,
        ),
      ),
    );
  }

  Widget getUploadDocumentsScreenBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16.0,
          children: [
            if (isTeacher)
              AppTextfield(
                onTap: () {
                  openClassBottomSheet(context, classes, (classModel) {
                    setState(() {
                      selectedClass = classModel;
                      selectedSection = null;
                      getSectionListFuture = SchoolDetailsViewModel.instance
                          .getSectionList(classModel.classCode)
                          .then((ApiResponse<List<Section>> response) {
                        if (response.success) {
                          sections = response.data ?? [];
                        }
                        return response;
                      });
                    });
                  });
                },
                enabled: false,
                hintText: selectedClass?.className ?? 'Select Class',
              ),
            if (isTeacher)
              AppTextfield(
                onTap: () {
                  openSectionBottomSheet(context, sections, (section) {
                    setState(() {
                      selectedSection = section;
                    });
                  });
                },
                enabled: false,
                hintText: selectedSection?.sectionName ?? 'Select Section',
              ),
            if (isTeacher)
              AppButton(
                text: "Search",
                onPressed: (isLoading) {
                  if (selectedClass == null || selectedSection == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select both class and section',
                          textScaler: TextScaler.linear(1.0),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    getDocumentListFuture = ViewDocumentViewModel.instance
                        .getTeacherViewDocumentList(selectedClass!.classCode,
                            selectedSection!.sectionCode)
                        .then((ApiResponse<Map<String, List<Document>>>
                            response) {
                      if (response.success) {
                        setState(() {
                          documents = response.data ?? {};
                        });
                      }
                      return response;
                    });
                  });
                },
              ),
            getStudentDocumentList(),
          ],
        ),
      ),
    );
  }

  Widget getStudentDocumentList() {
    return AppFutureBuilder(
      future: getDocumentListFuture,
      builder: (context, snapshot) => getTeacherDocumentList(),
    );
  }

  Widget getTeacherDocumentList() {
    if (documents.isEmpty) {
      return const NoDataWidget();
    }
    return getDocumentListView();
  }

  Widget getDocumentListView() {
    return ListView.builder(
      itemCount: documents.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        String key = documents.keys.elementAt(index);
        List<Document> docList = documents[key] ?? [];

        return ViewDocumentTile(
          title: key,
          subtitle: "${docList.length} Document(s)",
          icon: Icons.file_copy_rounded,
          items: docList,
        );
      },
    );
  }
}

class ViewDocumentTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Document> items;

  const ViewDocumentTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });

  @override
  _ViewDocumentTileState createState() => _ViewDocumentTileState();
}

class _ViewDocumentTileState extends State<ViewDocumentTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  void _toggleExpand() {
    if (widget.items.isEmpty) {
      return;
    }
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorConstant.primaryColor)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              widget.icon,
              color: ColorConstant.primaryColor,
              size: 28,
            ),
            title: Text(
              widget.title,
              textScaler: const TextScaler.linear(1.0),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorConstant.primaryColor,
                fontFamily: fontFamily,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              widget.subtitle,
              textScaler: const TextScaler.linear(1.0),
              style: const TextStyle(
                color: ColorConstant.inactiveColor,
                fontFamily: fontFamily,
                fontSize: 14,
              ),
            ),
            trailing: widget.items.isNotEmpty
                ? IconButton(
                    icon: Icon(isExpanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down),
                    onPressed: _toggleExpand,
                  )
                : null,
            onTap: _toggleExpand,
          ),
          if (widget.items.isNotEmpty)
            SizeTransition(
              sizeFactor: _animation,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 16.0,
                  left: 56,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.items
                      .map(
                        (item) => InkWell(
                          onTap: () {
                            launchURLString(item.attachment ?? "");
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "•  ${item.remarks ?? ""} (Upload Date - ${formatAnyDateToDDMMYY(item.uploadDate ?? "")})",
                              textScaler: const TextScaler.linear(1.0),
                              style: const TextStyle(
                                color: ColorConstant.inactiveColor,
                                fontFamily: fontFamily,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}
