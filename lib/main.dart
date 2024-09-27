import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/connnection_check/connection_check_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: white,
        primaryColor: orange,
        fontFamily: "Gilroy",
        appBarTheme: AppBarTheme(
          backgroundColor: white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const ConnectionCheckView(),
    );
  }
}
