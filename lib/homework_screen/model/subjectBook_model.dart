import 'dart:convert';

import 'package:flutter/material.dart';

class SubjectbookModel {
  final String? subject;
  final String? subjectCode;
  final List<Book>? books;
  final List<Notebook>? noteBooks;
  DateTime? dueDate;
  TextEditingController? homeworkText;
  DateTime? testSchedule;
  List<Book>? selectedBooks;
  List<Notebook>? selectedNotebooks;
  bool doesHomeworkAlreadyExist;
  String? fileName;
  String? documentName;

  SubjectbookModel({
    this.subject,
    this.subjectCode,
    this.books,
    this.noteBooks,
    this.dueDate,
    this.homeworkText,
    this.selectedBooks = const [],
    this.selectedNotebooks = const [],
    this.testSchedule,
    this.doesHomeworkAlreadyExist = false,
    this.fileName,
    this.documentName,
  });

  factory SubjectbookModel.fromJson(Map<String, dynamic> json) {
    List<Book> booksList = [];
    List<Notebook> noteBooksList = [];

    if (json['books'] != null && json['books'].toString().isNotEmpty) {
      booksList = (jsonDecode(json['books']) as List)
          .map((book) => Book.fromJson(book))
          .toList();
    }

    if (json['noteBooks'] != null && json['noteBooks'].toString().isNotEmpty) {
      noteBooksList = (jsonDecode(json['noteBooks']) as List)
          .map((book) => Notebook.fromJson(book))
          .toList();
    }

    return SubjectbookModel(
      subject: json['subject'],
      subjectCode: json['subjectCode'],
      books: booksList,
      noteBooks: noteBooksList,
    );
  }

  static List<SubjectbookModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SubjectbookModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'subjectCode': subjectCode,
      'books': jsonEncode(books?.map((book) => book.toJson()).toList() ?? []),
      'noteBooks':
          jsonEncode(noteBooks?.map((book) => book.toJson()).toList() ?? []),
      'fileName': fileName,
      'documentName': documentName,
    };
  }
}

class Book {
  final int? bookid;
  final String? bookname;
  final String? isdefault;

  Book({
    this.bookid,
    this.bookname,
    this.isdefault,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookid: json['bookid'],
      bookname: json['bookname'],
      isdefault: json['isdefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookid': bookid,
      'bookname': bookname,
      'isdefault': isdefault,
    };
  }
}

class Notebook {
  final int? notebookid;
  final String? notebookname;
  final String? isdefault;

  Notebook({
    this.notebookid,
    this.notebookname,
    this.isdefault,
  });

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      notebookid: json['notebookid'],
      notebookname: json['notebookname'],
      isdefault: json['isdefault'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notebookid': notebookid,
      'notebookname': notebookname,
      'isdefault': isdefault,
    };
  }
}
