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

// import 'dart:async';
// import 'dart:io';
// import 'package:ebookapp/core/constants/constant.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player/video_player.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:path_provider/path_provider.dart';

// class WallpaperMusicController extends GetxController {
//   // Observable untuk status dan pilihan
//   final selectedWallpaper = RxString('');
//   final selectedMusic = RxString('');

//   // Status kontrol
//   final wallpaperStatus = Rx<WallpaperStatus>(WallpaperStatus.idle);
//   final musicStatus = Rx<WallpaperStatus>(WallpaperStatus.idle);

//   // Video dan Audio Controllers
//   final videoControllers = <String, VideoPlayerController>{}.obs;
//   final audioPlayer = AudioPlayer();

//   // Volume kontrol
//   final audioVolume = RxDouble(0.5);
//   final errorMessage = RxString('');

//   @override
//   void onInit() {
//     super.onInit();
//     loadSelections(); // Pastikan untuk memuat pilihan saat inisialisasi
//     _initializeServices();
//   }

//   void saveSelections() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selectedWallpaper', selectedWallpaper.value);
//     await prefs.setString('selectedMusic', selectedMusic.value);

//     // Debug: Print setelah berhasil menyimpan
//     debugPrint('Selected Wallpaper: ${selectedWallpaper.value}');
//     debugPrint('Selected Music: ${selectedMusic.value}');
//   }

//   void loadSelections() async {
//     final prefs = await SharedPreferences.getInstance();
//     selectedWallpaper.value = prefs.getString('selectedWallpaper') ?? '';
//     selectedMusic.value = prefs.getString('selectedMusic') ?? '';

//     // Debug: Print setelah memuat pilihan
//     debugPrint('Loaded Wallpaper: ${selectedWallpaper.value}');
//     debugPrint('Loaded Music: ${selectedMusic.value}');
//   }

//   Future<void> _initializeServices() async {
//     try {
//       // Inisialisasi Audio Player
//       audioPlayer.onPlayerStateChanged.listen(_handleAudioStateChange);
//       // Inisialisasi video dan image controllers
//       await _initializeWallpapers();
//     } catch (e) {
//       _handleInitializationError(e);
//     }
//   }

//   Future<void> _initializeWallpapers() async {
//     try {
//       wallpaperStatus.value = WallpaperStatus.loading;
//       errorMessage.value = '';

//       // Pisahkan video dan image wallpapers
//       final videoList =
//           AssetPaths.wallpapers.where((w) => w.endsWith('.mp4')).toList();

//       final imageList = AssetPaths.wallpapers
//           .where((w) => w.endsWith('.jpg') || w.endsWith('.png'))
//           .toList();

//       // Inisialisasi video wallpapers
//       for (var videoPath in videoList) {
//         await _validateAndInitializeVideo(videoPath);
//       }

//       wallpaperStatus.value = WallpaperStatus.loaded;
//     } catch (e) {
//       wallpaperStatus.value = WallpaperStatus.error;
//       _handleInitializationError(e);
//     }
//   }

//   Future<void> _validateAndInitializeVideo(String videoPath) async {
//     try {
//       debugPrint('Mencoba memuat video: $videoPath');

//       final byteData = await rootBundle.load(videoPath);
//       if (byteData.lengthInBytes == 0) {
//         debugPrint('Video asset kosong: $videoPath');
//         return;
//       }

//       // Buat file sementara dari asset
//       final file = await _saveTemporaryVideo(videoPath, byteData);

//       final controller = VideoPlayerController.file(file);
//       await controller.initialize();
//       controller.setLooping(true);
//       controller.setVolume(0.0);
//       videoControllers[videoPath] = controller;

//       debugPrint('Video berhasil dimuat: $videoPath');
//     } catch (e) {
//       debugPrint('Error inisialisasi video: $videoPath - $e');
//     }
//   }

//   Future<File> _saveTemporaryVideo(String videoPath, ByteData byteData) async {
//     final file = File(
//         '${(await getTemporaryDirectory()).path}/${videoPath.split('/').last}');
//     await file.create(recursive: true);
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//     return file;
//   }

//   void selectWallpaper(String wallpaper) {
//     if (wallpaper.isEmpty || !AssetPaths.wallpapers.contains(wallpaper)) {
//       debugPrint('Wallpaper tidak ditemukan atau path kosong');
//       return;
//     }

//     selectedWallpaper.value = wallpaper;
//     saveSelections(); // Simpan pilihan wallpaper
//     debugPrint(
//         'Dua Wallpaper yang dipilih: ${selectedWallpaper.value}'); // Debug

//     update();
//   }

//   Future<void> selectMusic(String musicTrack) async {
//     try {
//       musicStatus.value = WallpaperStatus.loading;

//       // Validasi keberadaan musik
//       final byteData = await rootBundle.load(musicTrack);
//       if (byteData.lengthInBytes == 0) {
//         debugPrint('Music asset kosong: $musicTrack');
//         return;
//       }

//       // Jika musik yang dipilih sama dengan yang sudah diputar, lakukan pause
//       if (selectedMusic.value == musicTrack) {
//         if (audioPlayer.state == PlayerState.playing) {
//           await audioPlayer.pause();
//         } else {
//           await audioPlayer
//               .play(AssetSource(musicTrack.replaceFirst('assets/', '')));
//         }
//       } else {
//         // Hentikan musik yang sedang diputar
//         await audioPlayer.stop();
//         await audioPlayer.play(
//           AssetSource(musicTrack.replaceFirst('assets/', '')),
//         );
//         selectedMusic.value = musicTrack;
//         saveSelections(); // Simpan pilihan musik
//         debugPrint('Dua musik yang dipilih: ${selectedMusic.value}'); // Debug
//       }

//       musicStatus.value = WallpaperStatus.loaded;
//     } catch (e) {
//       musicStatus.value = WallpaperStatus.error;
//       _handleAudioError(e);
//     }
//   }

//   void _handleAudioStateChange(PlayerState state) {
//     switch (state) {
//       case PlayerState.playing:
//         debugPrint('Audio sedang diputar');
//         break;
//       case PlayerState.stopped:
//         debugPrint('Audio dihentikan');
//         break;
//       default:
//         break;
//     }
//   }

//   void _handleAudioError(dynamic error) {
//     debugPrint('Audio Error: $error');
//     errorMessage.value = 'Gagal memuat musik: ${error.toString()}';
//     musicStatus.value = WallpaperStatus.error;
//   }

//   void _handleInitializationError(dynamic error) {
//     debugPrint('Initialization Error: $error');
//     errorMessage.value = 'Gagal menginisialisasi: ${error.toString()}';
//     wallpaperStatus.value = WallpaperStatus.error;
//   }

//   void setAudioVolume(double volume) {
//     audioVolume.value = volume;
//     audioPlayer.setVolume(volume);
//   }

//   VideoPlayerController? getVideoController(String videoPath) {
//     final controller = videoControllers[videoPath];
//     return (controller != null && controller.value.isInitialized)
//         ? controller
//         : null;
//   }

//   @override
//   void onClose() {
//     videoControllers.forEach((_, controller) => controller.dispose());
//     audioPlayer.stop();
//     audioPlayer.dispose();
//     super.onClose();
//   }
// }

// // Enum untuk status
// enum WallpaperStatus { idle, loading, error, loaded }


import 'dart:async';  
import 'dart:io';  
import 'package:ebookapp/core/constants/constant.dart';  
import 'package:flutter/foundation.dart';  
import 'package:flutter/services.dart';  
import 'package:get/get.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:video_player/video_player.dart';  
import 'package:audioplayers/audioplayers.dart';  
import 'package:path_provider/path_provider.dart';  

class WallpaperMusicController extends GetxController {  
  // Observable untuk status dan pilihan  
  final selectedWallpaper = RxString('');  
  final selectedMusic = RxString('');  

  // Status kontrol  
  final wallpaperStatus = Rx<WallpaperStatus>(WallpaperStatus.idle);  
  final musicStatus = Rx<WallpaperStatus>(WallpaperStatus.idle);  

  // Video dan Audio Controllers  
  final videoControllers = <String, VideoPlayerController>{}.obs;  
  final audioPlayer = AudioPlayer();  

  // Volume kontrol  
  final audioVolume = RxDouble(0.5);  
  final errorMessage = RxString('');  

  // Getter untuk daftar wallpaper  
  List<String> getAllWallpapers() {  
    return [  
      ...AssetPaths.wallpapers.where((w) =>   
        w.endsWith('.jpg') ||   
        w.endsWith('.png') ||   
        w.endsWith('.gif') ||   
        w.endsWith('.mp4')  
      ).toList(),  
      // Tambahkan wallpaper default  
      'assets/gif/ocean-diver.gif',  
      'assets/gif/mountain-landscape.gif',  
      'assets/gif/space-animation.gif',  
      'assets/videos/Wallpaper01.mp4',  
    ];  
  }  

  // Getter untuk wallpaper default  
  List<String> getDefaultWallpapers() {  
    return [  
      'assets/gif/ocean-diver.gif',  
      'assets/gif/mountain-landscape.gif',  
      'assets/gif/space-animation.gif',  
      'assets/videos/Wallpaper01.mp4',  
    ];  
  }  

  @override  
  void onInit() {  
    super.onInit();  
    loadSelections();   
    _initializeServices();  
  }  

  void saveSelections() async {  
    final prefs = await SharedPreferences.getInstance();  
    await prefs.setString('selectedWallpaper', selectedWallpaper.value);  
    await prefs.setString('selectedMusic', selectedMusic.value);  

    debugPrint('Selected Wallpaper: ${selectedWallpaper.value}');  
    debugPrint('Selected Music: ${selectedMusic.value}');  
  }  

  void loadSelections() async {  
    final prefs = await SharedPreferences.getInstance();  
    selectedWallpaper.value = prefs.getString('selectedWallpaper') ?? '';  
    selectedMusic.value = prefs.getString('selectedMusic') ?? '';  

    debugPrint('Loaded Wallpaper: ${selectedWallpaper.value}');  
    debugPrint('Loaded Music: ${selectedMusic.value}');  
  }  

  Future<void> _initializeServices() async {  
    try {  
      audioPlayer.onPlayerStateChanged.listen(_handleAudioStateChange);  
      await _initializeWallpapers();  
    } catch (e) {  
      _handleInitializationError(e);  
    }  
  }  

  Future<void> _initializeWallpapers() async {  
    try {  
      wallpaperStatus.value = WallpaperStatus.loading;  
      errorMessage.value = '';  

      final videoList = getAllWallpapers().where((w) => w.endsWith('.mp4')).toList();  
      final imageList = getAllWallpapers().where((w) =>   
        w.endsWith('.jpg') || w.endsWith('.png') || w.endsWith('.gif')  
      ).toList();  

      for (var videoPath in videoList) {  
        await _validateAndInitializeVideo(videoPath);  
      }  

      wallpaperStatus.value = WallpaperStatus.loaded;  
    } catch (e) {  
      wallpaperStatus.value = WallpaperStatus.error;  
      _handleInitializationError(e);  
    }  
  }  

  Future<void> _validateAndInitializeVideo(String videoPath) async {  
    try {  
      debugPrint('Mencoba memuat video: $videoPath');  

      final byteData = await rootBundle.load(videoPath);  
      if (byteData.lengthInBytes == 0) {  
        debugPrint('Video asset kosong: $videoPath');  
        return;  
      }  

      final file = await _saveTemporaryVideo(videoPath, byteData);  

      final controller = VideoPlayerController.file(file);  
      await controller.initialize();  
      controller.setLooping(true);  
      controller.setVolume(0.0);  
      videoControllers[videoPath] = controller;  

      debugPrint('Video berhasil dimuat: $videoPath');  
    } catch (e) {  
      debugPrint('Error inisialisasi video: $videoPath - $e');  
    }  
  }  

  Future<File> _saveTemporaryVideo(String videoPath, ByteData byteData) async {  
    final file = File(  
        '${(await getTemporaryDirectory()).path}/${videoPath.split('/').last}');  
    await file.create(recursive: true);  
    await file.writeAsBytes(byteData.buffer.asUint8List());  
    return file;  
  }  

  void selectWallpaper(String wallpaper) {  
    if (wallpaper.isEmpty || !getAllWallpapers().contains(wallpaper)) {  
      debugPrint('Wallpaper tidak ditemukan atau path kosong');  
      return;  
    }  

    selectedWallpaper.value = wallpaper;  
    saveSelections();  
    debugPrint('Wallpaper yang dipilih: ${selectedWallpaper.value}');  

    update();  
  }  

  VideoPlayerController? getVideoController(String videoPath) {  
    final controller = videoControllers[videoPath];  
    return (controller != null && controller.value.isInitialized)  
        ? controller  
        : null;  
  }  

  @override  
  void onClose() {  
    videoControllers.forEach((_, controller) => controller.dispose());  
    audioPlayer.stop();  
    audioPlayer.dispose();  
    super.onClose();  
  }  

  // Metode tambahan untuk manajemen audio (opsional)  
  Future<void> selectMusic(String musicTrack) async {  
    try {  
      musicStatus.value = WallpaperStatus.loading;  

      final byteData = await rootBundle.load(musicTrack);  
      if (byteData.lengthInBytes == 0) {  
        debugPrint('Music asset kosong: $musicTrack');  
        return;  
      }  

      if (selectedMusic.value == musicTrack) {  
        if (audioPlayer.state == PlayerState.playing) {  
          await audioPlayer.pause();  
        } else {  
          await audioPlayer  
              .play(AssetSource(musicTrack.replaceFirst('assets/', '')));  
        }  
      } else {  
        await audioPlayer.stop();  
        await audioPlayer.play(  
          AssetSource(musicTrack.replaceFirst('assets/', '')),  
        );  
        selectedMusic.value = musicTrack;  
        saveSelections();  
        debugPrint('Musik yang dipilih: ${selectedMusic.value}');  
      }  

      musicStatus.value = WallpaperStatus.loaded;  
    } catch (e) {  
      musicStatus.value = WallpaperStatus.error;  
      _handleAudioError(e);  
    }  
  }  

  void setAudioVolume(double volume) {  
    audioVolume.value = volume;  
    audioPlayer.setVolume(volume);  
  }  

  void _handleAudioStateChange(PlayerState state) {  
    switch (state) {  
      case PlayerState.playing:  
        debugPrint('Audio sedang diputar');  
        break;  
      case PlayerState.stopped:  
        debugPrint('Audio dihentikan');  
        break;  
      default:  
        break;  
    }  
  }  

  void _handleAudioError(dynamic error) {  
    debugPrint('Audio Error: $error');  
    errorMessage.value = 'Gagal memuat musik: ${error.toString()}';  
    musicStatus.value = WallpaperStatus.error;  
  }  

  void _handleInitializationError(dynamic error) {  
    debugPrint('Initialization Error: $error');  
    errorMessage.value = 'Gagal menginisialisasi: ${error.toString()}';  
    wallpaperStatus.value = WallpaperStatus.error;  
  }  
}  

// Enum untuk status  
enum WallpaperStatus { idle, loading, error, loaded }  