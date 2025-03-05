import 'package:ebookapp/app/modules/settings/controllers/payment_detail_controller.dart';
import 'package:ebookapp/app/modules/settings/controllers/setting_theme_controller.dart';
import 'package:ebookapp/app/modules/settings/controllers/user_controller.dart';
import 'package:ebookapp/app/routes/app_pages.dart';
import 'package:ebookapp/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan UserController diinisialisasi
    Get.put(UserController()); // Tambahkan ini jika belum ada di tempat lain

    final ThemeController themeController = Get.put(ThemeController());
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Pengaturan',
            style: GoogleFonts.leagueSpartan(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 25,
            ),
          ),
          centerTitle: true,
          backgroundColor: themeController.currentColor, // Warna biru gelap
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Watermark.png'),
              fit: BoxFit.cover, // Mengatur gambar agar menutupi seluruh area
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              _buildSettingItem(
                image: 'assets/icons/user_icon.png',
                title: 'Akun Saya',
                onTap: () {
                  Get.toNamed(Routes.myAccount);
                },
              ),
              const Divider(),
              _buildSettingItem(
                image: 'assets/icons/pencil_icon.png',
                title: 'Ganti Walpaper dan Musik',
                onTap: () {
                  Get.toNamed(Routes.settingsTheme);
                },
              ),
              const Divider(),
              _buildSettingItem(
                image: 'assets/icons/key_icon.png',
                title: 'Ganti Kata Sandi',
                onTap: () {
                  Get.toNamed(Routes.changePass);
                },
              ),
              const Divider(),
              _buildSettingItem(
                image: 'assets/icons/crown_icon.png',
                title: 'Tingkatkan Akun',
                onTap: () {
                  // Ambil paymentStatus dari PaymentController
                  final paymentStatus =
                      Get.find<PaymentController>().paymentStatus.value;
                  // Kirim paymentStatus sebagai argumen
                  Get.toNamed(Routes.upgradeAccount, arguments: paymentStatus);
                },
              ),
              const Divider(),
              _buildSettingItem(
                image: 'assets/icons/exit_icon.png',
                title: 'Keluar',
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFE9E9E9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.leagueSpartan(
            fontSize: 20, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 320,
            height: 270,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 18),
                    Expanded(
                      child: Text(
                        'Keluar dari akun',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Kamu yakin ingin keluar dari akumu untuk sementara?',
                  style: GoogleFonts.leagueSpartan(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Ambil instance SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      final userController = Get.find<UserController>();

                      // Ambil userId yang tersimpan di SharedPreferences
                      final int? storedUserId = prefs.getInt('userId');
                      final int? currentUserId = userController.userId.value;

                      // Jika userId berbeda, ganti data SharedPreferences dengan data baru
                      if (storedUserId != currentUserId) {
                        await prefs.setInt(
                            'userId', currentUserId ?? 0); // Simpan userId baru
                        debugPrint(
                            "SharedPreferences diperbarui dengan userId baru: $currentUserId");
                      } else {
                        // Jika userId sama, muat kembali data yang tersimpan
                        debugPrint(
                            "UserId sama, memuat kembali data SharedPreferences");
                      }

                      // Panggil method logout dari UserController
                      await userController.logout();
                      // Navigasi ke halaman login setelah logout
                      Get.offAllNamed(Routes.login);
                    },
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.leagueSpartan(
                          fontSize: 15, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE33535),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
