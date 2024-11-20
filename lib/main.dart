import 'package:extract_text_demo/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/app_bindings.dart';
import 'views/file_text_extractor_view.dart';
import 'views/quill_editor_view.dart';

void main() {
  LoggerService.init();

  runApp(GetMaterialApp(
    initialBinding: AppBindings(),
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => FileTextExtractorView()),
      GetPage(name: '/quillEditor', page: () => QuillEditorView()),
    ],
  ));
}
