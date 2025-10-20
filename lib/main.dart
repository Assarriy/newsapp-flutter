import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:news_app/bindings/app_bindings.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      
      // PERBAIKAN: Menggunakan ThemeData untuk tema gelap yang konsisten
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent, // Warna utama adalah merah tua
        
        // Skema warna untuk konsistensi di seluruh widget Flutter
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accent,
          background: AppColors.background,
        ),
        
        // Tema AppBar default
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background, // Cocok dengan background layar
          foregroundColor: AppColors.primaryText, // Warna ikon dan judul
          elevation: 0,
        ),
        
        // Tema Tombol default
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent, // Tombol menggunakan warna aksen
            foregroundColor: AppColors.primaryText, // Teks di tombol berwarna putih
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Tema Teks default
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.primaryText),
          bodyMedium: TextStyle(color: AppColors.secondaryText),
        ),
      ),
      
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
    );
  }
}