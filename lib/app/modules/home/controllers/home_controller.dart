import 'dart:convert';

import 'package:ebookapp/app/data/models/user_model.dart';
import 'package:ebookapp/app/modules/settings/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
        return;
      }

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] == null) {
        Get.snackbar('No Data', 'User profile data not found.');
        return;
      }

      // Parsing data ke dalam model UserResponse
      userResponse.value = UserResponse.fromJson(jsonResponse);

      debugPrint(
          '✅ User profile data fetched successfully: ${userResponse.value}');
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching user profile.');
      debugPrint("Error fetching user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}