import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  runApp(const MyApp());
}

extension Logger on Object {
  void log() => devtools.log(toString());
}

Option<T> getRandomOption<T>(T value) => randomBool()
    .map(
      (isValid) => isValid ? some(value) : none<T>(),
    )
    .run();

Option<Unit> goToShoppingCenter() => getRandomOption(unit);

Option<Unit> goToLocalMarket() => getRandomOption(unit);

Option<String> buyBanana() => getRandomOption('🍌');
Option<String> buyApple() => getRandomOption('🍎');
Option<String> buyPear() => getRandomOption('🍐');

int count = 0;
int localMarketCount = 0;
int shoppingCenterCount = 0;
void testApp() async {
  await for (final value in Stream.periodic(
    const Duration(milliseconds: 1000),
    (i) => test2(),
  ).take(10)) {}
}

Option<dynamic> test2() => goToShoppingCenter().map(
      (_) {
        count++;
        'time $count'.log();
        localMarketCount++;
        'goToLocalMarket $localMarketCount'.log();
        return goToLocalMarket();
        // return true;
      },
    ).alt(() {
      count++;
      'time $count'.log();
      shoppingCenterCount++;
      'goToShoppingCenter $shoppingCenterCount'.log();
      return some(some(unit));
    }).andThen(() {
      'can buy banana'.log();
      return buyBanana().flatMap((t) {
        t.log();
        'can buy apple'.log();
        return buyApple().flatMap((t) {
          'can buy pear'.log();
          return buyPear().flatMap((t) {
            t.log();
            return none();
          });
        });
      });
    });

Option<dynamic> test1() => goToShoppingCenter().alt(
      () {
        localMarketCount++;
        return goToLocalMarket();
      },
    ).andThen(() {
      count++;
      'time $count'.log();
      if (count > shoppingCenterCount + localMarketCount) {
        shoppingCenterCount++;
        'goToShoppingCenter $shoppingCenterCount'.log();
      } else {
        'goToLocalMarket $localMarketCount'.log();
      }
      // 'can buy banana'.log();
      return buyBanana().flatMap((t) {
        t.log();
        // 'can buy apple'.log();
        return buyApple().flatMap((t) {
          // 'can buy pear'.log();
          return buyPear().flatMap((t) {
            t.log();
            return none();
          });
        });
      });
    });

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
