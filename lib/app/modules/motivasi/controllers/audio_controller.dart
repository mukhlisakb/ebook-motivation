import 'dart:async';  
import 'dart:io';  
import 'package:flutter/services.dart' show rootBundle;  
import 'package:path_provider/path_provider.dart';  
import 'package:audioplayers/audioplayers.dart';  
import 'package:flutter/material.dart';  
import 'package:get/get.dart';  

class AudioController extends GetxController {  
  // Audio Player  
  late AudioPlayer _audioPlayer;  

  // Observable states  
  final RxBool isPlaying = false.obs;  
  final RxString currentTrack = ''.obs;  

  // Daftar track audio  
  final List<String> audioTracks = [  
    'avenged.mp3',  
    // Tambahkan daftar track lainnya  
  ];  

  // Audio source path  
  final String initialAudioSourcePath;  

  AudioController({  
    required this.initialAudioSourcePath,   
    List<String>? audioTracks  
  }) {  
    if (audioTracks != null) {  
      this.audioTracks.addAll(audioTracks);  
    }  
  }  

  @override  
  void onInit() {  
    super.onInit();  
    _initializeAudioPlayer();  
  }  

  Future<void> _initializeAudioPlayer() async {  
    _audioPlayer = AudioPlayer();  
    
    try {  
      // Set track awal  
      currentTrack.value = initialAudioSourcePath;  

      // Coba load dari path lokal  
      final localPath = await _getLocalAudioPath(initialAudioSourcePath);  
      if (localPath.isNotEmpty) {  
        await _audioPlayer.setSource(DeviceFileSource(localPath));  
      }  

      // Setup listener  
      _setupPlayerListeners();  

      // Putar musik otomatis saat inisialisasi  
      await play();  
    } catch (e) {  
      _handleAudioError(e);  
    }  
  }  

  void _setupPlayerListeners() {  
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {  
      isPlaying.value = state == PlayerState.playing;  
    });  

    _audioPlayer.onPlayerComplete.listen((_) {  
      isPlaying.value = false;  
      // Putar track selanjutnya secara otomatis  
      _playNextTrack();  
    });  
  }  

  Future<String> _getLocalAudioPath(String audioFileName) async {  
    try {  
      // Load bytes dari asset  
      final audioBytes = await rootBundle.load('assets/audio/$audioFileName');  
      
      // Simpan ke direktori sementara  
      final tempDir = await getTemporaryDirectory();  
      final tempFile = File('${tempDir.path}/$audioFileName');  
      
      await tempFile.writeAsBytes(  
        audioBytes.buffer.asUint8List(  
          audioBytes.offsetInBytes,   
          audioBytes.lengthInBytes  
        )  
      );  
      
      return tempFile.path;  
    } catch (e) {  
      print('Audio loading error: $e');  
      return '';  
    }  
  }  

  // Ganti track audio  
  Future<void> changeTrack(String newTrack) async {  
    try {  
      // Pause track saat ini  
      await pause();  

      // Set track baru  
      currentTrack.value = newTrack;  

      // Load track baru  
      final localPath = await _getLocalAudioPath(newTrack);  
      if (localPath.isNotEmpty) {  
        await _audioPlayer.setSource(DeviceFileSource(localPath));  
        await play();  
      }  
    } catch (e) {  
      _handleAudioError(e);  
    }  
  }  

  // Putar track selanjutnya secara otomatis  
  void _playNextTrack() {  
    if (audioTracks.isEmpty) return;  

    int currentIndex = audioTracks.indexOf(currentTrack.value);  
    int nextIndex = (currentIndex + 1) % audioTracks.length;  
    
    changeTrack(audioTracks[nextIndex]);  
  }  

  // Toggle play/pause  
  Future<void> togglePlayPause() async {  
    try {  
      if (isPlaying.value) {  
        await pause();  
      } else {  
        await play();  
      }  
    } catch (e) {  
      _handleAudioError(e);  
    }  
  }  

  // Play music  
  Future<void> play() async {  
    try {  
      await _audioPlayer.resume();  
      isPlaying.value = true;  
    } catch (e) {  
      _handleAudioError(e);  
    }  
  }  

  // Pause music  
  Future<void> pause() async {  
    try {  
      await _audioPlayer.pause();  
      isPlaying.value = false;  
    } catch (e) {  
      _handleAudioError(e);  
    }  
  }  

  // Error handling  
  void _handleAudioError(dynamic error) {  
    debugPrint('Audio Error: $error');  
    Get.snackbar(  
      'Audio Error',   
      error.toString(),  
      snackPosition: SnackPosition.BOTTOM,  
      backgroundColor: Colors.red,  
      colorText: Colors.white,  
    );  
  }  

  @override  
  void onClose() {  
    _audioPlayer.dispose();  
    super.onClose();  
  }  
}  