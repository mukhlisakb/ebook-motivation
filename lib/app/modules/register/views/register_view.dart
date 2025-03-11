import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ebookapp/app/modules/register/controllers/register_controller.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RegisterPage extends GetView<RegisterController> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Text('Buat Akun',
            //     style: GoogleFonts.leagueSpartan(
            //         fontSize: 35, fontWeight: FontWeight.bold)),
            // SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildNameStep(),
                  _buildEmailStep(),
                  _buildPhoneStep(),
                  _buildDobStep(),
                  _buildDomisiliStep(),
                  _buildJobStep(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _goBack,
                  child: Text('Kembali'),
                ),
                ElevatedButton(
                  onPressed: _goNext,
                  child: Text('Selanjutnya'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hallo, kenalan dulu yuk!',
            style: GoogleFonts.leagueSpartan(
                fontSize: 34, fontWeight: FontWeight.bold)),
        Text('Siapa Nama kamu?',
            style: GoogleFonts.leagueSpartan(fontSize: 14)),
        SizedBox(height: 20),
        _buildTextFormField(
          controller: controller.nameController,
          label: 'Nama',
          isError: controller.isNameError.value,
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Terima kasih, [Nama]! Silakan, masukkan email kamu.',
            style: GoogleFonts.leagueSpartan(fontSize: 18)),
        SizedBox(height: 20),
        _buildTextFormField(
          controller: controller.emailController,
          label: 'Email',
          isError: controller.isEmailError.value,
        ),
      ],
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Agar kami bisa lebih dekat denganmu...',
            style: GoogleFonts.leagueSpartan(fontSize: 18)),
        SizedBox(height: 20),
        _buildTextFormField(
          controller: controller.phoneNumberController,
          label: 'Nomor Telepon',
          isError: controller.isPhoneError.value,
          onChanged: (value) {
            if (!value.startsWith('08')) {
              controller.isPhoneError.value = true;
            } else {
              controller.isPhoneError.value = false;
            }
          },
        ),
      ],
    );
  }

  Widget _buildDobStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ulang tahunmu spesial! Kapan hari lahirmu?',
            style: GoogleFonts.leagueSpartan(fontSize: 18)),
        SizedBox(height: 20),
        _buildDateField(),
      ],
    );
  }

  Widget _buildDomisiliStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Biar kami tahu lebih banyak tentangmu...',
            style: GoogleFonts.leagueSpartan(fontSize: 18)),
        SizedBox(height: 20),
        _buildTextFormField(
          controller: controller.domisiliController,
          label: 'Domisili (Kota/Kabupaten)',
          isError: controller.isDomisiliError.value,
          onChanged: (value) {
            controller.fetchCities(value);
          },
        ),
      ],
    );
  }

  Widget _buildJobStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hampir selesai! Boleh tahu pekerjaanmu saat ini?',
            style: GoogleFonts.leagueSpartan(fontSize: 18)),
        SizedBox(height: 20),
        _buildJobDropdown(),
        Obx(() {
          if (controller.selectedJobType.value == 0) {
            // "Lainnya"
            return _buildTextFormField(
              controller: controller.customJobController,
              label: 'Tuliskan Pekerjaan',
              isError: controller.isCustomJobError.value,
            );
          }
          return SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool isError = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.leagueSpartan(color: Colors.black26, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.grey,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: controller.dobController,
      decoration: InputDecoration(
        labelText: 'Kapan ulang tahun mu?',
        labelStyle:
            GoogleFonts.leagueSpartan(color: Colors.black26, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          controller.dobController.text = formattedDate;
        }
      },
    );
  }

  Widget _buildJobDropdown() {
    return DropdownButtonFormField2<int>(
      decoration: InputDecoration(
        labelText: 'Pekerjaan',
        labelStyle:
            GoogleFonts.leagueSpartan(color: Colors.black26, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      isExpanded: true,
      value: controller.selectedJobType.value,
      onChanged: (newValue) {
        controller.selectedJobType.value = newValue!;
      },
      items: [
        DropdownMenuItem(value: 0, child: Text('Lainnya')),
        DropdownMenuItem(value: 1, child: Text('Pelajar')),
        DropdownMenuItem(value: 2, child: Text('Mahasiswa')),
        DropdownMenuItem(value: 3, child: Text('Pegawai Negeri')),
        DropdownMenuItem(value: 4, child: Text('Pegawai Swasta')),
        DropdownMenuItem(value: 5, child: Text('Profesional')),
        DropdownMenuItem(value: 6, child: Text('Ibu Rumah Tangga')),
        DropdownMenuItem(value: 7, child: Text('Pengusaha')),
        DropdownMenuItem(value: 8, child: Text('Tidak Bekerja')),
      ],
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _goNext() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}
