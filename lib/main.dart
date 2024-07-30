import 'package:flutter/material.dart';
import 'package:passtrackdash/colors.dart';
import 'package:passtrackdash/components/auth.dart';
//import 'package:passtrackdash/pages/sign.dart';
import 'package:passtrackdash/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volcano Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: mcgpalette0[50]!),
        useMaterial3: true,
      ),
      home: AuthService().handleAuthState(),
    );
  }
}
