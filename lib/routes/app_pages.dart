import 'package:get/get.dart';
import 'package:news_app/bindings/home_binding.dart';
import 'package:news_app/views/home_view.dart';
import 'package:news_app/views/news_detail_view.dart';
import 'package:news_app/views/search_view.dart';
import 'package:news_app/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: _Paths.SPLASH, page: () => SplashView()),
    GetPage(name: _Paths.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(name: _Paths.NEWS_DETAIL, page: () => NewsDetailView()),

    GetPage(
      name: Routes.SEARCH,
      page: () => const SearchView(),
      // Transisi yang lebih cocok untuk halaman pencarian
      transition: Transition.downToUp,
    ),
  ];
}
