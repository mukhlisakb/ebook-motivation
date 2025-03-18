import 'dart:async';  
import 'package:flutter/foundation.dart';  
import 'package:get/get.dart';  
import 'package:video_player/video_player.dart';  

class WallpaperMusicController extends GetxController {  
  // Observable untuk status dan pilihan  
  final selectedWallpaper = ''.obs;  
  final selectedMusic = ''.obs;  
  
  // Status inisialisasi video  
  final isVideoInitializing = false.obs;  
  
  // Observable Map untuk video controllers  
  final videoControllers = <String, VideoPlayerController>{}.obs;  
  
  // Map untuk status inisialisasi video  
  final _videoInitStatus = <String, bool>{};  

  // Dummy data untuk wallpaper dan musik dengan prioritas  
  final List<String> wallpapers = [  
    'assets/videos/Wallpaper01.mp4',  
    'assets/videos/Wallpaper02.mp4',  
    'assets/videos/Wallpaper03.mp4',  
    'assets/videos/Wallpaper04.mp4',  
    'assets/videos/Wallpaper05.mp4',  
    'assets/pictures/Wallpaper_img_01.jpg',  
    'assets/pictures/Wallpaper_img_02.jpg',  
    'assets/pictures/Wallpaper_img_03.jpg',  
    'assets/pictures/Wallpaper_img_04.jpg'  
  ];  

  final List<String> musicTracks = [  
    'assets/music_0.mp3',  
    'assets/music_1.mp3',  
    'assets/music_2.mp3'  
  ];  

  @override  
  void onInit() {  
    super.onInit();  
    // Inisialisasi video controllers secara asinkron  
    _initializeVideoControllersOptimized();  
  }  

  // Inisialisasi video controllers dengan optimasi  
  Future<void> _initializeVideoControllersOptimized() async {  
    // Ambil video yang akan diinisialisasi (maksimal 3)  
    final videosToInitialize = wallpapers  
        .where((w) => w.endsWith('.mp4'))  
        .take(3)  
        .toList();  

    try {  
      isVideoInitializing.value = true;  
      
      // Gunakan compute untuk menghindari blocking UI thread  
      await compute(_initializeVideosInBackground, videosToInitialize);  
      
      isVideoInitializing.value = false;  
      update();  
    } catch (e) {  
      print('Error initializing videos: $e');  
      isVideoInitializing.value = false;  
    }  
  }  

  // Fungsi statis untuk inisialisasi video di background  
  static Future<Map<String, VideoPlayerController>> _initializeVideosInBackground(List<String> videoPaths) async {  
    final controllers = <String, VideoPlayerController>{};  
    
    for (var videoPath in videoPaths) {  
      final controller = VideoPlayerController.asset(videoPath);  
      
      try {  
        await controller.initialize();  
        controller.setLooping(true);  
        controller.setVolume(0.0); // Matikan suara default  
        
        controllers[videoPath] = controller;  
      } catch (e) {  
        print('Failed to initialize video: $videoPath - $e');  
      }  
    }  
    
    return controllers;  
  }  

  // Metode untuk mendapatkan video controller  
  VideoPlayerController? getVideoController(String videoPath) {  
    return videoControllers[videoPath];  
  }  

  // Metode untuk memilih wallpaper dengan validasi  
  void selectWallpaper(String wallpaper) {  
    if (wallpapers.contains(wallpaper)) {  
      selectedWallpaper.value = wallpaper;  
      
      // Jika wallpaper video, pastikan diinisialisasi  
      if (wallpaper.endsWith('.mp4')) {  
        initializeVideoController(wallpaper);  
      }  
      
      update();  
    }  
  }  

  // Inisialisasi video controller dengan penanganan error  
  Future<void> initializeVideoController(String videoPath) async {  
    if (!videoControllers.containsKey(videoPath)) {  
      try {  
        final controller = VideoPlayerController.asset(videoPath);  
        await controller.initialize();  
        
        controller.setLooping(true);  
        controller.setVolume(0.0); // Matikan suara default  
        
        videoControllers[videoPath] = controller;  
        _videoInitStatus[videoPath] = true;  
        
        update();  
      } catch (e) {  
        print('Error initializing video controller: $e');  
        _videoInitStatus[videoPath] = false;  
      }  
    }  
  }  

  // Metode untuk memilih musik dengan validasi  
  void selectMusic(String music) {  
    if (musicTracks.contains(music)) {  
      selectedMusic.value = music;  
      update();  
    }  
  }  

  // Pembersihan sumber daya  
  @override  
  void onClose() {  
    // Buang semua video controllers dengan penanganan error  
    videoControllers.forEach((path, controller) {  
      try {  
        controller.dispose();  
      } catch (e) {  
        print('Error disposing video controller for $path: $e');  
      }  
    });  
    
    videoControllers.clear();  
    super.onClose();  
  }  

  // Metode utilitas untuk mendapatkan status inisialisasi video  
  bool isVideoInitialized(String videoPath) {  
    return _videoInitStatus[videoPath] ?? false;  
  }  
}  