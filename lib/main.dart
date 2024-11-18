import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:extract_text_demo/permissionHandler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:html/parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MaterialApp(
    home: FileTextExtractor(),
  ));
}

class FileTextExtractor extends StatefulWidget {
  const FileTextExtractor({Key? key}) : super(key: key);

  @override
  State<FileTextExtractor> createState() => _FileTextExtractorState();
}

class _FileTextExtractorState extends State<FileTextExtractor> {
  String extractedText = "Choose a file to extract text";
  TextEditingController textController = TextEditingController();

  // Pick file from device
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      processFile(filePath);
    }
  }

  // Pick image using camera
  Future<void> captureImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      processFile(image.path);
    }
  }

  // Detect file type and process accordingly
  Future<void> processFile(String filePath) async {
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
        case 'docx':
          text = await extractTextFromExcel(filePath);
          break;
        case 'xlsx':
          text = await extractTextFromExcel(filePath);
          break;
        case 'txt':
          text = await extractTextFromTxt(filePath);
          break;
        case 'json':
          text = await extractTextFromJson(filePath);
          break;
        case 'html':
          text = await extractTextFromHtml(filePath);
          break;
        default:
          text = "Unsupported file type: $fileExtension";
      }

      setState(() {
        extractedText = text;
      });
      textController.text =
          extractedText; // Pre-fill the editor with extracted text
    } catch (e) {
      setState(() {
        extractedText = "Error: $e";
      });
    }
  }

  // Save edited text to a file
  Future<void> saveTextToFile() async {
    // Request permission to write to storage (for Android)
    //PermissionStatus status = await Permission.storage.request();
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/extracted_text_${DateTime.now()}.txt';
    final file = File(filePath);
    await file.writeAsString(textController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File saved at $filePath')),
    );
  }

  // Extract text from PDF
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

  // Extract text from image
  Future<String> extractTextFromImage(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  // Extract text from Excel
  Future<String> extractTextFromExcel(String filePath) async {
    var fileBytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(fileBytes);
    StringBuffer buffer = StringBuffer();

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        buffer.writeln(row.map((cell) => cell?.value).join(", "));
      }
    }
    return buffer.toString();
  }

  // Extract text from TXT
  Future<String> extractTextFromTxt(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }

  // Extract text from JSON
  Future<String> extractTextFromJson(String filePath) async {
    final file = File(filePath);
    final jsonData = json.decode(await file.readAsString());
    return jsonData.toString();
  }

  // Extract text from HTML
  Future<String> extractTextFromHtml(String filePath) async {
    final file = File(filePath);
    final document = parse(await file.readAsString());
    return document.body!.text;
  }

  @override
  Widget build(BuildContext context) {
    storagePermission();
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Text Extractor"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: textController,
                maxLines: null, // Allow multiline text
                decoration: const InputDecoration(
                  hintText: 'Edit extracted text here...',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickFile,
                child: const Text("Choose File"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: captureImage,
                child: const Text("Capture Image"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: saveTextToFile,
                child: const Text("Save Extracted Text"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
