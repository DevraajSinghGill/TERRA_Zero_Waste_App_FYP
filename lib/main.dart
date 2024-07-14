import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/chatbot/consts.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/controllers/comment_controller.dart';
import 'package:terra_zero_waste_app/controllers/post_controller.dart';
import 'package:terra_zero_waste_app/controllers/user_controller.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/task_group_provider.dart';
import 'package:terra_zero_waste_app/screens/splash/splash_screen.dart';
import 'package:terra_zero_waste_app/controllers/image_controller.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(apiKey: GEMENI_API_KEY);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      ensureScreenSize: true,
      designSize: Size(373, 650),
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ImageController()),
            ChangeNotifierProvider(create: (_) => LoadingController()),
            ChangeNotifierProvider(create: (_) => UserController()),
            ChangeNotifierProvider(create: (_) => PostController()),
            ChangeNotifierProvider(create: (_) => CommentController()),
            ChangeNotifierProvider(create: (_) => TaskProvider()), // Add TaskProvider here
          ],
          child: GetMaterialApp(
            title: 'TERRA Zero Waste App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                centerTitle: true,
                backgroundColor: Colors.green[900], 
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, 
                ),
                iconTheme: IconThemeData(color: Colors.white), 
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.2)),
              child: const SplashScreen(),
            ),
          ),
        );
      },
    );
  }
}
