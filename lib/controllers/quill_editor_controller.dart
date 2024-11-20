import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class QuillEditorController extends GetxController {
  late quill.QuillController quillController;
  var showSystemKeyboard = true.obs;

  final FocusNode androidFocusNode = FocusNode();
  final FocusNode disabledFocusNode = AlwaysDisabledFocusNode();

  @override
  void onInit() {
    super.onInit();
    String initialText = Get.arguments ?? '';
    final doc = quill.Document();
    doc.insert(0, initialText);
    quillController = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void toggleKeyboard() {
    showSystemKeyboard.toggle();
    if (!showSystemKeyboard.value) {
      // Disable focus to hide the keyboard
      androidFocusNode.unfocus();
    }
  }

  Future<void> saveEditedText() async {
    try {
      String? filePath;

      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          filePath =
              '${directory.path}/edited_text_${DateTime.now().millisecondsSinceEpoch}.txt';
        } else {
          Get.snackbar('Error', 'Unable to access external storage');
          return;
        }
      } else if (Platform.isIOS || Platform.isWindows) {
        final directory = await getApplicationDocumentsDirectory();
        filePath =
            '${directory.path}/edited_text_${DateTime.now().millisecondsSinceEpoch}.txt';
      } else {
        Get.snackbar('Error', 'Unsupported platform for file saving');
        return;
      }

      if (filePath != null) {
        final file = File(filePath);

        // Fetching the latest plain text content
        final plainText = quillController.document.toPlainText().trim();

        print('Document Content: ${quillController.document.toDelta()}');

        if (plainText.isEmpty) {
          Get.snackbar('Error', 'Cannot save an empty document');
          return;
        }

        await file.writeAsString(plainText);

        Get.snackbar('Success', 'File saved at $filePath');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save file: $e');
    }
  }

  @override
  void onClose() {
    androidFocusNode.dispose();
    disabledFocusNode.dispose();
    super.onClose();
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
