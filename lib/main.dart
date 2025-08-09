import 'package:flutter/material.dart';

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await deleteDatabase(join(await getDatabasesPath(), 'autocare.db'));
  runApp(const AutoCareApp());
}

class AutoCareApp extends StatelessWidget {
  const AutoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoCare+',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
