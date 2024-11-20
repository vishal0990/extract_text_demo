import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../services/logger_service.dart';

class FileTextExtractorController extends GetxController {
  var extractedText = "Choose a file to extract text".obs;
  var isLoading = false.obs;

  Future<void> pickFile() async {
    LoggerService.talker.info("User initiated file selection");
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      LoggerService.talker.debug("File selected: $filePath");
      processFile(filePath);
    } else {
      LoggerService.talker.warning("No file selected");
    }
  }

  Future<void> processFile(String filePath) async {
    isLoading(true);
    LoggerService.talker.info("Processing file: $filePath");

    try {
      String fileExtension = filePath.split('.').last.toLowerCase();
      String text;
      LoggerService.talker.info("File processed successfully");

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

      // Navigate to the Quill Editor Page with extracted text
      Get.toNamed('/quillEditor', arguments: text);
    } catch (e, st) {
      Get.snackbar("Error", e.toString());
      LoggerService.talker.error("Error processing file", e, st);
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
