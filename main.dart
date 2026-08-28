import 'package:flutter/material.dart';
import 'package:nagajob/Frontend-jobseeker/seeker_profile.dart';
import 'package:nagajob/screen_login.dart'; 
import 'package:provider/provider.dart';

import 'Frontend-jobposting/post_vacancy.dart';
import 'Frontend-jobposting/post_vacancy_provider.dart';
import 'admin_provider.dart';
import 'auth_provider.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VacancyProvider()), // Add this line
        ChangeNotifierProvider(create: (_) => AdminProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(   
      title: 'NEIS',
      theme: ThemeData( 
        useMaterial3: true,
        // This forces the app to use your local pubspec.yaml asset
        fontFamily: 'Roboto', 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // Set the Staff Dashboard as your temporary home screen to test it!
      home: const ScreenLogin(), 
    );
  }
}
// ScreenStaffLogin

// "Naga Job: Job Vacancies Management System",

// admin@naga.gov.ph
// admin123

// mark@gmail.com
// a01b63a4
// node server.js

// angelo@gmail.com
// 3a58e391