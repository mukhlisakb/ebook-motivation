import 'package:ebookapp/app/routes/app_pages.dart';
import 'package:ebookapp/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ebookapp/app/modules/register/controllers/register_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RegisterPage extends GetView<RegisterController> {
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Watermark.png'),
            fit: BoxFit.cover, // Mengatur gambar agar menutupi seluruh area
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buat Akun',
                  style: GoogleFonts.leagueSpartan(
                      fontSize: 35, fontWeight: FontWeight.bold)),
              Text(
                'Data yang di isi hanya dapat dilihat oleh kamu\ndan tim support kami.',
                style: GoogleFonts.leagueSpartan(
                    fontSize: 14, color: Colors.black54),
              ),
              SizedBox(height: 20),
              // Form Fields
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle: GoogleFonts.leagueSpartan(
                      color: Colors.black26, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GoogleFonts.leagueSpartan(
                      color: Colors.black26, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Dropdown untuk Jenis Kelamin
              DropdownButtonFormField2<String>(
                decoration: InputDecoration(
                  labelText: 'Jenis Kelamin',
                  labelStyle: GoogleFonts.leagueSpartan(
                      color: Colors.black26, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                isExpanded: true,
                hint: Text('Pilih Jenis Kelamin', style: GoogleFonts.leagueSpartan(
                        color: Colors.black26, fontSize: 14),),
                value: controller.genderController.text.isEmpty
                    ? null
                    : controller.genderController.text,
                onChanged: (newValue) {
                  controller.genderController.text = newValue!;
                },
                items: [
                  DropdownMenuItem(value: 'M', child: Text('Pria')),
                  DropdownMenuItem(value: 'F', child: Text('Wanita')),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller.phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  labelStyle: GoogleFonts.leagueSpartan(
                      color: Colors.black26, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller.dobController,
                decoration: InputDecoration(
                  labelText: 'Kapan ulang tahun mu?',
                  labelStyle: GoogleFonts.leagueSpartan(
                      color: Colors.black26, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    controller.dobController.text = formattedDate;
                  }
                },
              ),
              SizedBox(height: 16),
              // TextField untuk Domisili
              TextField(
                controller: controller.domisiliController,
                decoration: InputDecoration(
                  labelText: 'Domisili (Kota/Kabupaten)',
                  labelStyle: GoogleFonts.leagueSpartan(
                      color: Colors.black26, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: (value) {
                  controller.fetchCities(value);
                },
              ),
              Obx(() {
                if (controller.domisiliList.isNotEmpty) {
                  return Container(
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.domisiliList.length,
                      itemBuilder: (context, index) {
                        final city = controller.domisiliList[index];
                        return ListTile(
                          title: Text(city['name']),
                          onTap: () {
                            controller.onCitySelected(city);
                            controller.domisiliController.text = city['name'];
                            controller.domisiliList.clear();
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
              SizedBox(height: 16),
              // Dropdown untuk Pekerjaan
              Obx(() {
                return DropdownButtonFormField2<int>(
                  decoration: InputDecoration(
                    labelText: 'Pekerjaan',
                    labelStyle: GoogleFonts.leagueSpartan(
                        color: Colors.black26, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  isExpanded: true,
                  hint: Text('Pilih Pekerjaan', style: GoogleFonts.leagueSpartan(
                        color: Colors.black26, fontSize: 14),),
                  value: controller.selectedJobType.value == 0
                      ? null
                      : controller.selectedJobType.value,
                  onChanged: (newValue) {
                    controller.selectedJobType.value = newValue!;
                  },
                  items: [
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
              }),
              SizedBox(height: 20),
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          // Periksa apakah gender dan pekerjaan sudah dipilih
                          if (controller.genderController.text.isEmpty ||
                              controller.selectedJobType.value == 0) {
                            Get.snackbar('Error',
                                'Silakan pilih jenis kelamin dan pekerjaan.');
                            return;
                          }
                          controller.register();
                          Get.toNamed(Routes.confirmPass);
                        },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: controller.isLoading.value
                        ? CircularProgressIndicator()
                        : Text(
                            'Selanjutnya',
                            style: GoogleFonts.leagueSpartan(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorBackground,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: GoogleFonts.leagueSpartan(
                        fontSize: 16, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
