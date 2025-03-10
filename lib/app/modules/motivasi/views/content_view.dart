
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:ebookapp/app/modules/motivasi/controllers/audio_controller.dart';
import 'package:ebookapp/app/modules/motivasi/controllers/live_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ebookapp/app/data/models/motivasi_model.dart';
import 'package:ebookapp/app/modules/motivasi/controllers/content_controller.dart';
import 'package:ebookapp/app/modules/settings/controllers/setting_theme_controller.dart';
import 'package:ebookapp/app/modules/settings/controllers/user_controller.dart';
import 'package:ebookapp/app/routes/app_pages.dart';

class ContentView extends GetView<ContentController> {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final Subcategory? subcategory = Get.arguments as Subcategory?;

    if (subcategory == null) {
      return const Scaffold(
        body: Center(child: Text("Subcategory tidak ditemukan")),
      );
    }

    // Inisialisasi Live Wallpaper Controller
    final LiveWallpaperController liveWallpaperController = 
        Get.put(LiveWallpaperController());

    // Inisialisasi Audio Controller dengan daftar track
    final AudioController audioController = Get.put(AudioController(
        initialAudioSourcePath: 'avenged.mp3',
        audioTracks: ['avenged.mp3']));

    final ThemeController themeController = Get.find<ThemeController>();
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Live Wallpaper
          Obx(() => liveWallpaperController.isWallpaperVisible
              ? Positioned.fill(
                  child: Image.asset(
                    liveWallpaperController.currentWallpaper,
                    fit: BoxFit.cover,
                    opacity: AlwaysStoppedAnimation(
                      liveWallpaperController.wallpaperOpacity
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          // Konten Utama
          _buildBody(
            subcategory, 
            themeController, 
            userController, 
            audioController,
            liveWallpaperController
          ),

          // Kontrol Wallpaper
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: [
                // Tombol Visibility Wallpaper
                Obx(() => IconButton(
                  icon: Icon(
                    liveWallpaperController.isWallpaperVisible 
                      ? Icons.visibility 
                      : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () => liveWallpaperController.toggleWallpaperVisibility(),
                )),

                // Slider Opacity
                Obx(() => SizedBox(
                  width: 100,
                  child: Slider(
                    value: liveWallpaperController.wallpaperOpacity,
                    onChanged: (value) => liveWallpaperController.setWallpaperOpacity(value),
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white54,
                  ),
                )),

                // Tombol Ganti Wallpaper
                IconButton(
                  icon: const Icon(Icons.switch_access_shortcut, color: Colors.white),
                  onPressed: () => liveWallpaperController.nextWallpaper(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    Subcategory subcategory,
    ThemeController themeController,
    UserController userController,
    AudioController audioController,
    LiveWallpaperController liveWallpaperController,
  ) {
    final slideCount = 0.obs;
    final PageController pageController = PageController(keepPage: true);

    return GetBuilder<ContentController>(
      initState: (_) => controller.fetchContents(subcategoryId: subcategory.id),
      builder: (controller) {
        if (controller.isLoading.value && controller.imageBytesList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.imageBytesList.isEmpty) {
          return const Center(child: Text("No images available"));
        }

        return FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final SharedPreferences prefs = snapshot.data!;
            final int? storedUserId = prefs.getInt('userId');
            final int? currentUserId = userController.userId.value;

            if (storedUserId != currentUserId) {
              prefs.remove('slideCount');
              prefs.remove('isScrollLimitReached');
              prefs.setInt('userId', currentUserId ?? 0);
            }

            bool isScrollLimitReached =
                prefs.getBool('isScrollLimitReached') ?? false;

            if (isScrollLimitReached && !userController.isPremium.value) {
              Future.microtask(() => Get.offNamed(Routes.ticketPremium));
              return const SizedBox.shrink();
            }

            return LayoutBuilder(builder: (context, constraints) {
              return GestureDetector(
                onTap: () {
                  // Toggle play/pause saat layar di tap
                  audioController.togglePlayPause();
                },
                onLongPress: () {
                  // Toggle wallpaper saat long press
                  liveWallpaperController.toggleWallpaperVisibility();
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      slideCount.value++;
                      debugPrint("Slide count: ${slideCount.value}");

                      if (!userController.isPremium.value &&
                          slideCount.value >= 2) {
                        prefs.setBool('isScrollLimitReached', true);
                        Future.microtask(
                            () => Get.offNamed(Routes.ticketPremium));
                      }

                      controller.fetchContents(
                          subcategoryId: subcategory.id);
                    }
                    return true;
                  },
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: userController.isPremium.value
                            ? controller.imageBytesList.length +
                                (controller.nextCursor.value != null ? 1 : 0)
                            : (controller.imageBytesList.length > 3
                                ? 3
                                : controller.imageBytesList.length),
                        itemBuilder: (context, index) {
                          if (index >= controller.imageBytesList.length) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final imageBytes =
                              controller.imageBytesList[index].value;
                          if (imageBytes == null) {
                            return const Center(
                                child: Text("Image data is null"));
                          }

                          return _buildPageItem(index, imageBytes);
                        },
                      ),
                      // Motivational Text
                      Positioned(
                        bottom: 100,
                        left: 20,
                        right: 20,
                        child: Text(
                          "Discipline turns potential into reality.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Bottom Action Buttons
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.white),
                              onPressed: () {
                                // Handle share action
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite_border, color: Colors.white),
                              onPressed: () {
                                // Handle like action
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  // Modifikasi method _buildPageItem untuk ukuran 150x150
  Widget _buildPageItem(int index, Uint8List imageBytes) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                width: 150,
                height: 150,
              ),
            ),
          ),
          Positioned(
            bottom: -30, // Sesuaikan posisi nomor
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "(${index + 1})",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
