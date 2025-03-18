// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../controllers/wallpaper_music_controller.dart';

// class WallpaperMusicView extends StatefulWidget {
//   const WallpaperMusicView({Key? key}) : super(key: key);

//   @override
//   _WallpaperMusicViewState createState() => _WallpaperMusicViewState();
// }

// class _WallpaperMusicViewState extends State<WallpaperMusicView>
//     with AutomaticKeepAliveClientMixin {
//   final PageController _pageController = PageController();

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();

//     // Nonaktifkan rotasi layar
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();

//     // Kembalikan orientasi layar default
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return GetBuilder<WallpaperMusicController>(
//       builder: (controller) => Scaffold(
//         backgroundColor: Colors.white,
//         appBar: _buildAppBar(),
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: PageView(
//                     controller: _pageController,
//                     physics: const NeverScrollableScrollPhysics(),
//                     children: [
//                       _buildWallpaperSelection(controller),
//                       _buildMusicSelection(controller),
//                     ],
//                   ),
//                 ),
//                 _buildIndicator(),
//                 const SizedBox(height: 10),
//                 _buildNavigationButton(controller),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Get.back(),
//       ),
//       title: Text(
//         'Pilih Wallpaper & Musik',
//         style: GoogleFonts.leagueSpartan(color: Colors.black),
//       ),
//     );
//   }

//   Widget _buildIndicator() {
//     return SmoothPageIndicator(
//       controller: _pageController,
//       count: 2,
//       effect: const WormEffect(
//         activeDotColor: Colors.blue,
//         dotColor: Colors.grey,
//         dotHeight: 8,
//         dotWidth: 8,
//       ),
//     );
//   }

//   Widget _buildNavigationButton(WallpaperMusicController controller) {
//     return ElevatedButton(
//       onPressed: () {
//         if (_pageController.page == 1) {
//           Get.back();
//         } else {
//           _pageController.nextPage(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//           );
//         }
//       },
//       style: ElevatedButton.styleFrom(
//         minimumSize: const Size(double.infinity, 50),
//         backgroundColor: Colors.blue,
//       ),
//       child: Text(
//         _pageController.hasClients && _pageController.page == 1
//             ? 'Selesai'
//             : 'Selanjutnya',
//         style: const TextStyle(color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildWallpaperSelection(WallpaperMusicController controller) {
//     return Column(
//       children: [
//         Text(
//           'Pilih Wallpaper',
//           style: GoogleFonts.leagueSpartan(fontSize: 24),
//         ),
//         Obx(() {
//           // Tampilkan indikator loading jika sedang menginisialisasi video
//           if (controller.isVideoInitializing.value) {
//             return const Expanded(
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           return Expanded(
//             child: controller.wallpapers.isEmpty
//                 ? const Center(child: Text("Tidak ada wallpaper tersedia"))
//                 : GridView.builder(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       childAspectRatio: 0.7,
//                       crossAxisSpacing: 8,
//                       mainAxisSpacing: 8,
//                     ),
//                     itemCount: controller.wallpapers.length,
//                     itemBuilder: (context, index) {
//                       final wallpaper = controller.wallpapers[index];
//                       return _buildWallpaperItem(controller, wallpaper);
//                     },
//                   ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildWallpaperItem(
//       WallpaperMusicController controller, String wallpaper) {
//     final isSelected = controller.selectedWallpaper.value == wallpaper;

//     return GestureDetector(
//       onTap: () => controller.selectWallpaper(wallpaper),
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? Colors.blue : Colors.grey,
//             width: isSelected ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           image: !wallpaper.endsWith('.mp4')
//               ? DecorationImage(
//                   image: AssetImage(wallpaper),
//                   fit: BoxFit.cover,
//                 )
//               : null,
//         ),
//         child: wallpaper.endsWith('.mp4')
//             ? _buildVideoPlayer(controller, wallpaper)
//             : null,
//       ),
//     );
//   }

//   Widget _buildVideoPlayer(
//       WallpaperMusicController controller, String wallpaper) {
//     final videoController = controller.getVideoController(wallpaper);

//     if (videoController == null || !videoController.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return AspectRatio(
//       aspectRatio: videoController.value.aspectRatio,
//       child: VideoPlayer(videoController),
//     );
//   }

//   Widget _buildMusicSelection(WallpaperMusicController controller) {
//     return Column(
//       children: [
//         Text(
//           'Pilih Musik',
//           style: GoogleFonts.leagueSpartan(fontSize: 24),
//         ),
//         Expanded(
//           child: controller.musicTracks.isEmpty
//               ? const Center(child: Text("Tidak ada musik tersedia"))
//               : ListView.builder(
//                   itemCount: controller.musicTracks.length,
//                   itemBuilder: (context, index) {
//                     final musicTrack = controller.musicTracks[index];
//                     final isSelected =
//                         controller.selectedMusic.value == musicTrack;

//                     return ListTile(
//                       title: Text('Lagu ${index + 1}'),
//                       trailing: isSelected
//                           ? const Icon(Icons.check, color: Colors.blue)
//                           : null,
//                       onTap: () {
//                         controller.selectMusic(musicTrack);
//                       },
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }
// }



import 'package:ebookapp/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Nonaktifkan rotasi layar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();

    // Kembalikan orientasi layar default
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<WallpaperMusicController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Pilih Wallpaper & Musik',
        style: GoogleFonts.leagueSpartan(color: Colors.black),
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
    return ElevatedButton(
      onPressed: () {
        if (_pageController.page == 1) {
          Get.back();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: colorBackground,
      ),
      child: Text(
        _pageController.hasClients && _pageController.page == 1
            ? 'Selesai'
            : 'Selanjutnya',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildWallpaperSelection(WallpaperMusicController controller) {
    return Column(
      children: [
        Text(
          'Pilih Wallpaper',
          style: GoogleFonts.leagueSpartan(fontSize: 24),
        ),
        Obx(() {
          // Tampilkan indikator loading jika sedang menginisialisasi video
          if (controller.isVideoInitializing.value) {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Expanded(
            child: AssetPaths.wallpapers.isEmpty
                ? const Center(child: Text("Tidak ada wallpaper tersedia"))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
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
      onTap: () => controller.selectWallpaper(wallpaper),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colorBackground : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(15),
          image: !wallpaper.endsWith('.mp4')
              ? DecorationImage(
                  image: AssetImage(wallpaper),
                  fit: BoxFit.cover,
                  colorFilter: isSelected
                      ? ColorFilter.mode(
                          colorBackground.withOpacity(0.3), BlendMode.srcATop)
                      : null,
                )
              : null,
        ),
        child: wallpaper.endsWith('.mp4')
            ? _buildVideoPlayer(controller, wallpaper)
            : null,
      ),
    );
  }

  Widget _buildVideoPlayer(
      WallpaperMusicController controller, String wallpaper) {
    final videoController = controller.getVideoController(wallpaper);

    if (videoController == null || !videoController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        // Toggle play/pause saat di-tap
        if (videoController.value.isPlaying) {
          videoController.pause();
        } else {
          videoController.play();
        }
      },
      child: AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(videoController),
            Obx(() {
              final isSelected =
                  controller.selectedWallpaper.value == wallpaper;
              if (isSelected) {
                return CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(
                    videoController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicSelection(WallpaperMusicController controller) {
    return Column(
      children: [
        Text(
          'Pilih Musik',
          style: GoogleFonts.leagueSpartan(fontSize: 24),
        ),
        Expanded(
          child: AssetPaths.musicTracks.isEmpty
              ? const Center(child: Text("Tidak ada musik tersedia"))
              : ListView.builder(
                  itemCount: AssetPaths.musicTracks.length,
                  itemBuilder: (context, index) {
                    final musicTrack = AssetPaths.musicTracks[index];
                    final isSelected =
                        controller.selectedMusic.value == musicTrack;

                    return ListTile(
                      title: Text('Penyejuk Hati ${index + 1}'),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: colorBackground)
                          : null,
                      onTap: () {
                        controller.selectMusic(musicTrack);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
