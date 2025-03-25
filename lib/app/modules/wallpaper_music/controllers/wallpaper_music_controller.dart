import 'dart:async';
import 'dart:io';
import 'package:ebookapp/core/constants/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class WallpaperMusicController extends GetxController {
  final PageController pageController = PageController();
  final selectedWallpaper = RxString('');
  final selectedMusic = RxString('');
  final wallpaperStatus = Rx<WallpaperStatus>(WallpaperStatus.idle);
  final musicStatus = Rx<WallpaperStatus>(WallpaperStatus.idle);
  final videoControllers = <String, VideoPlayerController>{}.obs;
  final audioPlayer = AudioPlayer();
  final audioVolume = RxDouble(0.5);
  final errorMessage = RxString('');

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

      final videoList =
          getAllWallpapers().where((w) => w.endsWith('.mp4')).toList();

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
      wallpaperStatus.value = WallpaperStatus.error;
      errorMessage.value = 'Gagal memuat video: ${e.toString()}';
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

    // Preload video di latar belakang
    Future.delayed(Duration.zero, () async {
      await _validateAndInitializeVideo(wallpaper);
    });

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

  // Getter untuk daftar wallpaper
  List<String> getAllWallpapers() {
    return [
      ...AssetPaths.wallpapers
          .where((w) =>
              w.endsWith('.jpg') ||
              w.endsWith('.png') ||
              w.endsWith('.gif') ||
              w.endsWith('.mp4'))
          .toList(),
      'assets/gif/ocean-diver.gif',
      'assets/gif/mountain-landscape.gif',
      'assets/gif/space-animation.gif',
      'assets/videos/Wallpaper01.mp4',
    ];
  }
}

// Enum untuk status
enum WallpaperStatus { idle, loading, error, loaded }

// -------------- untuk menambahkan wallpaper dan musik --------------
