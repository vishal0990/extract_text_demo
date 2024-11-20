import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';

import 'editor_controller.dart';

class EditorPage extends StatelessWidget {
  final EditorController editorController = Get.put(EditorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GetX Quill Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: editorController.saveDocument,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: editorController.clearDocument,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              // Rebuild the editor if the document changes
              return quill.QuillEditor.basic(
                controller: editorController.quillController,
              );
            }),
          ),
          quill.QuillToolbar.simple(
              controller: editorController.quillController),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Saved Document"),
                  content: Obx(() {
                    if (editorController.savedContent.isEmpty) {
                      return const Text("No content saved.");
                    }
                    return Text(editorController.savedContent.toString());
                  }),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Show Saved Data"),
          ),
        ],
      ),
    );
  }
}
