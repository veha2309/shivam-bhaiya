import 'package:flutter/material.dart';
import 'package:school_app/curriculum_screen/model/curriculam.dart';
import 'package:school_app/document/model/document_type.dart';
import 'package:school_app/homework_screen/model/subject_model.dart';
import 'package:school_app/result_analysis/model/result_analysis_drop_down_model.dart';
import 'package:school_app/result_analysis/model/result_analysis_template_model.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

void openSessionBottomSheet(
    BuildContext context, List<Session> items, Function(Session) onSelect) {
  if (items.isEmpty) {
    return;
  }
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select Session",
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index].sessionName,
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                  onTap: () {
                    onSelect(items[index]);
                    popScreen(context);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

void openMonthBottomSheet(
    BuildContext context, List<String> items, Function(String) onSelect) {
  if (items.isEmpty) {
    return;
  }
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select Month",
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index],
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                  onTap: () {
                    onSelect(items[index]);
                    popScreen(context);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

void openClassBottomSheet(BuildContext context, List<ClassModel> items,
    Function(ClassModel) onSelect) {
  if (items.isEmpty) {
    return;
  }
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select Class",
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index].className,
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                  onTap: () {
                    onSelect(items[index]);
                    popScreen(context);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

void openSectionBottomSheet(
    BuildContext context, List<Section> items, Function(Section) onSelect) {
  if (items.isEmpty) {
    return;
  }
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select Section",
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index].sectionName,
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                  onTap: () {
                    onSelect(items[index]);
                    popScreen(context);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

void openSubjectModelBottomSheet(BuildContext context, List<SubjectModel> items,
    Function(SubjectModel) onSelect) {
  if (items.isEmpty) {
    return;
  }
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select Subject",
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index].subjectName ?? "",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                  onTap: () {
                    onSelect(items[index]);
                    popScreen(context);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

void openDocumentTypeBottomSheet(BuildContext context, List<DocumentType> items,
    Function(DocumentType) onSelect) {
  if (items.isEmpty) {
    return;
  }
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select Document Type",
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index].docTypeName ?? "",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                  onTap: () {
                    onSelect(items[index]);
                    popScreen(context);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

void showMonthsBottomSheet(BuildContext context, Function(String) onTap) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: monthsMMM.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              monthsMMM[index],
              textScaler: const TextScaler.linear(1.0),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
            onTap: () {
              onTap(monthsMMM[index]);
              popScreen(context);
            },
          );
        },
      );
    },
  );
}

void showContactBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: const Icon(Icons.mail, color: Colors.blue),
                title: const Text(
                  "Anand Vihar",
                  textScaler: TextScaler.linear(1.0),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: fontFamily,
                  ),
                ),
                onTap: () {
                  sendEmail(
                      context,
                      "mobileappsupportav@vivekanandschool.in",
                      "Unable to Login – Request for Support",
                      "Dear Team,\nI am facing issues while trying to log in to the school mobile app. Kindly help me with the login credentials.\n\nPlease find the details below for your reference:\n\nPlease fill all below details\n\nStudent Name:\n\nClass & Section:\n\nAdmission Number:\n\nLooking forward to your support.");
                  popScreen(context);
                }),
            ListTile(
                leading: const Icon(Icons.mail, color: Colors.green),
                title: const Text(
                  "Preet Vihar",
                  textScaler: TextScaler.linear(1.0),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: fontFamily,
                  ),
                ),
                onTap: () {
                  sendEmail(
                      context,
                      "mobileappsupportpv@vivekanandschool.in",
                      "Unable to Login – Request for Support",
                      "Dear Team,\nI am facing issues while trying to log in to the school mobile app. Kindly help me with the login credentials.\n\nPlease find the details below for your reference:\n\nPlease fill all below details\n\nStudent Name:\n\nClass & Section:\n\nAdmission Number:\n\nLooking forward to your support.");
                  popScreen(context);
                }),
          ],
        ),
      );
    },
  );
}

void showPhoneBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text(
              "Anand Vihar",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
            onTap: () {
              makePhoneCall("+91-1146516983");
              popScreen(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text(
              "Preet Vihar",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
            onTap: () {
              makePhoneCall("+91-1143097909");
              popScreen(context);
            },
          ),
        ],
      );
    },
  );
}

void showMessageBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text(
              "Anand Vihar",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
            onTap: () {
              sendMessage("+91-1146516983");
              popScreen(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text(
              "Preet Vihar",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
            onTap: () {
              sendMessage("+91-1143097909");
              popScreen(context);
            },
          ),
        ],
      );
    },
  );
}

void openResultAnalysisDropDownBottomSheet(
    BuildContext context,
    List<ResultAnalysisDropDownModel> items,
    Function(ResultAnalysisDropDownModel) onSelect) {
  if (items.isEmpty) {
    return;
  }
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Select Option",
              textAlign: TextAlign.left,
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index].label ?? "",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: fontFamily,
                    ),
                  ),
                  onTap: () {
                    onSelect(items[index]);
                    popScreen(context);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

void openResultAnalysisTemplateBottomSheet(
    BuildContext context,
    List<ResultAnalysisTemplateModel> items,
    Function(ResultAnalysisTemplateModel) onSelect) {
  if (items.isEmpty) {
    return;
  }
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              items[index].reportName ?? "-",
              textScaler: const TextScaler.linear(1.0),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
            onTap: () {
              onSelect(items[index]);
              popScreen(context);
            },
          );
        },
      );
    },
  );
}
