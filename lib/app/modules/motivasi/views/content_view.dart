import 'dart:typed_data';
import 'package:ebookapp/app/data/models/motivasi_model.dart';
import 'package:ebookapp/app/modules/motivasi/controllers/content_controller.dart';
import 'package:ebookapp/app/modules/settings/controllers/setting_theme_controller.dart';
import 'package:ebookapp/app/modules/settings/controllers/user_controller.dart';
import 'package:ebookapp/app/routes/app_pages.dart';
import 'package:ebookapp/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentView extends GetView<ContentController> {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final Subcategory? subcategory = Get.arguments as Subcategory?;

    if (subcategory == null) {
      return Scaffold(
        body: Center(child: Text("Subcategory tidak ditemukan")),
      );
    }

    final ThemeController themeController = Get.find<ThemeController>();
    final UserController userController = Get.find<UserController>();

    if (userController.isPremium.value == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Memantau perubahan isPremium
    ever(userController.isPremium, (isPremium) async {
      if (isPremium) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('slideCount'); // Hapus slideCount
        await prefs
            .remove('isScrollLimitReached'); // Hapus isScrollLimitReached
        debugPrint("SharedPreferences dihapus karena isPremium = true");
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(subcategory, themeController),
      body: Stack(
        children: [
          Image.asset('assets/images/screen_view.png', height: 917, width: 600),
          _buildBody(subcategory, themeController, userController),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
      Subcategory subcategory, ThemeController themeController) {
    return AppBar(
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Motivasi',
          style: GoogleFonts.leagueSpartan(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          children: [
            TextSpan(
              text: '\n${subcategory.id}. ${subcategory.name}',
              style: GoogleFonts.leagueSpartan(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: themeController.currentColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            debugPrint('Image clicked');
            Get.toNamed(Routes.pengingatContentsDrop, arguments: subcategory);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/caret.png', // Ganti dengan path gambar Anda
              width: 24,
              height: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    Subcategory subcategory,
    ThemeController themeController,
    UserController userController,
  ) {
    // Menggunakan RxInt untuk slideCount
    final slideCount = 0.obs;

    // Gunakan PageController dengan keepPage: true
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

            // Jika userId berbeda, hapus data SharedPreferences
            if (storedUserId != currentUserId) {
              prefs.remove('slideCount');
              prefs.remove('isScrollLimitReached');
              prefs.setInt('userId', currentUserId ?? 0); // Simpan sebagai int
            }

            bool isScrollLimitReached =
                prefs.getBool('isScrollLimitReached') ?? false;

            // Jika isScrollLimitReached == true dan isPremium == false, pindah ke halaman ticketPremium
            if (isScrollLimitReached && !userController.isPremium.value) {
              Future.microtask(() => Get.offNamed(Routes.ticketPremium));
              return const SizedBox.shrink(); // Kembalikan widget kosong
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Cek apakah scroll mencapai akhir halaman
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  // Increment slideCount hanya jika scroll mencapai akhir halaman
                  slideCount.value++;
                  debugPrint("Slide count: ${slideCount.value}");

                  // Jika slideCount >= 2 dan pengguna bukan premium, pindah ke halaman ticketPremium
                  if (!userController.isPremium.value &&
                      slideCount.value >= 2) {
                    prefs.setBool('isScrollLimitReached', true);
                    Future.microtask(() => Get.offNamed(Routes.ticketPremium));
                  }

                  // Panggil fetchContents untuk memuat lebih banyak gambar
                  controller.fetchContents(subcategoryId: subcategory.id);
                }

                return true;
              },
              child: PageView.builder(
                controller: pageController, // Gunakan PageController
                scrollDirection: Axis.vertical,
                itemCount: userController.isPremium.value
                    ? controller.imageBytesList.length +
                        (controller.nextCursor.value != null ? 1 : 0)
                    : (controller.imageBytesList.length > 3
                        ? 3
                        : controller.imageBytesList.length),
                itemBuilder: (context, index) {
                  if (index >= controller.imageBytesList.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final imageBytes = controller.imageBytesList[index].value;
                  if (imageBytes == null) {
                    return const Center(child: Text("Image data is null"));
                  }

                  return _buildPageItem(index, imageBytes);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPageItem(int index, Uint8List imageBytes) {
    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            child: Image.memory(
              imageBytes,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                "(${index + 1})",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
