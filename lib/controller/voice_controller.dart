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
      if (await VoiceToText.startRecording()) {
        _isRecording = true;
      }
    }
  }

  Future<String?> stopRecordingAndSaveFile() async {
    if (_isRecording == true) {
      voiceFilePath = await VoiceToText.stopRecording();
      if (voiceFilePath.isNotEmpty) {
        _isRecording = false;
      }
      return voiceFilePath;
    }
    return null;
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
}
