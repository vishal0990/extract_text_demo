import 'package:get/get.dart';
import '../controllers/file_text_extractor_controller.dart';
import '../controllers/quill_editor_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FileTextExtractorController());
    Get.lazyPut(() => QuillEditorController());
  }
}
