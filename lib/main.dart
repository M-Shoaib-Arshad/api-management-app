import 'package:flutter/material.dart';
import 'screens/users_list_screen.dart';

void main() {
  runApp(const ApiManagementApp());
}

class ApiManagementApp extends StatelessWidget {
  const ApiManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 2,
        ),
      ),
      home: const UsersListScreen(),
    );
  }
}
