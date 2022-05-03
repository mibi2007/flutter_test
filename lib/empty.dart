import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

extension Logger on Object {
  void log() => devtools.log(toString());
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});

  static Person fromJson(Map<String, dynamic> json) {
    return Person(name: json['name'] as String, age: json['age'] as int);
  }

  @override
  String toString() => 'Person(name: $name, age: $age)';
}

const url = 'http://localhost:8080/people1.json';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> _pressed() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concurrency'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Container()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pressed,
        tooltip: 'Run',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
