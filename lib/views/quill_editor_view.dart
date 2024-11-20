import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import '../controllers/quill_editor_controller.dart';

class QuillEditorView extends StatelessWidget {
  final controller = Get.put(QuillEditorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Extracted Text"),
        actions: [
          IconButton(
            onPressed: controller.saveEditedText,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: controller.toggleKeyboard,
            icon: Obx(() => Icon(
              controller.showSystemKeyboard.value
                  ? Icons.keyboard
                  : Icons.keyboard_hide,
            )),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return quill.QuillEditor(
                controller: controller.quillController,
                scrollController: ScrollController(),
                focusNode: controller.showSystemKeyboard.value
                    ? controller.androidFocusNode
                    : controller.disabledFocusNode,

              );
            }),
          ),
          quill.QuillToolbar.simple(controller: controller.quillController),
        ],
      ),
    );
  }
}
