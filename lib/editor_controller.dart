import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';

class EditorController extends GetxController {
  // QuillController to manage the editor state
  late quill.QuillController quillController;

  // Observable to store saved document content (as JSON)
  final RxList<dynamic> savedContent = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize the QuillController
    _loadDocument();
  }

  void _loadDocument() {
    if (savedContent.isNotEmpty) {
      // Load saved content
      final doc = quill.Document.fromJson(savedContent);
      quillController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      // Initialize with an empty document
      quillController = quill.QuillController.basic();
    }
  }

  void saveDocument() {
    // Save the current document to JSON format
    final json = quillController.document.toDelta().toJson();
    savedContent.assignAll(json); // Update the observable list
    Get.snackbar("Success", "Document saved successfully!");
  }

  void clearDocument() {
    // Clear the editor and saved content
    savedContent.clear();
    quillController = quill.QuillController.basic();
    update(); // Notify UI to rebuild if necessary
  }
}
