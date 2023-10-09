import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:blog_explorer/blog_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox('blogBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SubSpace'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: AnimatedSplashScreen(
          splash: Image.asset("images/logo.png"),
          splashIconSize: double.infinity,
          duration: 1500,
          splashTransition: SplashTransition.fadeTransition,
          animationDuration: const Duration(seconds: 1),
          backgroundColor: Colors.black,
          // nextScreen: RegisterPage(),
          nextScreen: blog_page(),
        ),
    );
  }
}
