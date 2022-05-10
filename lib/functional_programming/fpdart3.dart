import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

extension Logger on Object {
  void log() => devtools.log(toString());
}

Map<String, int> stringToMap(String string) => string.split('').fold(
    <String, int>{},
    (acc, letter) => {
          ...acc,
          letter: (acc[letter] ?? 0) + 1,
        });

String combine(Map<String, int> map) =>
    map.entries.where((element) => element.value > 1).map((e) => e.key * e.value).join();

void testApp() {
  const originalText = 'original text';
  combine(stringToMap(originalText)).log();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    testApp();
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
