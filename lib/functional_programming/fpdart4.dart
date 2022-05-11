import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

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

const url = 'http://10.0.2.2:5500/api/people1.json';

extension CheckJson on String {
  bool isJson() {
    try {
      jsonDecode(this);
    } catch (e) {
      return false;
    }
    return true;
  }
}

abstract class ApiFailure {}

class PersonFailure implements ApiFailure {}

TaskEither<PersonFailure, Iterable<Person>> parseJson() => TaskEither.tryCatch(
      () => http
          .get(Uri.parse(url)) //
          .then((resp) {
            if (resp.statusCode != 200) {
              throw ClientException('Status code is not 200');
            }
            return resp.body;
          })
          .then((value) {
            // value.log();
            if (!value.isJson()) {
              throw ClientException('Server Error');
            }
            return value;
          })
          .then((str) => jsonDecode(str))
          .then((value) => value as List<dynamic>)
          .then((jsonList) => jsonList.map((json) => Person.fromJson(json as Map<String, dynamic>)))
          .then(
            (value) => value,
            onError: onError,
          )
          .catchError(onError),
      (err, stackTrace) {
        if (err is http.ClientException) {
          err.message.log();
        }
        return PersonFailure();
      },
    );

Iterable<Person> onError(error, stackTrace) {
  error.toString().log();
  return [];
}

void testIt() async {
  final persons = (await parseJson().run()).getOrElse((l) => []);
  persons.log();
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
    testIt();
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
