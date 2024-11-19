import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
  bool isLoading = false;

  // Pick file from device
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      processFile(filePath);
    }
  }

  // Process the file and extract text
  Future<void> processFile(String filePath) async {
    setState(() {
      isLoading = true;
    });

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

      // Navigate to the full-page editor with Quill
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuillEditorPage(initialText: text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  // Extract text from Image
  Future<String> extractTextFromImage(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  // Extract text from Txt
  Future<String> extractTextFromTxt(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Text Extractor"),
      ),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: pickFile,
              child: const Text("Choose File"),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// Quill Editor Page
class QuillEditorPage extends StatefulWidget {
  final String initialText;

  const QuillEditorPage({Key? key, required this.initialText})
      : super(key: key);

  @override
  State<QuillEditorPage> createState() => _QuillEditorPageState();
}

class _QuillEditorPageState extends State<QuillEditorPage> {
  late quill.QuillController _controller;
  bool showAndroidKeyboard = true;
  final FocusNode _androidFocusNode = FocusNode();
  final FocusNode _customFocusNode = AlwaysDisabledFocusNode();

  @override
  void dispose() {
    _androidFocusNode.dispose();
    _customFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize QuillController with the extracted text
    final doc = quill.Document();
    doc.insert(0, widget.initialText);
    _controller = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> saveEditedText() async {
    final directory = await getExternalStorageDirectory();
    final filePath =
        '${directory!.path}/edited_text_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(filePath);

    final plainText = _controller.document.toPlainText();
    await file.writeAsString(plainText);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File saved at $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Extracted Text"),
        actions: [
          IconButton(
            onPressed: saveEditedText,
            icon: const Icon(Icons.save),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  showAndroidKeyboard = !showAndroidKeyboard;

                  if (!showAndroidKeyboard) {
                    FocusScope.of(context).unfocus(); // Hides the keyboard
                  }
                });
              },
              icon: Icon(showAndroidKeyboard
                  ? Icons.keyboard_alt
                  : Icons.keyboard_alt_outlined))
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
            child: quill.QuillEditor(
              controller: _controller,
              scrollController: ScrollController(),
              focusNode:
                  showAndroidKeyboard ? _androidFocusNode : _customFocusNode,
              // padding: const EdgeInsets.all(8.0),
            ),
          ),
        ),
      ),
      bottomNavigationBar: quill.QuillToolbar.simple(controller: _controller),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false; // Prevents the keyboard from opening
}
