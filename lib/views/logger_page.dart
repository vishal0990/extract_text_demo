import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../services/logger_service.dart';

class LoggerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Logs")),
        body: TalkerScreen(talker: LoggerService.talker));
  }
}
