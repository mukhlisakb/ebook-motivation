import 'dart:convert';  
import 'dart:typed_data';  
import 'package:ebookapp/app/data/models/content_model.dart';  
import 'package:ebookapp/app/data/models/cursor_pagination_model.dart';  
import 'package:ebookapp/app/data/models/motivasi_model.dart';  
import 'package:ebookapp/app/modules/motivasi/controllers/motivasi_controller.dart';
import 'package:ebookapp/app/modules/pengingat/controllers/pengingat_category_controller.dart';  
import 'package:ebookapp/app/routes/app_pages.dart';  
import 'package:flutter/material.dart';  
import 'package:get/get.dart';  
import 'package:http/http.dart' as http;  
import 'package:shared_preferences/shared_preferences.dart';  

class PengingatController extends GetxController {  
  var contents = <Content>[].obs;  
  var imageBytesList = <Rx<Uint8List?>>[].obs;  
  var isLoading = false.obs;  
  var nextCursor = RxnString();  
  var subcategoryId = 0.obs; // ID subcategory saat ini  
  var subcategories = <Subcategory>[].obs; // Daftar semua subcategories  

  @override  
  void onInit() {  
    super.onInit();  
    fetchSubcategoriesFromMotivasiController();  
  }  

  @override  
  void onClose() {  
    contents.clear();  
    imageBytesList.clear();  
    isLoading.value = false;  
    nextCursor.value = null;  
    super.onClose();  
  }  

  // Fungsi untuk mengambil token dari SharedPreferences  
  Future<String?> getToken() async {  
    final prefs = await SharedPreferences.getInstance();  
    return prefs.getString('token');  
  }  

  // Fungsi untuk mengambil konten berdasarkan subcategoryId  
  Future<void> fetchContents({required int subcategoryId}) async {  
    if (isLoading.value) return;  
    isLoading.value = true;  
    update();  

    try {  
      final token = await getToken();  
      if (token == null) {  
        Get.snackbar('Error', 'User not authenticated!');  
        return;  
      }  

      debugPrint('🔄 Fetching motivasi data for subcategoryId: $subcategoryId');  

      final response = await http.get(  
        Uri.parse(  
            'https://ebook.dev.whatthefun.id/api/v1/contents?subcategory_id=$subcategoryId&cursor=${nextCursor.value ?? ''}&limit=3'),  
        headers: {  
          'Authorization': 'Bearer $token',  
          'Content-Type': 'application/json',  
          'Accept': 'application/json',  
        },  
      );  

      if (response.statusCode != 200) {  
        Get.snackbar('Error', 'Failed to load motivasi');  
        return;  
      }  

      final jsonResponse = json.decode(response.body);  

      if (jsonResponse['data'] == null || jsonResponse['data'].isEmpty) {  
        Get.snackbar('No Data', 'Data motivasi tidak ditemukan.');  
        return;  
      }  

      // Reset lists jika ini adalah fetch pertama  
      if (nextCursor.value == null) {  
        contents.clear();  
        imageBytesList.clear();  
      }  

      await fetchImages(jsonResponse['data']);  

      if (jsonResponse['meta'] != null) {  
        nextCursor.value =  
            CursorPagination.fromJson(jsonResponse['meta']).nextCursor;  
      } else {  
        nextCursor.value = null;  
      }  

      debugPrint('✅ Motivasi data fetched successfully');  
      debugPrint('Total items fetched: ${contents.length}');  
      debugPrint('Next cursor: ${nextCursor.value}');  

      // Jika konten habis, langsung pindah ke subcategory berikutnya  
      if (nextCursor.value == null) {  
        final currentSubcategory = subcategories.firstWhere(  
          (subcategory) => subcategory.id == subcategoryId,  
        );  
        _loadNextSubcategory(currentSubcategory);  
      }  
    } catch (e) {  
      Get.snackbar('Error', 'An error occurred while fetching motivasi.');  
      debugPrint("Error fetching motivasi: $e");  
    } finally {  
      isLoading.value = false;  
      update();  
    }  
  }  

  // Fungsi untuk mengambil gambar dari URL  
  Future<void> fetchImages(List rawContentsData) async {  
    List<Future<void>> downloadTasks = [];  

    for (var element in rawContentsData) {  
      Content content = Content.fromJson(element);  
      Rx<Uint8List?> imageRx = Rx<Uint8List?>(null);  
      String imageUrl = content.imageUrls.optimized.isNotEmpty  
          ? content.imageUrls.optimized  
          : content.imageUrls.original;  

      contents.add(content);  
      imageBytesList.add(imageRx);  

      downloadTasks.add(downloadAndConvertImage(imageUrl, imageRx));  
    }  

    await Future.wait(downloadTasks);  
  }  

  // Fungsi untuk mengunduh dan mengonversi gambar ke Uint8List  
  Future<void> downloadAndConvertImage(  
      String imageUrl, Rx<Uint8List?> imageRx) async {  
    if (imageUrl.isEmpty) {  
      debugPrint("Invalid image URL: $imageUrl");  
      imageRx.value = null;  
      return;  
    }  

    final token = await getToken();  
    if (token == null) {  
      Get.snackbar('Error', 'User not authenticated!');  
      return;  
    }  

    try {  
      debugPrint("Downloading image: $imageUrl");  

      final response = await http.get(  
        Uri.parse(imageUrl),  
        headers: {  
          'Authorization': 'Bearer $token',  
          'Accept': 'application/json',  
        },  
      );  

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {  
        imageRx.value = response.bodyBytes;  
        debugPrint("✅ Image downloaded successfully: $imageUrl");  
      } else {  
        imageRx.value = null;  
        debugPrint(  
            "❌ Failed to download image, Status Code: ${response.statusCode}");  
      }  
    } catch (e) {  
      imageRx.value = null;  
      debugPrint("⚠️ Error saat mengunduh gambar: $e");  
    }  
  }  

  // Fungsi untuk mengambil subcategory berikutnya  
  Subcategory? getNextSubcategory(Subcategory currentSubcategory) {  
    // Pastikan daftar subcategory tidak kosong  
    if (subcategories.isEmpty) {  
      debugPrint("Daftar subcategory kosong");  
      return null;  
    }  

    // Cari index subcategory saat ini  
    final currentIndex = subcategories.indexWhere(  
      (subcategory) => subcategory.id == currentSubcategory.id,  
    );  

    // Jika subcategory saat ini tidak ditemukan  
    if (currentIndex == -1) {  
      debugPrint("Subcategory saat ini tidak ditemukan dalam daftar");  
      return null;  
    }  

    // Jika tidak ada subcategory berikutnya  
    if (currentIndex >= subcategories.length - 1) {  
      debugPrint("Tidak ada subcategory berikutnya");  
      return null;  
    }  

    // Kembalikan subcategory berikutnya  
    return subcategories[currentIndex + 1];  
  }  

  // Fungsi untuk memuat semua subcategories dari MotivasiController  
  Future<void> fetchSubcategoriesFromMotivasiController() async {  
    final motivasiController = Get.find<PengingatIdController>();  
    subcategories.value = motivasiController.subcategories;  
    debugPrint('✅ Subcategories fetched from MotivasiController');  
  }  

  void _loadNextSubcategory(Subcategory currentSubcategory) {  
    debugPrint(  
        "Mencari subcategory berikutnya untuk subcategory ID: ${currentSubcategory.id}");  
    final nextSubcategory = this.getNextSubcategory(currentSubcategory);  

    if (nextSubcategory != null) {  
      debugPrint(  
          "Subcategory berikutnya ditemukan: ${nextSubcategory.id} - ${nextSubcategory.name}");  
      debugPrint("Navigasi ke subcategory berikutnya...");  
      Get.offNamed(Routes.motivationContents, arguments: nextSubcategory);  
    } else {  
      debugPrint("Tidak ada subcategory berikutnya");  
      Get.snackbar('Info', 'Tidak ada subcategory berikutnya');  
    }  
  }  
}