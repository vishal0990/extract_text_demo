import 'package:talker/talker.dart';

class LoggerService {
  static final Talker talker = Talker(
    settings: TalkerSettings(
      useConsoleLogs: true,
      useHistory: true,
      enabled: true,
      timeFormat: TimeFormat.timeAndSeconds
    ),
  );

  static void init() {
    talker.debug("Logger initialized");
  }
}
