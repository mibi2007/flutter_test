import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  runApp(const MyApp());
}

extension Logger on Object {
  void log() => devtools.log(toString());
}

/// Returns the result of the division between `a` and `b`
Option<double> divide(Option<int> a, Option<int> b) {
  if (a.isNone()) {
    return none();
  } else {
    // return a.flatMap((t) => b.getOrElse(() => 0));
    if (b.getOrElse(() => 0) == 0) return none();
    return some(a.getOrElse(() => 0) / b.getOrElse(() => 0));
  }
}

Option<int> getPrice(String productName) {
  if (productName.length > 6) {
    return none();
  } else {
    return some(productName.length);
  }
}

void testApp() {
  const List<int> list = [1, 2, 3, 4, 13];
  list.fold<int>(0, (sum, next) => sum + next).log();
  list.reduce((sum, next) => sum + next).log();
  list.where((e) => e > 2).fold<num>(0, (sum, next) => sum + next).log();
  list.where((e) => e > 2).reduce((sum, next) => sum + next).log();
  final divideResult = divide(Option.of(6), Option.of(2));
  divideResult.match((t) => t.log(), () => none());
  // divideResult.foldMap(Monoid.instance('can not divide', (a1, a2) => 'can not divide'.log), (t) => t.log());
  final predicate = Option<int>.fromPredicate(2, (a) => a > 5);
  predicate.match((t) => t.log(), () => none());

  final price = getPrice('Prod');
  price.match((t) => t.log(), () => 'no price'.log());
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
