import 'dart:async';

import 'package:flutter/services.dart';
import 'classes/session.dart';
import 'package:permission_handler/permission_handler.dart';

class VonageVideoChat {
  static const MethodChannel _channel = const MethodChannel('vonage');

  static const EventChannel _event = const EventChannel('vonage-video-chat-session');
  static const EventChannel _hasStream = const EventChannel('vonage-video-chat-hasStream');

  Stream get sessionStream => _event.receiveBroadcastStream();
  Stream get hasStream => _hasStream.receiveBroadcastStream();

  static Future<SessionResponse> initSession(Session session) async {
    print ('initSession');
    bool havePermissions = await checkPermissions();
    if (havePermissions) {
      try {
        final result = await _channel.invokeMethod('initSession', { "sessionId": session.id, "token": session.token,
          "apiKey": session.apiKey });
        return SessionResponse.fromJson(result);
      } on PlatformException {
        return SessionResponse(false);
      }
    }
    print("permissions not granted");
    return SessionResponse(false);
  }

  static Future<String> endSession() async {
    print ('endSession');
    try {
      return await _channel.invokeMethod('endSession', {});
    } on PlatformException {
      return "error";
    }
  }

  static Future<bool> publishStream(String publisherName) async {
    try {
      final result = await _channel.invokeMethod('publishStream', { "name": publisherName });
      return result["success"] == true;
    } on PlatformException catch (err) {
      print(err);
      return false;
    }
  }

  static Future<String> unpublishStream() async {
    try {
      return await _channel.invokeMethod('unpublishStream', {});
    } on PlatformException {
      return "error";
    }
  }

  static Future<bool> checkPermissions() async {
    bool cameraGranted = await Permission.camera.request().isGranted;
    bool cameraDenied = false;
    if (!cameraGranted) {
      cameraDenied = await Permission.camera.isPermanentlyDenied;
    }
    bool microphoneGranted = await Permission.microphone.request().isGranted;
    bool microphoneDenied = false;
    if (!microphoneGranted) {
      microphoneDenied = await Permission.microphone.isPermanentlyDenied;
    }

    if (cameraDenied || microphoneDenied) {
      openAppSettings();
    }
    if (cameraGranted && microphoneGranted) {
      return true;
    }
    return false;
  }

  static Future<bool> enableMicrophone() async{
    bool result = false;
    try{
      await _channel.invokeMethod('enableMicrophone');
      result = true;
    } catch(err){
      result = false;
    }
    return result;
  }
  static Future<bool> disableMicrophone() async{
    bool result = false;
    try{
      await _channel.invokeMethod('disableMicrophone');
      result = true;
    } catch(err){
      print(err);
    }
    return result;
  }
  static Future<bool> enableCamera() async{
    bool result = false;
    try{
      await _channel.invokeMethod('enableCamera');
      result = true;
    } catch(err){
      print(err);
    }
    return result;
  }
  static Future<bool> disableCamera() async{
    bool result = false;
    try{
      await _channel.invokeMethod('disableCamera');
      result = true;
    } catch(err){
      print(err);
    }
    return result;
  }
  /// Enable and disabled the subscriber audio, if subscriber is connected
  /// ```dart
  /// setSubscriberAudioStatus(true);// enable audio
  /// setSubscriberAudioStatus(false);// disabled audio
  /// ```
  static Future<void> setSubscriberAudioStatus(bool status) async{
    try {
      await _channel.invokeMethod('setSubscriberAudio',{ 'status' : status});
    } catch (err){
      print(err);
    }
  } 
}

