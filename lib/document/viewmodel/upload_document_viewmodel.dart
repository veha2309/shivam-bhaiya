import 'dart:io';
import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/document/model/upload_document_pre_sign_request.dart';
import 'package:school_app/document/model/upload_document_pre_sign_response.dart';
import 'package:school_app/document/model/document_type.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class UploadDocumentViewModel with ChangeNotifier {
  UploadDocumentViewModel._();

  static UploadDocumentViewModel? _instance;

  static UploadDocumentViewModel get instance =>
      _instance ??= UploadDocumentViewModel._();

  Future<ApiResponse<List<DocumentType>>> getDocumentType() async {
    return NetworkManager.instance.makeRequest(
      Endpoints.getDocumentTypeCombo,
      (json) async => DocumentType.fromJsonList(json as List<dynamic>),
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<UploadDocumentPreSignResponse>> getPresignUrl(
    String fileName,
  ) async {
    return NetworkManager.instance.makeRequest(
      Endpoints.uploadDocumentPresignUrl(fileName),
      (json) async => UploadDocumentPreSignResponse.fromJson(json),
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<void>> uploadDocument(
    File file, {
    required String classCode,
    required String sectionCode,
    required String documentType,
    required String remark,
    required String endpoint,
  }) async {
    return NetworkManager.instance.uploadFile(
      Endpoints.uploadDocument,
      file,
      fullEndpoint: endpoint,
      (json) async {
        print(json);
        return;
      },
      fields: {
        'classCode': classCode,
        'sectionCode': sectionCode,
        'documentType': documentType,
        'remark': remark,
      },
    );
  }

  Future<ApiResponse<void>> saveUploadedDocumentData({
    required String classCode,
    required String sectionCode,
    required String documentType,
    required String remark,
    required String bucketName,
    required String fileName,
  }) async {
    final payload = {
      'classCode': classCode,
      'sectionCode': sectionCode,
      'documentType': documentType,
      'remark': remark,
      'bucketName': bucketName,
      'fileName': fileName,
    };
    return NetworkManager.instance.makeRequest(
      Endpoints.saveUploadedDocumentData,
      (json) async {
        return;
      },
      method: HttpMethod.post,
      body: payload,
    );
  }

  Future<ApiResponse<void>> deleteDocument(String fileName) async {
    return NetworkManager.instance.makeRequest(
      Endpoints.deleteHomeworkDocument(fileName),
      (json) async {
        return;
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<String>> viewUploadedHomework({
    required String fileName,
  }) async {
    final affiliationCode =
        AuthViewModel.instance.getLoggedInUser()?.affiliationCode;

    if (affiliationCode == null || affiliationCode.isEmpty) {
      return ApiResponse.failure('Affiliation code not found');
    }

    final bucketName = "$affiliationCode-homework";

    return NetworkManager.instance.makeRequest(
      Endpoints.getPresignUrlForViewHomeworkDocument(bucketName, fileName),
      (json) async => json,
      method: HttpMethod.get,
    );
  }
}
