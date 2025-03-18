
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


// import 'package:flutter/foundation.dart';  
// import 'package:flutter/material.dart';  
// import 'package:get/get.dart';  

// class LiveWallpaperController extends GetxController   
//     with WidgetsBindingObserver {  
//   // Gunakan ValueNotifier untuk efisiensi memori  
//   final wallpaperVisibility = ValueNotifier<bool>(true);  
//   final wallpaperOpacity = ValueNotifier<double>(0.5);  
//   final currentWallpaperIndex = ValueNotifier<int>(0);  

//   // Gunakan list statis untuk daftar wallpaper default  
//   static const List<String> _defaultWallpapers = [  
//     'assets/gif/ocean-diver.gif',  
//     'assets/gif/mountain-landscape.gif',  
//     'assets/gif/space-animation.gif',  
//   ];  

//   // List wallpaper dengan mekanisme privat  
//   final _wallpaperList = <String>[  
//     ..._defaultWallpapers  
//   ];  

//   // Getter untuk wallpaper saat ini  
//   String get currentWallpaper =>   
//     _wallpaperList[currentWallpaperIndex.value];  

//   @override  
//   void onInit() {  
//     super.onInit();  
//     // Tambahkan observer untuk siklus hidup aplikasi  
//     WidgetsBinding.instance.addObserver(this);  
//   }  

//   // Toggle visibilitas wallpaper dengan validasi  
//   void toggleWallpaperVisibility() {  
//     wallpaperVisibility.value = !wallpaperVisibility.value;  
//   }  

//   // Set opacity wallpaper dengan pembatasan  
//   void setWallpaperOpacity(double opacity) {  
//     wallpaperOpacity.value = opacity.clamp(0.0, 1.0);  
//   }  

//   // Ganti ke wallpaper selanjutnya dengan perlindungan  
//   void nextWallpaper() {  
//     currentWallpaperIndex.value =   
//       (currentWallpaperIndex.value + 1) % _wallpaperList.length;  
//   }  

//   // Tambah wallpaper baru ke daftar dengan validasi  
//   void addWallpaper(String wallpaperPath) {  
//     if (!_wallpaperList.contains(wallpaperPath)) {  
//       _wallpaperList.add(wallpaperPath);  
//     }  
//   }  

//   // Hapus wallpaper dari daftar dengan manajemen index  
//   void removeWallpaper(String wallpaperPath) {  
//     _wallpaperList.remove(wallpaperPath);  
    
//     // Sesuaikan index jika wallpaper yang dihapus adalah wallpaper saat ini  
//     if (currentWallpaperIndex.value >= _wallpaperList.length) {  
//       currentWallpaperIndex.value = _wallpaperList.length - 1;  
//     }  
//   }  

//   // Reset ke wallpaper default  
//   void resetToDefaultWallpapers() {  
//     _wallpaperList.clear();  
//     _wallpaperList.addAll(_defaultWallpapers);  
//     currentWallpaperIndex.value = 0;  
//   }  

//   // Metode untuk menangani perubahan siklus hidup aplikasi  
//   @override  
//   void didChangeAppLifecycleState(AppLifecycleState state) {  
//     switch (state) {  
//       case AppLifecycleState.paused:  
//         // Contoh: Simpan state saat aplikasi di-background  
//         _saveWallpaperState();  
//         break;  
//       case AppLifecycleState.resumed:  
//         // Contoh: Muat ulang state saat kembali ke aplikasi  
//         _restoreWallpaperState();  
//         break;  
//       default:  
//         break;  
//     }  
//   }  

//   // Metode untuk menyimpan state wallpaper (opsional)  
//   void _saveWallpaperState() {  
//     // Implementasi penyimpanan state, misalnya ke SharedPreferences  
//     try {  
//       // Contoh:  
//       // final prefs = await SharedPreferences.getInstance();  
//       // prefs.setInt('currentWallpaperIndex', currentWallpaperIndex.value);  
//       // prefs.setBool('wallpaperVisibility', wallpaperVisibility.value);  
//       // prefs.setDouble('wallpaperOpacity', wallpaperOpacity.value);  
//     } catch (e) {  
//       debugPrint('Error saving wallpaper state: $e');  
//     }  
//   }  

//   // Metode untuk memuat ulang state wallpaper (opsional)  
//   void _restoreWallpaperState() {  
//     // Implementasi pemulihan state, misalnya dari SharedPreferences  
//     try {  
//       // Contoh:  
//       // final prefs = await SharedPreferences.getInstance();  
//       // final savedIndex = prefs.getInt('currentWallpaperIndex');  
//       // final savedVisibility = prefs.getBool('wallpaperVisibility');  
//       // final savedOpacity = prefs.getDouble('wallpaperOpacity');  
      
//       // if (savedIndex != null) {  
//       //   currentWallpaperIndex.value = savedIndex;  
//       // }  
//       // if (savedVisibility != null) {  
//       //   wallpaperVisibility.value = savedVisibility;  
//       // }  
//       // if (savedOpacity != null) {  
//       //   wallpaperOpacity.value = savedOpacity;  
//       // }  
//     } catch (e) {  
//       debugPrint('Error restoring wallpaper state: $e');  
//     }  
//   }  

//   // Pembersihan sumber daya  
//   @override  
//   void onClose() {  
//     // Hapus observer  
//     WidgetsBinding.instance.removeObserver(this);  

//     // Dispose ValueNotifier  
//     wallpaperVisibility.dispose();  
//     wallpaperOpacity.dispose();  
//     currentWallpaperIndex.dispose();  

//     super.onClose();  
//   }  
// }  
