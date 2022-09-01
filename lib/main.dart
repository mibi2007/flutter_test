// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

void main() {
  runApp(ExampleApp());
}

class AppColors {
  static const Color primaryBlue = Color(0xFF2C3D5B);
  static const Color secondaryBlue = Color(0xFF315D93);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color orange = Color(0xFFFB7200);
  static const Color lightOrange1 = Color(0xFFFB923C);
  static const Color lightOrange2 = Color(0xFFFDBA74);
  static const Color lightOrange3 = Color(0xFFFDBA74);
  static const Color lightOrange4 = Color(0xFFFFEDD5);
  static const Color darkEmerald = Color(0xFF109867);
  static const Color emerald = Color(0xFF34D399);
  static const Color emerald1 = Color(0xFF6EE7B7);
  static const Color emerald2 = Color(0xFFA7F3D0);
  static const Color emerald3 = Color(0xFFD1FAE5);
  static const Color darkRed = Color(0xFFB90F0F);
  static const Color red = Color(0xFFEF4444);
  static const Color red1 = Color(0xFFFEE2E2);
  static const Color lightBlue1 = Color(0xFF06A5FF);
  static const Color lightBlue2 = Color(0xFF27B1FF);
  static const Color lightBlue3 = Color(0xFF5BC3FE);
  static const Color lightBlue4 = Color(0xFF98D6FA);
  static const Color lightBlue5 = Color(0xFFB6E5FF);
  static const Color lightBlue6 = Color(0xFFD0EEFF);
  static const Color blueGray50 = Color(0xFFF8FAFC);
  static const Color blueGray100 = Color(0xFFF1F5F9);
  static const Color blueGray200 = Color(0xFFE2E8F0);
  static const Color blueGray300 = Color(0xFFCBD5E1);
  static const Color blueGray400 = Color(0xFF94A3B8);
  static const Color blueGray500 = Color(0xFF64748B);
  static const Color blueGray600 = Color(0xFF475569);
  static const Color blueGray700 = Color(0xFF334155);
  static const Color blueGray800 = Color(0xFF1E293B);
  static const Color blueGray900 = Color(0xFF0F172A);
}

ThemeData lightTheme() => ThemeData.light().copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
      inputDecorationTheme: InputDecorationTheme(
        border: MaterialStateOutlineInputBorder.resolveWith((states) {
          final isFocused = states.contains(MaterialState.focused);
          final isDisabled = states.contains(MaterialState.disabled);
          final hasError = states.contains(MaterialState.error);

          final color = isDisabled
              ? AppColors.blueGray400
              : hasError
                  ? Colors.red
                  : AppColors.primaryBlue;
          const width = 1.0;

          return OutlineInputBorder(borderSide: BorderSide(color: color, width: width));
        }),
      ),
    );

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consistent design with Flutter Theme'),
        actions: [IconButton(icon: Icon(Icons.account_circle), onPressed: () {})],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: ExampleWidget(),
        ),
      ),
    );
  }
}

class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextFormField(
          controller: TextEditingController(),
          decoration: InputDecoration(
            hintText: 'enabled',
            labelText: 'label',
            suffixIcon: Icon(Icons.email),
          ),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'enabled error',
            errorText: 'error',
          ),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'disabled',
          ),
          enabled: false,
        ),
      ],
    );
  }
}
