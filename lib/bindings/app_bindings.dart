// lib/bindings/app_bindings.dart

import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/services/news_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // 1. Daftarkan NewsService terlebih dahulu
    Get.lazyPut<NewsService>(() => NewsService());

    // 2. Saat mendaftarkan NewsController, berikan NewsService menggunakan Get.find()
    Get.put<NewsController>(NewsController(Get.find()), permanent: true);
  }
}