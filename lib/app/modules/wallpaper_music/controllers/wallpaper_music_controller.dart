
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ebookapp/core/constants/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';


// Enum untuk status media
enum MediaStatus {
  idle,
  loading,
  error,
  loaded,
  partialLoaded
}

class WallpaperMusicController extends GetxController {
  // Audio player
  final AudioPlayer audioPlayer = AudioPlayer();

  // Kontroler untuk navigasi halaman
  final PageController pageController = PageController();

  // Reactive variables untuk wallpaper dan musik
  final selectedWallpaper = RxString('');
  final selectedMusic = RxString('');
  final wallpaperStatus = Rx<MediaStatus>(MediaStatus.idle);
  final musicStatus = Rx<MediaStatus>(MediaStatus.idle);
  
  // Kontrol video
  final videoControllers = <String, VideoPlayerController>{}.obs;
  final videoThumbnails = <String, Uint8List>{}.obs;
  final videoLoadingStatus = <String, bool>{}.obs;

  // Kontrol audio
  final audioVolume = RxDouble(0.5);
  final errorMessage = RxString('');

  // State audio
  final isAudioPlaying = RxBool(false);

  // Daftar wallpaper dan musik dari konstanta
  List<String> get wallpapers => AssetPaths.wallpapers;
  List<String> get musicTracks => AssetPaths.musicTracks;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _setupAudioListeners();
  }

  @override
  void onClose() {
    // Pembersihan sumber daya
    pageController.dispose();
    videoControllers.forEach((_, controller) => controller.dispose());
    audioPlayer.stop();
    audioPlayer.dispose();
    super.onClose();
  }

  // Inisialisasi layanan dengan penanganan error yang lebih baik
  Future<void> _initializeServices() async {
    try {
      wallpaperStatus.value = MediaStatus.loading;
      musicStatus.value = MediaStatus.loading;

      await Future.wait([
        _loadSavedSelections(),
        _processVideoWallpapers(),
        _initializeMusicTracks()
      ], eagerError: false).then((_) {
        // Cek apakah ada video yang berhasil dimuat
        if (videoThumbnails.isNotEmpty) {
          wallpaperStatus.value = MediaStatus.loaded;
        } else {
          wallpaperStatus.value = MediaStatus.error;
        }
        musicStatus.value = MediaStatus.loaded;
      }).catchError((error) {
        debugPrint('Initialization partial error: $error');
        wallpaperStatus.value = MediaStatus.error;
        musicStatus.value = MediaStatus.error;
        errorMessage.value = error.toString();
      });
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  // Proses video wallpaper dengan generate thumbnail
  Future<void> _processVideoWallpapers() async {
    final videoList = wallpapers.where((w) => w.endsWith('.mp4')).toList();
    final tempDir = await getTemporaryDirectory();

    for (var videoPath in videoList) {
      try {
        // Load video dari assets
        final byteData = await rootBundle.load(videoPath);
        final originalFile = File('${tempDir.path}/${videoPath.split('/').last}');
        await originalFile.writeAsBytes(byteData.buffer.asUint8List());

        // Inisialisasi video controller
        final videoController = VideoPlayerController.file(originalFile);
        await videoController.initialize();
        
        // Ambil screenshot pertama
        final thumbnailBytes = await _captureVideoScreenshot(originalFile.path);
        
        if (thumbnailBytes != null) {
          videoThumbnails[videoPath] = thumbnailBytes;
          videoControllers[videoPath] = videoController;
          videoController.setVolume(0);

          debugPrint('Thumbnail berhasil dibuat: $videoPath');
        } else {
          debugPrint('Gagal membuat thumbnail: $videoPath');
        }
      } catch (e) {
        debugPrint('Error memproses video $videoPath: $e');
      }
    }
  }

  // Metode untuk mengambil screenshot video
  Future<Uint8List?> _captureVideoScreenshot(String videoPath) async {
    try {
      // Gunakan platform channel untuk mengambil screenshot
      const platform = MethodChannel('video_thumbnail_channel');
      
      final result = await platform.invokeMethod('getVideoThumbnail', {
        'videoPath': videoPath,
        'maxWidth': 400,
        'maxHeight': 400,
        'quality': 75
      });

      // Konversi result ke Uint8List jika berhasil
      return result is Uint8List ? result : null;
    } catch (e) {
      debugPrint('Gagal mengambil screenshot: $e');
      return null;
    }
  }

  // Setup listener untuk status audio
  void _setupAudioListeners() {
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      switch (state) {
        case PlayerState.playing:
          isAudioPlaying.value = true;
          break;
        case PlayerState.paused:
        case PlayerState.stopped:
          isAudioPlaying.value = false;
          break;
        default:
          break;
      }
    });
  }

  // Pilih wallpaper (play video)
  Future<void> selectWallpaper(String wallpaper) async {
    try {
      // Stop semua video yang sedang berjalan
      videoControllers.forEach((key, controller) {
        if (key != wallpaper) {
          controller.pause();
        }
      });

      // Jika wallpaper adalah video
      if (wallpaper.endsWith('.mp4')) {
        final controller = videoControllers[wallpaper];
        if (controller != null) {
          // Toggle play/pause
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        }
      }

      selectedWallpaper.value = wallpaper;
      await _saveSelections();
      update();
    } catch (e) {
      debugPrint('Error memilih wallpaper: $e');
    }
  }

  // Pilih musik
  Future<void> selectMusic(String musicTrack) async {
    try {
      // Jika musik yang sama diklik
      if (selectedMusic.value == musicTrack) {
        // Toggle playback
        if (audioPlayer.state == PlayerState.playing) {
          await audioPlayer.pause();
        } else {
          await audioPlayer.play(
            AssetSource(musicTrack.replaceFirst('assets/', '')),
          );
        }
      } else {
        // Mainkan musik baru
        await audioPlayer.stop();
        await audioPlayer.play(
          AssetSource(musicTrack.replaceFirst('assets/', '')),
        );
      }

      // Update state musik
      selectedMusic.value = musicTrack;
      await _saveSelections();
    } catch (e) {
      musicStatus.value = MediaStatus.error;
      errorMessage.value = 'Gagal memuat musik: ${e.toString()}';
    }
  }

  // Metode untuk mendapatkan thumbnail video
  Uint8List? getVideoThumbnail(String videoPath) {
    return videoThumbnails[videoPath];
  }

  // Metode untuk mendapatkan kontroler video
  VideoPlayerController? getVideoController(String videoPath) {
    return videoControllers[videoPath];
  }

  // Muat pilihan tersimpan
  Future<void> _loadSavedSelections() async {
    final prefs = await SharedPreferences.getInstance();
    selectedWallpaper.value = prefs.getString('selectedWallpaper') ?? '';
    selectedMusic.value = prefs.getString('selectedMusic') ?? '';
  }

  // Simpan pilihan
  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedWallpaper', selectedWallpaper.value);
    await prefs.setString('selectedMusic', selectedMusic.value);
  }

  // Inisialisasi trek musik
  Future<void> _initializeMusicTracks() async {
    try {
      await Future.wait(
        musicTracks.map((track) async {
          try {
            await rootBundle.load(track);
          } catch (e) {
            debugPrint('Gagal memuat musik: $track');
          }
        })
      );
    } catch (e) {
      musicStatus.value = MediaStatus.error;
      errorMessage.value = 'Gagal memuat musik: ${e.toString()}';
    }
  }

  // Kontrol volume audio
  void setAudioVolume(double volume) {
    audioVolume.value = volume;
    audioPlayer.setVolume(volume);
  }

  // Hentikan musik
  Future<void> stopMusic() async {
    await audioPlayer.stop();
    isAudioPlaying.value = false;
  }

  // Stop semua video
  void stopAllVideos() {
    videoControllers.forEach((_, controller) {
      controller.pause();
    });
  }

  // Penanganan error inisialisasi
  void _handleInitializationError(dynamic error) {
    debugPrint('Initialization Error: $error');
    wallpaperStatus.value = MediaStatus.error;
    musicStatus.value = MediaStatus.error;
    errorMessage.value = 'Gagal menginisialisasi: ${error.toString()}';
  }

  // Method utilitas status
  bool get isWallpaperLoading => wallpaperStatus.value == MediaStatus.loading;
  bool get isWallpaperError => wallpaperStatus.value == MediaStatus.error;
  bool get isMusicLoading => musicStatus.value == MediaStatus.loading;
  bool get isMusicError => musicStatus.value == MediaStatus.error;

  // Pengecekan seleksi
  bool isWallpaperSelected(String wallpaper) {
    return selectedWallpaper.value == wallpaper;
  }

  bool isMusicSelected(String musicTrack) {
    return selectedMusic.value == musicTrack;
  }
}
