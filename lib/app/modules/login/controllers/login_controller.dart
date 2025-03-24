// import 'dart:convert';
// import 'package:ebookapp/core/utlis/api_endpoint.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// class LoginController extends GetxController {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passController = TextEditingController();
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   RxBool isHidden = true.obs;

//   // Cek apakah pengguna sudah login
//   RxBool isLoggedIn = false.obs;

//   // State untuk error border
//   RxBool isEmailError = false.obs;
//   RxBool isPasswordError = false.obs;

//   // State untuk menyimpan pesan kesalahan
//   RxString errorMessage = ''.obs;

//   // Constructor
//   LoginController() {
//     _checkLoginStatus();
//   }

//   // Fungsi untuk memeriksa status login
//   Future<void> _checkLoginStatus() async {
//     final SharedPreferences prefs = await _prefs;
//     String? token = prefs.getString('token');

//     if (token != null) {
//       isLoggedIn.value = true;
//       // Navigasi ke HomePage jika sudah login
//       Get.offAllNamed('/home');
//     }
//   }

//   // Fungsi untuk login dengan email dan password
//   Future<bool> loginWithEmail() async {
//     var headers = {'Content-Type': 'application/json'};

//     try {
//       var url =
//           Uri.parse(ApiEndpoint.baseUrl + ApiEndpoint.authEndPoint.loginEmail);
//       Map<String, String> body = {
//         'email': emailController.text.trim(),
//         'password': passController.text
//       };

//       // Kirim request POST ke server
//       http.Response response =
//           await http.post(url, body: jsonEncode(body), headers: headers);

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);

//         // Cek apakah login berhasil (code == 0)
//         if (json['data'] != null && json['data']['token'] != null) {
//           var token = json['data']['token'];

//           // Simpan token ke SharedPreferences
//           final SharedPreferences prefs = await _prefs;
//           await prefs.setString('token', token);

//           // Set status login berhasil
//           isLoggedIn.value = true;

//           // Navigasi ke HomePage
//           Get.offAllNamed(
//               '/home'); // Menggunakan GetX untuk navigasi ke halaman Home
//           return true; // Login berhasil
//         } else {
//           // Jika login gagal, set error state dan pesan
//           setErrorState();
//           errorMessage.value = 'Email atau kata sandi yang ada masukkan salah';
//           Get.snackbar('Login Failed', errorMessage.value);
//           return false; // Login gagal
//         }
//       } else {
//         // Jika login gagal, set error state
//         setErrorState();
//         errorMessage.value = 'Email atau kata sandi yang ada masukkan salah';
//         Get.snackbar('Login Failed', errorMessage.value);
//         return false; // Login gagal
//       }
//     } catch (e) {
//       // Tangani error seperti koneksi internet yang hilang
//       setErrorState();
//       errorMessage.value = 'An error occurred. Please try again.';
//       Get.snackbar('Login Failed', errorMessage.value);
//       return false; // Login gagal
//     }
//   }

//   // Metode untuk mengaktifkan state error (border merah)
//   void setErrorState() {
//     isEmailError.value = true;
//     isPasswordError.value = true;
//   }

//   // Metode untuk mereset state error saat pengguna mulai mengetik
//   void resetErrorState() {
//     isEmailError.value = false;
//     isPasswordError.value = false;
//   }
// }

// import 'dart:convert';
// import 'package:ebookapp/core/utlis/api_endpoint.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// class LoginController extends GetxController {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passController = TextEditingController();
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   RxBool isHidden = true.obs;

//   // Cek apakah pengguna sudah login
//   RxBool isLoggedIn = false.obs;

//   // State untuk error border
//   RxBool isEmailError = false.obs;
//   RxBool isPasswordError = false.obs;

//   // State untuk menyimpan pesan kesalahan
//   RxString errorMessage = ''.obs;

//   // Constructor
//   LoginController() {
//     _checkLoginStatus();
//   }

//   // Fungsi untuk memeriksa status login
//   Future<void> _checkLoginStatus() async {
//     final SharedPreferences prefs = await _prefs;
//     String? token = prefs.getString('token');

//     if (token != null) {
//       isLoggedIn.value = true;
//       // Navigasi ke HomePage jika sudah login
//       Get.offAllNamed('/home');
//     }
//   }

//   // Fungsi untuk login dengan email dan password
//   Future<bool> loginWithEmail() async {
//     var headers = {'Content-Type': 'application/json'};

//     try {
//       var url =
//           Uri.parse(ApiEndpoint.baseUrl + ApiEndpoint.authEndPoint.loginEmail);
//       Map<String, String> body = {
//         'email': emailController.text.trim(),
//         'password': passController.text
//       };

//       // Kirim request POST ke server
//       http.Response response =
//           await http.post(url, body: jsonEncode(body), headers: headers);

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);

//         // Cek apakah login berhasil (code == 0)
//         if (json['data'] != null && json['data']['token'] != null) {
//           var token = json['data']['token'];

//           // Simpan token ke SharedPreferences
//           final SharedPreferences prefs = await _prefs;
//           await prefs.setString('token', token);

//           // Set status login berhasil
//           isLoggedIn.value = true;

//           // Navigasi ke HomePage
//           Get.offAllNamed(
//               '/home'); // Menggunakan GetX untuk navigasi ke halaman Home
//           return true; // Login berhasil
//         } else {
//           // Jika login gagal, set error state dan pesan
//           setErrorState();
//           errorMessage.value = 'Email atau kata sandi yang ada masukkan salah';
//           Get.snackbar('Login Gagal', errorMessage.value);
//           return false; // Login gagal
//         }
//       } else {
//         // Jika login gagal, set error state
//         setErrorState();
//         errorMessage.value = 'Email atau kata sandi yang ada masukkan salah';
//         Get.snackbar('Login Gagal', errorMessage.value);
//         return false; // Login gagal
//       }
//     } catch (e) {
//       // Tangani error seperti koneksi internet yang hilang
//       setErrorState();
//       errorMessage.value = 'Silahkan Coba Kembali.';
//       Get.snackbar('Login Gagal', errorMessage.value);
//       return false; // Login gagal
//     }
//   }

//   // Fungsi untuk mengatur ulang kata sandi (Forgot Password)
//   Future<bool> forgotPassword(String email) async {
//     // Navigasi langsung ke halaman sukses
//     Get.offAllNamed('/success-forgot');

//     var headers = {'Content-Type': 'application/json'};

//     try {
//       var url =
//           Uri.parse('https://ebook.dev.whatthefun.id/api/v1/forgot-password');
//       Map<String, String> body = {
//         'email': email.trim(),
//       };

//       // Kirim request POST ke server
//       http.Response response =
//           await http.post(url, body: jsonEncode(body), headers: headers);

//       // Debugging: print status code and response body
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       // Berikut ini dapat Anda hapus jika tidak perlu memeriksa respons server
//       if (response.statusCode == 200) {
//         if (response.body.isNotEmpty) {
//           final json = jsonDecode(response.body);
//           Get.snackbar('Berhasil', json['message']); // Tampilkan pesan sukses
//         } else {
//           Get.snackbar('Gagal', 'Respons dari server kosong.');
//         }
//       } else {
//         // Tangani kesalahan dari server
//         final json = jsonDecode(response.body);
//         Get.snackbar('Gagal',
//             json['message'] ?? 'Gagal mengirim email untuk reset kata sandi.');
//       }
//     } catch (e) {
//       // Tangani error
//       print('Error occurred: $e'); // Untuk debugging
//       Get.snackbar('Gagal', 'Terjadi kesalahan, silakan coba lagi.');
//     }

//     return true; // Kembali true seiring permintaan
//   }

//   // Metode untuk mengaktifkan state error (border merah)
//   void setErrorState() {
//     isEmailError.value = true;
//     isPasswordError.value = true;
//   }

//   // Metode untuk mereset state error saat pengguna mulai mengetik
//   void resetErrorState() {
//     isEmailError.value = false;
//     isPasswordError.value = false;
//   }
// }

import 'dart:convert';
import 'package:ebookapp/core/utlis/api_endpoint.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  // TextEditingController untuk email dan password
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // State untuk menampilkan atau menyembunyikan password
  RxBool isHidden = true.obs;

  // State untuk status login
  RxBool isLoggedIn = false.obs;

  // State untuk error border
  RxBool isEmailError = false.obs;
  RxBool isPasswordError = false.obs;

  // State untuk menyimpan pesan kesalahan
  RxString errorMessage = ''.obs;

  // Constructor
  LoginController() {
    _checkLoginStatus();
  }

  // Fungsi untuk memeriksa status login
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString('token');

    // Jika token ada, pengguna sudah login
    if (token != null) {
      isLoggedIn.value = true;
      Get.offAllNamed('/home'); // Navigasi ke halaman Home
    }
  }

  // Fungsi untuk login dengan email dan password
  Future<bool> loginWithEmail() async {
    var headers = {'Content-Type': 'application/json'};

    try {
      // Endpoint login
      var url =
          Uri.parse(ApiEndpoint.baseUrl + ApiEndpoint.authEndPoint.loginEmail);
      Map<String, String> body = {
        'email': emailController.text.trim(),
        'password': passController.text,
      };

      // Kirim request POST ke server
      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);

      // Cek status respons dari server
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Cek apakah login berhasil (token tersedia)
        if (json['data'] != null && json['data']['token'] != null) {
          var token = json['data']['token'];

          // Simpan token ke SharedPreferences
          final SharedPreferences prefs = await _prefs;
          await prefs.setString('token', token);

          isLoggedIn.value = true; // Set status login berhasil
          Get.offAllNamed('/home'); // Navigasi ke halaman Home
          return true; // Login berhasil
        } else {
          // Jika login gagal, set error state dan pesan
          setErrorState();
          errorMessage.value = 'Email atau kata sandi yang dimasukkan salah';
          Get.snackbar('Login Gagal', errorMessage.value);
          return false; // Login gagal
        }
      } else {
        // Jika server mengembalikan error
        setErrorState();
        errorMessage.value = 'Email atau kata sandi yang dimasukkan salah';
        Get.snackbar('Login Gagal', errorMessage.value);
        return false; // Login gagal
      }
    } catch (e) {
      // Tangani error
      setErrorState();
      errorMessage.value = 'Silahkan Coba Kembali.';
      Get.snackbar('Login Gagal', errorMessage.value);
      return false; // Login gagal
    }
  }

  // Fungsi untuk mengatur ulang kata sandi (Forgot Password)
  Future<bool> forgotPassword(String email) async {
    // Navigasi langsung ke halaman sukses
    Get.offAllNamed('/success-forgot');

    var headers = {'Content-Type': 'application/json'};

    try {
      var url =
          Uri.parse('https://ebook.dev.whatthefun.id/api/v1/forgot-password');
      Map<String, String> body = {
        'email': email.trim(),
      };

      // Kirim request POST ke server
      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        Get.snackbar('Berhasil', json['message']); // Tampilkan pesan sukses
      } else {
        // Tangani kesalahan dari server
        final json = jsonDecode(response.body);
        Get.snackbar('Gagal',
            json['message'] ?? 'Gagal mengirim email untuk reset kata sandi.');
      }
    } catch (e) {
      // Tangani error
      Get.snackbar('Gagal', 'Terjadi kesalahan, silakan coba lagi.');
    }

    return true; // Kembali true seiring permintaan
  }

  // Metode untuk mengatur state error (border merah)
  void setErrorState() {
    isEmailError.value = true;
    isPasswordError.value = true;
  }

  // Metode untuk mereset state error saat pengguna mulai mengetik
  void resetErrorState() {
    isEmailError.value = false;
    isPasswordError.value = false;
  }
}
