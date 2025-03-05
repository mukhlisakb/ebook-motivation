import 'dart:convert';
import 'package:ebookapp/app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  var isLoading = false.obs; // Untuk menandai proses loading
  var userResponse = Rxn<UserResponse>(); // Menyimpan data UserResponse
  var isPremium = false.obs; // Menyimpan status premium user
  var userId = Rxn<int>();
  final isScrollLimitReached = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadIsPremium(); // Muat isPremium dari SharedPreferences saat controller diinisialisasi
    fetchUserProfile(); // Ambil data profil user saat controller diinisialisasi
  }

  @override
  void onClose() {
    userResponse.value = null; // Bersihkan data saat controller ditutup
    isLoading.value = false; // Reset status loading
    userId.value = null;
    super.onClose();
  }

  // Method untuk mengambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method untuk menyimpan isPremium ke SharedPreferences
  Future<void> _saveIsPremium(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', isPremium);
    debugPrint('✅ Saved isPremium: $isPremium');
  }

  // Method untuk memuat isPremium dari SharedPreferences
  Future<void> _loadIsPremium() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium.value = prefs.getBool('isPremium') ?? false;
    debugPrint('✅ Loaded isPremium: ${isPremium.value}');
  }

  // Method untuk mengambil data profil user dari API
  Future<void> fetchUserProfile() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'User not authenticated!');
        return;
      }

      debugPrint('🔄 Fetching user profile data');
      debugPrint('🔄 https://ebook.dev.whatthefun.id/api/v1/profile');

      final response = await http.get(
        Uri.parse('https://ebook.dev.whatthefun.id/api/v1/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to load user profile');
        debugPrint('Error response: ${response.body}');
        return;
      }

      final jsonResponse = json.decode(response.body);
      debugPrint('API Response: $jsonResponse'); // Cetak respons API

      if (jsonResponse['data'] == null) {
        Get.snackbar('No Data', 'User profile data not found.');
        return;
      }

      // Parsing data ke dalam model UserResponse
      userResponse.value = UserResponse.fromJson(jsonResponse);

      // Set ID user
      userId.value = userResponse.value?.user.id;

      // Simpan isPremium ke SharedPreferences
      if (userResponse.value?.user.isPremium != null) {
        await _saveIsPremium(userResponse.value!.user.isPremium);
        isPremium.value = userResponse.value!.user.isPremium;
        debugPrint('✅ Updated isPremium: ${isPremium.value}');
      }

      debugPrint(
          '✅ User profile data fetched successfully: ${userResponse.value}');
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching user profile.');
      debugPrint("Error fetching user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk memperbarui profil user
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'User not authenticated!');
        return;
      }

      debugPrint('🔄 Updating user profile data');
      debugPrint('🔄 https://ebook.dev.whatthefun.id/api/v1/profile');

      // Kirim data ke server dengan format yang sesuai
      final response = await http.post(
        Uri.parse('https://ebook.dev.whatthefun.id/api/v1/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': data['name'],
          'email': data['email'],
          'birth_date': data['birth_date'],
          'city_code': data['city_code'],
          'job_type': data['job_type'],
          'job': data['job'],
          'phone_number': data['phone_number'],
          'gender': data['gender'],
        }),
      );

      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to update user profile');
        debugPrint('Error response: ${response.body}');
        return;
      }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] == null) {
        Get.snackbar(
            'Error', 'Failed to update profile: ${jsonResponse['message']}');
        return;
      }

      // Update userResponse dengan data terbaru
      userResponse.value = UserResponse.fromJson(jsonResponse);

      Get.snackbar('Success', 'User profile updated successfully');
      debugPrint('✅ User profile updated successfully: ${userResponse.value}');
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while updating user profile.');
      debugPrint("Error updating user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk mencari kota berdasarkan query
  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    try {
      final token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'User not authenticated!');
        return [];
      }

      debugPrint('🔄 Searching cities with query: $query');
      debugPrint(
          '🔄 https://ebook.dev.whatthefun.id/api/v1/register/cities?search=$query');

      final response = await http.get(
        Uri.parse(
            'https://ebook.dev.whatthefun.id/api/v1/register/cities?search=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to search cities');
        debugPrint('Error response: ${response.body}');
        return [];
      }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] == null) {
        Get.snackbar('No Data', 'No cities found.');
        return [];
      }

      // Parsing data kota
      final List<Map<String, dynamic>> cities = [];
      for (var city in jsonResponse['data']) {
        cities.add({
          'name': city['name'],
          'code': city['code'],
        });
      }

      debugPrint('✅ Cities fetched successfully: $cities');
      return cities;
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while searching cities.');
      debugPrint("Error searching cities: $e");
      return [];
    }
  }

  Future<void> logout() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'User not authenticated!');
        return;
      }

      debugPrint('🔄 Logging out');
      debugPrint('🔄 https://ebook.dev.whatthefun.id/api/v1/logout');

      final response = await http.post(
        Uri.parse('https://ebook.dev.whatthefun.id/api/v1/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to logout');
        debugPrint('Error response: ${response.body}');
        return;
      }

      // Hapus token dan semua data pembayaran dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      // Reset nilai di controller
      userId.value = null;

      Get.snackbar('Success', 'Logged out successfully');
      debugPrint('✅ Logged out successfully');
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while logging out.');
      debugPrint("Error logging out: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
