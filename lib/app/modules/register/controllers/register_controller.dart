import 'package:flutter/material.dart';  
import 'package:get/get.dart';  
import 'package:http/http.dart' as http;  
import 'dart:convert';  
import 'package:ebookapp/app/data/models/user_model.dart';  

class RegisterController extends GetxController {  
  // TextEditingController untuk form fields  
  final nameController = TextEditingController();  
  final emailController = TextEditingController();  
  final passwordController = TextEditingController();  
  final confirmPasswordController = TextEditingController();  
  final dobController = TextEditingController(); // Tanggal lahir  
  final cityCodeController = TextEditingController();  
  final phoneNumberController = TextEditingController();  
  final genderController = TextEditingController();  
  final domisiliController = TextEditingController();  

  // State untuk loading dan error  
  var isLoading = false.obs;  
  var errorMessage = ''.obs;  
  var domisiliList = <Map<String, dynamic>>[].obs;  
  var selectedJobType = 0.obs; // Pekerjaan (1-8)  
  var isAgreed = false.obs;

  // Fungsi untuk validasi form  
  bool validateForm() {  
    // Log nilai dari setiap field  
    print('Name: ${nameController.text}');  
    print('Email: ${emailController.text}');  
    print('Password: ${passwordController.text}');  
    print('Confirm Password: ${confirmPasswordController.text}');  
    print('Birth Date: ${dobController.text}');  
    print('City Code: ${cityCodeController.text}');  
    print('Job Type: ${selectedJobType.value}');  
    print('Phone Number: ${phoneNumberController.text}');  
    print('Gender: ${genderController.text}');  

    if (nameController.text.isEmpty ||  
        emailController.text.isEmpty ||  
        passwordController.text.isEmpty ||  
        confirmPasswordController.text.isEmpty ||  
        dobController.text.isEmpty || // Periksa dobController  
        cityCodeController.text.isEmpty ||  
        selectedJobType.value == 0 || // Periksa selectedJobType  
        phoneNumberController.text.isEmpty ||  
        genderController.text.isEmpty) {  
      errorMessage.value = 'Harap lengkapi semua field.';  
      return false;  
    }  

    if (passwordController.text != confirmPasswordController.text) {  
      errorMessage.value = 'Password dan konfirmasi password tidak cocok.';  
      return false;  
    }

    if(!isAgreed.value) {
      errorMessage.value = 'Harap setujui ketentuan dan kebijakan privasi';
    }

    return true;  
  }  

  // Fungsi untuk melakukan registrasi  
  Future<void> register() async {  
    if (!validateForm()) return;  

    isLoading.value = true;  
    errorMessage.value = '';  

    try {  
      // Data yang akan dikirim ke API  
      final Map<String, dynamic> requestBody = {  
        "name": nameController.text,  
        "email": emailController.text,  
        "password": passwordController.text,  
        "password_confirmation": confirmPasswordController.text,  
        "birth_date": dobController.text, // Gunakan dobController  
        "city_code": cityCodeController.text,  
        "job_type": selectedJobType.value.toString(), // Gunakan selectedJobType  
        "phone_number": phoneNumberController.text,  
        "gender": genderController.text,  
      };  

      // Kirim request POST ke API  
      final response = await http.post(  
        Uri.parse('https://ebook.dev.whatthefun.id/api/v1/register'),  
        headers: {'Content-Type': 'application/json'},  
        body: jsonEncode(requestBody),  
      );  

      // Handle response  
      if (response.statusCode == 200 || response.statusCode == 201) {  
        final userResponse = UserResponse.fromJson(jsonDecode(response.body));  
        resetForm();  
      } else {  
        final errorResponse = jsonDecode(response.body);  
        errorMessage.value = errorResponse['message'] ?? 'Registrasi gagal.';  
      }  
    } catch (e) {  
      errorMessage.value = 'Terjadi kesalahan: $e';  
    } finally {  
      isLoading.value = false;  
    }  
  }  

  // Fungsi untuk mencari kota  
  Future<void> fetchCities(String query) async {  
    if (query.isEmpty) {  
      domisiliList.clear(); // Kosongkan daftar jika query kosong  
      return;  
    }  

    debugPrint('🔄 Searching cities with query: $query');  

    try {  
      final response = await http.get(  
        Uri.parse(  
            'https://ebook.dev.whatthefun.id/api/v1/register/cities?search=$query'),  
        headers: {  
          'Content-Type': 'application/json',  
          'Accept': 'application/json',  
        },  
      );  

      if (response.statusCode != 200) {  
        Get.snackbar('Error', 'Failed to search cities');  
        debugPrint('Error response: ${response.body}');  
        return;  
      }  

      final jsonResponse = json.decode(response.body);  
      if (jsonResponse['data'] == null) {  
        Get.snackbar('No Data', 'No cities found.');  
        return;  
      }  

      // Parsing data kota  
      domisiliList.value = List<Map<String, dynamic>>.from(  
        jsonResponse['data'].map((city) => {  
              'name': city['name'],  
              'code': city['code'],  
            }),  
      );  

      debugPrint('✅ Cities fetched successfully: $domisiliList');  
    } catch (e) {  
      Get.snackbar('Error', 'An error occurred while searching cities.');  
      debugPrint("Error searching cities: $e");  
    }  
  }  

  void onCitySelected(Map<String, dynamic> city) {  
    // Implementasi saat kota dipilih  
    cityCodeController.text = city['code'];  
    domisiliList.clear(); // Kosongkan daftar setelah memilih kota  
  }  

  // Fungsi untuk mereset form  
  void resetForm() {  
    nameController.clear();  
    emailController.clear();  
    passwordController.clear();  
    confirmPasswordController.clear();  
    dobController.clear();  
    cityCodeController.clear();  
    phoneNumberController.clear();  
    genderController.clear();  
    domisiliController.clear();  
    domisiliList.clear();  
    selectedJobType.value = 0; // Reset pekerjaan  
  }  

  @override  
  void onClose() {  
    // Dispose semua controller saat controller dihapus  
    nameController.dispose();  
    emailController.dispose();  
    passwordController.dispose();  
    confirmPasswordController.dispose();  
    dobController.dispose();  
    cityCodeController.dispose();  
    phoneNumberController.dispose();  
    genderController.dispose();  
    domisiliController.dispose();  
    super.onClose();  
  }  
}