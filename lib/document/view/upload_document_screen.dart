import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/document/model/upload_document_pre_sign_response.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/document/model/document_type.dart';
import 'package:school_app/document/viewmodel/upload_document_viewmodel.dart';
import 'package:school_app/auth/view_model/auth.dart';

enum ImageSourceType {
  pickImage,
  captureImage,
}

class UploadDocumentScreen extends StatefulWidget {
  static const String routeName = '/upload-document';
  final String? title;
  const UploadDocumentScreen({
    super.key,
    this.title,
  });

  @override
  _UploadDocumentScreenState createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  String? documentType;
  XFile? pickedImage;
  PlatformFile? selectedFile;
  DocumentType? selectedDocumentType;
  List<DocumentType> documentTypes = [];

  final TextEditingController remarkController = TextEditingController();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<DocumentType>>>? getDocumentTypeFuture;

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

    // Fetch document types
    getDocumentTypeFuture = UploadDocumentViewModel.instance
        .getDocumentType()
        .then((ApiResponse<List<DocumentType>> response) {
      if (response.success) {
        setState(() {
          documentTypes = response.data ?? [];
        });
      }
      return response;
    });
  }

  ClassModel? selectedClass;
  Section? selectedSection;

  List<ClassModel> classes = [];
  List<Section> sections = [];

  Future<void> pickImage(ImageSourceType sourceType) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: sourceType == ImageSourceType.captureImage
          ? ImageSource.camera
          : ImageSource.gallery,
      // For Android 13+, this automatically uses the Photo Picker
      // which provides limited access and complies with Google Play policies
    );
    setState(() {
      pickedImage = image;
    });
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
      // On Android 13+, this will automatically use the Photo Picker
      // for image/video files, complying with Google Play policies
    );
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: widget.title ?? "My Documents",
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16.0,
              children: [
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
                FutureBuilder<ApiResponse<List<DocumentType>>>(
                  future: getDocumentTypeFuture,
                  builder: (context, snapshot) {
                    return AppTextfield(
                      onTap: () {
                        openDocumentTypeBottomSheet(
                          context,
                          documentTypes,
                          (type) {
                            setState(() {
                              selectedDocumentType = type;
                            });
                          },
                        );
                      },
                      enabled: false,
                      hintText: selectedDocumentType?.docTypeName ??
                          'Select Document Type',
                    );
                  },
                ),
                if (selectedFile == null && pickedImage == null) ...[
                  Row(
                    spacing: 16.0,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => pickImage(ImageSourceType.captureImage),
                          child: Container(
                            height: 100,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: ColorConstant.secondaryTextColor,
                                ),
                                borderRadius: BorderRadius.circular(5)),
                            child: const Text(
                              "TAKE PHOTO",
                              textAlign: TextAlign.center,
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: fontFamily,
                                color: ColorConstant.secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => pickImage(ImageSourceType.pickImage),
                          child: Container(
                            height: 100,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: ColorConstant.secondaryTextColor,
                                ),
                                borderRadius: BorderRadius.circular(5)),
                            child: const Text(
                              "GALLERY",
                              textAlign: TextAlign.center,
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: fontFamily,
                                color: ColorConstant.secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: pickFiles,
                          child: Container(
                            height: 100,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ColorConstant.secondaryTextColor,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "CHOOSE FILE",
                              textAlign: TextAlign.center,
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: fontFamily,
                                color: ColorConstant.secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (selectedFile != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorConstant.secondaryTextColor,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedFile!.name,
                                textScaler: const TextScaler.linear(1.0),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: fontFamily,
                                  color: ColorConstant.secondaryTextColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: ColorConstant.secondaryTextColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedFile = null;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Size: ${_formatFileSize(selectedFile!.size)}',
                          textScaler: const TextScaler.linear(1.0),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: fontFamily,
                            color: ColorConstant.secondaryTextColor,
                          ),
                        ),
                        Text(
                          'Extension: ${selectedFile!.extension}',
                          textScaler: const TextScaler.linear(1.0),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: fontFamily,
                            color: ColorConstant.secondaryTextColor,
                          ),
                        ),
                        if (['png', 'jpg', 'jpeg', 'gif', 'webp', 'heic', 'heif']
                            .contains(selectedFile!.extension?.toLowerCase())) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(selectedFile!.path!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else if (pickedImage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorConstant.secondaryTextColor,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pickedImage!.name,
                                textScaler: const TextScaler.linear(1.0),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily,
                                  color: ColorConstant.secondaryTextColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: ColorConstant.secondaryTextColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  pickedImage = null;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(pickedImage!.path),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                AppTextfield(
                  controller: remarkController,
                  hintText: "Enter any Remark",
                  enabled: true,
                  showIcon: false,
                  onSubmit: (_) {},
                ),
                const SizedBox(height: 20),
                Row(
                  spacing: 8.0,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: (isLoading) async {
                          if (selectedClass == null ||
                              selectedSection == null ||
                              selectedDocumentType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select class, section and document type'),
                              ),
                            );
                            return;
                          }

                          final homeModel = AuthViewModel.instance.homeModel;
                          if (homeModel == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User data not found'),
                              ),
                            );
                            return;
                          }

                          final User? user =
                              AuthViewModel.instance.getLoggedInUser();
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User data not found'),
                              ),
                            );
                            return;
                          }

                          if (selectedFile == null && pickedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a file to upload'),
                              ),
                            );
                            return;
                          }

                          if (remarkController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter remark'),
                              ),
                            );
                            return;
                          }

                          isLoading.value = true;
                          File fileToUpload;
                          if (selectedFile != null) {
                            fileToUpload = File(selectedFile!.path!);
                          } else if (pickedImage != null) {
                            fileToUpload = File(pickedImage!.path);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No file selected'),
                              ),
                            );
                            return;
                          }

                          ApiResponse<UploadDocumentPreSignResponse>
                              presignResponse = await UploadDocumentViewModel
                                  .instance
                                  .getPresignUrl(
                                      fileToUpload.path.split('/').last);

                          if (!presignResponse.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'An error occurred, please try again!'),
                              ),
                            );
                            return;
                          }

                          UploadDocumentPreSignResponse
                              uploadDocumentPreSignResponse =
                              presignResponse.data!;

                          ApiResponse uploadResponse =
                              await UploadDocumentViewModel.instance
                                  .uploadDocument(
                            fileToUpload,
                            endpoint:
                                uploadDocumentPreSignResponse.presignUrl ?? "",
                            classCode: selectedClass?.classCode ?? "",
                            documentType:
                                selectedDocumentType?.docTypeCode ?? "",
                            remark: remarkController.text,
                            sectionCode: selectedSection?.sectionCode ?? "",
                          );

                          if (uploadResponse.success) {
                            ApiResponse saveUploadDocumentData =
                                await UploadDocumentViewModel.instance
                                    .saveUploadedDocumentData(
                              classCode: selectedClass?.classCode ?? "",
                              sectionCode: selectedSection?.sectionCode ?? "",
                              documentType:
                                  selectedDocumentType?.docTypeCode ?? "",
                              remark: remarkController.text,
                              bucketName:
                                  uploadDocumentPreSignResponse.bucketName ??
                                      "",
                              fileName:
                                  uploadDocumentPreSignResponse.fileName ?? "",
                            );

                            if (!saveUploadDocumentData.success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('An error occurred'),
                                ),
                              );
                              isLoading.value = false;
                              return;
                            }

                            isLoading.value = false;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Document uploaded successfully'),
                              ),
                            );
                            // Clear the form
                            setState(() {
                              selectedFile = null;
                              pickedImage = null;
                              selectedClass = null;
                              selectedSection = null;
                              selectedDocumentType = null;
                              remarkController.clear();
                            });
                          } else {
                            isLoading.value = false;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(uploadResponse.errorMessage ??
                                    'Failed to upload document'),
                              ),
                            );
                          }
                        },
                        text: "UPLOAD",
                        textStyle: const TextStyle(
                          fontFamily: fontFamily,
                          color: ColorConstant.onPrimary,
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
}
