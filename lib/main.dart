import 'dart:io';

import 'package:extract_text_demo/permissionHandler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const GetMaterialApp(
    home: FileTextExtractor(),
  ));
}

class FileTextExtractorController extends GetxController {
  var extractedText = "Choose a file to extract text".obs;
  var isLoading = false.obs;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      processFile(filePath);
    }
  }

  Future<void> processFile(String filePath) async {
    isLoading(true);

    try {
      String fileExtension = filePath.split('.').last.toLowerCase();
      String text;

      switch (fileExtension) {
        case 'pdf':
          text = await extractTextWithSyncfusion(filePath);
          break;
        case 'jpg':
        case 'jpeg':
        case 'png':
          text = await extractTextFromImage(filePath);
          break;
        case 'txt':
          text = await extractTextFromTxt(filePath);
          break;
        default:
          text = "Unsupported file type: $fileExtension";
      }

      // Navigate to the Quill Editor Page
      Get.to(() => QuillEditorPage(), arguments: text);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<String> extractTextWithSyncfusion(String filePath) async {
    final fileBytes = await File(filePath).readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: fileBytes);
    final PdfTextExtractor textExtractor = PdfTextExtractor(document);
    String extractedText = '';

    for (int i = 0; i < document.pages.count; i++) {
      extractedText +=
          textExtractor.extractText(startPageIndex: i, endPageIndex: i) ?? '';
    }

    document.dispose();
    return extractedText;
  }

  Future<String> extractTextFromImage(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  Future<String> extractTextFromTxt(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }
}

class FileTextExtractor extends StatelessWidget {
  const FileTextExtractor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FileTextExtractorController());
    storagePermission();
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Text Extractor"),
      ),
      body: Obx(
        () => Stack(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: controller.pickFile,
                child: const Text("Choose File"),
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QuillEditorController extends GetxController {
  late quill.QuillController quillController;
  var showAndroidKeyboard = true.obs;

  final FocusNode androidFocusNode = FocusNode();
  final FocusNode customFocusNode = AlwaysDisabledFocusNode();

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

  Future<void> saveEditedText() async {
    final directory = await getExternalStorageDirectory();
    final filePath =
        '${directory!.path}/edited_text_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(filePath);

    final plainText = quillController.document.toPlainText();
    await file.writeAsString(plainText);

    Get.snackbar("Success", "File saved at $filePath");
  }

  @override
  void onClose() {
    androidFocusNode.dispose();
    customFocusNode.dispose();
    super.onClose();
  }
}

class QuillEditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuillEditorController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Extracted Text"),
        actions: [
          IconButton(
            onPressed: controller.saveEditedText,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              controller.showAndroidKeyboard.toggle();

              if (!controller.showAndroidKeyboard.value) {
                FocusScope.of(context).unfocus();
              }
            },
            icon: Obx(() => Icon(controller.showAndroidKeyboard.value
                ? Icons.keyboard_alt
                : Icons.keyboard_alt_outlined)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6, // Restrict height
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Obx(() => quill.QuillEditor(
                  controller: controller.quillController,
                  scrollController: ScrollController(),
                  focusNode: controller.showAndroidKeyboard.value
                      ? controller.androidFocusNode
                      : controller.customFocusNode,
                )),
          ),
        ),
      ),
      bottomNavigationBar:
          quill.QuillToolbar.simple(controller: controller.quillController),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
