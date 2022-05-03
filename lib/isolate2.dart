import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart' show StreamGroup;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
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

@immutable
class PersonsRequest {
  final ReceivePort receivePort;
  final Uri uri;

  const PersonsRequest(this.receivePort, this.uri);

  static Iterable<PersonsRequest> all() sync* {
    for (final i in Iterable.generate(3, (i) => i)) {
      yield PersonsRequest(
        ReceivePort(),
        Uri.parse('http://localhost:8080/people${i + 1}.json'),
      );
    }
  }
}

class Request {
  final SendPort sendPort;
  final Uri uri;

  const Request(this.sendPort, this.uri);

  Request.fromPersonRequest(PersonsRequest request)
      : sendPort = request.receivePort.sendPort,
        uri = request.uri;
}

Stream<Iterable<Person>> getPersons() {
  final streams = PersonsRequest.all().map(
    (req) => //
        Isolate.spawn(getPersonsIsolate, Request.fromPersonRequest(req))
            .asStream()
            .asyncExpand((_) => req.receivePort)
            .takeWhile((element) => element is Iterable<Person>)
            .cast(),
  );

  return StreamGroup.merge(streams).cast();
}

void getPersonsIsolate(Request request) async {
  // final persons = await HttpClient() //
  //     .getUrl(request.uri)
  //     .then((request) => request.close())
  //     .then((response) => response.transform(utf8.decoder).join())
  //     .then((body) => json.decode(body) as List<dynamic>)
  //     .then((json) => json.map((person) => Person.fromJson(person)).toList());
  // print(persons);
  // request.sendPort.send(persons);
  await for (final persons in Stream.periodic(
    const Duration(seconds: 1),
    (_) => HttpClient() //
        .getUrl(request.uri)
        .then((request) => request.close())
        .then((response) => response.transform(utf8.decoder).join())
        .then((body) => json.decode(body) as List<dynamic>)
        .then((json) => json.map((person) => Person.fromJson(person)))
        .then((persons) => request.sendPort.send(persons)),
  ).take(3)) {}
  Isolate.exit(request.sendPort);
}

// Stream<Widget> getPersonsWidgets () async {
//   final persons = await getPersons();
//   print(persons);
//   return persons.map((person) => Text(person.name));
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Person> peoples = [];
  void _pressed() {
    _stream.cast();
    // setState(() {
    //   peoples.clear();
    // });
    // final _persons = [];
    // await for (final persons in getPersons()) {
    //   _persons.addAll(persons);
    //   print(_persons);
    //   if (_persons.length == 9) {
    //     setState(() {
    //       peoples.addAll(persons);
    //     });
    //     peoples.clear();
    //     _persons.clear();
    //   }
    // }
  }

  final Stream<Iterable<Person>> _stream = (() {
    late final StreamController<Iterable<Person>> controller;
    controller = StreamController<Iterable<Person>>(onListen: (() => getPersons()));
    return controller.stream;
  })();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot<Iterable<Person>> snapshot) {
            final List<Widget> children = [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              children.addAll(snapshot.data!.map((person) => Text(person.name)));
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            );
          },
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
