import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;
  var message = ''.obs;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'User not authenticated!');
        return;
      }

      debugPrint('🔄 Changing password');
      debugPrint('🔄 https://ebook.dev.whatthefun.id/api/v1/change-password');

      final response = await http.post(
        Uri.parse('https://ebook.dev.whatthefun.id/api/v1/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation':
              confirmPassword, // Sesuaikan dengan field yang diharapkan API
        }),
      );

      if (response.statusCode != 200) {
        final jsonResponse = json.decode(response.body);
        Get.snackbar(
            'Error', jsonResponse['message'] ?? 'Failed to change password');
        debugPrint('Error response: ${response.body}');
        return;
      }

      message.value = 'Kata sandi berhasil diubah.';
      Get.snackbar('Success', message.value);
      debugPrint('✅ Password changed successfully');
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while changing password.');
      debugPrint("Error changing password: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
