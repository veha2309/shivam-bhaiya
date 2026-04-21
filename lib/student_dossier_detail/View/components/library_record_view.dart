import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier_detail/Model/library_record_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class LibraryRecordView extends StatefulWidget {
  final String studentId;
  const LibraryRecordView({super.key, required this.studentId});

  @override
  State<LibraryRecordView> createState() => _LibraryRecordViewState();
}

class _LibraryRecordViewState extends State<LibraryRecordView> {
  Future<List<ApiResponse<List<LibraryRecordModel>>>>? getDossierLibraryDetails;
  List<List<LibraryRecordModel>?> libraryRecordModels = [];
  List<Session> selectedSessions = [];

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
          callGetDossierLibraryDetails(selectedSessions);
        }
      }
      return response;
    });
  }

  void callGetDossierLibraryDetails(List<Session> sessions) {
    // Create a list of futures for the sessions
    List<Future<ApiResponse<List<LibraryRecordModel>>>> futures = [];

    for (var session in sessions) {
      futures
          .add(StudentDossierDetailViewModel.instance.getDossierLibraryDetail(
        sessionId: session.sessionCode,
        studentId: widget.studentId,
      ));
    }

    // Wait for all futures to complete
    var future = Future.wait(futures).then((responses) {
      List<List<LibraryRecordModel>?> data = responses
          .map((response) => response.success ? response.data : null)
          .toList();
      for (var record in data) {
        if (record != null && record.isNotEmpty) {
          libraryRecordModels.add(record);
        }
      }

      if (libraryRecordModels.isEmpty) {
        loadMore();
      }
      setState(() {});
      return responses;
    });
    getDossierLibraryDetails ??= future;
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
    callGetDossierLibraryDetails(nextSessions);
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
        future: getSessionListFuture,
        builder: (context, snapshot) {
          if (libraryRecordModels.isEmpty) {
            return const NoDataWidget();
          }
          return Column(
            spacing: 16,
            children: [
              AppFutureBuilder(
                  future: getDossierLibraryDetails,
                  builder: (context, snapshot) {
                    // Check if all sessions have empty data
                    bool allEmpty = libraryRecordModels
                        .every((model) => model == null || model.isEmpty);

                    if (allEmpty) {
                      return const NoDataWidget();
                    }

                    return Column(
                      spacing: 24,
                      children: [
                        for (int i = 0; i < selectedSessions.length; i++)
                          if (libraryRecordModels.length > i &&
                              libraryRecordModels[i] != null &&
                              libraryRecordModels[i]!.isNotEmpty)
                            Column(
                              spacing: 16,
                              children: [
                                Text(
                                  libraryRecordModels[i]!.first.sessionName ??
                                      "--",
                                  textScaler: const TextScaler.linear(1.0),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: ColorConstant.primaryColor,
                                  ),
                                ),
                                ListView.separated(
                                  itemCount: libraryRecordModels[i]!.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    color: ColorConstant.inactiveColor,
                                    height: 20,
                                    thickness: 0.2,
                                  ),
                                  itemBuilder: (context, index) {
                                    LibraryRecordModel? library =
                                        libraryRecordModels[i]![index];
                                    return TableWidget(
                                      rows: [
                                        TableRowConfiguration(
                                          rowHeight: 25,
                                          cells: [
                                            TableCellConfiguration(
                                              text: "Sr. No.",
                                            ),
                                            TableCellConfiguration(
                                                text: "${index + 1}"),
                                          ],
                                        ),
                                        TableRowConfiguration(
                                          cells: [
                                            TableCellConfiguration(
                                                text: "Book Name"),
                                            TableCellConfiguration(
                                                text: library.bookName),
                                          ],
                                        ),
                                        TableRowConfiguration(
                                          rowHeight: 25,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "Book Type"),
                                            TableCellConfiguration(
                                                text: library.bookType),
                                          ],
                                        ),
                                        TableRowConfiguration(
                                          rowHeight: 25,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "Subject Name"),
                                            TableCellConfiguration(
                                                text: library.subjectName),
                                          ],
                                        ),
                                        TableRowConfiguration(
                                          rowHeight: 25,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "Issued Date"),
                                            TableCellConfiguration(
                                                text: library.issuedDate),
                                          ],
                                        ),
                                        TableRowConfiguration(
                                          rowHeight: 25,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "Expected Return Date"),
                                            TableCellConfiguration(
                                                text:
                                                    library.expectedReturnDate),
                                          ],
                                        ),
                                        TableRowConfiguration(
                                          rowHeight: 25,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "Return Date"),
                                            TableCellConfiguration(
                                                text: library.returnedDate),
                                          ],
                                        ),
                                        TableRowConfiguration(
                                          rowHeight: 25,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "Fine"),
                                            TableCellConfiguration(
                                                text: library.fine),
                                          ],
                                        ),
                                        TableRowConfiguration(
                                          rowHeight: 25,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "Book Rating"),
                                            TableCellConfiguration(
                                              child: RatingStars(
                                                value:
                                                    double.tryParse("3.5") ?? 0,
                                                onValueChanged: (v) {
                                                  setState(() {
                                                    library.rating =
                                                        v.toString();
                                                  });
                                                },
                                                starCount: 5,
                                                starSize: 20,
                                                valueLabelColor:
                                                    const Color(0xff9b9b9b),
                                                valueLabelTextStyle:
                                                    const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        fontSize: 12.0),
                                                valueLabelRadius: 10,
                                                maxValue: 5,
                                                starSpacing: 2,
                                                maxValueVisibility: true,
                                                valueLabelVisibility: false,
                                                animationDuration:
                                                    const Duration(
                                                        milliseconds: 1000),
                                                valueLabelPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1,
                                                        horizontal: 8),
                                                valueLabelMargin:
                                                    const EdgeInsets.only(
                                                        right: 8),
                                                starOffColor:
                                                    const Color(0xffe7e8ea),
                                                starColor: Colors.yellow,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      showBorder: false,
                                    );
                                  },
                                ),
                              ],
                            ),
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
                  }),
            ],
          );
        });
  }
}
