
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveWallpaperController extends GetxController {
  // Visibilitas wallpaper
  final RxBool _isWallpaperVisible = true.obs;
  
  // Opacity wallpaper
  final RxDouble _wallpaperOpacity = 0.5.obs;
  
  // Daftar wallpaper (default)
  final RxList<String> _wallpaperList = [
    'assets/gif/ocean-diver.gif',
    'assets/gif/mountain-landscape.gif',
    'assets/gif/space-animation.gif',
  ].obs;

  // Index wallpaper saat ini
  final RxInt _currentWallpaperIndex = 0.obs;

  // Getter untuk visibilitas wallpaper
  bool get isWallpaperVisible => _isWallpaperVisible.value;
  
  // Getter untuk opacity wallpaper
  double get wallpaperOpacity => _wallpaperOpacity.value;
  
  // Getter untuk wallpaper saat ini
  String get currentWallpaper => _wallpaperList[_currentWallpaperIndex.value];

  // Toggle visibilitas wallpaper
  void toggleWallpaperVisibility() {
    _isWallpaperVisible.value = !_isWallpaperVisible.value;
  }

  // Set opacity wallpaper
  void setWallpaperOpacity(double opacity) {
    _wallpaperOpacity.value = opacity.clamp(0.0, 1.0);
  }

  // Ganti ke wallpaper selanjutnya
  void nextWallpaper() {
    _currentWallpaperIndex.value = 
      (_currentWallpaperIndex.value + 1) % _wallpaperList.length;
  }

  // Tambah wallpaper baru ke daftar
  void addWallpaper(String wallpaperPath) {
    if (!_wallpaperList.contains(wallpaperPath)) {
      _wallpaperList.add(wallpaperPath);
    }
  }

  // Hapus wallpaper dari daftar
  void removeWallpaper(String wallpaperPath) {
    _wallpaperList.remove(wallpaperPath);
    
    // Sesuaikan index jika wallpaper yang dihapus adalah wallpaper saat ini
    if (_currentWallpaperIndex.value >= _wallpaperList.length) {
      _currentWallpaperIndex.value = _wallpaperList.length - 1;
    }
  }

  // Reset ke wallpaper default
  void resetToDefaultWallpapers() {
    _wallpaperList.value = [
      'assets/gif/ocean-diver.gif',
      'assets/gif/mountain-landscape.gif',
      'assets/gif/space-animation.gif',
    ];
    _currentWallpaperIndex.value = 0;
  }
}
