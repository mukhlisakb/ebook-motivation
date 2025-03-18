// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';

// class WallpaperMusicController extends GetxController {
//   // Observable untuk status dan pilihan
//   final selectedWallpaper = ''.obs;
//   final selectedMusic = ''.obs;

//   // Status inisialisasi video
//   final isVideoInitializing = false.obs;

//   // Observable Map untuk video controllers
//   final videoControllers = <String, VideoPlayerController>{}.obs;

//   // Map untuk status inisialisasi video
//   final _videoInitStatus = <String, bool>{};

//   // Dummy data untuk wallpaper dan musik dengan prioritas
//   final List<String> wallpapers = [
//     'assets/videos/Wallpaper01.mp4',
//     'assets/videos/Wallpaper02.mp4',
//     'assets/videos/Wallpaper03.mp4',
//     'assets/videos/Wallpaper04.mp4',
//     'assets/videos/Wallpaper05.mp4',
//     'assets/pictures/Wallpaper_img_01.jpg',
//     'assets/pictures/Wallpaper_img_02.jpg',
//     'assets/pictures/Wallpaper_img_03.jpg',
//     'assets/pictures/Wallpaper_img_04.jpg'
//   ];

//   final List<String> musicTracks = [
//     'assets/music_0.mp3',
//     'assets/music_1.mp3',
//     'assets/music_2.mp3'
//   ];

//   @override
//   void onInit() {
//     super.onInit();
//     // Inisialisasi video controllers secara asinkron
//     _initializeVideoControllersOptimized();
//   }

//   // Inisialisasi video controllers dengan optimasi
//   Future<void> _initializeVideoControllersOptimized() async {
//     // Ambil video yang akan diinisialisasi (maksimal 3)
//     final videosToInitialize = wallpapers
//         .where((w) => w.endsWith('.mp4'))
//         .take(3)
//         .toList();

//     try {
//       isVideoInitializing.value = true;

//       // Gunakan compute untuk menghindari blocking UI thread
//       await compute(_initializeVideosInBackground, videosToInitialize);

//       isVideoInitializing.value = false;
//       update();
//     } catch (e) {
//       print('Error initializing videos: $e');
//       isVideoInitializing.value = false;
//     }
//   }

//   // Fungsi statis untuk inisialisasi video di background
//   static Future<Map<String, VideoPlayerController>> _initializeVideosInBackground(List<String> videoPaths) async {
//     final controllers = <String, VideoPlayerController>{};

//     for (var videoPath in videoPaths) {
//       final controller = VideoPlayerController.asset(videoPath);

//       try {
//         await controller.initialize();
//         controller.setLooping(true);
//         controller.setVolume(0.0); // Matikan suara default

//         controllers[videoPath] = controller;
//       } catch (e) {
//         print('Failed to initialize video: $videoPath - $e');
//       }
//     }

//     return controllers;
//   }

//   // Metode untuk mendapatkan video controller
//   VideoPlayerController? getVideoController(String videoPath) {
//     return videoControllers[videoPath];
//   }

//   // Metode untuk memilih wallpaper dengan validasi
//   void selectWallpaper(String wallpaper) {
//     if (wallpapers.contains(wallpaper)) {
//       selectedWallpaper.value = wallpaper;

//       // Jika wallpaper video, pastikan diinisialisasi
//       if (wallpaper.endsWith('.mp4')) {
//         initializeVideoController(wallpaper);
//       }

//       update();
//     }
//   }

//   // Inisialisasi video controller dengan penanganan error
//   Future<void> initializeVideoController(String videoPath) async {
//     if (!videoControllers.containsKey(videoPath)) {
//       try {
//         final controller = VideoPlayerController.asset(videoPath);
//         await controller.initialize();

//         controller.setLooping(true);
//         controller.setVolume(0.0); // Matikan suara default

//         videoControllers[videoPath] = controller;
//         _videoInitStatus[videoPath] = true;

//         update();
//       } catch (e) {
//         print('Error initializing video controller: $e');
//         _videoInitStatus[videoPath] = false;
//       }
//     }
//   }

//   // Metode untuk memilih musik dengan validasi
//   void selectMusic(String music) {
//     if (musicTracks.contains(music)) {
//       selectedMusic.value = music;
//       update();
//     }
//   }

//   // Pembersihan sumber daya
//   @override
//   void onClose() {
//     // Buang semua video controllers dengan penanganan error
//     videoControllers.forEach((path, controller) {
//       try {
//         controller.dispose();
//       } catch (e) {
//         print('Error disposing video controller for $path: $e');
//       }
//     });

//     videoControllers.clear();
//     super.onClose();
//   }

//   // Metode utilitas untuk mendapatkan status inisialisasi video
//   bool isVideoInitialized(String videoPath) {
//     return _videoInitStatus[videoPath] ?? false;
//   }
// }

import 'dart:async';
import 'package:ebookapp/core/constants/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class WallpaperMusicController extends GetxController {
  // Observable untuk status dan pilihan
  final selectedWallpaper = RxString('');
  final selectedMusic = RxString('');

  // Status dan error handling
  final isVideoInitializing = RxBool(false);
  final isAudioLoading = RxBool(false);
  final errorMessage = RxString('');

  // Video dan Audio Controllers
  final videoControllers = <String, VideoPlayerController>{}.obs;
  late AudioPlayer audioPlayer;

  // Volume kontrol
  final audioVolume = RxDouble(0.5);

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Inisialisasi Audio Player
      audioPlayer = AudioPlayer();

      // Setup listener untuk status audio
      audioPlayer.onPlayerStateChanged.listen(_handleAudioStateChange);
      audioPlayer.onPlayerComplete.listen((_) => print('Audio completed'));

      // Inisialisasi video controllers
      await _initializeVideoControllers();
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  Future<void> _initializeVideoControllers() async {
    try {
      isVideoInitializing.value = true;
      errorMessage.value = '';

      // Filter video untuk diinisialisasi
      final videoList =
          AssetPaths.wallpapers.where((w) => w.endsWith('.mp4')).toList();

      // Validasi dan inisialisasi video
      for (var videoPath in videoList) {
        await _validateAndInitializeVideo(videoPath);
      }

      isVideoInitializing.value = false;
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  Future<void> _validateAndInitializeVideo(String videoPath) async {
    try {
      // Validasi keberadaan asset
      await rootBundle.load(videoPath);

      final controller = VideoPlayerController.asset(videoPath);
      await controller.initialize();

      controller.setLooping(true);
      controller.setVolume(0.0);

      // Simpan controller yang valid
      videoControllers[videoPath] = controller;
    } catch (e) {
      print('Video initialization error: $videoPath - $e');
    }
  }

  void selectWallpaper(String wallpaper) {
    if (!AssetPaths.wallpapers.contains(wallpaper)) return;

    // Stop video lain yang sedang berjalan
    videoControllers.forEach((path, controller) {
      if (path != wallpaper && controller.value.isPlaying) {
        controller.pause();
      }
    });

    selectedWallpaper.value = wallpaper;

    if (wallpaper.endsWith('.mp4')) {
      _validateAndInitializeVideo(wallpaper).then((_) {
        final controller = videoControllers[wallpaper];
        controller?.play();
      });
    }

    update();
  }

  Future<void> selectMusic(String musicTrack) async {
    try {
      // Validasi keberadaan musik
      await rootBundle.load(musicTrack);

      isAudioLoading.value = true;
      await audioPlayer.stop();

      // Gunakan AssetSource dengan path yang benar
      await audioPlayer
          .play(AssetSource(musicTrack.replaceFirst('assets/', '')));

      selectedMusic.value = musicTrack;
      isAudioLoading.value = false;
    } catch (e) {
      _handleAudioError(e);
    }
  }

  // Handler untuk status audio
  void _handleAudioStateChange(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        print('Audio sedang diputar');
        break;
      case PlayerState.stopped:
        print('Audio dihentikan');
        break;
      default:
        break;
    }
  }

  // Handler error audio
  void _handleAudioError(dynamic error) {
    print('Audio Error: $error');
    errorMessage.value = 'Gagal memuat musik: ${error.toString()}';
    isAudioLoading.value = false;
  }

  // Handler error inisialisasi
  void _handleInitializationError(dynamic error) {
    print('Initialization Error: $error');
    errorMessage.value = 'Gagal menginisialisasi: ${error.toString()}';
    isVideoInitializing.value = false;
    isAudioLoading.value = false;
  }

  // Kontrol volume audio
  void setAudioVolume(double volume) {
    audioVolume.value = volume;
    audioPlayer.setVolume(volume);
  }

  @override
  void onClose() {
    // Pembersihan sumber daya
    videoControllers.forEach((_, controller) => controller.dispose());
    audioPlayer.stop();
    audioPlayer.dispose();
    super.onClose();
  }

  // Metode utilitas untuk mendapatkan status video
  VideoPlayerController? getVideoController(String videoPath) {
    final controller = videoControllers[videoPath];
    return (controller != null && controller.value.isInitialized)
        ? controller
        : null;
  }
}
