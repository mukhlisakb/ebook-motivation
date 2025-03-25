import 'package:ebookapp/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/wallpaper_music_controller.dart';

class WallpaperMusicView extends StatefulWidget {
  const WallpaperMusicView({Key? key}) : super(key: key);

  @override
  _WallpaperMusicViewState createState() => _WallpaperMusicViewState();
}

class _WallpaperMusicViewState extends State<WallpaperMusicView>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenSize = MediaQuery.of(context).size;

    return GetBuilder<WallpaperMusicController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWallpaperSelection(controller),
                      _buildMusicSelection(controller),
                    ],
                  ),
                ),
                _buildIndicator(),
                const SizedBox(height: 10),
                _buildNavigationButton(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: 2,
      effect: const WormEffect(
        activeDotColor: colorBackground,
        dotColor: Colors.grey,
        dotHeight: 8,
        dotWidth: 8,
      ),
    );
  }

  Widget _buildNavigationButton(WallpaperMusicController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth,
      child: ElevatedButton(
        onPressed: () async {
          if (_pageController.page == 1) {
            // Jika ini halaman kedua (musical selection)
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool(
                'isNewUser', false); // Set pengguna baru menjadi false

            // Arahkan ke halaman /home dan refresh data pengguna
            Get.offNamed('/home', arguments: {'refresh': true});
          } else {
            // Jika halaman pertama (wallpaper selection)
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(screenWidth, 50),
          backgroundColor: colorBackground,
        ),
        child: Text(
          _pageController.hasClients && _pageController.page == 1
              ? 'Selesai'
              : 'Selanjutnya',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWallpaperSelection(WallpaperMusicController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Wallpapermu!',
          style: GoogleFonts.leagueSpartan(
              fontSize: 34, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Text(
          'Kamu bisa memilih wallpaper yang paling kamu suka loh.\nagar menambah pengalamanmu saat membaca',
          style: GoogleFonts.leagueSpartan(fontSize: 14),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 20),
        Obx(() {
          if (controller.wallpaperStatus.value == WallpaperStatus.loading) {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (controller.wallpaperStatus.value == WallpaperStatus.error) {
            return Expanded(
              child: Center(
                child: Text(
                  'Error: ${controller.errorMessage.value}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final size = MediaQuery.of(context).size;
          return Expanded(
            child: AssetPaths.wallpapers.isEmpty
                ? const Center(child: Text("Tidak ada wallpaper tersedia"))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (size.width > 400) ? 3 : 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: AssetPaths.wallpapers.length,
                    itemBuilder: (context, index) {
                      final wallpaper = AssetPaths.wallpapers[index];
                      return _buildWallpaperItem(controller, wallpaper);
                    },
                  ),
          );
        }),
      ],
    );
  }

  Widget _buildWallpaperItem(
      WallpaperMusicController controller, String wallpaper) {
    final isSelected = controller.selectedWallpaper.value == wallpaper;

    return GestureDetector(
      onTap: () {
        // Memilih wallpaper saat diklik.
        controller.selectWallpaper(wallpaper);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colorBackground : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: wallpaper.endsWith('.mp4')
            ? _buildVideoPlayer(controller, wallpaper, isSelected)
            : _buildImageTile(wallpaper, isSelected),
      ),
    );
  }

  Widget _buildImageTile(String wallpaper, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(wallpaper),
          fit: BoxFit.cover,
          colorFilter: isSelected
              ? ColorFilter.mode(
                  colorBackground.withOpacity(0.3), BlendMode.srcATop)
              : null,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(
      WallpaperMusicController controller, String wallpaper, bool isSelected) {
    final videoController = controller.getVideoController(wallpaper);

    // Memeriksa apakah video controller tersedia dan sudah diinisialisasi
    if (videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Memutar atau menghentikan video berdasarkan status pemilihan
    if (isSelected) {
      videoController.play();
    } else {
      videoController.pause();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: AspectRatio(
          aspectRatio: videoController.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(videoController),
              if (isSelected)
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(
                    videoController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicSelection(WallpaperMusicController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ayo pilih lagumu!',
          style: GoogleFonts.leagueSpartan(
              fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Musik ini akan diputar saat kamu sedang membuka bacaan,\njadi pilih sesuai mood mu ya!',
          style: GoogleFonts.leagueSpartan(fontSize: 14),
        ),
        const SizedBox(height: 20),
        Obx(() {
          if (controller.musicStatus.value == WallpaperStatus.loading) {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (controller.musicStatus.value == WallpaperStatus.error) {
            return Expanded(
              child: Center(
                child: Text(
                  'Error: ${controller.errorMessage.value}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return Expanded(
            child: AssetPaths.musicTracks.isEmpty
                ? const Center(child: Text("Tidak ada musik tersedia"))
                : ListView.builder(
                    itemCount: AssetPaths.musicTracks.length,
                    itemBuilder: (context, index) {
                      final musicTrack = AssetPaths.musicTracks[index];
                      final isSelected =
                          controller.selectedMusic.value == musicTrack;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Penyejuk Hati ${index + 1}'),
                              InkWell(
                                onTap: () {
                                  controller.selectMusic(musicTrack);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorBackground
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isSelected ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        }),
      ],
    );
  }
}

// ------- Perbaikan code baru -------

