import 'dart:io';

import 'package:chat_bot/logger_custom.dart';
import 'package:chat_bot/models/voice_to_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:get/state_manager.dart';

class VoiceBotController extends GetxController {
// ==================== Variables ==============================================

  final TextEditingController messageController = TextEditingController();
  final FlutterSoundRecorder soundRecorder = FlutterSoundRecorder();
  late bool _isRecording = false;
  String voiceFilePath = '';

  @override
  void onInit() {
    super.onInit();
    _isRecording = false;
    voiceFilePath = '';
  }

// ==================== Getters ================================================
  bool getRecordingStatus() => _isRecording;
// ==================== Setters ================================================

// ==================== Uitlilty Functions =====================================
  Future<void> startRecording() async {
    voiceFilePath = '';
    if (_isRecording == false) {
      voiceFilePath = await VoiceToText.startRecording();
      if (voiceFilePath.isNotEmpty) {
        _isRecording = true;
      }
    }
  }

  Future<void> stopRecordingAndSaveFile() async {
    if (_isRecording == true) {
      // update file voice path when stop recorder
      voiceFilePath = await VoiceToText.stopRecording(voiceFilePath);
      if (voiceFilePath.isNotEmpty) {
        _isRecording = false;
      }
    }
  }

  Future<String?> convertVoiceToText() async {
    String textContent = '';
    if (voiceFilePath.isNotEmpty) {
      textContent = await VoiceToText.processVoiceToText(voiceFilePath);
      // Delete file audio and reset file path
      await deleteFile(voiceFilePath);
      voiceFilePath = '';
    }

    return textContent;
  }

  Future<void> deleteFile(String filePath) async {
    try {
      // Create a File instance
      File file = File(filePath);
      // Check if the file exists
      bool exists = await file.exists();
      if (exists) {
        // Delete the file
        await file.delete();
      }
    } catch (e) {
      CustomLogger().error('Error occurred while deleting the file: $e');
    }
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
