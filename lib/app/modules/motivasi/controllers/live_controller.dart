// import 'package:ebookapp/app/modules/wallpaper_music/controllers/wallpaper_music_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class LiveWallpaperController extends GetxController {
//   final WallpaperMusicController wallpaperMusicController = Get.find<WallpaperMusicController>();

//   // Visibilitas wallpaper
//   final RxBool _isWallpaperVisible = true.obs;

//   // Opacity wallpaper
//   final RxDouble _wallpaperOpacity = 0.5.obs;

//   // Daftar wallpaper default
//   final RxList<String> _defaultWallpapers = [
//     'assets/gif/ocean-diver.gif',
//     'assets/gif/mountain-landscape.gif',
//     'assets/gif/space-animation.gif',
//   ].obs;

//   // Daftar wallpaper kustom
//   final RxList<String> _customWallpapers = <String>[].obs;

//   // Index wallpaper saat ini
//   final RxInt _currentWallpaperIndex = 0.obs;

//   // Getter untuk visibilitas wallpaper
//   bool get isWallpaperVisible => _isWallpaperVisible.value;

//   // Getter untuk opacity wallpaper
//   double get wallpaperOpacity => _wallpaperOpacity.value;

//   // Getter untuk wallpaper saat ini dengan fallback
//   String get currentWallpaper {
//     // Prioritaskan wallpaper yang dipilih dari WallpaperMusicController
//     final selectedWallpaper = wallpaperMusicController.selectedWallpaper.value;

//     if (selectedWallpaper.isNotEmpty) {
//       return selectedWallpaper;
//     }

//     // Jika tidak ada wallpaper yang dipilih, gunakan dari daftar
//     final combinedWallpapers = [..._defaultWallpapers, ..._customWallpapers];

//     if (combinedWallpapers.isEmpty) {
//       return 'assets/gif/ocean-diver.gif'; // Fallback terakhir
//     }

//     return combinedWallpapers[_currentWallpaperIndex.value % combinedWallpapers.length];
//   }

//   // Getter untuk mendapatkan semua wallpaper
//   List<String> get allWallpapers => [..._defaultWallpapers, ..._customWallpapers];

//   @override
//   void onInit() {
//     super.onInit();
//     // Tambahkan listener untuk perubahan wallpaper di WallpaperMusicController
//     ever(wallpaperMusicController.selectedWallpaper, (wallpaper) {
//       if (wallpaper.isNotEmpty) {
//         update(); // Trigger rebuild jika wallpaper berubah
//       }
//     });
//   }

//   // Toggle visibilitas wallpaper
//   void toggleWallpaperVisibility() {
//     _isWallpaperVisible.value = !_isWallpaperVisible.value;
//     update();
//   }

//   // Set opacity wallpaper
//   void setWallpaperOpacity(double opacity) {
//     _wallpaperOpacity.value = opacity.clamp(0.0, 1.0);
//     update();
//   }

//   // Ganti ke wallpaper selanjutnya
//   void nextWallpaper() {
//     final combinedWallpapers = [..._defaultWallpapers, ..._customWallpapers];

//     if (combinedWallpapers.isNotEmpty) {
//       _currentWallpaperIndex.value =
//         (_currentWallpaperIndex.value + 1) % combinedWallpapers.length;

//       // Perbarui wallpaper yang dipilih di WallpaperMusicController
//       wallpaperMusicController.selectWallpaper(currentWallpaper);

//       update();
//     }
//   }

//   // Tambah wallpaper kustom baru
//   void addCustomWallpaper(String wallpaperPath) {
//     if (!_customWallpapers.contains(wallpaperPath)) {
//       _customWallpapers.add(wallpaperPath);
//       update();
//     }
//   }

//   // Hapus wallpaper kustom
//   void removeCustomWallpaper(String wallpaperPath) {
//     _customWallpapers.remove(wallpaperPath);

//     // Sesuaikan index jika wallpaper yang dihapus adalah wallpaper saat ini
//     final combinedWallpapers = [..._defaultWallpapers, ..._customWallpapers];

//     if (_currentWallpaperIndex.value >= combinedWallpapers.length) {
//       _currentWallpaperIndex.value = combinedWallpapers.length - 1;
//     }

//     update();
//   }

//   // Reset ke wallpaper default
//   void resetToDefaultWallpapers() {
//     _customWallpapers.clear();
//     _currentWallpaperIndex.value = 0;

//     // Reset wallpaper yang dipilih di WallpaperMusicController
//     wallpaperMusicController.selectWallpaper(_defaultWallpapers.first);

//     update();
//   }

//   // Metode untuk mendapatkan widget wallpaper
//   Widget renderWallpaper() {
//     if (!isWallpaperVisible) return const SizedBox.shrink();

//     return Opacity(
//       opacity: wallpaperOpacity,
//       child: Image.asset(
//         currentWallpaper,
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//         errorBuilder: (context, error, stackTrace) {
//           // Fallback jika gambar tidak dapat dimuat
//           return Container(
//             color: Colors.black,
//             child: const Center(
//               child: Icon(
//                 Icons.broken_image,
//                 color: Colors.white,
//                 size: 50,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:ebookapp/app/modules/wallpaper_music/controllers/wallpaper_music_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class LiveWallpaperController extends GetxController {
  final WallpaperMusicController wallpaperMusicController =
      Get.find<WallpaperMusicController>();

  // Visibilitas wallpaper
  final RxBool _isWallpaperVisible = true.obs;

  // Opacity wallpaper
  final RxDouble _wallpaperOpacity = 0.5.obs;

  // Daftar wallpaper default
  final RxList<String> _defaultWallpapers = [
    'assets/gif/ocean-diver.gif',
    'assets/gif/mountain-landscape.gif',
    'assets/gif/space-animation.gif',
    'assets/videos/Wallpaper01.mp4', // Pastikan path video benar
  ].obs;

  // Daftar wallpaper kustom
  final RxList<String> _customWallpapers = <String>[].obs;

  // Index wallpaper saat ini
  final RxInt _currentWallpaperIndex = 0.obs;

  // Video controller untuk wallpaper video
  VideoPlayerController? _videoController;

  // Getter untuk visibilitas wallpaper
  bool get isWallpaperVisible => _isWallpaperVisible.value;

  // Getter untuk opacity wallpaper
  double get wallpaperOpacity => _wallpaperOpacity.value;

  // Getter untuk wallpaper saat ini dengan fallback
  String get currentWallpaper {
    final selectedWallpaper = wallpaperMusicController.selectedWallpaper.value;

    if (selectedWallpaper.isNotEmpty) {
      return selectedWallpaper;
    }

    final combinedWallpapers = [..._defaultWallpapers, ..._customWallpapers];
    if (combinedWallpapers.isEmpty) {
      return 'assets/gif/ocean-diver.gif'; // Fallback terakhir
    }

    return combinedWallpapers[
        _currentWallpaperIndex.value % combinedWallpapers.length];
  }

  @override
  void onInit() {
    super.onInit();
    // Tambahkan listener untuk perubahan wallpaper di WallpaperMusicController
    ever(wallpaperMusicController.selectedWallpaper, (wallpaper) {
      _initializeVideoIfNeeded(); // Inisialisasi video hanya jika wallpaper diubah
      update(); // Trigger rebuild jika wallpaper berubah
    });
  }

  // Toggle visibilitas wallpaper
  void toggleWallpaperVisibility() {
    _isWallpaperVisible.value = !_isWallpaperVisible.value;
    update();
  }

  // Set opacity wallpaper
  void setWallpaperOpacity(double opacity) {
    _wallpaperOpacity.value = opacity.clamp(0.0, 1.0);
    update();
  }

  // Ganti ke wallpaper selanjutnya
  void nextWallpaper() {
    final combinedWallpapers = [..._defaultWallpapers, ..._customWallpapers];

    if (combinedWallpapers.isNotEmpty) {
      _currentWallpaperIndex.value =
          (_currentWallpaperIndex.value + 1) % combinedWallpapers.length;

      // Perbarui wallpaper yang dipilih di WallpaperMusicController
      wallpaperMusicController.selectWallpaper(currentWallpaper);

      // Inisialisasi video controller jika perlu
      _initializeVideoIfNeeded();

      update();
    }
  }

  // Inisialisasi video jika wallpaper saat ini adalah video
  void _initializeVideoIfNeeded() {
    // Hapus controller video lama jika ada
    _videoController?.dispose();

    // Cek apakah wallpaper saat ini adalah video
    if (currentWallpaper.toLowerCase().endsWith('.mp4')) {
      _videoController = VideoPlayerController.asset(currentWallpaper);
      _videoController!.initialize().then((_) {
        _videoController!.setLooping(true);
        _videoController!.play();
        update();
      }).catchError((error) {
        debugPrint('Error initializing video player: $error');
      });
    } else {
      _videoController = null; // Reset jika bukan video
    }
  }

  // Metode untuk mendapatkan widget wallpaper
  Widget renderWallpaper() {
    if (!isWallpaperVisible) return const SizedBox.shrink();

    // Jika wallpaper adalah video
    if (currentWallpaper.toLowerCase().endsWith('.mp4')) {
      return Opacity(
        opacity: wallpaperOpacity,
        child: _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            : Container(
                color: Colors.black,
                child: const Center(
                    child: CircularProgressIndicator()), // Menampilkan loading
              ),
      );
    }

    // Untuk gambar biasa
    return Opacity(
      opacity: wallpaperOpacity,
      child: Image.asset(
        currentWallpaper,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 50,
              ),
            ),
          );
        },
      ),
    );
  }

  // Pastikan video controller di-dispose saat controller ditutup
  @override
  void onClose() {
    _videoController?.dispose();
    super.onClose();
  }
}
