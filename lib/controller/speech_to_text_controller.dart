import 'package:get/state_manager.dart';

class SpeechToTextController extends GetxController {
// ==================== Variables ==============================================

  late final RxBool _isRecording = false.obs;

  @override
  void onInit() {
    super.onInit();
    _isRecording.value = false;
  }

// ==================== Getters ================================================
  bool getRecordingStatus() => _isRecording.value;
// ==================== Setters ================================================

// ==================== Uitlilty Functions =====================================
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
