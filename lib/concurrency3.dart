import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Concurrency',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Concurrency'),
    );
  }
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

const url1 = 'http://127.0.0.1:5500/api/people.json';
const url2 = 'http://127.0.0.1:5500/api/people2.json';

extension EmptyOnError<T> on Future<List<Iterable<T>>> {
  Future<List<Iterable<T>>> emptyOnError() => catchError((_, __) => List<Iterable<T>>.empty());
}

extension EmptyOnError2<T> on Future<Iterable<T>> {
  Future<Iterable<T>> emptyOnError() => catchError((_, __) => Iterable<T>.empty());
}

Future<Iterable<Person>> parseJson(String url) => http
    .get(Uri.parse(url)) //
    .then((resp) => resp.body)
    .then((str) => jsonDecode(str) as List<dynamic>)
    .then((jsonList) => jsonList.map((json) => Person.fromJson(json as Map<String, dynamic>)));

void testIt() async {
  // final result = await Future.forEach([url1, url2], (element) {
  //   return parseJson(element as String);
  // }).catchError((_, __) => -1);
  final result = await Future.forEach([url1, url2], parseJson).catchError((_, __) => -1);
  if (result != null) 'err'.log();
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  Future<void> _pressed() async {}

  @override
  Widget build(BuildContext context) {
    testIt();
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
