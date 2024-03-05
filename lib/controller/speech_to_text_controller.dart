import 'package:get/state_manager.dart';

class SpeechToTextController extends GetxController {
// ==================== Variables ==============================================

  late final RxBool _isRecording = false.obs;
  List<LangquageName> languageNames = [];
  String currentLocaleIdBot = 'default';

  @override
  void onInit() {
    super.onInit();
    _isRecording.value = false;
    _initlanguageNames();
  }

// ==================== Getters ================================================
  bool getRecordingStatus() => _isRecording.value;
// ==================== Setters ================================================

// ==================== Uitlilty Functions =====================================
  void _initlanguageNames() {
    languageNames.add(LangquageName('default', 'default'));
    languageNames.add(LangquageName('en_US', 'English'));
    languageNames.add(LangquageName('vi_VN', 'Vietnamese'));
    currentLocaleIdBot = 'default';
  }
}

class RecordStatus {
  static const String finishConverting = 'finishConverting';
  static const String send = 'send';
  static const String recording = 'recording';
  static const String finishRecording = 'finishRecording';
  static const String refresh = 'refresh';
  static const String converting = 'converting';
  static const String none = 'none';
  static const String exit = 'exit';
}

/// A single locale with a [name], localized to the current system locale,
/// and a [localeId] which can be used in the [SpeechToText.listen] method to choose a
/// locale for speech recognition.
class LangquageName {
  final String localeId;
  final String name;

  LangquageName(this.localeId, this.name);
}
