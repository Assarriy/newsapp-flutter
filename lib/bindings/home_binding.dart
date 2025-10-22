// lib/bindings/home_binding.dart

import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/services/news_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Anda bisa mendaftarkan service di sini jika hanya digunakan untuk home
    // Namun, lebih baik mendaftarkannya di AppBindings agar tersedia global.

    // Saat mendaftarkan NewsController, berikan NewsService menggunakan Get.find()
    Get.lazyPut<NewsController>(() => NewsController(Get.find()));
  }
}