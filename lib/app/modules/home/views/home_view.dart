import 'package:ebookapp/app/modules/settings/controllers/payment_detail_controller.dart';
import 'package:ebookapp/app/modules/settings/controllers/setting_theme_controller.dart';
import 'package:ebookapp/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  static const Color appBarColor = Color(0xFF32497B);

  // Fungsi untuk styling text
  TextStyle _getTextStyle(
      {double fontSize = 20,
      Color color = Colors.black,
      List<Shadow>? shadows}) {
    return GoogleFonts.leagueSpartan(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
      height: 0.9,
      shadows: shadows ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan instance yang sama dari ThemeController
    final ThemeController themeController = Get.find<ThemeController>();

    // Memanggil fetchUserProfile setelah widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserProfile();
    });

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Home',
            style: _getTextStyle(color: Colors.white),
          ),
          backgroundColor:
              themeController.currentColor, // Menggunakan warna yang dipilih
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Get.toNamed('/settings');
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Watermark.png'),
              fit: BoxFit.cover, // Mengatur gambar agar menutupi seluruh area
            ),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.userResponse.value == null) {
              return Center(child: Text('No user data available'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Memuat ulang data pengguna
                await controller.fetchUserProfile();
              },
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  // Greeting message
                  Container(
                    padding: EdgeInsets.all(10),
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        text:
                            'Assalamualaikum, ${controller.userResponse.value?.user.name} \n\n',
                        style: _getTextStyle(fontSize: 24, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                'Terima kasih sudah mendaftar kesini.\nOya, buku ini berisi motivasi yang menyejukkan hati, serta pengingat yang berpedoman kepada Al-Qur\'an. Semoga dapat bermanfaat dan menambah semangat dalam kehidupan sehari-hari ya.... Aamiin Ya Robbal Alamin.',
                            style: _getTextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Motivasi Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        // Navigasi ke halaman Motivasi dengan GetX
                        Get.toNamed(Routes
                            .motivasi); // Pastikan menggunakan Routes yang benar
                      },
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/Motivasi1.png',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Text(
                              'Motivasi',
                              style: _getTextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.7),
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Text(
                              '>',
                              style: _getTextStyle(
                                  fontSize: 24, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pengingat Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        print('Navigate to pengingat page');
                        Get.toNamed(Routes.pengingat);
                      }, // Ganti dengan route yang sesuai
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/Pengingat1.png',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 16,
                            bottom: 10,
                            child: Text(
                              'Pengingat',
                              style: _getTextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black.withOpacity(0.7),
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Text(
                              '>',
                              style: _getTextStyle(
                                  fontSize: 24, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Premium Button
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          print('Navigating to Try Premium page...');
                          final paymentStatus =
                              Get.find<PaymentController>().paymentStatus.value;
                          Get.toNamed(Routes.tryPremium,
                              arguments: paymentStatus);
                        },
                        icon: Image.asset(
                          'assets/images/crown.png',
                          width: 20,
                          height: 20,
                        ),
                        label: Text(
                          'Coba Premium!',
                          style: _getTextStyle(
                            fontSize: 16,
                            color: appBarColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          side: const BorderSide(color: appBarColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
