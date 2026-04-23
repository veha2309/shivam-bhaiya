import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/document/model/view_document.dart';
import 'package:school_app/document/viewmodel/view_document_viewmodel.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class DocumentViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, List<Document>> _documents = {};
  Map<String, List<Document>> get documents => _documents;

  List<Document> _allDocuments = [];
  List<Document> get allDocuments => _allDocuments;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  DocumentViewModel() {
    loadDocuments();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    final response = await NetworkManager.instance.makeRequest(
      Endpoints.getStudentViewDocumentEndpoint,
      (json) async {
        Map<String, List<Document>> docs = (json as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((item) => Document.fromJson(item)).toList(),
              ),
            ) ?? {};
        return docs;
      },
      method: HttpMethod.get,
    );

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      _documents = response.data!;
      _allDocuments = _documents.values.expand((e) => e).toList();
    } else {
      // Fallback Dummy Data
      _documents = {
        'Circulars': [
          Document(remarks: 'Annual Day Celebration 2024', documentType: 'Circular', uploadDate: '2024-05-16', attachment: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
          Document(remarks: 'School Reopens on 3rd June', documentType: 'Circular', uploadDate: '2024-05-10', attachment: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
        ],
        'Notices': [
          Document(remarks: 'Fee Payment Reminder', documentType: 'Notice', uploadDate: '2024-05-15', attachment: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
        ],
        'Holiday Homework': [
          Document(remarks: 'Summer Vacation Homework', documentType: 'Holiday Homework', uploadDate: '2024-05-14', attachment: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
        ],
        'Worksheets': [
          Document(remarks: 'Maths Worksheet - Fractions', documentType: 'Worksheet', uploadDate: '2024-05-13', attachment: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
        ],
        'Syllabus': [
          Document(remarks: 'Science Syllabus 2024-25', documentType: 'Syllabus', uploadDate: '2024-05-12', attachment: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
        ],
      };
      _allDocuments = _documents.values.expand((e) => e).toList();
    }
    _allDocuments.sort((a, b) => (b.uploadDate ?? "").compareTo(a.uploadDate ?? ""));

    _isLoading = false;
    notifyListeners();
  }

  List<Document> get filteredDocuments {
    if (_searchQuery.isEmpty) return _allDocuments;
    return _allDocuments.where((doc) {
      return (doc.remarks ?? "").toLowerCase().contains(_searchQuery.toLowerCase()) ||
             (doc.documentType ?? "").toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
}
