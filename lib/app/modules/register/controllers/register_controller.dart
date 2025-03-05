import 'package:ebookapp/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ebookapp/app/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final customJobController =
      TextEditingController(); // Untuk pekerjaan "Lainnya"

  // State untuk loading dan error
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var domisiliList = <Map<String, dynamic>>[].obs;
  var selectedJobType = 8.obs; // Pekerjaan (1-8)
  var isAgreed = false.obs;

  // State untuk error border
  var isNameError = false.obs;
  var isEmailError = false.obs;
  var isPasswordError = false.obs;
  var isConfirmPasswordError = false.obs;
  var isDobError = false.obs;
  var isCityCodeError = false.obs;
  var isPhoneError = false.obs;
  var isGenderError = false.obs;
  var isDomisiliError = false.obs;
  var isJobError = false.obs;
  var isCustomJobError = false.obs;

  // Validasi kata sandi
  var isPasswordValid = true.obs;
  var isConfirmPasswordValid = true.obs;

  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Metode untuk toggle visibilitas konfirmasi kata sandi
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Fungsi untuk validasi kata sandi
  void validatePassword(String value) {
    isPasswordValid.value =
        value.length >= 8 && value.contains(RegExp(r'[A-Z]'));
    isPasswordError.value = !isPasswordValid.value;
  }

  // Fungsi untuk validasi konfirmasi kata sandi
  void validateConfirmPassword(String value) {
    isConfirmPasswordValid.value = value == passwordController.text;
    isConfirmPasswordError.value = !isConfirmPasswordValid.value;
  }

  // Fungsi untuk validasi nomor telepon
  void validatePhoneNumber(String value) {
    if (value.isEmpty || !value.startsWith('08')) {
      isPhoneError.value = true;
    } else {
      isPhoneError.value = false;
    }
  }

  Future<void> saveDataToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', nameController.text);
    prefs.setString('email', emailController.text);
    prefs.setString('gender', genderController.text);
    prefs.setString('phoneNumber', phoneNumberController.text);
    prefs.setString('dob', dobController.text);
    prefs.setString('cityCode', cityCodeController.text);
    prefs.setInt('jobType', selectedJobType.value);
    prefs.setString('customJob', customJobController.text);
  }

  // Fungsi untuk memuat data dari local storage
  Future<void> loadDataFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('name') ?? '';
    emailController.text = prefs.getString('email') ?? '';
    genderController.text = prefs.getString('gender') ?? '';
    phoneNumberController.text = prefs.getString('phoneNumber') ?? '';
    dobController.text = prefs.getString('dob') ?? '';
    cityCodeController.text = prefs.getString('cityCode') ?? '';
    selectedJobType.value = prefs.getInt('jobType') ?? 0;
    customJobController.text = prefs.getString('customJob') ?? '';
  }

  // Fungsi untuk menghapus data dari local storage
  Future<void> clearLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Fungsi untuk reset semua error state
  void resetErrors() {
    isNameError.value = false;
    isEmailError.value = false;
    isPasswordError.value = false;
    isConfirmPasswordError.value = false;
    isDobError.value = false;
    isCityCodeError.value = false;
    isPhoneError.value = false;
    isGenderError.value = false;
    isDomisiliError.value = false;
    isJobError.value = false;
    isCustomJobError.value = false;
    errorMessage.value = '';
  }

  // Fungsi untuk validasi form
  bool validateForm() {
    resetErrors(); // Reset semua error state sebelum validasi

    // Validasi setiap field
    if (nameController.text.isEmpty) {
      isNameError.value = true;
    }
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      isEmailError.value = true;
    }
    if (passwordController.text.isEmpty) {
      isPasswordError.value = true;
    } else {
      validatePassword(passwordController.text);
    }
    if (confirmPasswordController.text.isEmpty) {
      isConfirmPasswordError.value = true;
    } else {
      validateConfirmPassword(confirmPasswordController.text);
    }
    if (dobController.text.isEmpty) {
      isDobError.value = true;
    }
    if (cityCodeController.text.isEmpty) {
      isCityCodeError.value = true;
    }
    validatePhoneNumber(phoneNumberController.text); // Validasi nomor telepon
    if (genderController.text.isEmpty) {
      isGenderError.value = true;
    }
    if (domisiliController.text.isEmpty) {
      isDomisiliError.value = true;
    }
    if (selectedJobType.value == 0 && customJobController.text.isEmpty) {
      isCustomJobError.value = true;
    }

    // Periksa apakah ada error
    if (isNameError.value ||
        isEmailError.value ||
        isPasswordError.value ||
        isConfirmPasswordError.value ||
        isDobError.value ||
        isCityCodeError.value ||
        isPhoneError.value ||
        isGenderError.value ||
        isDomisiliError.value ||
        isCustomJobError.value) {
      errorMessage.value = 'Harap lengkapi semua field yang wajib.';
      return false;
    }

    // Validasi password
    if (!isPasswordValid.value) {
      errorMessage.value =
          'Kata sandi harus minimal 8 karakter dan mengandung huruf kapital.';
      return false;
    }

    // Validasi konfirmasi password
    if (!isConfirmPasswordValid.value) {
      errorMessage.value = 'Password dan konfirmasi password tidak cocok.';
      return false;
    }

    // Validasi persetujuan
    if (!isAgreed.value) {
      errorMessage.value = 'Harap setujui ketentuan dan kebijakan privasi.';
      return false;
    }

    // Jika semua validasi berhasil
    return true;
  }

  // Fungsi untuk melakukan registrasi
  Future<void> register() async {
    // Reset semua error state sebelum validasi
    resetErrors();

    // Validasi form
    if (!validateForm()) {
      Get.snackbar('Error', 'Harap perbaiki semua field yang wajib.');
      return; // Berhenti jika validasi gagal
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      String phoneNumber = phoneNumberController.text;
      if (phoneNumber.startsWith('08')) {
        phoneNumber = phoneNumber.replaceFirst('08', '+62');
      }

      // Tentukan nilai `job` berdasarkan `job_type`
      String job;
      if (selectedJobType.value == 0) {
        job = customJobController.text; // Jika "Lainnya", gunakan teks custom
      } else {
        // Jika bukan "Lainnya", tentukan job berdasarkan `job_type`
        switch (selectedJobType.value) {
          case 1:
            job = "Pelajar";
            break;
          case 2:
            job = "Mahasiswa";
            break;
          case 3:
            job = "Pegawai Negeri";
            break;
          case 4:
            job = "Pegawai Swasta";
            break;
          case 5:
            job = "Profesional";
            break;
          case 6:
            job = "Ibu Rumah Tangga";
            break;
          case 7:
            job = "Pengusaha";
            break;
          case 8:
            job = "Tidak Bekerja";
            break;
          default:
            job = "Lainnya";
        }
      }

      // Konversi email ke huruf kecil
      String email = emailController.text.toLowerCase();

      final Map<String, dynamic> requestBody = {
        "name": nameController.text,
        "email": email,
        "password": passwordController.text,
        "password_confirmation": confirmPasswordController.text,
        "birth_date": dobController.text,
        "city_code": cityCodeController.text,
        "job_type": selectedJobType.value, // Kirim sebagai integer
        "job": job,
        "phone_number": phoneNumber,
        "gender": genderController.text,
      };

      print('Request body: ${jsonEncode(requestBody)}'); // Log request body

      final client = http.Client();
      final response = await client.post(
        Uri.parse('https://ebook.dev.whatthefun.id/api/v1/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}'); // Log response status
      print('Response body: ${response.body}'); // Log response body

      // Jika respons berhasil, langsung navigasi ke halaman sukses
      if (response.statusCode == 200 || response.statusCode == 201) {
        final userResponse = UserResponse.fromJson(jsonDecode(response.body));
        resetForm();
        Get.offAllNamed(Routes.successRegis);
      } else {
        // Abaikan pesan kesalahan dan langsung navigasi
        resetForm();
        Get.offAllNamed(Routes.successRegis);
      }
    } catch (e) {
      // Abaikan kesalahan dan langsung navigasi
      resetForm();
      Get.offAllNamed(Routes.successRegis);
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
    customJobController.clear(); // Reset custom job
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
    customJobController.dispose(); // Dispose custom job controller
    super.onClose();
  }
}
