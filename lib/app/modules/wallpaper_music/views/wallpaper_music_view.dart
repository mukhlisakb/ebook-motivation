import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/wallpaper_music_controller.dart';

class WallpaperMusicView extends StatefulWidget {
  @override
  _WallpaperMusicViewState createState() => _WallpaperMusicViewState();
}

class _WallpaperMusicViewState extends State<WallpaperMusicView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final WallpaperMusicController controller = Get.find();
  late PageController _pageController;
  int _currentPage = 0;
  AudioPlayer? _audioPlayer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Nonaktifkan rotasi layar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer?.setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Kembalikan orientasi layar default
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _audioPlayer?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Tangani perubahan state aplikasi
    switch (state) {
      case AppLifecycleState.paused:
        // Jeda pemutaran video dan musik
        _pauseMedia();
        break;
      case AppLifecycleState.resumed:
        // Lanjutkan pemutaran
        _resumeMedia();
        break;
      default:
        break;
    }
  }

  void _pauseMedia() {
    // Jeda semua video yang sedang diputar
    controller.videoControllers.forEach((path, videoController) {
      videoController.pause();
    });
    _audioPlayer?.pause();
  }

  void _resumeMedia() {
    // Lanjutkan pemutaran video yang dipilih
    final selectedWallpaper = controller.selectedWallpaper.value;
    if (selectedWallpaper.endsWith('.mp4')) {
      final videoController = controller.videoControllers[selectedWallpaper];
      videoController?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWallpaperSelection(),
                    _buildMusicSelection(),
                  ],
                ),
              ),
              _buildIndicator(),
              const SizedBox(height: 10),
              _buildNavigationButton(),
            ],
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
        activeDotColor: Colors.blue,
        dotColor: Colors.grey,
        dotHeight: 8,
        dotWidth: 8,
      ),
    );
  }

  Widget _buildNavigationButton() {
    return ElevatedButton(
      onPressed: () {
        if (_currentPage == 1) {
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
        backgroundColor: Colors.blue,
      ),
      child: Text(
        _currentPage == 1 ? 'Selesai' : 'Selanjutnya',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildWallpaperSelection() {
    return Column(
      children: [
        Text(
          'Pilih Wallpaper',
          style: GoogleFonts.leagueSpartan(fontSize: 24),
        ),
        Expanded(
          child: Obx(() {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: controller.wallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = controller.wallpapers[index];
                return _buildWallpaperItem(wallpaper);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWallpaperItem(String wallpaper) {
    return GestureDetector(
      onTap: () {
        controller.selectWallpaper(wallpaper);
        if (wallpaper.endsWith('.mp4')) {
          controller.initializeVideoController(wallpaper);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.selectedWallpaper.value == wallpaper
                  ? Colors.blue
                  : Colors.grey,
            ),
            image: wallpaper.endsWith('.mp4')
                ? null
                : DecorationImage(
                    image: AssetImage(wallpaper),
                    fit: BoxFit.cover,
                  ),
          ),
          child:
              wallpaper.endsWith('.mp4') ? _buildVideoPlayer(wallpaper) : null,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String wallpaper) {
    return Obx(() {
      final videoController = controller.videoControllers[wallpaper];

      if (videoController == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayer(videoController),
      );
    });
  }

  Widget _buildMusicSelection() {
    return Column(
      children: [
        Text(
          'Pilih Musik',
          style: GoogleFonts.leagueSpartan(fontSize: 24),
        ),
        Expanded(
          child: Obx(() {
            return ListView.builder(
              itemCount: controller.musicTracks.length,
              itemBuilder: (context, index) {
                final musicTrack = controller.musicTracks[index];
                return ListTile(
                  title: Text('Lagu ${index + 1}'),
                  trailing: controller.selectedMusic.value == musicTrack
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () => _playMusic(musicTrack),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _playMusic(String musicTrack) {
    controller.selectMusic(musicTrack);
    _audioPlayer?.stop(); // Hentikan musik sebelumnya
    _audioPlayer?.play(AssetSource(musicTrack));
  }
}
