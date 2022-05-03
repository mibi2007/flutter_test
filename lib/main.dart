import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PersonsProvider()),
      ],
      child: const MyApp(),
    ),
  );
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

extension EmptyOnError<T> on Future<List<Iterable<T>>> {
  Future<List<Iterable<T>>> emptyOnError() => catchError((_, __) => List<Iterable<T>>.empty());
}

extension EmptyOnError2<T> on Future<Iterable<T>> {
  Future<Iterable<T>> emptyOnError() => catchError((_, __) => Iterable<T>.empty());
}

const url = 'http://127.0.0.1:5500/api/apis.json';

mixin ListOfThingAPI<T> {
  Future<Iterable<T>> get(String url) => http
      .get(Uri.parse(url)) //
      .then((resp) => resp.body)
      .then((str) => jsonDecode(str) as List<dynamic>)
      .then((list) => list.cast());
}

class GetApiEndPoints with ListOfThingAPI<String> {}

class GetPeople with ListOfThingAPI<Map<String, dynamic>> {
  Future<Iterable<Person>> getPeople(String url) =>
      get(url).then((jsons) => jsons.map((json) => Person.fromJson(json)));
}

Future<void> testIt() async {
  final result = await GetApiEndPoints().get(url).then(
        (endPoints) => Future.wait(
          endPoints.map((endPoint) => GetPeople().getPeople(endPoint)),
        ),
      );
  print(result);
}

class PersonsProvider with ChangeNotifier {
  List<Iterable<Person>> persons;
  PersonsProvider({this.persons = const []});

  Future<void> updateValue() async {
    final result = await GetApiEndPoints().get(url).then(
          (endPoints) => Future.wait(
            endPoints.map((endPoint) => GetPeople().getPeople(endPoint)),
          ),
        );
    persons = result;
    persons.log();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  void _pressed(BuildContext context) {
    context.read<PersonsProvider>().updateValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concurrency'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Person List'),
            ...context.watch<PersonsProvider>().persons.expand((element) => element.map((e) => Text(e.name))).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pressed(context),
        tooltip: 'Run',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
