import 'package:ebookapp/app/modules/settings/controllers/setting_theme_controller.dart';
import 'package:ebookapp/app/modules/settings/controllers/user_controller.dart';
import 'package:get/get.dart';

import '../controllers/content_controller.dart';

class ContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContentController>(
      () => ContentController(),
    );
    Get.lazyPut<ThemeController>(
      () => ThemeController(),
    );
    Get.lazyPut<UserController>(
      () => UserController(),
    );
  }
}