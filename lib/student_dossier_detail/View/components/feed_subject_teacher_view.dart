import 'dart:math';

import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier/Model/student_dossier.dart';
import 'package:school_app/student_dossier_detail/Model/student_feedback_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/constants.dart';

class FeedSubjectTeacherView extends StatefulWidget {
  final StudentDossier student;

  const FeedSubjectTeacherView({super.key, required this.student});

  @override
  State<FeedSubjectTeacherView> createState() => _FeedSubjectTeacherViewState();
}

class _FeedSubjectTeacherViewState extends State<FeedSubjectTeacherView> {
  Future<List<ApiResponse<List<StudentFeedbackModel>>>>?
      getStudentFeedbackFutures;
  List<List<StudentFeedbackModel>?> feedbackModels = [];
  List<Session> selectedSessions = [];
  String? _selectedSubject;

  Future<ApiResponse<List<Session>>>? getSessionListFuture;
  List<Session> sessions = [];

  @override
  void initState() {
    super.initState();
    getSessionListFuture = SchoolDetailsViewModel.instance
        .getSessionList()
        .then((ApiResponse<List<Session>> response) {
      if (response.success) {
        sessions = response.data ?? [];
        if (sessions.isNotEmpty) {
          // Get first three sessions or fewer if less than three are available
          selectedSessions = sessions.take(3).toList().cast<Session>();
          callGetStudentFeedback(selectedSessions);
        }
      }
      return response;
    });
  }

  void callGetStudentFeedback(List<Session> sessions) {
    // Create a list of futures for the sessions
    List<Future<ApiResponse<List<StudentFeedbackModel>>>> futures = [];

    for (var session in sessions) {
      futures.add(StudentDossierDetailViewModel.instance.getStudentFeedback(
        studentId: widget.student.studentId ?? "",
        sessionCode: session.sessionCode,
      ));
    }

    // Wait for all futures to complete
    var future = Future.wait(futures).then((responses) {
      List<List<StudentFeedbackModel>?> data = responses
          .map((response) => response.success ? response.data : null)
          .toList();
      for (var feedback in data) {
        if (feedback != null && feedback.isNotEmpty) {
          feedbackModels.add(feedback);
        }
      }

      if (feedbackModels.isEmpty) {
        loadMore();
      }
      setState(() {});
      return responses;
    });
    getStudentFeedbackFutures ??= future;
  }

  void loadMore() {
    if (sessions.isEmpty) {
      return;
    }
    // Get next three sessions starting from the last fetched index
    sessions.removeRange(0, min(3, sessions.length));
    List<Session> nextSessions = sessions.take(3).toList().cast<Session>();

    // Add the new sessions to the selected sessions list
    selectedSessions.addAll(nextSessions);

    // Call the API for the new sessions
    callGetStudentFeedback(nextSessions);
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
      future: getSessionListFuture,
      builder: (context, snapshot) {
        if (feedbackModels.isEmpty) {
          return const NoDataWidget();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Student Feedback",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            AppFutureBuilder(
              future: getStudentFeedbackFutures,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Check if all sessions have empty data
                bool allEmpty = feedbackModels
                    .every((model) => model == null || model.isEmpty);

                if (allEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feedback_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          "No feedback data available",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: fontFamily,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try selecting a different session",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: fontFamily,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  spacing: 24,
                  children: [
                    for (int i = 0; i < selectedSessions.length; i++)
                      if (feedbackModels.length > i &&
                          feedbackModels[i] != null &&
                          feedbackModels[i]!.isNotEmpty)
                        _buildSessionFeedback(
                            selectedSessions[i], feedbackModels[i]!),
                    if (sessions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: AppButton(
                          onPressed: (_) => loadMore(),
                          text: 'Load More',
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSessionFeedback(
      Session session, List<StudentFeedbackModel> feedbacks) {
    // Group observations by subject
    Map<String, Map<String, String>> subjectObservations = {};

    // Extract all unique subjects
    Set<String> allSubjects = {};
    for (var feedback in feedbacks) {
      for (var observation in feedback.observations ?? []) {
        for (var data in observation.observationData) {
          allSubjects.add(data.subject);
        }
      }
    }

    // Initialize the map for each subject
    for (var subject in allSubjects) {
      subjectObservations[subject] = {};
    }

    // Fill in the observations for each subject
    for (var feedback in feedbacks) {
      for (var observation in feedback.observations ?? []) {
        for (var data in observation.observationData) {
          subjectObservations[data.subject]![observation.observationName] =
              data.observationValue;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: ColorConstant.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  feedbacks.first.ptmName ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: fontFamily,
                  ),
                  textScaler: const TextScaler.linear(1),
                ),
              ),
              Text(
                session.sessionName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: fontFamily,
                ),
                textScaler: const TextScaler.linear(1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Subject Tabs
        _buildSubjectTabs(subjectObservations),
      ],
    );
  }

  Widget _buildSubjectTabs(
      Map<String, Map<String, String>> subjectObservations) {
    final subjects = subjectObservations.keys.toList();

    // Initialize selected subject if not set
    _selectedSubject ??= subjects.isNotEmpty ? subjects.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject selection tabs
        Scrollbar(
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final isSelected = subject == _selectedSubject;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSubject = subject;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorConstant.primaryColor
                          : Colors.grey.shade200,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      subject,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Content for selected subject
        if (_selectedSubject != null)
          _buildSubjectContent(
              _selectedSubject!, subjectObservations[_selectedSubject!]!),
      ],
    );
  }

  Widget _buildSubjectContent(
      String subject, Map<String, String> observations) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstant.primaryColor),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: ColorConstant.primaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(7),
              ),
            ),
            child: Text(
              "Feedback for $subject",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: fontFamily,
                color: ColorConstant.primaryColor,
              ),
            ),
          ),

          // Observation items
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: observations.entries.map((entry) {
                final observationName = entry.key;
                final value = entry.value;
                final isPositive = value.toLowerCase() == "yes";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status icon
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 12, top: 2),
                        decoration: BoxDecoration(
                          color: isPositive ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPositive ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),

                      // Observation text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              observationName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: fontFamily,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPositive ? "Satisfactory" : "Needs Improvement",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: fontFamily,
                                color: isPositive
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
