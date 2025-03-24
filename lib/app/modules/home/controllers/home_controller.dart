import 'dart:convert';
import 'package:ebookapp/app/data/models/user_model.dart';
import 'package:ebookapp/app/modules/settings/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var userResponse = Rxn<UserResponse>(); // Menyimpan data UserResponse

  @override
  void onClose() {
    userResponse.value = null; // Bersihkan data saat controller ditutup
    isLoading.value = false; // Reset status loading
    super.onClose();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchUserProfile() async {
    if (isLoading.value) return; // Mencegah pemanggilan ganda
    isLoading.value = true;

    try {
      final token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'User not authenticated!');
        return;
      }

      final response = await http.get(
        Uri.parse('https://ebook.dev.whatthefun.id/api/v1/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          userResponse.value = UserResponse.fromJson(jsonResponse);
        } else {
          Get.snackbar('Error', 'User profile data not found.');
        }
      } else {
        Get.snackbar('Error', 'Failed to load user profile');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching user profile.');
      debugPrint("Error fetching user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
