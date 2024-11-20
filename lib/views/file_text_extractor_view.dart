import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/file_text_extractor_controller.dart';
import 'logger_page.dart';

class FileTextExtractorView extends StatelessWidget {
  final controller = Get.put(FileTextExtractorController());

  @override
  Widget build(BuildContext context) {
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
            ElevatedButton(
              onPressed: () {
                Get.to(() => LoggerPage());
              },
              child: const Text("View Logs"),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
