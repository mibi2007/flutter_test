import 'dart:async';
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
  late String upperCaseName;

  Person({required this.name, required this.age});

  static Person fromJson(Map<String, dynamic> json) {
    return Person(name: json['name'] as String, age: json['age'] as int);
  }

  Person setUpperCaseName() {
    return Person(name: name.toUpperCase(), age: age);
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
// extension EmptyOnError3<T> on Stream<Iterable<T>> {
//   Stream<Iterable<T>> emptyOnError() => catch((_, __) => Iterable<T>.empty());
// }

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

void testIt() async {
  await for (final people in Stream.periodic(const Duration(seconds: 3)).asyncExpand((event) => GetApiEndPoints()
      .get(url)
      .then((endPoins) => Future.wait(endPoins.map((endPoint) => GetPeople().getPeople(endPoint))))
      .asStream())) {
    people.log();
  }
}

class PersonsProvider with ChangeNotifier {
  // List<Iterable<Person>> persons;
  List<Widget> personNames = [];
  StreamSubscription? _stream;
  void updateValue() async {
    if (_stream != null) _stream!.cancel();
    _stream = Stream.periodic(const Duration(seconds: 3))
        .asyncExpand((event) => GetApiEndPoints()
            .get(url)
            .then((endPoins) => Future.wait(endPoins.map((endPoint) => GetPeople().getPeople(endPoint))))
            .asStream()
            .transform(StreamUpperCaseString()))
        .listen((result) {
      personNames = result.expand((element) => element.map((e) => Text(e.name))).toList();
      notifyListeners();
    });
  }
}

class UpperCaseSink implements EventSink<List<Iterable<Person>>> {
  final EventSink<List<Iterable<Person>>> _sink;

  const UpperCaseSink(this._sink);
  @override
  void add(List<Iterable<Person>> event) =>
      _sink.add(event.map((element) => element.map((person) => person.setUpperCaseName())).toList());

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _sink.addError;

  @override
  void close() => _sink.close;
}

class StreamUpperCaseString extends StreamTransformerBase<List<Iterable<Person>>, List<Iterable<Person>>> {
  @override
  Stream<List<Iterable<Person>>> bind(Stream<List<Iterable<Person>>> stream) =>
      Stream<List<Iterable<Person>>>.eventTransformed(stream, (sink) => UpperCaseSink(sink));
}

//  class MergeIterableListSink implements EventSink<List<String>> {
//    final EventSink<List<String>> _sink;

//   const MergeIterableListSink(this._sink);
//   @override
//   void add(List<Iterable<Person>> event) => _sink.add(event.expand((element) => element.map((e) => e.name)).toList());

//   @override
//   void addError(Object error, [StackTrace? stackTrace]) => _sink.addError;

//   @override
//   void close() => _sink.close;
// }

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
            ...context.watch<PersonsProvider>().personNames,
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
